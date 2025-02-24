import os
import json
from flask import Flask, render_template, jsonify
from sqlalchemy import create_engine, text, Table, Column, Integer, String, MetaData
from sqlalchemy.orm import sessionmaker

# Load environment variables from config.json
env_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")
with open(env_file_path, "r") as env_file:
    env_vars = json.load(env_file)

DB_HOST = env_vars["DB_HOST"]
DB_NAME = env_vars["DB_NAME"]
DB_USER = env_vars["DB_USER"]
DB_PASSWORD = env_vars["DB_PASSWORD"]

app = Flask(__name__)

# SQLAlchemy engine configuration
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
metadata = MetaData()

# Define the user_activities table schema
user_activities = Table(
    'user_activities', metadata,
    Column('id', Integer, primary_key=True, autoincrement=True),
    Column('user_id', Integer),
    Column('activity', String),
    Column('timestamp', String)  # Adjust the type as per your requirements
)

# Function to create the table if it doesn't exist
def create_table_if_not_exists():
    if not engine.dialect.has_table(engine, 'user_activities'):
        metadata.create_all(engine)
        print("Created 'user_activities' table.")
        insert_sample_data()
    else:
        print("'user_activities' table already exists.")

# Function to insert sample data
def insert_sample_data():
    session = Session()
    sample_data = [
        {'user_id': 1, 'activity': 'Logged in', 'timestamp': '2025-02-24 13:25:17'},
        {'user_id': 2, 'activity': 'Viewed dashboard', 'timestamp': '2025-02-24 13:30:00'},
        # Add more sample records as needed
    ]
    session.execute(user_activities.insert(), sample_data)
    session.commit()
    session.close()
    print("Inserted sample data into 'user_activities' table.")

@app.route("/")
def index():
    """Fetches user activity data and displays it."""
    session = Session()
    try:
        query = text("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        result = session.execute(query)
        activities = result.fetchall()
        return render_template("index.html", activities=activities)
    except Exception as e:
        return f"Error fetching data: {e}", 500
    finally:
        session.close()

@app.route("/api/activities")
def get_activities():
    """Returns user activity data as JSON."""
    session = Session()
    try:
        query = text("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        result = session.execute(query)
        activities = result.fetchall()
        return jsonify([{"user_id": row[0], "activity": row[1], "timestamp": row[2]} for row in activities])
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route("/test-connection")
def test_connection():
    """Simple test to check if database connection is working."""
    session = Session()
    try:
        session.execute(text("SELECT 1;"))
        return "Connection to the database is successful!"
    except Exception as e:
        return f"Error: {e}", 500
    finally:
        session.close()

if __name__ == "__main__":
    # Ensure the table exists before starting the app
    create_table_if_not_exists()
    app.run(host="0.0.0.0", port=8080)
