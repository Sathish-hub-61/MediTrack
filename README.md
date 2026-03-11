# 🏥 MediTrack: Online Monitoring of Quality, Safety, and Lifecycle of Medicines

**MediTrack** is an enterprise-grade medical safety platform designed to monitor the clinical quality and shelf-life of medicines. It bridges the "Last Mile" gap between pharmacies and patients by providing active intervention when medicines are approaching their expiration date.

![App Logo](assets/images/app_icon.png)

---

## 🚀 Key Features

*   **🛡️ Quality Monitoring:** Tracks the lifecycle of medicines from dispensation to disposal.
*   **📞 Triple-Alert System:** Simultaneous automated **Voice Calls**, **SMS**, and **Push Notifications** triggered 7 days before medicine expiry.
*   **☁️ Omni-Channel Sync:** Real-time data synchronization between the **Pharmacy Web Portal** (Python/Flask) and the **Mobile App** (Flutter).
*   **🤖 AI Safety Assistant:** Integrated **Google Gemini AI** to answer patient queries regarding medication and safety instructions.
*   **🔐 Enterprise Security:** Hardened environment management with `.env` shielding and Firebase-backed authentication.

---

## 🛠️ Technology Stack

### **Frontend (Mobile)**
*   **Framework:** Flutter (Dark/Light Mode support)
*   **State Management:** Provider
*   **UI Components:** Sizer (Responsive Design), Google Fonts

### **Backend & Web Portal**
*   **Language:** Python (Flask Framework)
*   **Database:** Google Cloud Firestore (NoSQL)
*   **Authentication:** Firebase Auth (Email/Password & Bypass logic)

### **Communications API**
*   **Voice & SMS:** Twilio API
*   **Push Notifications:** Firebase Cloud Messaging (FCM)

---

## 📁 Project Structure

```text
MediTrack/
├── lib/               # Flutter Mobile App Logic
├── pharmacy_portal/   # Python/Flask Web Dashboard & Alert Backend
├── assets/            # App Icons, Images, and Fonts
├── android/           # Android Native Configuration
├── .env               # (Required) API Keys & Credentials
└── pubspec.yaml       # Flutter Dependencies
```

---

## ⚙️ Setup & Installation

### **1. Flutter Mobile App**
1. Navigate to the root directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### **2. Pharmacy Portal (Backend)**
1. Navigate to the `pharmacy_portal` folder.
2. Create and activate a Virtual Environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Or .venv\Scripts\Activate.ps1 on Windows
   ```
3. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the server:
   ```bash
   python app.py
   ```

### **3. Running the Alert Job**
To scan the database and trigger Voice/SMS/Push alerts manually:
```bash
python alert_job.py
```

---

## 🛡️ "Quality" Monitoring Logic
In this project, **Quality** is defined as the chemical and clinical integrity of the medicine. When a medicine expires, its quality degrades. The system monitors this lifecycle online and intervenes before the quality lapses, ensuring 100% patient safety.

---

## 🏆 Project Outcomes
*   **Technical:** Successful integration of IVR (Interactive Voice Response) with Cloud Database.
*   **Social:** Reduction in accidental consumption of expired medication.
*   **Technical:** Automated multi-channel safety net for high-risk patients.

---

**Developed for the ASAC Capstone 2026**
*Submitted with ❤️ for Medical Safety.*
