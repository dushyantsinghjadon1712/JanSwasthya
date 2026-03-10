DELIMITER $$

CREATE TRIGGER trg_update_stock_after_txn
AFTER INSERT ON stock_transactions
FOR EACH ROW
BEGIN
  IF NEW.txn_type = 'IN' THEN
    UPDATE medicine_batches
    SET quantity_in_stock = quantity_in_stock + NEW.qty
    WHERE batch_id = NEW.batch_id;
  ELSEIF NEW.txn_type = 'OUT' THEN
    UPDATE medicine_batches
    SET quantity_in_stock = quantity_in_stock - NEW.qty
    WHERE batch_id = NEW.batch_id;
  END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER trg_low_stock_alert
AFTER UPDATE ON medicine_batches
FOR EACH ROW
BEGIN
  DECLARE total_stock INT;
  DECLARE reorder INT;

  SELECT SUM(quantity_in_stock) INTO total_stock
  FROM medicine_batches
  WHERE medicine_id = NEW.medicine_id;

  SELECT reorder_level INTO reorder
  FROM medicines
  WHERE medicine_id = NEW.medicine_id;

  IF total_stock <= reorder THEN
    INSERT INTO low_stock_alerts (medicine_id, current_stock, reorder_level, status)
    VALUES (NEW.medicine_id, total_stock, reorder, 'Open');
  END IF;
END$$

DELIMITER ;
INSERT INTO stock_transactions(batch_id, txn_type, qty, reference_note)
VALUES
(1, 'OUT', 10, 'Issued to patient prescription_id=1');
SELECT batch_id, batch_code, quantity_in_stock
FROM medicine_batches;
SELECT * FROM stock_transactions;
SELECT * FROM low_stock_alerts ORDER BY alert_id DESC;
DELIMITER $$