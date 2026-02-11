from flask import Flask, render_template, request, redirect, session, jsonify
import mysql.connector
from werkzeug.security import check_password_hash

app = Flask(__name__)
app.secret_key = "janswasthya_secret"


# ================= DB CONNECTION =================

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="your_password",
        database="janswasthya_db",
        autocommit=True
    )


# ================= LOGIN =================

@app.route("/", methods=["GET","POST"])
def login():

    if request.method == "POST":

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM users WHERE username=%s",
            (request.form["username"],)
        )

        user = cursor.fetchone()
        conn.close()

        if user and check_password_hash(user["password_hash"], request.form["password"]):
            session["user_id"] = user["user_id"]
            session["role"] = user["role"]
            return redirect("/dashboard")

    return render_template("login.html")


# ================= DASHBOARD =================

@app.route("/dashboard")
def dashboard():
    return render_template("dashboard.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")


# ================= PATIENT REGISTRATION =================

@app.route("/register_patient", methods=["GET","POST"])
def register_patient():

    if request.method == "POST":

        conn = get_db_connection()
        cursor = conn.cursor()

        # 🔍 DUPLICATE PHONE CHECK
        cursor.execute(
            "SELECT * FROM patients WHERE phone=%s",
            (request.form.get("phone"),)
        )

        existing = cursor.fetchone()

        if existing:
            conn.close()
            return "Patient already registered with this phone."

        # ✔ INSERT NEW PATIENT
        cursor.execute("""
            INSERT INTO patients
            (full_name, gender, phone, address)
            VALUES (%s,%s,%s,%s)
        """, (
            request.form.get("name"),
            request.form.get("gender"),
            request.form.get("phone"),
            request.form.get("address")
        ))

        conn.close()

        return redirect("/create_visit")

    return render_template("register_patient.html")


# ================= CREATE VISIT + TOKEN =================

@app.route("/create_visit", methods=["GET", "POST"])
def create_visit():

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # ================= FETCH PATIENTS =================
    cursor.execute("""
        SELECT patient_id, full_name
        FROM patients
        ORDER BY patient_id DESC
    """)
    patients = cursor.fetchall()

    # ================= FETCH DOCTORS =================
    cursor.execute("""
        SELECT doctor_id, doctor_name
        FROM doctors
        ORDER BY doctor_name
    """)
    doctors = cursor.fetchall()

    # ================= HANDLE FORM SUBMIT =================
    if request.method == "POST":

        patient_id = request.form["patient_id"]
        doctor_id = request.form["doctor_id"]
        symptoms = request.form["symptoms"]

        # ---------- INSERT VISIT ----------
        cursor.execute("""
            INSERT INTO visits
            (patient_id, doctor_id, visit_date, symptoms)
            VALUES (%s, %s, CURDATE(), %s)
        """, (patient_id, doctor_id, symptoms))

        visit_id = cursor.lastrowid

        # ================= SAFE TOKEN GENERATION =================

        cursor.execute("""
            SELECT MAX(token_no) AS max_token
            FROM opd_tokens
            WHERE token_date = CURDATE()
        """)

        result = cursor.fetchone()

        if result["max_token"] is None:
            token_no = 1
        else:
            token_no = result["max_token"] + 1

        # ---------- INSERT TOKEN ----------
        cursor.execute("""
            INSERT INTO opd_tokens
            (visit_id, token_no, token_date)
            VALUES (%s, %s, CURDATE())
        """, (visit_id, token_no))

        conn.close()

        return redirect("/queue")

    # ================= LOAD PAGE =================
    conn.close()

    return render_template(
        "create_visit.html",
        patients=patients,
        doctors=doctors
    )


# ================= LIVE QUEUE =================

@app.route("/queue")
def queue():
    return render_template("queue.html")


@app.route("/queue_data")
def queue_data():

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT t.token_no,
               p.full_name,
               d.doctor_name
        FROM opd_tokens t
        JOIN visits v ON t.visit_id=v.visit_id
        JOIN patients p ON v.patient_id=p.patient_id
        JOIN doctors d ON v.doctor_id=d.doctor_id
        ORDER BY t.token_no
    """)

    data = cursor.fetchall()
    conn.close()

    return jsonify(data)


# ================= DOCTOR QUEUE =================

@app.route("/doctor_queue")
def doctor_queue():

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT v.visit_id,
               p.full_name,
               v.symptoms
        FROM visits v
        JOIN patients p ON v.patient_id=p.patient_id
        ORDER BY v.visit_id DESC
    """)

    visits = cursor.fetchall()
    conn.close()

    return render_template(
        "doctor_queue.html",
        visits=visits
    )


# ================= CONSULT =================

@app.route("/consult/<int:visit_id>")
def consult(visit_id):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
    SELECT
        medicine_id,
        generic_name
    FROM medicines
    ORDER BY generic_name
""")

    medicines = cursor.fetchall()

    conn.close()

    return render_template(
        "consult.html",
        visit_id=visit_id,
        medicines=medicines
    )


@app.route("/save_prescription", methods=["POST"])
def save_prescription():

    conn = get_db_connection()
    cursor = conn.cursor()

    visit_id = request.form["visit_id"]
    medicine_id = request.form["medicine_id"]
    dosage = request.form["dosage"]
    duration_days = request.form["days"]
    quantity = request.form["quantity"]

    # ================= CHECK EXISTING PRESCRIPTION =================

    cursor.execute("""
        SELECT prescription_id
        FROM prescriptions
        WHERE visit_id=%s
    """, (visit_id,))

    existing = cursor.fetchone()

    if existing:
        prescription_id = existing[0]
    else:
        cursor.execute("""
            INSERT INTO prescriptions (visit_id)
            VALUES (%s)
        """, (visit_id,))
        prescription_id = cursor.lastrowid

    # ================= INSERT MEDICINE ITEM =================

    cursor.execute("""
        INSERT INTO prescription_items
        (prescription_id, medicine_id, dosage,
         duration_days, quantity)
        VALUES (%s,%s,%s,%s,%s)
    """, (
        prescription_id,
        medicine_id,
        dosage,
        duration_days,
        quantity
    ))

    conn.close()

    return redirect("/pharmacy")

# ================= PHARMACY QUEUE =================

@app.route("/pharmacy")
def pharmacy():

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
    SELECT
        pr.prescription_id,
        p.full_name
    FROM prescriptions pr
    JOIN visits v ON pr.visit_id = v.visit_id
    JOIN patients p ON v.patient_id = p.patient_id
    WHERE IFNULL(pr.issued_status, 0) = 0
""")


    prescriptions = cursor.fetchall()
    conn.close()

    return render_template(
        "pharmacy_queue.html",
        prescriptions=prescriptions
    )


# ================= VIEW PRESCRIPTION =================

@app.route("/pharmacy/<int:pid>")
def view_prescription(pid):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            m.generic_name AS medicine_name,
            pi.dosage,
            pi.duration_days AS days
        FROM prescription_items pi
        JOIN medicines m
        ON pi.medicine_id = m.medicine_id
        WHERE pi.prescription_id = %s
    """, (pid,))

    items = cursor.fetchall()
    conn.close()

    return render_template(
        "issue_medicine.html",
        items=items
    )
@app.route("/issue_medicine/<int:pid>", methods=["POST"])
def issue_medicine(pid):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # ================= FETCH PRESCRIPTION ITEMS =================
    cursor.execute("""
        SELECT
            medicine_id,
            quantity
        FROM prescription_items
        WHERE prescription_id = %s
    """, (pid,))

    items = cursor.fetchall()

    # ================= DEDUCT STOCK =================
    for item in items:

        cursor.execute("""
            UPDATE medicines
            SET stock = stock - %s
            WHERE medicine_id = %s
        """, (
            item["quantity"],
            item["medicine_id"]
        ))

    # ================= MARK AS ISSUED =================
    cursor.execute("""
        UPDATE prescriptions
        SET issued_status = 1
        WHERE prescription_id = %s
    """, (pid,))

    conn.close()

    return redirect("/pharmacy")


# ================= RUN =================

if __name__ == "__main__":
    app.run(debug=True)

