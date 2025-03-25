

-- SECTION A: General Views
-- ---------------------------

-- View: Doctor Availability (Visible to all roles)
CREATE OR REPLACE VIEW Doctor_Availability AS
SELECT DoctorID, FirstName, LastName, Specialization, Availability
FROM Doctor;

-- View: Patient Visit Summary (Admin only)
CREATE OR REPLACE VIEW Patient_Visit_Summary AS
SELECT V.VisitID, P.FirstName || ' ' || P.LastName AS PatientName,
       D.FirstName || ' ' || D.LastName AS DoctorName,
       V.VisitDate, V.VisitReason, V.VisitStatus
FROM Visit V
JOIN Patient P ON V.PatientID = P.PatientID
JOIN Doctor D ON V.DoctorID = D.DoctorID;

-- View: Billing Insights (Admin only)
CREATE OR REPLACE VIEW Billing_Insights AS
SELECT B.BillID, P.FirstName || ' ' || P.LastName AS PatientName,
       V.VisitDate, B.TotalAmount, B.PaymentStatus
FROM Billing B
JOIN Visit V ON B.VisitID = V.VisitID
JOIN Patient P ON B.PatientID = P.PatientID;

