"""
Quick diagnostic script to check Firestore data and identify sync issues.
Run this from the pharmacy_portal directory.
"""
import firebase_admin
from firebase_admin import credentials, firestore
import os

# Initialize Firebase Admin (bypasses all security rules)
if not firebase_admin._apps:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("=" * 60)
print("MEDITRACK SYNC DIAGNOSTIC")
print("=" * 60)

# 1. List ALL users in Firestore
print("\n--- ALL USERS in Firestore 'users' collection ---")
users = db.collection('users').stream()
user_count = 0
for u in users:
    user_count += 1
    data = u.to_dict()
    print(f"  Doc ID: {u.id}")
    print(f"    Name:  {data.get('name', 'N/A')}")
    print(f"    Phone: {data.get('phone', 'N/A')}")
    print(f"    Email: {data.get('email', 'N/A')}")
    print()
if user_count == 0:
    print("  *** NO USERS FOUND in Firestore 'users' collection! ***")
    print("  This means the pharmacy portal cannot look up users by phone.")

# 2. List ALL medicines in Firestore
print("\n--- ALL MEDICINES in Firestore 'medicines' collection ---")
meds = db.collection('medicines').stream()
med_count = 0
for m in meds:
    med_count += 1
    data = m.to_dict()
    print(f"  Doc ID: {m.id}")
    print(f"    Medicine:   {data.get('medicineName', 'N/A')}")
    print(f"    userId:     {data.get('userId', 'N/A')}")
    print(f"    Disposed:   {data.get('disposed', 'N/A')}")
    print(f"    AddedBy:    {data.get('addedByPharmacy', 'N/A')}")
    print(f"    ExpiryDate: {data.get('expiryDate', 'N/A')}")
    print()
if med_count == 0:
    print("  *** NO MEDICINES FOUND in Firestore! ***")

# 3. Check Firebase Auth users
print("\n--- Firebase Auth Users (first 10) ---")
from firebase_admin import auth
try:
    page = auth.list_users()
    auth_count = 0
    for user in page.users:
        auth_count += 1
        if auth_count > 10:
            break
        print(f"  UID:    {user.uid}")
        print(f"    Email: {user.email or 'N/A'}")
        print(f"    Phone: {user.phone_number or 'N/A'}")
        print(f"    Name:  {user.display_name or 'N/A'}")
        print()
except Exception as e:
    print(f"  Error listing auth users: {e}")

print("=" * 60)
print("DIAGNOSIS COMPLETE")
print("=" * 60)
