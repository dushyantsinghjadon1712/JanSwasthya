CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(60) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Receptionist','Doctor','Pharmacist','Admin') NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELETE FROM users WHERE username='admin';
INSERT INTO users(full_name, username, password_hash, role)
VALUES (
  'System Admin',
  'admin',
  'scrypt:32768:8:1$ewO69v8EoPUxr5i0$3251eee6e13dd84952f18a581be807192e3ee7fa48d241f83abae4e0531b1778aaa00cafa78f44af100e05b901859a67a3aae680cd2e0c86117ada468a9e538a',
  'Admin'
);
