from flask import Flask, request, Response
import os

app = Flask(__name__)
FILES_DIR = "files"


@app.route("/health")
def health():
    return {"ok": True}


@app.route("/")
def serve():
    host = request.host.split(":")[0].lower()
    name = host.split(".")[0]
    filepath = os.path.join(FILES_DIR, f"{name}.ps1")

    if not os.path.exists(filepath):
        return Response(f"Not found: {name}.ps1", status=404, mimetype="text/plain")

    with open(filepath, "r", encoding="utf-8") as f:
        return Response(f.read(), mimetype="text/plain")
