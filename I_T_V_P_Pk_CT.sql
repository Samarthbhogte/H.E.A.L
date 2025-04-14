
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



