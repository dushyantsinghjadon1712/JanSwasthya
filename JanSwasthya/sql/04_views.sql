CREATE VIEW vw_daily_department_load AS
SELECT
  v.visit_date,
  d.name AS department,
  COUNT(*) AS total_patients
FROM visits v
JOIN departments d ON v.department_id = d.department_id
GROUP BY v.visit_date, d.name;
SELECT * FROM vw_daily_department_load ORDER BY visit_date DESC;
CREATE VIEW vw_doctor_workload AS
SELECT
  v.visit_date,
  doc.doctor_name,
  dept.name AS department,
  COUNT(*) AS total_visits
FROM visits v
JOIN doctors doc ON v.doctor_id = doc.doctor_id
JOIN departments dept ON v.department_id = dept.department_id
GROUP BY v.visit_date, doc.doctor_name, dept.name;
SELECT * FROM vw_doctor_workload ORDER BY total_visits DESC;
CREATE VIEW vw_low_stock_open AS
SELECT
  a.alert_id,
  m.generic_name,
  m.dosage_form,
  m.strength,
  a.current_stock,
  a.reorder_level,
  a.alert_date,
  a.status
FROM low_stock_alerts a
JOIN medicines m ON a.medicine_id = m.medicine_id
WHERE a.status = 'Open';
SELECT * FROM vw_low_stock_open ORDER BY alert_date DESC;
CREATE VIEW vw_expiring_batches_60days AS
SELECT
  b.batch_id,
  m.generic_name,
  m.dosage_form,
  m.strength,
  b.batch_code,
  b.expiry_date,
  b.quantity_in_stock
FROM medicine_batches b
JOIN medicines m ON b.medicine_id = m.medicine_id
WHERE b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 60 DAY)
ORDER BY b.expiry_date;
SELECT * FROM vw_expiring_batches_60days;
CREATE VIEW vw_top_prescribed_medicines AS
SELECT
  m.generic_name,
  m.dosage_form,
  m.strength,
  COUNT(*) AS times_prescribed,
  SUM(pi.quantity) AS total_quantity_prescribed
FROM prescription_items pi
JOIN medicines m ON pi.medicine_id = m.medicine_id
GROUP BY m.generic_name, m.dosage_form, m.strength
ORDER BY times_prescribed DESC
LIMIT 10;
SELECT * FROM vw_top_prescribed_medicines;
SELECT
  v.visit_date,
  pt.full_name AS patient_name,
  doc.doctor_name,
  dept.name AS department,
  v.symptoms,
  v.diagnosis,
  m.generic_name,
  m.dosage_form,
  m.strength,
  pi.dosage,
  pi.duration_days,
  pi.quantity
FROM visits v
JOIN patients pt ON v.patient_id = pt.patient_id
JOIN doctors doc ON v.doctor_id = doc.doctor_id
JOIN departments dept ON v.department_id = dept.department_id
JOIN prescriptions p ON v.visit_id = p.visit_id
JOIN prescription_items pi ON p.prescription_id = pi.prescription_id
JOIN medicines m ON pi.medicine_id = m.medicine_id
ORDER BY v.visit_date DESC;