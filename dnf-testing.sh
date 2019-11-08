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
    devel="$PROG_PATH/dnf-behave-tests/features:/opt/behave/features:Z"
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
  -f, --file               Path to Dockerfile to use
  -p, --podman             Force using podman instead of docker
  -r, --reserve            Keep bash shell session open after every single test executed
  -R, --reserveonfail      Keep bash shell session open upon test failure
  -t, --tags       TAG     Pass specific tag to the behave command when running tests
  --noxfail                Skip tests marked as @xfail (same as --tags ~@xfail)
  --command        COMMAND DNF command to be used in tests
  --usecache               Use cache when building the image

Commands:
  list             List of available functional tests
  build [TYPE]     Build container with functional tests. The default TYPE is 'local'
  run [TEST...]    Run all tests. The set of tests can be optionally specified by [TEST...]
  shell            Run a bash shell session within the container

EOF
    exit 0
}

TEMP=$(getopt -n $0 -o hdf:rpRc:t: -l help,devel,file:,podman,reserve,reserveonfail,noxfail,usecache,container,command:,tags: -- "$@") || show_usage
eval set -- "$TEMP"

devel=""
IMAGE="dnf-bot/dnf-testing:latest"
PARAM_RESERVE=""
PARAM_TTY=""
PARAM_TAGS=""
PARAM_DNFCOMMAND=""
BUILD_CACHE="--no-cache"
DOCKER_BIN="sudo docker";
DOCKER_FILE="Dockerfile";

# use podman if docker is not on the system and podman is
if [ ! `command -v docker` ] && [ `command -v podman` ]; then
    DOCKER_BIN="podman"
fi

while :; do
    case "$1" in
        --) shift; break;;
        -h|--help) show_help;;
        -d|--devel) set_devel; shift;;
        -c|--container) IMAGE=$2; shift 2;;
        -f|--file) DOCKER_FILE=$2; shift 2;;
        -p|--podman) DOCKER_BIN="podman"; shift;;
        -r|--reserve) set_reserve; shift;;
        -R|--reserveonfail) set_reserveR; shift;;
        -t|--tags) PARAM_TAGS="$PARAM_TAGS --tags $2"; shift 2;;
        --noxfail) PARAM_TAGS="$PARAM_TAGS --tags ~@xfail"; shift;;
        --command) PARAM_DNFCOMMAND="--command $2"; shift 2;;
        --usecache) BUILD_CACHE=""; shift;;
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
            side-tag) type="side-tag";;
            distro) type="distro";;
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
    $DOCKER_BIN build --build-arg TYPE="$type" \
        ${BUILD_CACHE} --force-rm -t "$IMAGE" -f "$DOCKER_FILE" "$PROG_PATH"
    RET=$?
    exit $RET
}
[ "$action" = "build" ] && build

run()
{
    printf "Packages installed in the container:\n"
    $DOCKER_BIN run $PARAM_TTY --rm "$IMAGE" rpm -qa | sort
    FEATURES=($(gather_tests))
    [ ${#TESTS[@]} -eq 0 ] && TESTS=("${FEATURES[@]}")
    local failed=0
    local failed_test_name='Failed test(s):'
    if [ -z "$devel" ];then
        for feature in "${TESTS[@]}"; do
            printf "\n$DOCKER_BIN run $PARAM_TTY --rm "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS $PARAM_DNFCOMMAND "$feature"\n"
            $DOCKER_BIN run $PARAM_TTY --rm "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS $PARAM_DNFCOMMAND "$feature" >&2 || \
            if [ $? -ne 0 ]; then let ++failed && failed_test_name+=" $feature"; fi
        done
    else
        for feature in "${TESTS[@]}"; do
            printf "\n$DOCKER_BIN run $PARAM_TTY --rm --volume "$devel" "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS $PARAM_DNFCOMMAND "$feature"\n"
            $DOCKER_BIN run $PARAM_TTY --rm --volume "$devel" "$IMAGE" ./launch-test $PARAM_RESERVE $PARAM_TAGS $PARAM_DNFCOMMAND "$feature" >&2 || \
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
