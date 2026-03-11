"""
Fix: Update medicines to match the currently logged-in phone-auth UID.
Also update user profile.
"""
import firebase_admin
from firebase_admin import credentials, firestore
import os

if not firebase_admin._apps:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

# The phone-auth UID (currently logged in)
PHONE_AUTH_UID = 'bcCVVWK0h2YcwRUP7N26T0ah2Jq1'
# The email-auth UID (previous fix target)
EMAIL_AUTH_UID = 'fgiLANZXSeclvnBdetVKTUHl9Z92'

print("Updating all medicines to phone-auth UID...")
meds = db.collection('medicines').where('userId', '==', EMAIL_AUTH_UID).stream()
count = 0
for m in meds:
    count += 1
    data = m.to_dict()
    print(f"  Fixing: {data.get('medicineName')} -> {PHONE_AUTH_UID}")
    db.collection('medicines').document(m.id).update({'userId': PHONE_AUTH_UID})

print(f"Fixed {count} medicines!")

# Also create/update user profile for phone-auth UID
print(f"\nUpdating user profile for {PHONE_AUTH_UID}...")
db.collection('users').document(PHONE_AUTH_UID).set({
    'name': 'A K Sathisha',
    'phone': '+919019305882',
    'email': 'sathish615207@gmail.com',
}, merge=True)
print("DONE!")

# Verify
print("\nVerification:")
meds = db.collection('medicines').where('userId', '==', PHONE_AUTH_UID).stream()
for m in meds:
    data = m.to_dict()
    print(f"  -> {data.get('medicineName')} | userId: {data.get('userId')}")
print("\nRestart the app now!")
