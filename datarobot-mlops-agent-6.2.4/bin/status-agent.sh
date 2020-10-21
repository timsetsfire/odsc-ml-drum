#!/bin/bash

# setup some working rules by setting up the basedir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=$(dirname "$DIR")

AGENT_PID_FILE="$DIR"/PID.agent
AGENT_NOT_RUN_MSG="DataRobot MLOps-Agent is not running as a service."
AGENT_RUN_MSG="DataRobot MLOps-Agent is running as a service."

# platform type
MLOPS_OS_LINUX="linux-gnu"
MLOPS_OS_MAC="darwin"*

# Set the default AGENT_LOG_PATH
AGENT_LOG_PATH="$TOP_DIR"/logs/mlops.agent.log

usage() {
     echo "Usage: `basename $0 ` [--verbose | --help]"
     echo "     --help            this help menu"
     echo "     --verbose         provide process verbose resource usage"
}

check_status() {
    # No AGENT_PID_FILE means no MLOps agent is running as a service.
    if ! [[ -e "$AGENT_PID_FILE" ]]; then
        echo "$AGENT_NOT_RUN_MSG"
        exit 0
    fi

    # Empty AGENT_PID_FILE means no MLOps agent is running as a service.
    agent_pid=$(cat "$AGENT_PID_FILE")
    if [[ -z "$agent_pid" ]]; then
        echo "$AGENT_NOT_RUN_MSG"
        exit 0
    fi

    if ! [[ $(ps -p "$agent_pid" -o comm=) =~ "java" ]]; then
        echo "DataRobot MLOps-Agent was previously running (process id $agent_pid). It might exit out with error."
        echo "Check MLOps-Agent log file (default log file - $AGENT_LOG_PATH)."
        exit 1
    fi

    echo "$AGENT_RUN_MSG"
}

option_flag=$1
if [[ -z "$option_flag" ]]; then
    check_status
elif [[ "$option_flag" = "--verbose" ]]; then
    check_status
    if [[ "$OSTYPE" == ${MLOPS_OS_LINUX} ]]; then
        cmd_line="ps -eo %cpu,%mem,etime,msgsnd,msgrcv,oublk -q $agent_pid"
    elif [[ "$OSTYPE" == ${MLOPS_OS_MAC} ]]; then
        cmd_line="ps -o %cpu,%mem,etime,wq,msgsnd,msgrcv,oublk -p $agent_pid"
    else
        echo "INFO: ($OSTYPE) option 'verbose' not supported"
        exit 1
    fi
    eval $cmd_line
    for i in {1..5}; do sleep 2; \
        eval $cmd_line | tail -n 1; \
    done
elif [[ "$option_flag" = "--help" ]]; then
    usage
else
    usage
    exit 1
fi

exit 0
