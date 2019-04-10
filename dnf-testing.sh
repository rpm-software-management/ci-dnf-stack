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
  -p, --podman             Force using podman instead of docker
  -r, --reserve            Keep bash shell session open after every single test executed
  -R, --reserveonfail      Keep bash shell session open upon test failure
  -t, --tags       TAG     Pass specific tag to the behave command when running tests
  --noxfail                Skip tests marked as @xfail (same as --tags ~@xfail)

Commands:
  list             List of available functional tests
  build            Build container with functional tests
  run [TEST...]    Run all tests. The set of tests can be optionally specified by [TEST...]
  shell            Run a bash shell session within the container

EOF
    exit 0
}

TEMP=$(getopt -n $0 -o hdrpRc:t: -l help,devel,podman,reserve,reserveonfail,noxfail,container:,tags: -- "$@") || show_usage
eval set -- "$TEMP"

devel=""
IMAGE="dnf-bot/dnf-testing:latest"
PARAM_RESERVE=""
PARAM_TTY=""
PARAM_TAGS=""
DOCKER_BIN="sudo docker";
! rpm -q docker &>/dev/null && rpm -q podman &>/dev/null && DOCKER_BIN="podman"

while :; do
    case "$1" in
        --) shift; break;;
        -h|--help) show_help;;
        -d|--devel) set_devel; shift;;
        -c|--container) IMAGE=$2; shift 2;;
        -p|--podman) DOCKER_BIN="podman"; shift;;
        -r|--reserve) set_reserve; shift;;
        -R|--reserveonfail) set_reserveR; shift;;
        -t|--tags) PARAM_TAGS="$PARAM_TAGS --tags $2"; shift 2;;
        --noxfail) PARAM_TAGS="$PARAM_TAGS --tags ~@xfail"; shift;;
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
        TESTS+=( $arg )
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

gather_tests()
{
    $DOCKER_BIN run --rm "$IMAGE" behave --dry-run | grep '^ *Feature:' | sed 's@.*# features/\(.*\):.*$@\1@'
}

list()
{
    FEATURES=($(gather_tests))
    printf "%s\n" "${FEATURES[@]}"
    exit 0
}
[ "$action" = "list" ] && list

build()
{
    local output=($($DOCKER_BIN build --build-arg type="$type" --no-cache \
                    --force-rm -t "$IMAGE" "$PROG_PATH" | \
        tee >(cat - >&2) | tail -1))
    RET=$?
    if [ "$DOCKER_BIN" == "sudo docker" ]; then
        if [ ${#output[@]} -eq 3 ] && \
       	   [ "${output[0]}" = "Successfully" ] && 
           [ "${output[1]}" = "built" ]; then
            printf "%s\n" "${output[2]}"
        else
            fatal "Failed to parse output."
        fi
    else
        if [ $RET -eq 0 -a ${#output[@]} -eq 2 ]; then
            printf "%s\n" "${output[1]}"
        else
            fatal "Failed to parse output"
        fi
    fi
    exit 0
}
[ "$action" = "build" ] && build

run()
{
    FEATURES=($(gather_tests))
    [ ${#TESTS[@]} -eq 0 ] && TESTS=("${FEATURES[@]}")
    local failed=0
    local failed_test_name='Failed test(s):'
    if [ -z "$devel" ];then
        for feature in "${TESTS[@]}"; do
            printf "\n$DOCKER_BIN run $PARAM_TTY --rm "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS "$feature"\n"
            $DOCKER_BIN run $PARAM_TTY --rm "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS "$feature" >&2 || \
            if [ $? -ne 0 ]; then let ++failed && failed_test_name+=" $feature"; fi
        done
    else
        for feature in "${TESTS[@]}"; do
            printf "\n$DOCKER_BIN run $PARAM_TTY --rm -v "$devel" "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS "$feature"\n"
            $DOCKER_BIN run $PARAM_TTY --rm -v "$devel" -v "$devel_steps" "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS "$feature" >&2 || \
            if [ $? -ne 0 ]; then let ++failed && failed_test_name+=" $feature"; fi
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
        printf "\n$DOCKER_BIN run -it --rm "$IMAGE" bash\n"
        $DOCKER_BIN run -it --rm "$IMAGE" bash
    else
        printf "\n$DOCKER_BIN run -it --rm -v "$devel" "$IMAGE" bash\n"
        $DOCKER_BIN run -it --rm -v "$devel" "$IMAGE" bash
    fi
}
[ "$action" == "shell" ] && shell
