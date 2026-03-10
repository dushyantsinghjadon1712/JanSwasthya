# 🏥 JanSwasthya — Hospital Management & Pharmacy Intelligence System

JanSwasthya is a **full-stack hospital management system** designed to streamline healthcare workflows including patient registration, OPD token generation, doctor consultation, prescription management, and pharmacy inventory automation.

The system simulates **real-world hospital operations** by integrating database design, workflow automation, and inventory intelligence.

---

# 🚀 Features

## 👨‍⚕️ Patient & OPD Management
- Patient registration and record creation
- Automated OPD token generation
- Real-time patient queue tracking

## 🩺 Doctor Consultation
- Doctor queue dashboard
- Consultation workflow with prescription creation
- Multiple medicines per prescription

## 💊 Pharmacy Management
- Pharmacy queue for pending prescriptions
- Medicine issue workflow
- Automatic stock deduction after issuing medicines

## 📦 Inventory Intelligence
- Medicine stock tracking
- Low stock alert system
- Medicine consumption analytics

## 📊 Hospital Analytics Dashboard
- Total patients overview
- Total visits monitoring
- Prescription statistics
- Low stock medicine alerts

---

# 🛠 Tech Stack

| Layer | Technology |
|------|------------|
| Backend | Python (Flask) |
| Database | MySQL |
| Frontend | HTML, CSS, JavaScript |
| Styling | Tailwind CSS |
| Data Layer | SQL Views |

---

# 🧠 System Workflow

```
Patient Registration
        ↓
Visit Creation
        ↓
OPD Token Generation
        ↓
Doctor Consultation
        ↓
Prescription Creation
        ↓
Pharmacy Queue
        ↓
Medicine Issue
        ↓
Stock Deduction
        ↓
Low Stock Alerts
```

---

# 🗄 Database Design

Main tables used in the system:

```
patients
visits
doctors
prescriptions
prescription_items
medicines
opd_tokens
```

Database design features:

- Normalized relational schema
- Prescription–medicine mapping
- Inventory management
- Analytics queries for hospital insights

---

# ⚙️ Installation & Setup

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/janswasthya.git
cd janswasthya
```

---

## 2️⃣ Install Dependencies

```bash
pip install flask mysql-connector-python
```

---

## 3️⃣ Create Database

Open MySQL and run:

```sql
CREATE DATABASE janswasthya_db;
```

Update database credentials inside:

```
app.py
```

Example:

```python
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD",
        database="janswasthya_db"
    )
```

---

## 4️⃣ Run Application

```bash
python app.py
```

Open in browser:

```
http://127.0.0.1:5000
```

---

# 📂 Project Structure

```
JanSwasthya
│
├── app.py
├── templates
│   ├── base.html
│   ├── dashboard.html
│   ├── analytics.html
│   ├── pharmacy_queue.html
│   ├── consult.html
│   └── login.html
│
├── static
│   └── styles.css
│
└── database
    └── schema.sql
```

---

# 📈 Future Improvements

Planned enhancements:

- Medicine expiry alerts
- Batch tracking for pharmacy inventory
- Advanced analytics dashboards
- Machine learning for medicine demand forecasting
- Multi-hospital system support

---

# 🎯 Learning Outcomes

This project demonstrates practical experience in:

- Full-stack web development
- Relational database design
- Healthcare workflow automation
- Inventory management systems
- Data analytics dashboards

---

# 👨‍💻 Author

**Dushyant Jadon**  
B.Tech Computer Science Engineering  
Aspiring Data Analyst & Systems Developer

---

⭐ If you like this project, consider giving it a **star on GitHub**.
