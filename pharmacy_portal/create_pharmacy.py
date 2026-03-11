import bcrypt
from firebase_config import initialize_firebase

print("Initializing Firebase...")
db = initialize_firebase()

def create_pharmacy_account():
    print("--- Create New Pharmacy Account ---")
    username = input("Enter Pharmacy Username: ")
    pharmacy_name = input("Enter Pharmacy Display Name: ")
    password = input("Enter Password: ")
    
    # Hash password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    # Add to firestore
    doc_ref = db.collection('pharmacies').document()
    doc_ref.set({
        'username': username,
        'pharmacy_name': pharmacy_name,
        'password_hash': hashed
    })
    
    print(f"\nSuccess! Pharmacy '{pharmacy_name}' created.")
    print(f"You can now log in at http://localhost:5000 as '{username}'")

if __name__ == '__main__':
    create_pharmacy_account()
