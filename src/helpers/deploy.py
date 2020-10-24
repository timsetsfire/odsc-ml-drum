import datarobot as dr
import sys
import os
import subprocess
import yaml
from datarobot.mlops.mlops import MLOps
from datarobot.mlops.common.enums import OutputType
from datarobot.mlops.connected.client import MLOpsClient
from datarobot.mlops.common.exception import DRConnectedException
from datarobot.mlops.constants import Constants

token = sys.argv[1]
endpoint = sys.argv[2]
TRAINING_DATA = sys.argv[3]
DEPLOYMENT_NAME = "Boston Housing Prices ODSC"

model_info = {
        "name": "Boston Housing Pricins",
        "modelDescription": {
            "description": "prediction price of home"
        },
        "target": {
            "type": "Regression",
            "name": "medv",
        }
}

# Create connected client
mlops_client = MLOpsClient(endpoint, token)

# Add training_data to model configuration
print("Uploading training data - {}. This may take some time...".format(TRAINING_DATA))
dataset_id = mlops_client.upload_dataset(TRAINING_DATA)
print("Training dataset uploaded. Catalog ID {}.".format(dataset_id))
model_info["datasets"] = {"trainingDataCatalogId": dataset_id}

# Create the model package
print('Create model package')
model_pkg_id = mlops_client.create_model_package(model_info)
model_pkg = mlops_client.get_model_package(model_pkg_id)
model_id = model_pkg["modelId"]

# Deploy the model package
print('Deploy model package')
deployment_id = mlops_client.deploy_model_package(model_pkg["id"],
                                                            DEPLOYMENT_NAME)

# Enable data drift tracking
print('Enable feature drift')
enable_feature_drift = TRAINING_DATA is not None
mlops_client.update_deployment_settings(deployment_id, target_drift=True,
                                                  feature_drift=enable_feature_drift)
_ = mlops_client.get_deployment_settings(deployment_id)

print("\nDone.")
print("DEPLOYMENT_ID=%s, MODEL_ID=%s" % (deployment_id, model_id))

DEPLOYMENT_ID = deployment_id
MODEL_ID = model_id

with open("deployment_detail.yaml", "w") as f:
    yaml.dump( {"MODEL_ID": model_id, "DEPLOYMENT_ID": deployment_id}, f )

print("deployment details written to deployment_detail.yaml")