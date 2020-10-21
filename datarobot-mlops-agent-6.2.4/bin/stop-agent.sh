#!/bin/bash

# setup some working rules by setting up the basedir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=$(dirname "$DIR")

AGENT_PID_FILE="$DIR"/PID.agent
AGENT_NOT_RUNNING_MSG="No DataRobot MLOps-Agent is currently running as a service."

agent_pid=""
# Set the default AGENT_LOG_PATH
AGENT_LOG_PATH="$TOP_DIR"/logs/mlops.agent.log

if ! [[ -e "$AGENT_PID_FILE" ]]; then
    echo "${AGENT_NOT_RUNNING_MSG}"
    exit 1
fi

if [[ -f "${AGENT_PID_FILE}" && -r "${AGENT_PID_FILE}" && -w "${AGENT_PID_FILE}" ]]; then
    agent_pid=$(cat "${AGENT_PID_FILE}")
    # If there is no pid in the AGENT_PID_FILE or the pid is not valid, clean up the AGENT_PID_FILE and exit.
    if [[ -z "$agent_pid" ]]; then
        echo "${AGENT_NOT_RUNNING_MSG}"
        exit 1
    elif ! [[ $(ps -p "$agent_pid" -o comm=) =~ "java" ]]; then
        echo "DataRobot MLOps-Agent was previously running (process id $agent_pid). It might exit out with error."
        echo "Check MLOps-Agent log file (default log file - $AGENT_LOG_PATH)."
        echo "Clean up the MLOps-Agent pid file - $AGENT_PID_FILE"
        exit 1
    fi
else
    echo "Permission denied $AGENT_PID_FILE"
    exit 1
fi

kill "${agent_pid}"
for _ in {1..15}; do
    sleep 1
    if ! [[ $(ps -p "${agent_pid}" -o comm=) =~ "java" ]]; then
        echo "DataRobot MLOps-Agent shutdown done."
        rm "${AGENT_PID_FILE}"
        exit 0
    fi
 done

echo "DataRobot MLOps-Agent force shutdown initiated."
kill -9 "$agent_pid"
sleep 1
if [[ $(ps -p "$agent_pid" -o comm=) =~ "java" ]]; then
   echo "Force shutdown of DataRobot MLOps-Agent failed (PID:${agent_pid})"
   exit 1
fi

echo "DataRobot MLOps-Agent force shutdown done."
rm "${AGENT_PID_FILE}"
exit 0
