import firebase_admin
from firebase_admin import credentials, firestore
import bcrypt
import os

if not firebase_admin._apps:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

# Hash the requested password "Krishna"
new_password = 'Krishna'
hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

# Update all existing pharmacies
pharmacies = db.collection('pharmacies').stream()
found = False

for p in pharmacies:
    found = True
    print(f"Updating password for pharmacy '{p.to_dict().get('username')}'...")
    db.collection('pharmacies').document(p.id).update({
        'password_hash': hashed
    })
    
if not found:
    print("No pharmacies found! Creating 'my_pharmacy'...")
    db.collection('pharmacies').add({
        'username': 'my_pharmacy',
        'pharmacy_name': 'My Pharmacy',
        'password_hash': hashed,
    })

print("\nSuccess! The password is now securely set to: Krishna")
