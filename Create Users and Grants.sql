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
