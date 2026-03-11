import firebase_admin
from firebase_admin import credentials, auth
import os

if not firebase_admin._apps:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

EMAIL_ACCOUNT_UID = "fgiLANZXSeclvnBdetVKTUHl9Z92"
PHONE_ACCOUNT_UID = "bcCVVWK0h2YcwRUP7N26T0ah2Jq1"

print("Merging user accounts...")

# 1. Get the email user's email address
try:
    email_user = auth.get_user(EMAIL_ACCOUNT_UID)
    email_address = email_user.email
    print(f"Found email {email_address} on old email account.")
    
    # Delete the old email account so we can free up the email address
    print("Deleting old separate email account...")
    auth.delete_user(EMAIL_ACCOUNT_UID)
    print("Deleted successfully!")
except Exception as e:
    print(f"Could not find/delete old email account: {e}")
    # Assume it might have already been deleted or not found
    email_address = "sathish615207@gmail.com"

# 2. Add the email and password to the phone account
print(f"Updating phone account ({PHONE_ACCOUNT_UID}) to include email credentials...")
try:
    auth.update_user(
        PHONE_ACCOUNT_UID,
        email=email_address,
        password="password123",  # We must set a new password since we can't extract the old hash
        display_name="A K Sathisha"
    )
    print("Success! The accounts are now merged into the phone account.")
    print(f"You can now login using phone OTP or Email: {email_address} | password: password123")
except Exception as e:
    print(f"Error updating phone account: {e}")

