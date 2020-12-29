import flask
from flask import request, jsonify

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route('/', methods=['GET'])
def home():
    return "Welcome"

@app.route('/api/uwu', methods=['POST', 'GET'])
def edulinkresponses():
    if "method" in request.args:
        method = str(request.args["method"])
    else:
        return "Error: method provided"

    if method == "EduLink.Login":
        response = open("request-returns/EduLink.Login.json", "r")
    elif method == "EduLink.SchoolDetails":
        response = open("request-returns/EduLink.SchoolDetails.json", "r")

    return response.read()

app.run(host="0.0.0.0", port=8080)