-- Drop existing users to avoid conflicts
BEGIN
    FOR user_rec IN (SELECT username FROM dba_users WHERE username IN ('ADMIN_USER', 'DOC_USER', 'BILL_USER')) LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || user_rec.username || ' CASCADE';
    END LOOP;
END;
/

-- Creating Users with Strong Passwords (At least 12 characters, uppercase, numbers, special characters)
CREATE USER admin_user IDENTIFIED BY "Admin@Secure#1234";
CREATE USER doc_user IDENTIFIED BY "Doctor@Secure#1234";
CREATE USER bill_user IDENTIFIED BY "Billing@Secure#1234";

-- Grant Basic Database Access
GRANT CONNECT, RESOURCE TO admin_user;
GRANT CONNECT, RESOURCE TO doc_user;
GRANT CONNECT, RESOURCE TO bill_user;

-- Grant Admin Permissions
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER TO admin_user;
GRANT CREATE USER, ALTER USER, DROP USER TO admin_user;
GRANT CREATE ROLE, GRANT ANY ROLE TO admin_user;

-- Grant Doctor User Permissions
GRANT CREATE SESSION TO doc_user;
GRANT SELECT, INSERT, UPDATE ON Patient TO doc_user;
GRANT SELECT, INSERT, UPDATE ON Appointment TO doc_user;
GRANT SELECT, INSERT, UPDATE ON MedicalRecord TO doc_user;
GRANT SELECT ON Doctor TO doc_user;

-- Grant Billing User Permissions
GRANT CREATE SESSION TO bill_user;
GRANT SELECT, INSERT, UPDATE ON Billing TO bill_user;
GRANT SELECT ON Billing TO bill_user;

-- Prevent Revoking Unassigned Privileges
DECLARE
    v_count NUMBER;
BEGIN
    -- Check and revoke privilege only if granted
    SELECT COUNT(*) INTO v_count FROM DBA_SYS_PRIVS WHERE GRANTEE = 'DOC_USER' AND PRIVILEGE = 'DROP ANY TABLE';
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'REVOKE DROP ANY TABLE FROM doc_user';
    END IF;

    SELECT COUNT(*) INTO v_count FROM DBA_SYS_PRIVS WHERE GRANTEE = 'BILL_USER' AND PRIVILEGE = 'DROP ANY TABLE';
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'REVOKE DROP ANY TABLE FROM bill_user';
    END IF;
END;
/
