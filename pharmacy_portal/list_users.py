import firebase_admin
from firebase_admin import credentials, auth, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print('=== REGISTERED MEDITRACK USERS (Firestore) ===')
users = db.collection('users').stream()
found = False
for u in users:
    found = True
    d = u.to_dict()
    print(f"  Name  : {d.get('name')}")
    print(f"  Email : {d.get('email')}")
    print(f"  Phone : {d.get('phone')}")
    print(f"  UID   : {u.id}")
    print('  ---')

if not found:
    print('  No users found in Firestore users collection.')

print()
print('=== FIREBASE AUTH ACCOUNTS ===')
page = auth.list_users()
auth_found = False
for user in page.users:
    auth_found = True
    print(f"  Email : {user.email}")
    print(f"  Phone : {user.phone_number}")
    print(f"  UID   : {user.uid}")
    print('  ---')

if not auth_found:
    print('  No registered Auth accounts found.')
