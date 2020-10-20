# Boston Housing Model with Drum and Flask

This is part of a hands-on tutorial for productionizing machine-learning models using robust open-source tools.  This tutorial shows you how to go from a python scikit model, get REST API endpoint, test it for common deployment issues, containerize, and deploy it.  This is performed using a new open-source package, [DRUM](https://github.com/datarobot/datarobot-user-models), that moves beyond flask and takes advantage of NGINX and uWSGI for serving model in a production-grade manner.   This package provides support for a variety of modeling frameworks including: Keras, scikit learn, R, H2O, DataRobot, and more.  The package also incorporates unit testing for common deployment issues.  All of this is easy to containerize and even add monitoring agents.  

In this part of the tutorial, we demonstrate how to deploy a model with DataRobot DRUM package to an api, which will be consumed by a web app developed using Flask.  

The web app is based on the Boston Housing Prices dataset, and will allow a user to provide values for features, which will be used to predict the price of a home.  

## Recommendations

Before going through this example, it is encouraged to create a virtual python environment via conda of virtualenv.  

### via conda

```conda create --name odsc-drum python=3.7
conda activate odsc-drum
conda install -c conda-forge --file ./requirements.txt```

### via venv

```python3 -m venv odsc-drum
source ~/odsc-drum/bin/activate
pip install -r ./requirements.txt```

## Requirements

* update locations of stuff in `./src/start_model_server.sh` and `.src/start_server.sh`.  

* `datarobot-drum` -> `pip install datarobot-drum`
For hosting the model we'll leverage `datarobot-drum`.  This will include Flask as part of the install. 

* sklearn == 0.23.1 -> `pip install -U scikit-learn==0.23.1`
The model being hosted as built with sklearn 0.23.1.  

* wtforms -> `pip install wtforms`
This module is leveraged in the web app.  

__OR__

* `pip install -r requirements.txt`

## Start the Modeling Server 

From `Boston_Housing_with_flask_api` run 

`./src/start_model_server.sh`.

As is, the server is being started in verbose mode with logging level set to info.  

## Start the Web App

In a new terminal session, from `Boston_Housing_with_flask_api` run 

`./src/start_server.sh`

This will start the housing price web app.  

## Visit the web app

From any modern browser, access the web app at [`localhost:8080/frontend`](http://localhost:8080/frontend).  

