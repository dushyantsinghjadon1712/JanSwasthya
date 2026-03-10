DELIMITER $$
CREATE PROCEDURE sp_issue_token (
  IN p_visit_id INT,
  IN p_dept_id INT,
  IN p_token_date DATE
)
BEGIN
  DECLARE next_token INT;

  SELECT IFNULL(MAX(token_no), 0) + 1 INTO next_token
  FROM opd_tokens
  WHERE token_date = p_token_date
    AND department_id = p_dept_id;

  INSERT INTO opd_tokens (visit_id, token_no, token_date, department_id)
  VALUES (p_visit_id, next_token, p_token_date, p_dept_id);
END$$

DELIMITER ;
INSERT INTO visits(patient_id, doctor_id, department_id, visit_date, symptoms)
VALUES (1, 1, 1, CURDATE(), 'Body pain and weakness');
CALL sp_issue_token(5, 1, CURDATE());
SELECT * FROM opd_tokens WHERE department_id=1 AND token_date=CURDATE();
DELIMITER $$

CREATE PROCEDURE sp_issue_medicine (
  IN p_batch_id INT,
  IN p_qty INT,
  IN p_note VARCHAR(255)
)
BEGIN
  DECLARE current_stock INT;

  SELECT quantity_in_stock INTO current_stock
  FROM medicine_batches
  WHERE batch_id = p_batch_id;

  IF current_stock IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid batch_id';
  END IF;

  IF current_stock < p_qty THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient stock';
  ELSE
    INSERT INTO stock_transactions(batch_id, txn_type, qty, reference_note)
    VALUES (p_batch_id, 'OUT', p_qty, p_note);
  END IF;
END$$

DELIMITER ;
CALL sp_issue_medicine(1, 5, 'Issued to OPD patient');
SELECT * FROM stock_transactions ORDER BY txn_id DESC LIMIT 5;
SELECT batch_id, quantity_in_stock FROM medicine_batches WHERE batch_id=1;