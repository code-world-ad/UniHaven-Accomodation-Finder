SET ECHO ON;
ALTER TABLE Distance DROP CONSTRAINT Dist_aid;
ALTER TABLE Distance DROP CONSTRAINT Dist_cid;
DROP TABLE Users;
DROP TABLE College;
DROP TABLE Accommodation;
DROP TABLE Distance;
DROP Sequence user_sequence;
Drop Procedure register_user;
Drop Procedure find_colleges_at_location;
Drop Procedure check_login;
DROP Procedure get_accomodations_by_location;

CREATE TABLE Users (
    id INT PRIMARY KEY,
    name VARCHAR(25),
    contact INT,
    email VARCHAR(25),
    password VARCHAR(25),
    college_name VARCHAR(45),
    duration_of_stay NUMBER
);

CREATE TABLE College (
    cid INT PRIMARY KEY,
    name VARCHAR(55),
    location VARCHAR(25)
);

CREATE TABLE Accommodation (
    aid INT PRIMARY KEY,
    name VARCHAR(35),
    address VARCHAR(55),
    price INT,
    amenities VARCHAR(80),
    reviews INT,
    image VARCHAR(100),
    owner VARCHAR(20),
    contact INT
);

CREATE TABLE Distance (
    did INT PRIMARY KEY,
    accommodation_id INT,
    college_id INT,
    distance DECIMAL(10, 2) NOT NULL
);

CREATE SEQUENCE user_sequence START WITH 11;

CREATE OR REPLACE PROCEDURE register_user(
    p_name IN VARCHAR2,
    p_contact IN NUMBER,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2,
    p_college_name IN VARCHAR2,
    p_duration IN NUMBER

) AS
BEGIN
    INSERT INTO users (id, name, contact, email, password, college_name, duration_of_stay)
    VALUES (user_sequence.nextval, p_name, p_contact, p_email, p_password, p_college_name, p_duration);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE find_colleges_at_location(
    p_location IN VARCHAR2,
    p_colleges OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_colleges FOR
    SELECT name
    FROM college
    WHERE location = p_location;
END find_colleges_at_location;
/


CREATE OR REPLACE PROCEDURE check_login(
    p_email IN VARCHAR2,
    p_password IN Varchar2,
    p_login_success OUT NUMBER
)
AS
    v_user_count NUMBER;
BEGIN
    -- Check if the username exists in the users table
    SELECT COUNT(*)
    INTO v_user_count
    FROM users
    WHERE email = p_email and password = p_password;

    -- Set the login success status
    IF v_user_count > 0 THEN
        p_login_success := 1; -- User found, login successful
    ELSE
        p_login_success := 0; -- User not found, login failed
    END IF;
END check_login;
/

CREATE OR REPLACE PROCEDURE get_accommodations_by_location(
    p_location IN VARCHAR2,
    p_accommodations OUT SYS_REFCURSOR
) AS
BEGIN
    -- Open the output cursor
    OPEN p_accommodations FOR
    SELECT *
    FROM accommodation
    WHERE INSTR(address, p_location) > 0;
END get_accommodations_by_location;
/


ALTER TABLE Distance
ADD CONSTRAINT Dist_aid
FOREIGN KEY (accommodation_id) REFERENCES Accommodation(aid);

ALTER TABLE Distance
ADD CONSTRAINT Dist_cid
FOREIGN KEY (college_id) REFERENCES College(cid);

INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (1, 'John Doe', 1234567890, 'john.doe@example.com', 'John*123', 'Indian Institute of Technology Madras', 4);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (2, 'Jane Smith', 9876543210, 'jane.smith@example.com', 'Jane*123', 'anna university', 3);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (3, 'Anitha', 6369898059, 'anitha@example.com', 'Anitha*123', 'madras christian college', 4);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (4, 'Aditi', 8754102009, 'aditi@example.com', 'aditi*123', 'loyola college', 3);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (5, 'Akshiya', 7639482126, 'Akshiya@example.com', 'Akshiya*123', 'stella maris college', 3);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (6, 'Divya', 8838675959, 'Divya@example.com', 'Divya*123', 'madurai kamaraj university', 4);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (7, 'Hemanath', 9360149435, 'Hemanath@example.com', 'Hemanath*123', 'government college of technology', 4);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (8, 'Krish', 8755101009, 'Krish@example.com', 'Krish*123', 'psg college of technology', 3);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (9, 'Maha', 9876543782, 'Maha@example.com', 'Maha*123', 'Indian Institute of Technology Madras', 4);
INSERT INTO Users (id, name, contact, email, password, college_name, duration_of_stay) VALUES (10, 'Nisha', 8838675959, 'Nisha@example.com', 'Nisha*123', 'national institute of technology', 3);



-- Insert data into College table
INSERT INTO College (cid, name, location) VALUES (1, 'indian institute of technology madras', 'Chennai');
INSERT INTO College (cid, name, location) VALUES (2, 'anna university', 'Chennai');
INSERT INTO College (cid, name, location) VALUES (3, 'madras christian college','Chennai' );
INSERT INTO College (cid, name, location) VALUES (4, 'loyola college', 'Chennai');
INSERT INTO College (cid, name, location) VALUES (5, 'stella maris college', 'Chennai');
INSERT INTO College (cid, name, location) VALUES (6, 'national institute of technology', 'Trichy');
INSERT INTO College (cid, name, location) VALUES (7, 'government college of technology', 'Coimbatore');
INSERT INTO College (cid, name, location) VALUES (8, 'psg college of technology', 'Coimbatore');
INSERT INTO College (cid, name, location) VALUES (10,'madurai kamaraj university', 'Madurai');
INSERT INTO College (cid, name, location) VALUES (11,'national college', 'Trichy');
INSERT INTO College (cid, name, location) VALUES (12,'psg institute of management', 'Coimbatore');
INSERT INTO College (cid, name, location) VALUES (13,'psg institute of medical sciences and research', 'Coimbatore');

INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (1, 'Bhimaas', '100, Feet Road, Vadapalani, Chennai', 450, 'wifi, parking, laundry, gym, swimming pool, power back-up', 4, 'under 500 5.jpg', 'Ravi Kumar', '9876543210');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (2, 'Savera', '146, Dr. Radhakrishnan Salai, Mylapore, Chennai', 800, 'wifi, parking, laundry, gym, swimming pool', 3, '500-1000 1.jpg', 'Priya Reddy', '8765432109');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (3, 'The Residency Towers', '115, Sir Thyagaraya Road, T. Nagar, Chennai', 1200, 'wifi, parking, laundry, gym, swimming pool, power back-up', 5, '1000-2000 2.jpg', 'Anil Menon', '7654321098');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (4, 'Grand Chola', 'No. 63, Mount Road, Guindy, Chennai', 6000, 'wifi, laundry, gym, swimming pool, power back-up', 4, '5000+ 7.jpg', 'Sunita Nair', '6543210987');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (5, 'Novotel', '120, St Marys Road, Alwarpet, Chennai', 1800, 'wifi, laundry, gym, swimming pool, power back-up', 5, '1000-2000 1.jpg', 'Rajesh Pillai', '5432109876');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (6, 'Hablis', '19 GST Road, Guindy, Chennai', 300, 'wifi, parking, laundry, gym', 2, 'under 500 4.jpg', 'Meena Iyer', '4321098765');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (7, 'The Westin', '154 Velachery Main Road, Velachery, Chennai', 350, 'wifi, parking, gym, swimming pool', 4, 'under 500 3.jpg', 'Vikas Gopal', '3210987654');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (8, 'Crowne', '132, T.T.K. Road, Alwarpet, Chennai', 2400, 'wifi, parking, gym, swimming pool, power back-up', 5, '2000-3000 4.jpg', 'Neha Ram', '2109876543');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (9, 'The Raintree', '636, Anna Salai, Teynampet, Chennai', 450, 'wifi, laundry, gym, swimming pool', 3, 'under 500 2.jpg', 'Suresh Kumar', '1987654321');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (10, 'The Raintrees', '120, St Marys Road, Alwarpet, Chennai', 1500, 'wifi, laundry, gym, swimming pool', 4, '1000-2000 4.png', 'Arun Babu', '2345678901');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (11, 'Saveras', '146, Dr. Radhakrishnan Salai, Mylapore, Chennai', 2000, 'wifi, parking, laundry, gym, swimming pool', 4, '2000-3000 1.jpg', 'Lakshmi Natarajan', '3456789012');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (12, 'Grand Gardenia', '22-25 Mannarpuram Junction, Trichy', 342, 'wifi, parking, laundry, gym', 3, 'under 500 1.jpg', 'Ganesh Ramachandran', '4567890123');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (13, 'Shaans', 'No.1, Rockins Road, Cantonment, Trichy', 550, 'wifi, parking, laundry, gym', 3, '500-1000 3.jpg', 'Vijay Anand', '5678901234');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (14, 'The Residency', '1076, Avinashi Road, Coimbatore', 3200, 'wifi, parking, laundry, gym, swimming pool', 5, '3000-5000 4.jpg', 'Ramesh Krishnan', '6789012345');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (15, 'Heritage Inn', '73, Sivasamy Road, Ram Nagar, Coimbatore', 1500, 'wifi, parking, laundry, gym', 4, '1000-2000 3.jpg', 'Nithya Mohan', '7890123456');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (16, 'Vivanta Coimbatore', '105, Race Course Road, Coimbatore', 750, 'wifi, parking, laundry, gym', 3, '500-1000 3.jpg', 'Manoj Reddy', '8901234567');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (17, 'Royal Court', '4, West Perumal Maistry Street, Madurai Main, Madurai', 2300, 'wifi, parking, laundry, gym', 4, '2000-3000 2.jpg', 'Srinivas Rao', '9012345678');
INSERT INTO Accommodation (aid, name, address, price, amenities, reviews, image, owner, contact) VALUES (18, 'The Gateway', 'No.40 T.P.K. Road, Pasumalai, Madurai', 3400, 'wifi, parking, laundry, gym', 5, '3000-5000 3.jpg', 'Kavya Iyer', '0123456789');

-- Insert data into Distance table
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (1, 1, 1, 3.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (2, 2, 1, 6);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (3, 3, 1, 7);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (4, 4, 2, 3.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (5, 5, 2, 4);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (6, 6, 3, 3.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (7, 7, 3, 6);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (8, 8, 4, 4);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (9, 9, 4, 5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (10, 10, 5, 1);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (11, 11, 5, 2.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (12, 12, 6, 3);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (13, 13, 6, 2.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (14, 14, 7, 5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (15, 15, 7, 2.5);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (16, 16, 8, 4);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (17, 17,10 , 3);
INSERT INTO Distance (did, accommodation_id, college_id, distance) VALUES (18, 18, 10, 7);


SELECT * FROM Accommodation;
SELECT * FROM Users;
commit;