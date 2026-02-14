import os
import firebase_admin
from firebase_admin import credentials, firestore
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin
# Note: You need a serviceAccountKey.json file in this directory
try:
    if not firebase_admin._apps:
        cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        else:
            # Fallback to default if running in a cloud environment with credentials set
            firebase_admin.initialize_app()
    db = firestore.client()
except Exception as e:
    print(f"Firebase initialization failed: {e}. Running in local mock mode.")
    db = None

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "MediTrack Backend"}), 200

# GET Medicines for a user
@app.route('/api/medicines/<user_id>', methods=['GET'])
def get_medicines(user_id):
    if not db:
        return jsonify({"error": "Database not initialized"}), 500
    
    try:
        docs = db.collection('medicines')\
                 .where('userId', '==', user_id)\
                 .where('disposed', '==', False)\
                 .stream()
        
        medicines = []
        for doc in docs:
            m = doc.to_dict()
            m['id'] = doc.id
            medicines.append(m)
            
        return jsonify(medicines), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# POST Add Medicine
@app.route('/api/medicines', methods=['POST'])
def add_medicine():
    if not db:
        return jsonify({"error": "Database not initialized"}), 500
    
    try:
        data = request.json
        # Add timestamp
        data['addedAt'] = datetime.now().isoformat()
        data['disposed'] = False
        
        doc_ref = db.collection('medicines').add(data)
        return jsonify({"id": doc_ref[1].id, "status": "success"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# PUT Dispose Medicine
@app.route('/api/medicines/dispose', methods=['PUT'])
def dispose_medicine():
    if not db:
        return jsonify({"error": "Database not initialized"}), 500
    
    try:
        data = request.json
        medicine_id = data.get('id')
        user_id = data.get('userId')
        
        doc_ref = db.collection('medicines').document(medicine_id)
        doc_ref.update({'disposed': True})
        
        # Log to history
        db.collection('history').add({
            'medicineId': medicine_id,
            'userId': user_id,
            'action': 'Disposed',
            'timestamp': datetime.now().isoformat(),
            'details': data.get('details', 'Marked as disposed')
        })
        
        return jsonify({"status": "success"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# GET History
@app.route('/api/history/<user_id>', methods=['GET'])
def get_history(user_id):
    if not db:
        return jsonify({"error": "Database not initialized"}), 500
    
    try:
        docs = db.collection('history')\
                 .where('userId', '==', user_id)\
                 .order_by('timestamp', direction=firestore.Query.DESCENDING)\
                 .stream()
        
        history = [doc.to_dict() for doc in docs]
        return jsonify(history), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
