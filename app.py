from flask import Flask, request, Response
import os

app = Flask(__name__)
FILES_DIR = "files"

@app.route("/")
def serve():
    host = request.host
    name = host.split(".")[0]
    filepath = os.path.join(FILES_DIR, f"{name}.ps1")
    if not os.path.exists(filepath):
        return Response("Not found", status=404)
    with open(filepath, "r") as f:
        content = f.read()
    return Response(content, mimetype="text/plain")