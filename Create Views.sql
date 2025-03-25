

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

-- SECTION B: Role-Specific Views
-- ---------------------------

-- View: Doctor-Only Patient Visit Summary
CREATE OR REPLACE VIEW Doctor_Only_Patient_Summary AS
SELECT V.VisitID, P.FirstName || ' ' || P.LastName AS PatientName,
       V.VisitDate, V.VisitReason, V.VisitStatus
FROM Visit V
JOIN Patient P ON V.PatientID = P.PatientID
WHERE V.DoctorID = (SELECT DoctorID FROM Doctor WHERE UserID =
                    (SELECT UserID FROM Users WHERE Username = SYS_CONTEXT('USERENV','SESSION_USER')));

-- View: Billing-Only Insights
CREATE OR REPLACE VIEW Billing_Only_View AS
SELECT B.BillID, P.FirstName || ' ' || P.LastName AS PatientName,
       V.VisitDate, B.TotalAmount, B.PaymentStatus
FROM Billing B
JOIN Visit V ON B.VisitID = V.VisitID
JOIN Patient P ON B.PatientID = P.PatientID;

-- SECTION C: Test Cases for Role Enforcement
-- ---------------------------

-- Test Case: Doctor tries to update Billing (Should fail)
BEGIN
    UPDATE Billing SET TotalAmount = 999.99 WHERE BillID = 'B001';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Doctor cannot update billing – ' || SQLERRM);
END;
/

-- Test Case: Billing Staff tries to SELECT from MedicalRecord (Should fail)
BEGIN
    FOR rec IN (SELECT * FROM MedicalRecord) LOOP
        NULL;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Billing staff not allowed to view medical records – ' || SQLERRM);
END;
/

-- Test Case: Patient tries to insert Visit (Should fail)
BEGIN
    INSERT INTO Visit (VisitID, PatientID, DoctorID, VisitDate, VisitReason, VisitStatus)
    VALUES ('V999', 'P001', 'D001', SYSDATE, 'Unauthorized Visit', 'Pending');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Unauthorized insert into Visit table – ' || SQLERRM);
END;
/

-- Test Case: Doctor tries to delete a user (Should fail)
BEGIN
    DELETE FROM Users WHERE Username = 'admin_user';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Doctor cannot delete users – ' || SQLERRM);
END;
/

-- SECTION D: Constraint Testing
-- ---------------------------

-- Test Case: Insert duplicate email in Patient (Should fail)
BEGIN
    INSERT INTO Patient (PatientID, UserID, FirstName, LastName, DOB, Gender, Email, PhoneNumber, EmergencyContact, CreatedAt)
    VALUES ('P999', 'U001', 'Test', 'Duplicate', SYSDATE, 'Male', 'alice@example.com', '1231231234', 'Test Contact', SYSDATE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Duplicate email not allowed – ' || SQLERRM);
END;
/

-- Test Case: Appointment in the past (Should fail business logic)
BEGIN
    INSERT INTO Appointment (AppointmentID, DoctorID, AppointmentDate, AppointmentStatus)
    VALUES ('A999', 'D001', TO_DATE('2023-01-01','YYYY-MM-DD'), 'Scheduled');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' ERROR CAUGHT: Cannot schedule appointment in the past – ' || SQLERRM);
END;
/

-- SECTION E: Additional Procedures
-- ---------------------------

-- Procedure: Update Visit Status
CREATE OR REPLACE PROCEDURE Update_Visit_Status (
    p_visit_id VARCHAR2,
    p_status   VARCHAR2
) AS
BEGIN
    IF p_status NOT IN ('Pending', 'Completed', 'Canceled') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid visit status.');
    END IF;

    UPDATE Visit
    SET VisitStatus = p_status
    WHERE VisitID = p_visit_id;
END;
/

-- Procedure: Complete Payment
CREATE OR REPLACE PROCEDURE Complete_Payment (
    p_bill_id VARCHAR2
) AS
BEGIN
    UPDATE Billing
    SET PaymentStatus = 'Paid'
    WHERE BillID = p_bill_id;
END;
/
