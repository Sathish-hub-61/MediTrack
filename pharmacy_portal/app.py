import os
import io
import datetime
import bcrypt
import pandas as pd
import logging
from firebase_admin import auth
from flask import Flask, render_template, request, redirect, url_for, session, flash, send_file
from firebase_config import initialize_firebase
from functools import wraps
from dotenv import load_dotenv

# Load root .env file from the flutter app directory
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(dotenv_path)

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'pharmacy_portal_super_secret_key')

ADMIN_USER = os.getenv('ADMIN_USERNAME', 'Admin_1')
ADMIN_PASS = os.getenv('ADMIN_PASSWORD', 'Delulu')

db = initialize_firebase()

# Decorators for auth
def login_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if 'pharmacy_username' not in session:
            flash("Please log in to access this page.", "error")
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return wrapper

def admin_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if 'admin' not in session:
            flash("Admin access required.", "error")
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    return wrapper

@app.route('/')
def index():
    if 'pharmacy_username' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        # Check pharmacy credentials in Firestore
        docs = db.collection('pharmacies').where('username', '==', username).limit(1).stream()
        pharmacy = None
        for doc in docs:
            pharmacy = doc.to_dict()
            pharmacy['id'] = doc.id
            
        if pharmacy:
            if bcrypt.checkpw(password.encode('utf-8'), pharmacy['password_hash'].encode('utf-8')):
                session['pharmacy_username'] = username
                session['pharmacy_name'] = pharmacy.get('pharmacy_name', username)
                return redirect(url_for('dashboard'))
            else:
                flash("Invalid password.", "error")
        else:
            flash("Pharmacy not found.", "error")
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    was_admin = 'admin' in session
    session.clear()
    if was_admin:
        return redirect(url_for('admin_login'))
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html', pharmacy_name=session.get('pharmacy_name'))

@app.route('/add_medicine', methods=['GET', 'POST'])
@login_required
def add_medicine():
    if request.method == 'POST':
        phone = request.form.get('customer_phone')
        medicine_name = request.form.get('medicine_name')
        batch_number = request.form.get('batch_number')
        mfg_date = request.form.get('manufactured_date')
        exp_date = request.form.get('expiry_date')
        use_case = request.form.get('use_case')
        
        # Automatically append Indian country code if + not present
        if not phone.startswith('+'):
            phone = '+91' + phone.lstrip('0')
            
        # 1. Look up user by phone number in Firestore
        users_ref = db.collection('users').where('phone', '==', phone).limit(1).stream()
        user_id = None
        for u in users_ref:
            user_id = u.id
            break
            
        # 1b. Fallback: Lookup directly in Firebase Auth
        if not user_id:
            try:
                user_record = auth.get_user_by_phone_number(phone)
                user_id = user_record.uid
                
                # Auto-create the Firestore user document since it's missing
                db.collection('users').document(user_id).set({
                    'phone': phone,
                    'name': user_record.display_name or 'Patient',
                    'email': user_record.email or ''
                })
            except Exception as e:
                logging.error(f"Failed to fetch or auto-create user in Firebase Auth: {e}")
            
        if not user_id:
            flash(f"User with phone {phone} not found! Ask them to register on the MediTrack app first.", "error")
            return redirect(url_for('add_medicine'))
            
        # 2. Prepare ISO 8601 dates for the mobile app schema
        added_at = datetime.datetime.utcnow().isoformat() + "Z"
        try:
            m_dt = datetime.datetime.strptime(mfg_date, '%Y-%m-%d').isoformat() + "Z"
            e_dt = datetime.datetime.strptime(exp_date, '%Y-%m-%d').isoformat() + "Z"
        except Exception as e:
            flash(f"Invalid date format. {str(e)}", "error")
            return redirect(url_for('add_medicine'))

        # 3. Create document in medicines collection identical to Flutter schema
        new_med_ref = db.collection('medicines').document()
        med_data = {
            'id': new_med_ref.id,
            'userId': user_id,
            'medicineName': medicine_name,
            'batchNumber': batch_number,
            'manufacturedDate': m_dt,
            'expiryDate': e_dt,
            'useCase': use_case,
            'disposed': 0, # Int instead of boolean matches Dart logic correctly
            'addedAt': added_at,
            'addedByPharmacy': session.get('pharmacy_username') # Extra tracking field
        }
        
        new_med_ref.set(med_data)
        flash("Medicine successfully added and synced to the mobile app!", "success")
        return redirect(url_for('add_medicine'))
        
    return render_template('add_medicine.html')

@app.route('/sales')
@login_required
def sales():
    # Show only sales added by the currently logged-in pharmacy
    username = session.get('pharmacy_username')
    meds_ref = db.collection('medicines').where('addedByPharmacy', '==', username).limit(100).stream()
    
    meds_list = []
    user_ids = set()
    for m in meds_ref:
        d = m.to_dict()
        meds_list.append(d)
        if d.get('userId'):
            user_ids.add(d['userId'])
            
    # Resolve user IDs to phone numbers for display
    users_dict = {}
    for uid in user_ids:
        u_doc = db.collection('users').document(uid).get()
        if u_doc.exists:
            users_dict[uid] = u_doc.to_dict().get('phone', 'Unknown')
            
    sales_data = []
    for d in meds_list:
        sales_data.append({
            'date': d.get('addedAt', '')[:10],
            'customer_phone': users_dict.get(d.get('userId'), 'Unknown'),
            'medicine_name': d.get('medicineName', ''),
            'batch': d.get('batchNumber', ''),
            'expiry': d.get('expiryDate', '')[:10]
        })
        
    # Sort sales by date descending
    sales_data.sort(key=lambda x: x['date'], reverse=True)
        
    return render_template('sales.html', sales=sales_data)

@app.route('/sales/export')
@login_required
def export_sales():
    username = session.get('pharmacy_username')
    meds_ref = db.collection('medicines').where('addedByPharmacy', '==', username).limit(500).stream()
    
    data = []
    for m in meds_ref:
        d = m.to_dict()
        data.append({
            'Date Added': d.get('addedAt', '')[:10],
            'User ID': d.get('userId', ''),
            'Medicine Name': d.get('medicineName', ''),
            'Batch Number': d.get('batchNumber', ''),
            'Expiry Date': d.get('expiryDate', '')[:10]
        })
        
    if not data:
        flash("No sales data to export.", "error")
        return redirect(url_for('sales'))

    df = pd.DataFrame(data)
    
    # Generate Excel in memory
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Sales')
    
    output.seek(0)
    return send_file(output, as_attachment=True, download_name='Pharmacy_Sales_Export.xlsx', mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

@app.route('/admin_login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        # Dynamic admin from .env
        if username == ADMIN_USER and password == ADMIN_PASS:
            session['admin'] = True
            return redirect(url_for('admin_dashboard'))
        flash("Invalid admin credentials", "error")
    return render_template('admin_login.html')

@app.route('/admin_dashboard')
@admin_required
def admin_dashboard():
    pharms = [p.to_dict() for p in db.collection('pharmacies').limit(100).stream()]
    all_meds = [m.to_dict() for m in db.collection('medicines').where('addedByPharmacy', '>=', '').limit(100).stream()]
    return render_template('admin_dashboard.html', pharmacies=pharms, medicines=all_meds)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
