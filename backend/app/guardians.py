from flask import Blueprint, request, jsonify

from .database import get_db

guardians_bp = Blueprint('guardians', __name__)

# CRUD routes for guardians
# Example:
@guardians_bp.route('/guardians', methods=['POST'])
def add_guardian():
    data = request.get_json()

    # Check if userId and guardianId fields exist in the request
    required_fields = ['userId', 'guardianId']
    if not all(key in data for key in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400

    user_id = data.get('userId')
    guardian_id = data.get('guardianId')

    # Check if userId and guardianId are valid integers
    if not isinstance(user_id, int) or not isinstance(guardian_id, int):
        return jsonify({'error': 'Invalid userId or guardianId'}), 400

    # Check if the user and guardian exist in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cur.fetchone()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    cur.execute("SELECT * FROM users WHERE id = ?", (guardian_id,))
    guardian = cur.fetchone()
    if not guardian:
        return jsonify({'error': 'Guardian not found'}), 404

    # Check if the user and guardian are not the same
    if user_id == guardian_id:
        return jsonify({'error': 'User and guardian cannot be the same'}), 400

    # Check if the guardian relationship already exists
    cur.execute("SELECT * FROM guardians WHERE userId = ? AND guardianId = ?", (user_id, guardian_id))
    existing_relationship = cur.fetchone()
    if existing_relationship:
        return jsonify({'error': 'Guardian relationship already exists'}), 400

    # Insert the guardian relationship into the database
    cur.execute("INSERT INTO guardians (userId, guardianId) VALUES (?, ?)", (user_id, guardian_id))
    db.commit()
    cur.close()

    return jsonify({'message': 'Guardian added successfully'}), 200

@guardians_bp.route('/guardians/<int:user_id>', methods=['GET'])
def get_guardians(user_id):
    # Check if the user exists in the database
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cur.fetchone()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Query the database for the guardians of the user
    cur.execute("SELECT * FROM guardians WHERE userId = ?", (user_id,))
    guardians = cur.fetchall()

    # Convert guardian data to a list of dictionaries
    guardian_list = []
    for guardian in guardians:
        # Retrieve the guardian details from the users table
        cur.execute("SELECT * FROM users WHERE id = ?", (guardian[2],))
        guardian_details = cur.fetchone()
        if guardian_details:
            guardian_dict = {
                'id': guardian[0],
                'userId': guardian[1],
                'guardianId': guardian[2],
                'guardian_username': guardian_details[1],
                'guardian_email': guardian_details[2],
                'guardian_contact': guardian_details[3],
                'guardian_role': guardian_details[5]
            }
            guardian_list.append(guardian_dict)

    return jsonify({
       'user': {'id': user[0], 'username': user[1], 'email': user[2], 'contact': user[3]},
        'guardians': guardian_list}), 200

@guardians_bp.route('/guardians/<int:user_id>/<int:guardian_id>', methods=['DELETE'])
def delete_guardian(user_id, guardian_id):
    # Check if the user and guardian exist in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cur.fetchone()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    cur.execute("SELECT * FROM users WHERE id = ?", (guardian_id,))
    guardian = cur.fetchone()
    if not guardian:
        return jsonify({'error': 'Guardian not found'}), 404

    # Check if the guardian relationship exists
    cur.execute("SELECT * FROM guardians WHERE userId = ? AND guardianId = ?", (user_id, guardian_id))
    existing_relationship = cur.fetchone()
    if not existing_relationship:
        return jsonify({'error': 'Guardian relationship not found'}), 404

    # Delete the guardian relationship from the database
    cur.execute("DELETE FROM guardians WHERE userId = ? AND guardianId = ?", (user_id, guardian_id))
    db.commit()
    cur.close()

    return jsonify({'message': 'Guardian deleted successfully'}), 200


@guardians_bp.route('/guardians/<int:guardian_id>/people', methods=['GET'])
def get_people_under_guardian(guardian_id):
    # Check if the guardian exists in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM users WHERE id = ?", (guardian_id,))
    guardian = cur.fetchone()
    if not guardian:
        return jsonify({'error': 'Guardian not found'}), 404

    # Query the database for people who are under the given guardian
    cur.execute("SELECT * FROM users WHERE id IN (SELECT userId FROM guardians WHERE guardianId = ?)", (guardian_id,))
    people = cur.fetchall()

    # Convert user data to a list of dictionaries
    people_list = [{'id': person[0], 'username': person[1], 'email': person[2]} for person in people]

    return jsonify({'guardian': {'id': guardian[0], 'username': guardian[1]}, 'people': people_list}), 200

@guardians_bp.route('/guardians/<int:guardian_id>/alerts', methods=['GET'])
def get_alerts_for_people_under_guardian(guardian_id):
    # Check if the guardian exists in the database
    db = get_db()
    cur = db.cursor()

    cur.execute("SELECT * FROM users WHERE id = ?", (guardian_id,))
    guardian = cur.fetchone()
    if not guardian:
        return jsonify({'error': 'Guardian not found'}), 404

    # Query the database for people who are under the given guardian
    cur.execute("SELECT userId FROM guardians WHERE guardianId = ?", (guardian_id,))
    user_ids = [row[0] for row in cur.fetchall()]

    # Query the database for alerts for all people under the given guardian
    alerts_list = []
    for user_id in user_ids:
        cur.execute("SELECT * FROM alerts WHERE victimId = ?", (user_id,))
        alerts = cur.fetchall()
        for alert in alerts:
            # Get details of the victim
            cur.execute("SELECT * FROM users WHERE id = ?", (alert[1],))
            victim = cur.fetchone()
            if victim:
                alert_dict = {
                    'id': alert[0],
                    'victim': {
                        'id': victim[0],
                        'username': victim[1],
                        'email': victim[2],
                        'contact': victim[3],
                        'role': victim[5]
                    },
                    'message': alert[2]
                }
                alerts_list.append(alert_dict)

    return jsonify({'guardian': {'id': guardian[0], 'username': guardian[1]}, 'alerts': alerts_list}), 200