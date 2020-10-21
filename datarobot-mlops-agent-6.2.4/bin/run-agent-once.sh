#!/bin/bash

# default AGENT_LOG_PROPERTIES = ../conf/stdout.mlops.log4j2.properties"
# default AGENT_JAR_PATH       = ../lib/agent-*.jar
# default AGENT_JVM_OPT        = -Xmx1G

# setup some working rules by setting up the basedir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=$(dirname "$DIR")

function print_help {
    echo "Usage: "
    echo "    $(basename  "$0" ) [--help | --mlops-url <url> | --api-token <token> ]"
    echo "       --help             this help menu"
    echo "       --mlops-url        URL to the DataRobot MLOps service"
    echo "       --api-token        DataRobot API token"
}

ARG_CNT=$#
ARG_LIST=("$@")

for (( i=0; i<ARG_CNT; i++));
do
   case "${ARG_LIST[${i}]}" in
       --help*)                  print_help ; exit 0;;
       --mlops-url*)             RUN_1_MLOPS_URL="${ARG_LIST[$((i+1))]:-}";;
       --api-token*)             RUN_1_API_TOKEN="${ARG_LIST[$((i+1))]:-}";;
       *)                        ;;
   esac
done

# Check arguments
if [[ -z "${RUN_1_FS_SPOOL}" ]] || [[ -z "${RUN_1_MLOPS_URL}" ]] || [[ -z "${RUN_1_API_TOKEN}" ]]; then
   echo "ERROR: Missing arguments."
   print_help
   exit 1
fi

if ! [[ -d "${RUN_1_FS_SPOOL}" ]]; then
   echo "ERROR: Spooler directory ${RUN_1_FS_SPOOL} not accessible"
   exit 1
fi
echo "INFO: Spool directory: ${RUN_1_FS_SPOOL}"
echo "INFO: MLops URL: ${RUN_1_MLOPS_URL}"
echo "INFO: Api token:${RUN_1_API_TOKEN}"


# java command
if [[ -n "${JAVA_HOME}" ]] && [[ -x "${JAVA_HOME}/bin/java" ]];  then
   CMD_JAVA="${JAVA_HOME}/bin/java"
elif type -p java; then
   CMD_JAVA=java
else
    echo "java is required, but not found. Please provide JAVA_HOME"
    exit 1
fi

# agent config file
if [[ -z "$AGENT_CONFIG_YAML" ]]; then
   AGENT_CONFIG_YAML="${TOP_DIR}/conf/template-conf.yaml"
fi
echo "INFO: AGENT_CONFIG_YAML=$AGENT_CONFIG_YAML"

# Log4j config file
if [[ -z "${AGENT_LOG_PROPERTIES}" ]] || ! [[ -r "${AGENT_LOG_PROPERTIES}" ]]; then
   AGENT_LOG_PROPERTIES="${TOP_DIR}/conf/stdout.mlops.log4j2.properties"
fi
echo "INFO: AGENT_LOG_PROPERTIES=$AGENT_LOG_PROPERTIES"

# Java settings
if [[ -n "${AGENT_JVM_OPT:-}" ]]; then
    # Coerce user provided JVM options to array
    # shellcheck disable=SC2206
    AGENT_JVM_OPT=($AGENT_JVM_OPT)
else
    AGENT_JVM_OPT=("-Xmx1G")
fi
echo "INFO: java settings: ${AGENT_JVM_OPT[*]}"

# Find agent jar file
if [[ -z "${AGENT_JAR_PATH}" ]]; then
   AGENT_JAR_PATH=$(find "${TOP_DIR}"/lib/ -name "agent-*.jar" | head  -1)
fi
echo "INFO: AGENT_JAR_PATH=${AGENT_JAR_PATH}"

echo
echo
echo "MLOps-Agent in run Once mode.."
echo
echo
cd "${DIR}" || exit

${CMD_JAVA} "${AGENT_JVM_OPT[@]}" \
        -Dlog4j.configurationFile="${AGENT_LOG_PROPERTIES}" \
        -cp "${AGENT_JAR_PATH}" com.datarobot.mlops.agent.Agent \
        --config "${AGENT_CONFIG_YAML}" \
        --mlops-url "${RUN_1_MLOPS_URL}" \
        --api-token "${RUN_1_API_TOKEN}"

