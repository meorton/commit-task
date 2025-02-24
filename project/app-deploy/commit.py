
import os
import json
import psycopg2
from flask import Flask, render_template, jsonify

# Define the path to the .env file
env_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")

# Load environment variables from .env file
with open(env_file_path, "r") as env_file:
    env_vars = json.load(env_file)

DB_HOST = env_vars["DB_HOST"]
DB_NAME = env_vars["DB_NAME"]
DB_USER = env_vars["DB_USER"]
DB_PASSWORD = env_vars["DB_PASSWORD"]

app = Flask(__name__)

def get_db_connection():
    """Establishes a connection to the Cloud SQL PostgreSQL database."""
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST
        )
        return conn
    except Exception as e:
        print("Error connecting to the database:", e)
        return None

@app.route("/")
def index():
    """Fetches user activity data and displays it."""
    conn = get_db_connection()
    if not conn:
        return "Error connecting to the database", 500

    try:
        cur = conn.cursor()
        cur.execute("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        activities = cur.fetchall()
        cur.close()
        conn.close()

        return render_template("index.html", activities=activities)
    except Exception as e:
        return f"Error fetching data: {e}", 500

@app.route("/api/activities")
def get_activities():
    """Returns user activity data as JSON."""
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cur = conn.cursor()
        cur.execute("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        activities = cur.fetchall()
        cur.close()
        conn.close()

        return jsonify([{"user_id": row[0], "activity": row[1], "timestamp": row[2]} for row in activities])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
