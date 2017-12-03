# Starter app.py

from flask import Flask, jsonify
import json

# Configure app and register blueprints
app = Flask(__name__)
app.config['SECRET_KEY'] = "pictionary please"

data = json.load(open('words.json'))

@app.route('/')
def index():
    return jsonify(data)
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
