python ./src/helpers/deploy.py $TOKEN $ENDPOINT ./data/boston_housing.csv
python ./src/helpers/agent_setup.py $TOKEN $ENDPOINT
export AGENT_DIRECTORY=$(ls . | grep datarobot)
pip install ./$AGENT_DIRECTORY/lib/datarobot_mlops-*.whl -q
mkdir -p /tmp/ta
./$AGENT_DIRECTORY/bin/start-agent.sh

