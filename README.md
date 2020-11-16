# Hands on tutorial with [Drum]((https://github.com/datarobot/datarobot-user-models)) 

[Communication](https://github.com/datarobot/datarobot-user-models#communication)

## Requirements

### Colab

All the notebooks in the root of this directory can be run on google colab, and this is the recommended means to follow along.  Just upload notebook from git repo in colab.  

### Local

To run the flask app, you will need 

* Python version >= 3.7

## Recommendations

Before running the flask app, it is encouraged to create a virtual python environment via conda of virtualenv.  

### via conda

```
conda create --name odsc-drum python=3.7
conda activate odsc-drum
conda install -c conda-forge --file ./requirements.txt
```

### via venv

```
python3 -m venv ~/odsc-drum
source ~/odsc-drum/bin/activate
pip install -r ./requirements.txt
```

Once you have made it to here, check the drum version with 
`drum --version`.  If you receive an error `ModuleNotFoundError: No module named 'flask'`, run

```
deactivate
source ~/odsc-drum/bin/activate
drum --version
```

### no virtual env

* `pip install -r requirements.txt`
