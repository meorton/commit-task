import socket
import os
import json
from flask import Flask, render_template, jsonify
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Log the Cloud Run IP address
def get_ip():
    return socket.gethostbyname(socket.gethostname())

print("Cloud Run IP Address:", get_ip())

# Define the path to the .env file
env_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")

# Load environment variables from .env file
with open(env_file_path, "r") as env_file:
    env_vars = json.load(env_file)

DB_HOST = env_vars["DB_HOST"]
DB_NAME = env_vars["DB_NAME"]
DB_USER = env_vars["DB_USER"]
DB_PASSWORD = env_vars["DB_PASSWORD"]

app = Flask(__name__)

# SQLAlchemy engine configuration with explicit port
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@/{DB_NAME}?host={DB_HOST}&port=5432"

# Create the engine and session factory
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)

@app.route("/")
def index():
    """Fetches user activity data and displays it."""
    session = Session()
    try:
        query = text("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        result = session.execute(query)
        activities = result.fetchall()
        session.close()

        return render_template("index.html", activities=activities)
    except Exception as e:
        session.close()
        return f"Error fetching data: {e}", 500

@app.route("/api/activities")
def get_activities():
    """Returns user activity data as JSON."""
    session = Session()
    try:
        query = text("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        result = session.execute(query)
        activities = result.fetchall()
        session.close()

        return jsonify([{"user_id": row[0], "activity": row[1], "timestamp": row[2]} for row in activities])
    except Exception as e:
        session.close()
        return jsonify({"error": str(e)}), 500

@app.route("/test-connection")
def test_connection():
    """Simple test to check if database connection is working."""
    session = Session()
    try:
        query = text("SELECT 1;")
        session.execute(query)
        session.close()
        return "Connection to the database is successful!"
    except Exception as e:
        session.close()
        return f"Error: {e}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
