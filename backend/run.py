import os
import sqlite3
from flask import g
from app import create_app

DATABASE = 'database.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
    return db

if __name__ == '__main__':
    app = create_app()
    
        
    # Initialize the database schema if it doesn't exist
    with app.app_context():
        if not os.path.exists(DATABASE):
            db = get_db()
            with app.open_resource('schema.sql', mode='r') as f:
                try:
                    db.cursor().executescript(f.read())
                    db.commit()
                    print("Database schema initialized successfully.")
                except Exception as e:
                    print("Error initializing database schema:", e)
        else:
            print("Database found!.")
    
    # app.run(debug=True, host="0.0.0.0")
    app.run(debug=True, host="192.168.43.175")
