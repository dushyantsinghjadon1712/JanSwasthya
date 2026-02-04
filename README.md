# JanSwasthya – OPD & Pharmacy Inventory DBMS (WHO Essential Medicines)

JanSwasthya is a real-world DBMS project designed for government hospitals to digitize OPD workflow, prescriptions, and pharmacy inventory management. It supports batch-wise medicine tracking, stock audit ledger, automatic low-stock alerts, and reporting views.

## Problem
Government hospitals often rely on manual OPD token systems and manual pharmacy stock tracking, leading to long waiting times, missing patient history, and frequent medicine stock-outs.

## Solution
JanSwasthya provides:
- Patient registration
- OPD visit creation + department-wise token issuance
- Doctor consultation + prescription management
- Pharmacy inventory with batch + expiry tracking
- Stock IN/OUT ledger using transactions
- Automatic low stock alerts using triggers
- Hospital admin reports using SQL Views

## Real-World Dataset
- WHO Model List of Essential Medicines (EML) used as the medicine master dataset

## Tech Stack
- MySQL
- MySQL Workbench
- SQL (Procedures, Triggers, Views)

## Key Features
- Auto token issuance (`sp_issue_token`)
- Safe medicine issuing with stock checks (`sp_issue_medicine`)
- Trigger-based inventory updates and low stock alerts
- Views for reporting:
  - Daily department patient load
  - Doctor workload
  - Expiring batches
  - Low stock alerts
  - Top prescribed medicines

## Folder Structure
- `sql/` → schema, triggers, procedures, views
- `docs/` → ERD, normalization, workflow documents
- `dataset/` → WHO medicines CSV
- `screenshots/` → output proofs

## Author
Dushyant Jadon
