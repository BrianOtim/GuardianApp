from flask import Blueprint, request, jsonify
from .database import get_db
import re
import bcrypt
import jwt 


auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    # Check if email and password fields exist in the request
    required_fields = ['email', 'password']
    if not all(key in data for key in required_fields):
        return jsonify({'error': 'Missing email or password'}), 400

    email = data.get('email')
    password = data.get('password')

    # Query the database to find the user with the provided email
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE email = ?", (email,))
    user = cur.fetchone()

    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Verify the password
    hashed_password = user[4]  # Assuming password is stored at index 4
    if not bcrypt.checkpw(password.encode('utf-8'), hashed_password):
        return jsonify({'error': 'Invalid email or password'}), 401

    # Generate a token or session for the user using PyJWT
    jwt_payload = {'email': email, 'role': user[5]}  # Assuming role is stored at index 5
    token = jwt.encode(jwt_payload, 'your_secret_key', algorithm='HS256')

    return jsonify({'token': token,'user': {'id': user[0], 'username': user[1], 'email': user[2], 'contact': user[3]}}), 200

def is_valid_email(email):
    # Regular expression to validate email format
    email_regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'
    return re.match(email_regex, email) is not None

def is_strong_password(password):
    # Password strength criteria (example)
    return len(password) >= 6

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # Check if id, username, email, contact, role, and password fields exist in the request
    required_fields = ['username', 'email', 'contact', 'role', 'password']
    if not all(key in data for key in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role')
    contact = data.get('contact')

    # Check if email is valid
    if not is_valid_email(email):
        return jsonify({'error': 'Invalid email format'}), 400
    
    # Check if password meets strength criteria
    if not is_strong_password(password):
        return jsonify({'error': 'Password should be at least 6 characters long'}), 400
    
    # Hash the password using bcrypt
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # Check if the username, email, or contact already exists
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE username = ? OR email = ? OR contact = ?", (username, email, contact))
    existing_user = cur.fetchone()
    if existing_user:
        return jsonify({'error': 'Username, email, or contact already taken'}), 400

    # Insert the new user into the database
    cur.execute("INSERT INTO users (username, email, contact, role, password) VALUES (?, ?, ?, ?, ?)",
                (username, email, contact, role, hashed_password))
    db.commit()
    cur.close()

    return jsonify({'message': 'User registered successfully'})

@auth_bp.route('/users', methods=['GET'])
def search_users():
    search_term = request.args.get('q')

    if not search_term:
        return jsonify({'error': 'Search term not provided'}), 400

    db = get_db()
    cur = db.cursor()

    # Search for users by username or email
    cur.execute("SELECT * FROM users WHERE username LIKE ? OR email LIKE ?", ('%' + search_term + '%', '%' + search_term + '%'))
    users = cur.fetchall()

    # Convert user data to a list of dictionaries
    user_list = [{'id': user[0], 'username': user[1], 'email': user[2]} for user in users]

    return jsonify({'users': user_list}), 200















