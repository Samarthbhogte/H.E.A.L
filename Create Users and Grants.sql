-- to enable DBMS_OUTPUT for logging messages
SET SERVEROUTPUT ON;

-------------------------------------------------------------
-- SECTION 1: for droping Existing Users (if they exist)
-------------------------------------------------------------
BEGIN
    FOR user_rec IN (SELECT username FROM dba_users 
                     WHERE username IN ('ADMIN_USER', 'DOC_USER', 'BILL_USER')) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || user_rec.username || ' CASCADE';
            DBMS_OUTPUT.PUT_LINE('Dropped user: ' || user_rec.username);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error dropping user ' || user_rec.username || ': ' || SQLERRM);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in dropping users block: ' || SQLERRM);
END;
/

-------------------------------------------------------------
-- SECTION 2: Create Users with Strong Passwords
-------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'CREATE USER ADMIN_USER IDENTIFIED BY "Admin@Secure#1234"';
    DBMS_OUTPUT.PUT_LINE('Created user: ADMIN_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating ADMIN_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE USER DOC_USER IDENTIFIED BY "Doctor@Secure#1234"';
    DBMS_OUTPUT.PUT_LINE('Created user: DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating DOC_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE USER BILL_USER IDENTIFIED BY "Billing@Secure#1234"';
    DBMS_OUTPUT.PUT_LINE('Created user: BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating BILL_USER: ' || SQLERRM);
END;
/
-------------------------------------------------------------
-- SECTION 3: Grant Basic Database Access (CONNECT, RESOURCE)
-------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO ADMIN_USER';
    DBMS_OUTPUT.PUT_LINE('Granted CONNECT, RESOURCE to ADMIN_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting CONNECT, RESOURCE to ADMIN_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO DOC_USER';
    DBMS_OUTPUT.PUT_LINE('Granted CONNECT, RESOURCE to DOC_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting CONNECT, RESOURCE to DOC_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO BILL_USER';
    DBMS_OUTPUT.PUT_LINE('Granted CONNECT, RESOURCE to BILL_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting CONNECT, RESOURCE to BILL_USER: ' || SQLERRM);
END;
/

-------------------------------------------------------------
-- SECTION 4: Grant Administrative Privileges to ADMIN_USER
-------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER TO ADMIN_USER';
    DBMS_OUTPUT.PUT_LINE('Granted DDL privileges to ADMIN_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting DDL privileges to ADMIN_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE USER, ALTER USER, DROP USER TO ADMIN_USER';
    DBMS_OUTPUT.PUT_LINE('Granted user management privileges to ADMIN_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting user management privileges to ADMIN_USER: ' || SQLERRM);
END;
/

BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE ROLE, GRANT ANY ROLE TO ADMIN_USER';
    DBMS_OUTPUT.PUT_LINE('Granted role management privileges to ADMIN_USER');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error granting role management privileges to ADMIN_USER: ' || SQLERRM);
END;
/

ALTER USER admin_user QUOTA UNLIMITED ON DATA;
GRANT CREATE PUBLIC SYNONYM TO ADMIN_USER;
