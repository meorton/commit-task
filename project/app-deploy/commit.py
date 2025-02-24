import os
import json
from flask import Flask, render_template, jsonify
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import SQLAlchemyError

# Load environment variables from config.json
env_file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")
with open(env_file_path, "r") as env_file:
    env_vars = json.load(env_file)

DB_HOST = env_vars["DB_HOST"]
DB_NAME = env_vars["DB_NAME"]
DB_USER = env_vars["DB_USER"]
DB_PASSWORD = env_vars["DB_PASSWORD"]

app = Flask(__name__)

# SQLAlchemy engine configuration with explicit port
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

# Create the engine and session factory
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)

def create_table_if_not_exists():
    """Creates the user_activities table if it doesn't exist."""
    try:
        with engine.connect() as connection:
            inspector = inspect(connection)
            if not inspector.has_table('user_activities'):
                create_table_query = """
                CREATE TABLE user_activities (
                    user_id SERIAL PRIMARY KEY,
                    activity VARCHAR(255) NOT NULL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
                """
                connection.execute(create_table_query)
                print("Table 'user_activities' created successfully.")
            else:
                print("Table 'user_activities' already exists.")
    except SQLAlchemyError as e:
        print(f"An error occurred: {e}")

def insert_sample_data():
    """Inserts sample data into the user_activities table."""
    try:
        with engine.connect() as connection:
            insert_query = """
            INSERT INTO user_activities (activity)
            VALUES ('Sample Activity 1'), ('Sample Activity 2');
            """
            connection.execute(insert_query)
            print("Sample data inserted successfully.")
    except SQLAlchemyError as e:
        print(f"An error occurred while inserting data: {e}")

def fetch_data():
    """Fetches and displays data from the user_activities table."""
    session = Session()
    try:
        query = text("SELECT user_id, activity, timestamp FROM user_activities ORDER BY timestamp DESC LIMIT 10;")
        result = session.execute(query)
        activities = result.fetchall()
        session.close()
        return activities
    except Exception as e:
        session.close()
        print(f"Error fetching data: {e}")
        return []

@app.route("/")
def index():
    """Fetches user activity data and displays it."""
    activities = fetch_data()
    return render_template("index.html", activities=activities)

@app.route("/api/activities")
def get_activities():
    """Returns user activity data as JSON."""
    activities = fetch_data()
    return jsonify([{"user_id": row[0], "activity": row[1], "timestamp": row[2]} for row in activities])

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
        return f"Error: {e}"

if __name__ == "__main__":
    create_table_if_not_exists()
    insert_sample_data()
    app.run(host="0.0.0.0", port=8080)
