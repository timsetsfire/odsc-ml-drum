from builtins import object  # pylint: disable=redefined-builtin
import pickle

class CustomInferenceModel(object):
    """
    This is a template for Python inference model scoring code.
    It loads the custom model pickle, performs any necessary preprocessing or feature engineering,
    and then performs predictions.

    Note: If your model is a binary classification model, you will likely want your predict
           function to use `predict_proba`, whereas for regression you will want to use `predict`
    """

    def __init__(self, path_to_model="custom_model/rf.pkl"):
        """Load the model pickle file."""

        with open(path_to_model, "rb") as picklefile:
            self.model = pickle.load(picklefile)

    def preprocess_features(self, X):
        """Add any required feature preprocessing here, if it's not handled by the pickled model"""
        X = X.fillna(0)

        return X

    def predict(self, X, positive_class_label=None, negative_class_label=None, **kwargs):
        """
        Predict with the pickled custom model.

        If your model is for classification, you likely want to ensure this function
        calls `predict_proba()`, whereas for regression it should use `predict()`
        """
        X = self.preprocess_features(X)
        prediction = self.model.predict(X)
        return prediction
