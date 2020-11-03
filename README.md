# Boston Housing Model with [Drum]((https://github.com/datarobot/datarobot-user-models)) and Flask

[Communication](https://github.com/datarobot/datarobot-user-models#communication)

## Requirements

### Colab

I recommend using the notebooks at root in colab (they are all set to go there).  Just upload notebook from git repo in colab.  

### Local

You can set up everything to run locally and also run the flask app.  

* Python version >= 3.7

## Recommendations

Before going through this example, it is encouraged to create a virtual python environment via conda of virtualenv.  

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
