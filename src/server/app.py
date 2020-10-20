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
drum_url = "http://localhost:6789/"
try:
    dr_monitoring = eval(os.environ.get("MLOPS_MONITORING"))
except:
    dr_monitoring = False
if dr_monitoring:
    import time
    from datarobot.mlops.mlops import MLOps
    from datarobot.mlops.common.enums import SpoolerType
    deployment_id = os.environ["MLOPS_DEPLOYMENT_ID"]
    model_id = os.environ["MLOPS_MODEL_ID"]
    mlops = (
        MLOps()
        .set_deployment_id(deployment_id)
        .set_model_id(model_id)
        .set_spool_file_max_size(5)
        .set_spool_max_files(1045876000)
        .set_async_reporting(True)
        .init()
    )

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
            start_time = time.time()
            prediction = response.json()["predictions"]
            end_time = time.time()
            ## need a timer
            if dr_monitoring:
                print("reporting to mlops")
                ## report predictions and stats back
                mlops.report_deployment_stats(1, end_time - start_time)
                # MLOPS: report the predictions data: features, predictions, class_names
                mlops.report_predictions_data(features_df=X, predictions=prediction)


            # prediction = custom_model.predict(X)
            print("heylksdfmlsdmsdflklmsdfsdf")
            return render_template('apis/form.html', form = form,
                                pred = prediction.pop())

        except ValueError:
            return render_template('apis//form.html', form=form)
    else:
        return render_template('apis//form.html', form=form)

@app.route('{}/'.format(url_prefix))
def ping():
    """This route is used to ensure that server has started"""
    return 'Server is up!\n'
