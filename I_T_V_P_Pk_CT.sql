
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


