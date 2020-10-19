# -----------------------------------------------------------
# Import Libraries
# -----------------------------------------------------------

import json
import importlib
import os
from traceback import format_exc

import pandas as pd
from werkzeug.exceptions import InternalServerError

from flask import Flask, request, render_template
from wtforms import Form, FloatField
import requests
from io import StringIO, BytesIO
import os
# -----------------------------------------------------------
# Forms
# -----------------------------------------------------------
drum_url = "http://localhost:1234/"

# Form Class
class MyForm(Form):
    crim = FloatField('crim', default = 0.00632)
    zn = FloatField('zn', default = 18)
    indus = FloatField('indus', default = 2.31)
    chas = FloatField('chas', default = 0)
    nox = FloatField('nox', default = 0.538)
    rm = FloatField('rm', default = 6.575)
    age = FloatField('age', default = 65.2)
    dis = FloatField('dis', default = 4.09)
    rad = FloatField('rad', default = 1)
    tax = FloatField('tax', default = 296)
    ptratio = FloatField('ptratio', default = 15.3)
    b = FloatField('b', default = 396.9)
    lstat = FloatField('lstat', default = 4.98)

sample_input = """crim,zn,indus,chas,nox,rm,age,dis,rad,tax,ptratio,b,lstat\n
{},{},{},{},{},{},{},{},{},{},{},{},{}"""

app = Flask(__name__, template_folder= 'frontend/templates', static_folder= 'frontend/static')

@app.errorhandler(InternalServerError)
def internal_server_error_handler(error):
    response = {
        'message': InternalServerError.description,
        'exception': repr(error),
        'traceback': format_exc(),
    }
    return json.dumps(response), 500

def get_url_prefix():
    return os.environ.get('URL_PREFIX', '')


def get_custom_model_instance():
    module_name = os.environ.get('MODULE_NAME')
    class_name = os.environ.get('CLASS_NAME')
    custom_model_module = importlib.import_module(module_name)
    CustomModelClass = getattr(custom_model_module, class_name)
    return CustomModelClass()

custom_model = get_custom_model_instance()
url_prefix = get_url_prefix()

# -----------------------------------------------------------
# Route Function
# -----------------------------------------------------------

@app.route('/frontend', methods=['GET', 'POST'])
def predict_outcome():
    """Renders a template with a form that asks for patient data.
       Uses that data to predict."""

    form = MyForm(request.form)
    if request.method == 'POST' and form.validate():
        try:
            to_send = sample_input.format(form.crim.data,
                                          form.zn.data,
                                          form.indus.data,
                                          form.chas.data,
                                          form.nox.data,
                                          form.rm.data,
                                          form.age.data,
                                          form.dis.data,
                                          form.rad.data,
                                          form.tax.data,
                                          form.ptratio.data,
                                          form.b.data,
                                          form.lstat.data)

            data = StringIO(to_send)
            X = pd.read_csv(data)



            print(X)
            ## changing to drum endpoint
            b_buf = BytesIO()
            b_buf.write(X.to_csv(index=False).encode("utf-8"))
            b_buf.seek(0)
            payload = {}
            files = [ ('X', b_buf) ]          
            headers= {}
            response = requests.request("POST", os.path.join(drum_url,"predict"), headers=headers, data = payload, files = files)
            prediction = response.json()["predictions"].pop()
            ##

            # prediction = custom_model.predict(X)
            print("heylksdfmlsdmsdflklmsdfsdf")
            return render_template('apis/form.html', form = form,
                                pred = prediction)

        except ValueError:
            return render_template('apis//form.html', form=form)
    else:
        return render_template('apis//form.html', form=form)

@app.route('{}/'.format(url_prefix))
def ping():
    """This route is used to ensure that server has started"""
    return 'Server is up!\n'
