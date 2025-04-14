
------------------------------------------------------------------
--                      INDEXES
------------------------------------------------------------------
-- Drop Queries to drop the indexes 
DROP INDEX ADMIN_USER.idx_appointment_date;
DROP INDEX ADMIN_USER.idx_visit_patient;
DROP INDEX ADMIN_USER.idx_visit_doctor;
DROP INDEX ADMIN_USER.idx_patient_email_phone;
DROP INDEX ADMIN_USER.idx_medicalrecord_patient;


-- Create an index on the Appointment table's AppointmentDate column
CREATE INDEX ADMIN_USER.idx_appointment_date
  ON ADMIN_USER.Appointment(AppointmentDate);
  
-- Create indexes on the Visit table's foreign key columns for faster joins
CREATE INDEX ADMIN_USER.idx_visit_patient
  ON ADMIN_USER.Visit(PatientID);

-- Create an index on the Visit table's DoctorID column for faster joins
CREATE INDEX ADMIN_USER.idx_visit_doctor
  ON ADMIN_USER.Visit(DoctorID);


-- Create a composite index on the Patient table's Email and PhoneNumber columns
-- for faster lookups when querying by both email and phone number together.
CREATE INDEX ADMIN_USER.idx_patient_email_phone
  ON ADMIN_USER.Patient(Email, PhoneNumber);

-- Create an index on the MedicalRecord table's PatientID column for efficient joins
CREATE INDEX ADMIN_USER.idx_medicalrecord_patient
  ON ADMIN_USER.MedicalRecord(PatientID);





----------------------------------------------------------
--    TRIGGERS
----------------------------------------------------------
-- This trigger checks, before any INSERT or UPDATE on the Appointment table, whether the new AppointmentDate is earlier than today (using TRUNC(SYSDATE) to ignore the time component)

CREATE OR REPLACE TRIGGER ADMIN_USER.trg_appointment_date_check
BEFORE INSERT OR UPDATE ON ADMIN_USER.Appointment
FOR EACH ROW
BEGIN
    IF :NEW.AppointmentDate < TRUNC(SYSDATE) THEN
       RAISE_APPLICATION_ERROR(-20001, 'Cannot schedule appointment in the past.');
    END IF;
END;
/

-- Auto-update the "UpdatedAt" Column on the Users Table

CREATE OR REPLACE TRIGGER ADMIN_USER.trg_update_user_timestamp
BEFORE UPDATE ON ADMIN_USER.Users
FOR EACH ROW
BEGIN
    :NEW.UpdatedAt := SYSDATE;
END;
/

--Prevent Deletion of Doctors if They Have Associated Appointments
CREATE OR REPLACE TRIGGER ADMIN_USER.trg_prevent_doctor_delete
BEFORE DELETE ON ADMIN_USER.Doctor
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM ADMIN_USER.Appointment
     WHERE DoctorID = :OLD.DoctorID;
    
    IF v_count > 0 THEN
       RAISE_APPLICATION_ERROR(-20002, 'Cannot delete doctor: appointments exist.');
    END IF;
END;
/








------------------------------------------------------------
-- [VIEW CREATION SECTION] - Run as ADMIN_USER
------------------------------------------------------------


SET SERVEROUTPUT ON;


------------------------------------------------------------------------
-- 1) CREATE OR REPLACE VIEW: Doctor_Availability
--    Allowed: ADMIN_USER, DOC_USER, BILL_USER
--    Others get "Access Denied."
------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW ADMIN_USER.Doctor_Availability AS
        SELECT 
            DoctorID,
            FirstName,
            LastName,
            Specialization,
            Availability
        FROM ADMIN_USER.Doctor
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) 
              IN (''ADMIN_USER'', ''DOC_USER'', ''BILL_USER'')

        UNION ALL

        SELECT 
            ''Access Denied'' AS DoctorID,
            ''Access Denied'' AS FirstName,
            ''Access Denied'' AS LastName,
            ''Access Denied'' AS Specialization,
            ''Access Denied'' AS Availability
        FROM DUAL
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) 
              NOT IN (''ADMIN_USER'', ''DOC_USER'', ''BILL_USER'')
    ';
    DBMS_OUTPUT.PUT_LINE('View ADMIN_USER.Doctor_Availability created.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER.Doctor_Availability: ' || SQLERRM);
END;
/

-- Grant SELECT on Doctor_Availability to DOC_USER and BILL_USER
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Doctor_Availability TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Doctor_Availability to DOC_USER');

    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Doctor_Availability TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Doctor_Availability to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Doctor_Availability: ' || SQLERRM);
END;
/

------------------------------------------------------------------------
-- 2) CREATE OR REPLACE VIEW: Patient_Visit_Summary
--    Allowed: ADMIN_USER, BILL_USER
--    Others get "Access Denied."
------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW ADMIN_USER.Patient_Visit_Summary AS
        SELECT 
            TO_CHAR(V.VisitID) AS VisitID,
            P.FirstName || '' '' || P.LastName AS PatientName,
            D.FirstName || '' '' || D.LastName AS DoctorName,
            TO_CHAR(V.VisitDate, ''YYYY-MM-DD'') AS VisitDate,
            V.VisitReason,
            V.VisitStatus
        FROM ADMIN_USER.Visit V
             JOIN ADMIN_USER.Patient P ON V.PatientID = P.PatientID
             JOIN ADMIN_USER.Doctor D ON V.DoctorID = D.DoctorID
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) 
              IN (''ADMIN_USER'', ''BILL_USER'')

        UNION ALL

        SELECT
            ''Access Denied'' AS VisitID,
            ''Access Denied'' AS PatientName,
            ''Access Denied'' AS DoctorName,
            ''Access Denied'' AS VisitDate,
            ''Access Denied'' AS VisitReason,
            ''Access Denied'' AS VisitStatus
        FROM DUAL
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) 
              NOT IN (''ADMIN_USER'', ''BILL_USER'')
    ';
    DBMS_OUTPUT.PUT_LINE('View ADMIN_USER.Patient_Visit_Summary created.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER.Patient_Visit_Summary: ' || SQLERRM);
END;
/
-- Grant SELECT on Patient_Visit_Summary to both BILL_USER and DOC_USER
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Patient_Visit_Summary TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Patient_Visit_Summary to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Patient_Visit_Summary to BILL_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Patient_Visit_Summary TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Patient_Visit_Summary to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Patient_Visit_Summary to DOC_USER: ' || SQLERRM);
END;
/


------------------------------------------------------------------------
-- 3) CREATE OR REPLACE VIEW: Billing_Insights
--    Allowed: ADMIN_USER only
--    Everyone else gets "Access Denied."
------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW ADMIN_USER.Billing_Insights AS
        SELECT
            TO_CHAR(B.BillID)       AS BillID,
            P.FirstName || '' '' || P.LastName AS PatientName,
            TO_CHAR(V.VisitDate, ''YYYY-MM-DD'') AS VisitDate,
            TO_CHAR(B.TotalAmount)  AS TotalAmount,
            B.PaymentStatus
        FROM ADMIN_USER.Billing B
             JOIN ADMIN_USER.Visit V    ON B.VisitID = V.VisitID
             JOIN ADMIN_USER.Patient P  ON B.PatientID = P.PatientID
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) = ''ADMIN_USER''

        UNION ALL

        SELECT
            ''Access Denied'' AS BillID,
            ''Access Denied'' AS PatientName,
            ''Access Denied'' AS VisitDate,
            ''Access Denied'' AS TotalAmount,
            ''Access Denied'' AS PaymentStatus
        FROM DUAL
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) <> ''ADMIN_USER''
    ';
    DBMS_OUTPUT.PUT_LINE('View ADMIN_USER.Billing_Insights created.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER.Billing_Insights: ' || SQLERRM);
END;
/
-- Grant SELECT on Billing_Insights to BILL_USER (so non-admin users see "Access Denied")
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Billing_Insights TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Billing_Insights to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Billing_Insights to BILL_USER: ' || SQLERRM);
END;
/

------------------------------------------------------------------------
-- 4) CREATE OR REPLACE VIEW: Doctor_Only_Patient_Summary
--    Allowed: DOC_USER only (and optionally ADMIN_USER)
------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW ADMIN_USER.Doctor_Only_Patient_Summary AS
        SELECT 
            TO_CHAR(V.VisitID) AS VisitID,
            P.FirstName || '' '' || P.LastName AS PatientName,
            TO_CHAR(V.VisitDate, ''YYYY-MM-DD'') AS VisitDate,
            V.VisitReason,
            V.VisitStatus
        FROM ADMIN_USER.Visit V
             JOIN ADMIN_USER.Patient P ON V.PatientID = P.PatientID
             JOIN ADMIN_USER.Doctor D ON V.DoctorID = D.DoctorID
             JOIN ADMIN_USER.Users U ON D.UserID = U.UserID
        WHERE UPPER(U.Username) = UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER''))
          AND UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) IN (''DOC_USER'', ''ADMIN_USER'')

        UNION ALL

        SELECT
            ''Access Denied'' AS VisitID,
            ''Access Denied'' AS PatientName,
            ''Access Denied'' AS VisitDate,
            ''Access Denied'' AS VisitReason,
            ''Access Denied'' AS VisitStatus
        FROM DUAL
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) NOT IN (''DOC_USER'', ''ADMIN_USER'')
    ';
    DBMS_OUTPUT.PUT_LINE('View ADMIN_USER.Doctor_Only_Patient_Summary created.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER.Doctor_Only_Patient_Summary: ' || SQLERRM);
END;
/
-- Grant SELECT on Doctor_Only_Patient_Summary to DOC_USER and to BILL_USER (so they can see "Access Denied")
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Doctor_Only_Patient_Summary TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Doctor_Only_Patient_Summary to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Doctor_Only_Patient_Summary to DOC_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Doctor_Only_Patient_Summary TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Doctor_Only_Patient_Summary to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Doctor_Only_Patient_Summary to BILL_USER: ' || SQLERRM);
END;
/
------------------------------------------------------------------------
-- 5) CREATE OR REPLACE VIEW: Billing_Only_View
--    Allowed: BILL_USER only (and optionally ADMIN_USER).
------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE VIEW ADMIN_USER.Billing_Only_View AS
        SELECT 
            TO_CHAR(B.BillID) AS BillID,
            P.FirstName || '' '' || P.LastName AS PatientName,
            TO_CHAR(V.VisitDate, ''YYYY-MM-DD'') AS VisitDate,
            TO_CHAR(B.TotalAmount) AS TotalAmount,
            B.PaymentStatus
        FROM ADMIN_USER.Billing B
             JOIN ADMIN_USER.Visit V   ON B.VisitID = V.VisitID
             JOIN ADMIN_USER.Patient P ON B.PatientID = P.PatientID
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) IN (''BILL_USER'', ''ADMIN_USER'')

        UNION ALL

        SELECT
            ''Access Denied''  AS BillID,
            ''Access Denied''  AS PatientName,
            ''Access Denied''  AS VisitDate,
            ''Access Denied''  AS TotalAmount,
            ''Access Denied''  AS PaymentStatus
        FROM DUAL
        WHERE UPPER(SYS_CONTEXT(''USERENV'', ''SESSION_USER'')) NOT IN (''BILL_USER'', ''ADMIN_USER'')
    ';
    DBMS_OUTPUT.PUT_LINE('View ADMIN_USER.Billing_Only_View created.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER.Billing_Only_View: ' || SQLERRM);
END;
/
-- Grant SELECT on Billing_Only_View to BILL_USER (already granted previously in your code)
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Billing_Only_View TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Billing_Only_View to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Billing_Only_View to BILL_USER: ' || SQLERRM);
END;
/

------------------------------------------------------------
-- [UNDERLYING TABLE PRIVILEGES SECTION]
------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Billing TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Billing to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Billing to DOC_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Visit TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Visit to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Visit to DOC_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Users TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Users to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Users to DOC_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.MedicalRecord TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on MedicalRecord to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on MedicalRecord to BILL_USER: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON ADMIN_USER.Visit TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted SELECT on Visit to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting SELECT on Visit to BILL_USER: ' || SQLERRM);
END;
/