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