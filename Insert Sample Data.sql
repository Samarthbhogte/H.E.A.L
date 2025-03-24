-- DATA for DMDD PROJECT

-- Insert Sample Data for Testing

-- Insert Data for UserRoles
INSERT INTO UserRoles VALUES ('R001', 'Admin');
INSERT INTO UserRoles VALUES ('R002', 'Doctor');
INSERT INTO UserRoles VALUES ('R003', 'BillingStaff');

-- Insert Data for Users
INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U001', 'admin_user', 'hashed_password', 'R001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U002', 'doctor_smith', 'hashed_password', 'R002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U003', 'billing_staff', 'hashed_password', 'R003', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U004', 'doctor_jane', 'hashed_password', 'R002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U005', 'billing_mary', 'hashed_password', 'R003', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Add Users for Patients & New Doctor
INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U006', 'bob_miller', 'hashed_password', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U007', 'emma_wilson', 'hashed_password', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U008', 'michael_johnson', 'hashed_password', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U009', 'sophia_lee', 'hashed_password', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO Users (UserID, Username, PasswordHash, RoleID, CreatedAt, UpdatedAt) 
VALUES ('U010', 'robert_brown', 'hashed_password', 'R002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);