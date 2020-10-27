# Boston Housing Model with [Drum]((https://github.com/datarobot/datarobot-user-models)) and Flask

[Communication](https://github.com/datarobot/datarobot-user-models#communication)

## Requirements

* Python version >= 3.7

If you want to follow along with section on Monitoring your deployment with DataRobot you will need
* JDK 11 or 12
* A trial account for DataRobot, which can be gotten [here](https://www.datarobot.com/trial/)

Have not tested this out on a windows machine.  

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

If you see any other error, please join the #thur-timwhittaker-rajivshah-a-tutorial-on-robust-machine-learning-deployment in OdscWestVirtual Slack 

This worked for me.  

### no virtual env

* `pip install -r requirements.txt`
