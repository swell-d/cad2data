import copy
import os
import subprocess
from pathlib import Path
from threading import Thread

from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/health', methods=['GET'])
def health():
    return jsonify(status='ok'), 200


@app.route('/rvt2ifc', methods=['POST'])
def run():
    if not request.is_json:
        return jsonify(error="JSON required"), 400
    data = request.get_json()
    rvt_input = data.get('rvt_input')
    ifc_output = data.get('ifc_output')
    if not rvt_input or not ifc_output:
        return jsonify(error="rvt_input and ifc_output are required"), 400
    Path(f"{ifc_output}.undone").touch()
    Thread(target=process, args=(rvt_input, ifc_output), daemon=True).start()
    return jsonify(started=True), 200


def process(rvt_input, ifc_output):
    log_path = f"{ifc_output}.undone"
    cmd = ['RVT2IFCconverter', rvt_input, ifc_output]
    with open(log_path, 'a', encoding='utf-8') as log:
        log.write(f"{rvt_input} -> {ifc_output} start...\n")
        result = subprocess.run(
            cmd,
            env=copy.deepcopy(os.environ),
            stdout=log,
            stderr=log,
            text=True,
            encoding='utf-8',
            errors='replace'
        )
        log.write(f"returncode: {result.returncode}\n")
        log.write(f"{rvt_input} -> {ifc_output} done.\n")
    os.rename(f"{ifc_output}.undone", f"{ifc_output}.done")
