CREATE DATABASE janswasthya_db;
USE janswasthya_db;
CREATE TABLE medicines (
  medicine_id INT AUTO_INCREMENT PRIMARY KEY,

  generic_name VARCHAR(255) NOT NULL,
  dosage_form VARCHAR(100),
  strength VARCHAR(100),

  therapeutic_category VARCHAR(150),
  who_list_section VARCHAR(100),
  notes TEXT,

  unit VARCHAR(30) DEFAULT 'unit',
  reorder_level INT DEFAULT 20 CHECK (reorder_level >= 0),

  UNIQUE (generic_name, dosage_form, strength)
);
CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(150) NOT NULL,
  phone VARCHAR(15),
  gst_no VARCHAR(20)
);

CREATE TABLE medicine_batches (
  batch_id INT AUTO_INCREMENT PRIMARY KEY,
  medicine_id INT NOT NULL,
  supplier_id INT NOT NULL,
  batch_code VARCHAR(50) NOT NULL UNIQUE,
  expiry_date DATE NOT NULL,
  mrp DECIMAL(10,2) NOT NULL,
  purchase_price DECIMAL(10,2) NOT NULL,
  quantity_in_stock INT NOT NULL CHECK (quantity_in_stock >= 0),
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);
SELECT COUNT(*) AS total_medicines FROM medicines;

SELECT * FROM medicines LIMIT 20;

SELECT therapeutic_category, COUNT(*) AS count
FROM medicines
GROUP BY therapeutic_category
ORDER BY count DESC;
CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT NOT NULL,
  doctor_name VARCHAR(120) NOT NULL,
  phone VARCHAR(15) UNIQUE,
  qualification VARCHAR(100),
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  gender ENUM('Male','Female','Other') NOT NULL,
  dob DATE,
  phone VARCHAR(15) NOT NULL UNIQUE,
  address VARCHAR(255)
);
CREATE TABLE visits (
  visit_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  department_id INT NOT NULL,
  visit_date DATE NOT NULL,
  symptoms VARCHAR(255),
  diagnosis VARCHAR(255),
  notes TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
CREATE TABLE opd_tokens (
  token_id INT AUTO_INCREMENT PRIMARY KEY,
  visit_id INT NOT NULL UNIQUE,
  token_no INT NOT NULL,
  token_date DATE NOT NULL,
  department_id INT NOT NULL,
  status ENUM('Queued','InProgress','Completed','Skipped') DEFAULT 'Queued',
  FOREIGN KEY (visit_id) REFERENCES visits(visit_id),
  FOREIGN KEY (department_id) REFERENCES departments(department_id),
  UNIQUE(token_no, token_date, department_id)
);
INSERT INTO departments(name) VALUES
('General Medicine'),
('Pediatrics'),
('Gynecology'),
('Orthopedics'),
('ENT'),
('Dermatology'),
('Ophthalmology'),
('Dental'),
('Emergency');
INSERT INTO doctors(department_id, doctor_name, phone, qualification) VALUES
(1, 'Dr. Anil Sharma', '9000000001', 'MBBS, MD'),
(2, 'Dr. Neha Singh', '9000000002', 'MBBS, MD'),
(3, 'Dr. Kavita Jain', '9000000003', 'MBBS, MD'),
(4, 'Dr. Rahul Meena', '9000000004', 'MBBS, MS'),
(5, 'Dr. Pooja Verma', '9000000005', 'MBBS, MS'),
(6, 'Dr. Aman Khan', '9000000006', 'MBBS, MD'),
(7, 'Dr. Priyanka Joshi', '9000000007', 'MBBS, MS'),
(8, 'Dr. Deepak Gupta', '9000000008', 'BDS'),
(9, 'Dr. Sunita Rao', '9000000009', 'MBBS');
INSERT INTO patients(full_name, gender, dob, phone, address) VALUES
('Ramesh Kumar', 'Male', '1997-04-12', '9100000001', 'Jaipur'),
('Sita Devi', 'Female', '1989-01-21', '9100000002', 'Ajmer'),
('Mohit Sharma', 'Male', '2002-08-10', '9100000003', 'Kota'),
('Aarti Meena', 'Female', '1995-12-02', '9100000004', 'Udaipur');
INSERT INTO visits(patient_id, doctor_id, department_id, visit_date, symptoms)
VALUES
(1, 1, 1, CURDATE(), 'Fever, headache'),
(2, 5, 5, CURDATE(), 'Ear pain, cold'),
(3, 4, 4, CURDATE(), 'Back pain'),
(4, 2, 2, CURDATE(), 'Cough and mild fever');
INSERT INTO opd_tokens(visit_id, token_no, token_date, department_id)
VALUES
(1, 1, CURDATE(), 1),
(2, 1, CURDATE(), 5),
(3, 1, CURDATE(), 4),
(4, 1, CURDATE(), 2);
SELECT * FROM departments;
SELECT * FROM doctors;
SELECT * FROM patients;
SELECT * FROM visits;
SELECT * FROM opd_tokens;
CREATE TABLE prescriptions (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  visit_id INT NOT NULL UNIQUE,
  prescribed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);
CREATE TABLE prescription_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  prescription_id INT NOT NULL,
  medicine_id INT NOT NULL,
  batch_id INT NULL,
  dosage VARCHAR(80),
  duration_days INT CHECK (duration_days >= 0),
  quantity INT NOT NULL CHECK (quantity > 0),
  FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id),
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);
INSERT INTO prescriptions(visit_id)
VALUES
(1), (2), (3), (4);
SELECT * FROM prescriptions;
SELECT medicine_id, generic_name, dosage_form, strength
FROM medicines
WHERE generic_name LIKE '%paracetamol%'
LIMIT 20;
SELECT medicine_id, generic_name, dosage_form, strength
FROM medicines
WHERE generic_name LIKE '%amoxicillin%'
LIMIT 20;
INSERT INTO prescription_items(prescription_id, medicine_id, dosage, duration_days, quantity)
VALUES
(1, 1, '1-0-1', 3, 6),
(1, 2, '0-1-0', 5, 5),
(2, 3, '1-1-1', 5, 15),
(3, 4, '1-0-0', 7, 7);
SELECT
  p.prescription_id,
  v.visit_id,
  pt.full_name AS patient_name,
  d.doctor_name,
  dept.name AS department,
  v.visit_date,
  m.generic_name,
  m.dosage_form,
  m.strength,
  pi.dosage,
  pi.duration_days,
  pi.quantity
FROM prescriptions p
JOIN visits v ON p.visit_id = v.visit_id
JOIN patients pt ON v.patient_id = pt.patient_id
JOIN doctors d ON v.doctor_id = d.doctor_id
JOIN departments dept ON v.department_id = dept.department_id
JOIN prescription_items pi ON p.prescription_id = pi.prescription_id
JOIN medicines m ON pi.medicine_id = m.medicine_id
ORDER BY p.prescription_id;
CREATE TABLE stock_transactions (
  txn_id INT AUTO_INCREMENT PRIMARY KEY,
  batch_id INT NOT NULL,
  txn_type ENUM('IN','OUT') NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  txn_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
  reference_note VARCHAR(255),
  FOREIGN KEY (batch_id) REFERENCES medicine_batches(batch_id)
);
CREATE TABLE low_stock_alerts (
  alert_id INT AUTO_INCREMENT PRIMARY KEY,
  medicine_id INT NOT NULL,
  alert_date DATE DEFAULT (CURRENT_DATE),
  current_stock INT NOT NULL,
  reorder_level INT NOT NULL,
  status ENUM('Open','Resolved') DEFAULT 'Open',
  FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);
INSERT INTO suppliers(supplier_name, phone, gst_no)
VALUES ('Central Medical Store', '9111111111', '00ABCDE1234F1Z5');
SELECT DISTINCT medicine_id FROM prescription_items;
INSERT INTO medicine_batches(medicine_id, supplier_id, batch_code, expiry_date, mrp, purchase_price, quantity_in_stock)
VALUES
(1, 1, 'BATCH001', '2026-12-31', 50.00, 35.00, 200),
(2, 1, 'BATCH002', '2026-11-30', 80.00, 60.00, 150),
(3, 1, 'BATCH003', '2027-03-31', 30.00, 20.00, 300);
SELECT batch_id, medicine_id, batch_code, expiry_date, quantity_in_stock
FROM medicine_batches;
UPDATE prescription_items
SET batch_id = 1
WHERE prescription_id = 1 AND medicine_id = 1;

UPDATE prescription_items
SET batch_id = 2
WHERE prescription_id = 1 AND medicine_id = 2;

UPDATE prescription_items
SET batch_id = 3
WHERE prescription_id = 1 AND medicine_id = 3;