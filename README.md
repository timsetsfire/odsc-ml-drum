# Boston Housing Model with Drum and Flask

## Requirements

* Python version >= 3.7

If you want to follow along with section on Monitoring your deployment with DataRobot you will need
* JDK 11 or 12
* A trial account for DataRobot, which can be gotten [here](https://www.datarobot.com/trial/)

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
python3 -m venv odsc-drum
source ~/odsc-drum/bin/activate
pip install -r ./requirements.txt
```

__OR__

* `pip install -r requirements.txt`
