#!/bin/bash

# default AGENT_LOG_PROPERTIES = ../conf/mlops.log4j2.properties
# default AGENT_CONFIG_YAML    = ../conf/mlops.agent.conf.yaml
# default AGENT_LOG_PATH       = ../logs/mlops.agent.log
# default AGENT_JAR_PATH       = ../lib/agent-*.jar
# default AGENT_JVM_OPT        = -Xmx1G

# setup some working rules by setting up the basedir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=$(dirname "$DIR")

AGENT_PID_FILE="$DIR"/PID.agent

# Set the default AGENT_LOG_PATH
AGENT_LOG_PATH="$TOP_DIR"/logs/mlops.agent.log
AGENT_OUT_PATH="$TOP_DIR"/logs/mlops.agent.out

# If any MLOps agent is running as a service, exit.
# If no AGENT_PID_FILE, start MLOps agent as a service.
# If there is an AGENT_PID_FILE, get the pid. If the pid is still running, exit.
# Otherwise, start MLOps agent as a service.
if [[ -e "$AGENT_PID_FILE" ]]; then
    if [[ -f "$AGENT_PID_FILE" && -r "$AGENT_PID_FILE" && -w "$AGENT_PID_FILE" ]]; then
        agent_pid=$(cat "$AGENT_PID_FILE")
        if [[ -n "$agent_pid" ]]; then
            if [[ $(ps -p "$agent_pid" -o comm=) =~ "java" ]]; then
                echo "DataRobot MLOps-Agent is already running as a service (process id $agent_pid)."
                echo "Stop it first."
                exit 1
            else
                echo "DataRobot MLOps-Agent was previously running (process id $agent_pid)."
                echo "It might exit out with error."
                echo "Check MLOps-Agent log file (default log file - $AGENT_LOG_PATH)."
                echo "Clean up the MLOps-Agent pid file - $AGENT_PID_FILE."
                exit 1
            fi
        fi
    else
        echo "Permission denied: $AGENT_PID_FILE"
        exit 1
    fi
fi


if [[ -d ${JAVA_HOME} ]]; then
   CMD_JAVA=${JAVA_HOME}/bin/java
else
   CMD_JAVA=java
fi

user_override=1

if [[ -z "$AGENT_CONFIG_YAML" ]]; then
   AGENT_CONFIG_YAML="$TOP_DIR"/conf/mlops.agent.conf.yaml
   user_override=0
elif ! [[ -r "$AGENT_CONFIG_YAML" && -f "$AGENT_CONFIG_YAML" ]]; then
   AGENT_CONFIG_YAML="$TOP_DIR"/conf/mlops.agent.conf.yaml
   user_override=0
fi

echo "INFO: AGENT_CONFIG_YAML=$AGENT_CONFIG_YAML"

if [[ -z "$AGENT_LOG_PROPERTIES" ]]; then
   AGENT_LOG_PROPERTIES="$TOP_DIR"/conf/mlops.log4j2.properties
elif ! [[ -r "$AGENT_LOG_PROPERTIES" && -f "$AGENT_LOG_PROPERTIES" ]]; then
   AGENT_LOG_PROPERTIES="$TOP_DIR"/conf/mlops.log4j2.properties
fi

echo "INFO: AGENT_LOG_PROPERTIES=$AGENT_LOG_PROPERTIES"

if [[ -z "$AGENT_JVM_OPT" ]]; then
   AGENT_JVM_OPT=-Xmx1G
fi

echo "INFO: AGENT_JVM_OPT=$AGENT_JVM_OPT"

if [[ -z "$AGENT_JAR_PATH" ]]; then
   AGENT_JAR_PATH=$(ls "$TOP_DIR"/lib/mlops-agent-*.jar)
fi

echo "INFO: AGENT_JAR_PATH=$AGENT_JAR_PATH"

function clean_path_string
{
   # remove spaces and quotes
   xquote=${1//\"/}
   echo "${xquote//\ /}"
}

if [[ $user_override == '1' ]]; then
   raw_agent_log_path=$(grep "logPath" "${AGENT_CONFIG_YAML}" | cut -d':' -f2)
   custom_log_path=$(clean_path_string "${raw_agent_log_path}")

   # If the custom_log_path is valid, set the AGENT_LOG_PATH to custom_log_path
   if [[ -f "$custom_log_path" && -r "$custom_log_path" && -w "$custom_log_path" ]]; then
       AGENT_LOG_PATH="$custom_log_path"
   fi
fi

echo "INFO: AGENT_LOG_PATH=${AGENT_LOG_PATH}"
echo
echo "Starting MLOps-Agent"
echo
echo
cd "${DIR}" || exit
nohup ${CMD_JAVA} "${AGENT_JVM_OPT}" -Dlog.file="${AGENT_LOG_PATH}" \
     -Dlog4j.configurationFile=file:"${AGENT_LOG_PROPERTIES}" \
     -cp "${AGENT_JAR_PATH}" com.datarobot.mlops.agent.Agent \
     --config "${AGENT_CONFIG_YAML}" > "${AGENT_OUT_PATH}" 2>&1 &

agent_pid=$!

sleep 2
if ! [[ $(ps -p "$agent_pid" -o comm=) =~ "java" ]]; then
    echo "========= MLOps-Agent LOG FILE: ${AGENT_LOG_PATH} ========= "
    tail -n 20 "${AGENT_LOG_PATH}"
    echo "============================================== "
    echo "Failed to start DataRobot MlOps-Agent (process id - $agent_pid)."
    exit 1
fi

echo "$agent_pid" > "$AGENT_PID_FILE"
echo "DataRobot MLOps-Agent is running."
exit 0
