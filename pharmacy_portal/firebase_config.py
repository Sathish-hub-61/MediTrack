import firebase_admin
from firebase_admin import credentials, firestore
import os

def initialize_firebase():
    if not firebase_admin._apps:
        # Load from serviceAccountKey.json if it exists
        if os.path.exists('serviceAccountKey.json'):
            cred = credentials.Certificate('serviceAccountKey.json')
            firebase_admin.initialize_app(cred)
            print("Firebase initialized with serviceAccountKey.json")
        else:
            print("WARNING: serviceAccountKey.json not found! Firebase Admin SDK needs this to bypass security rules.")
            print("Download it from Firebase Console -> Project Settings -> Service Accounts -> Generate New Private Key")
            print("Place the file in this folder and rename it to serviceAccountKey.json")
            # Fallback to application default credentials
            try:
                cred = credentials.ApplicationDefault()
                firebase_admin.initialize_app(cred)
            except Exception as e:
                print(f"Failed to load application default: {e}")
                
    return firestore.client()
