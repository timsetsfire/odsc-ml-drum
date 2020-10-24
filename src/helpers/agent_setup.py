import datarobot as dr
import sys
import os
import subprocess
import yaml

token = sys.argv[1]
endpoint = sys.argv[2]

client = dr.Client(token, os.path.join(endpoint, "api/v2"))
mlops_agents_tb = client.get("mlopsInstaller")
print("grab agents tarball")
with open("mlops-agent.tar.gz", "wb") as f:
    f.write(mlops_agents_tb.content)

pwd = os.getcwd()
print("unpack agents tarball")
os.system("tar -xf {}/mlops-agent.tar.gz".format(pwd))
agents_dir = next(filter(lambda x: "datarobot-mlops" in x, os.listdir(pwd)))

print("configuring agents")
with open(r'./{}/conf/mlops.agent.conf.yaml'.format(agents_dir)) as file:
    documents = yaml.load(file, Loader = yaml.FullLoader)

documents['mlopsUrl'] = endpoint
# Set your API token
documents['apiToken'] = token
with open('./{}/conf/mlops.agent.conf.yaml'.format(agents_dir), "w") as f:
    yaml.dump(documents, f)


