#!/bin/bash
set -euo pipefail

PROG_PATH=$(dirname $(readlink -f -- $0))

fatal()
{
    printf >&2 "Error: %s\n" "$*"
    exit 1
}

show_usage()
{
    printf >&2 "Try \`$0 --help' for more information.\n"
    exit 1
}

set_devel()
{
    devel="$PROG_PATH/dnf-docker-test/features:/tests:Z"
    devel_steps="$PROG_PATH/dnf-docker-test/features/steps:/behave/steps:Z"
}

set_reserve()
{
    PARAM_RESERVE="-r"
    PARAM_TTY="-it"
}

set_reserveR()
{
    PARAM_RESERVE="-R"
    PARAM_TTY="-it"
}

show_help()
{
    cat << EOF
$0 - functional tests for DNF.

Usage: $0 [OPTIONS...] {COMMAND}

Options:
  -h, --help               Show this help
  -c, --container  IMAGE   Specified Image ID or name if do not want to run the last built image
  -d, --devel              Share local feature/ with docker
  -r, --reserve            Keep bash shell session open after every single test executed
  -R, --reserveonfail      Keep bash shell session open upon test failure

Commands:
  list             List of available functional tests
  build            Build container with functional tests
  run [TEST...]    Run all tests. The set of tests can be optionally specified by [TEST...]
  shell            Run a bash shell session within the container

EOF
    exit 0
}

TEMP=$(getopt -n $0 -o hdrRc: -l help,devel,reserve,reserveonfail,container: -- "$@") || show_usage
eval set -- "$TEMP"

devel=""
IMAGE="dnf-bot/dnf-testing:latest"
PARAM_RESERVE=""
PARAM_TTY=""

while :; do
    case "$1" in
        --) shift; break;;
        -h|--help) show_help;;
        -d|--devel) set_devel; shift;;
        -c|--container) IMAGE=$2; shift 2;;
        -r|--reserve) set_reserve; shift;;
        -R|--reserveonfail) set_reserveR; shift;;
        *) fatal "Non-implemented option: $1"
    esac
done

action=
for arg; do
    case "$arg" in
        list) action="list";;
        build) action="build";;
        run) action="run";;
        shell) action="shell";;
        *) fatal "Unknown argument: $arg";;
    esac
    shift
    break
done
[ "$action" != "" ] || fatal "Specify command to do."
if [ "$action" = "run" ]; then
    TESTS=()
    for arg; do
        TESTS+=("$arg")
        shift
    done
elif [ "$action" = "build" ]; then
    type="local"
    for arg; do
        case "$arg" in
            jjb) type="jjb";;
            local) type="local";;
            "") type="local";;
            *) fatal "Unknown argument: $arg";;
        esac
        shift
    done
fi
[ $# -eq 0 ] || fatal "Too many arguments."

FEATURES=()
gather_tests()
{
    local glob="$PROG_PATH/dnf-docker-test/features/*.feature"
    local i=0
    for f in $glob; do
        if [ "$f" = "$glob" ]; then
            fatal "Can't find behave features."
        fi
        local feature=$(basename "$f")
        FEATURES+=("${feature%.feature}")
    done
}
gather_tests

list()
{
    printf "%s\n" "${FEATURES[@]}"
    exit 0
}
[ "$action" = "list" ] && list

build()
{
    local output=($(sudo docker build --build-arg type="$type" --no-cache \
                    --force-rm -t "$IMAGE" "$PROG_PATH" | \
        tee >(cat - >&2) | tail -1))
    if [ ${#output[@]} -eq 3 ] && \
       [ "${output[0]}" = "Successfully" ] && 
       [ "${output[1]}" = "built" ]; then
        printf "%s\n" "${output[2]}"
    else
        fatal "Failed to parse output."
    fi
    exit 0
}
[ "$action" = "build" ] && build

run()
{
    [ ${#TESTS[@]} -eq 0 ] && TESTS=("${FEATURES[@]}")
    local failed=0
    local failed_test_name='Failed test(s):'
    if [ -z "$devel" ];then
        for feature in "${TESTS[@]}"; do
            feature=${feature%.feature}  # cut-off .feature suffix if present
            for command in dnf-2 dnf-3; do
                printf "\nsudo docker run $PARAM_TTY --rm "$IMAGE" launch-test $PARAM_RESERVE "$feature" $command\n"
                sudo docker run $PARAM_TTY --rm "$IMAGE" launch-test $PARAM_RESERVE "$feature" $command >&2 || \
                if [ $? -ne 0 ]; then let ++failed && failed_test_name+=" $feature-$command"; fi
            done
        done
    else
        for feature in "${TESTS[@]}"; do
            feature=${feature%.feature}  # cut-off .feature suffix if present
            for command in dnf-2 dnf-3; do
                printf "\nsudo docker run $PARAM_TTY --rm -v "$devel" "$IMAGE" launch-test $PARAM_RESERVE "$feature" $command\n"
                sudo docker run $PARAM_TTY --rm -v "$devel" -v "$devel_steps" "$IMAGE" launch-test $PARAM_RESERVE "$feature" $command >&2 || \
                if [ $? -ne 0 ]; then let ++failed && failed_test_name+=" $feature-$command"; fi
            done
        done
    fi
    if [ "$failed" != 0 ]; then
        >&2 echo "$failed_test_name"
    fi
    exit $failed
}
[ "$action" = "run" ] && run

shell()
{
    if [ -z "$devel" ];then
        printf "\nsudo docker run -it --rm "$IMAGE" bash\n"
        sudo docker run -it --rm "$IMAGE" bash
    else
        printf "\nsudo docker run -it --rm -v "$devel" "$IMAGE" bash\n"
        sudo docker run -it --rm -v "$devel" "$IMAGE" bash
    fi
}
[ "$action" == "shell" ] && shell
