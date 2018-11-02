-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
???????
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM chinook.Employee;
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM chinook.Employee WHERE chinook.Employee.lastname='King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM chinook.Employee WHERE chinook.Employee.firstname='Andrew'
	AND chinook.Employee.reportsto IS NULL;

-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM chinook.album ORDER BY chinook.album.title DESC;

-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT chinook.customer.firstname FROM chinook.customer ORDER BY chinook.customer.city ASC;

-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO chinook.genre (genreid, name) VALUES (30, 'Future');
INSERT INTO chinook.genre (genreid, name) VALUES (31, 'Other');
-- Task – Insert two new records into Employee table
INSERT INTO chinook.employee (employeeid, lastname, firstname, title, reportsto, 
			 birthdate, hiredate, address, city,state, country, postalcode, 
			phone, fax, email) 
			VALUES (11, 'Woo', 'John', 'IT Staff', 6,'1989-06-01 00:00:00',
					'2003-06-01 00:00:00','500 BC Blvd','Vancouver','BC',
					'Canada','T5H 1Z9','525-874-0962','525-876-2344','JohnW@chinookcorp.com');

INSERT INTO chinook.employee (employeeid, lastname, firstname, title, reportsto, 
			 birthdate, hiredate, address, city,state, country, postalcode, 
			phone, fax, email) 
			VALUES (12, 'Kimmel', 'Jimmy', 'IT Staff', 6,'1969-01-27 00:00:00',
					'2001-10-15 00:00:00','620 BC Blvd','Vancouver','BC',
					'Canada','T6I 8Q3','525-860-2358','525-860-1960','JimmyK@chinookcopr.com');
-- Task – Insert two new records into Customer table
INSERT INTO chinook.customer (customerid, firstname, lastname, company,address, 
							  city,state, country, postalcode, phone, fax,email, supportrepid) 
			VALUES (70, 'Eddie', 'Brock', 'Venom Labels','500 Reno Blvd','Reno','NV',
					'USA','45795','525-874-0962','525-876-2344','venom@venom.com',5);

INSERT INTO chinook.customer (customerid, firstname, lastname, company,address, 
							  city,state, country, postalcode, phone, fax,email, supportrepid) 
			VALUES (71, 'Peter', 'Parker', NULL,'500 NYSQ Blvd','New York','NY',
					'USA','85736','780-725-9864','721-875-5431','spider@spider.com',2);
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE chinook.customer set firstname='Robert', lastname='Walter' 
WHERE firstname='Aaron'
AND lastname='Mitchell';
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE chinook.artist set name='CCR'
WHERE name='Creedence Clearwater Revival';
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM chinook.invoice WHERE billingaddress LIKE 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM chinook.invoice WHERE total BETWEEN 15 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM chinook.employee WHERE hiredate BETWEEN '2003-06-01 00:00:01' AND '2004-03-01 23:59:59';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
set schema 'chinook';
alter table invoice
drop constraint fk_invoicecustomerid;

alter table invoice
add constraint fk_invoicecustomerid
foreign key (customerid)
references customer (customerid)
on delete cascade;

alter table invoiceline
drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
add constraint fk_invoicelineinvoiceid
foreign key (invoiceid)
references invoice (invoiceid)
on delete cascade;

DELETE FROM customer WHERE firstname ='Robert' AND lastname='Walter';

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION getTime()
RETURNS TEXT as $$
BEGIN
	RETURN CURRENT_TIME;
END;
$$ LANGUAGE plpgsql;


-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION mediaLength(media_id INTEGER)
RETURNS INTEGER AS $$
DECLARE 
	mediaTypeRet TEXT;
BEGIN
	SELECT name INTO mediaTypeRet FROM mediatype WHERE mediatypeid = media_id;
	RETURN LENGTH(mediaTypeRet);
END
$$ LANGUAGE plpgsql;

-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION getInvoiceAvg()
RETURNS NUMERIC AS $$
BEGIN
	RETURN (SELECT AVG(total) FROM invoice);
END
$$ LANGUAGE plpgsql;
-- Task – Create a function that returns the most expensive track   
CREATE OR REPLACE FUNCTION getMaxTrackPrice()
RETURNS TABLE (
	name VARCHAR(200),
	unitprice NUMERIC(10,2)
) AS $$
BEGIN
	RETURN QUERY SELECT track.name, track.unitprice FROM chinook.track 
	WHERE chinook.track.unitprice = (SELECT MAX(track.unitprice) FROM chinook.track);
END
$$ LANGUAGE plpgsql;
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION getAvgInvoicePrice()
RETURNS NUMERIC AS $$
BEGIN
	RETURN (SELECT AVG(unitprice) FROM invoiceline);
END;
$$ LANGUAGE plpgsql;
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
set schema 'chinook';
CREATE OR REPLACE FUNCTION getGreaterThan1968()
RETURNS TABLE (
	employeeid INTEGER,
	lastname VARCHAR(20),
	firstname VARCHAR(20),
	title VARCHAR(30),
	reportsto INTEGER,
	birthdate TIMESTAMP,
	hiredate TIMESTAMP,
	address VARCHAR(70),
	city VARCHAR(40),
	state VARCHAR(40),
	country VARCHAR(40),
	postalcode VARCHAR(10),
	phone VARCHAR(24),
	fax VARCHAR(24),
	email VARCHAR(60)
) AS $$
BEGIN
	RETURN QUERY SELECT * FROM EMPLOYEE WHERE (SELECT EXTRACT(YEAR FROM EMPLOYEE.birthdate))>1968;
END;
$$ LANGUAGE plpgsql;
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
set schema 'chinook';
CREATE OR REPLACE FUNCTION getFirstAndLast()
RETURNS TABLE (
	firstname VARCHAR(60),
	lastname VARCHAR(60)
) AS $$
BEGIN
	RETURN QUERY SELECT employee.firstname, employee.lastname FROM EMPLOYEE;
END;
$$ LANGUAGE plpgsql;
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
set schema 'chinook';
CREATE OR REPLACE FUNCTION updateEmployee(nEmployeeId INT, oEmployeeId INT,
    nLastName TEXT,
    nFirstName TEXT,
    nTitle TEXT,
    nReportsTo INT,
    nBirthDate TIMESTAMP,
    nHireDate TIMESTAMP,
    nAddress TEXT,
    nCity TEXT,
    nState TEXT,
    nCountry TEXT,
    nPostalCode TEXT,
    nPhone TEXT,
    nFax TEXT,
    nEmail TEXT)
RETURNS void AS $$
BEGIN
	UPDATE Employee
	SET employeeid = nemployeeid, lastname = nlastname, 
		firstname = nfirstname, title = ntitle, reportsto = nreportsto,
		birthdate = nbirthdate, hiredate  = nhiredate, address = naddress, city = ncity,
		state = nstate, country = ncountry, postalcode = npostalcode, phone = nphone,
		fax = nfax, email = nemail
	WHERE employeeid = oemployeeid;
END;
$$ LANGUAGE plpgsql;


-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION getManager(name TEXT)
RETURNS TABLE (
	firstname VARCHAR(60),
	lastname VARCHAR(60)
) AS $$
BEGIN
	RETURN QUERY (SELECT employee.lastname, employee.firstname FROM employee 
			WHERE employeeid = (SELECT employee.reportsto FROM employee WHERE employee.lastname = name));
END;
$$ LANGUAGE plpgsql;
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
set schema 'chinook';
CREATE OR REPLACE FUNCTION getNameAndComp(id INTEGER)
RETURNS TABLE (
	firstname VARCHAR(60),
	lastname VARCHAR(60),
	company VARCHAR(60)
) AS $$
BEGIN
	RETURN QUERY SELECT customer.firstname, customer.lastname, customer.company FROM customer WHERE customer.customerid = id;
END;
$$ LANGUAGE plpgsql;
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
set schema 'chinook';
alter table invoice
drop constraint fk_invoicecustomerid;

alter table invoice
add constraint fk_invoicecustomerid
foreign key (customerid)
references customer (customerid)
on delete cascade;

alter table invoiceline
drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
add constraint fk_invoicelineinvoiceid
foreign key (invoiceid)
references invoice (invoiceid)
on delete cascade;
CREATE OR REPLACE FUNCTION removeInvoice(id INTEGER)
RETURNS void AS $$
BEGIN
	DELETE FROM invoice WHERE invoice.invoiceid = id;
END;
$$ LANGUAGE plpgsql;

-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
set schema 'chinook';
CREATE OR REPLACE FUNCTION insertEmployee(nEmployeeId INT,
    nLastName TEXT,
    nFirstName TEXT,
    nTitle TEXT,
    nReportsTo INT,
    nBirthDate TIMESTAMP,
    nHireDate TIMESTAMP,
    nAddress TEXT,
    nCity TEXT,
    nState TEXT,
    nCountry TEXT,
    nPostalCode TEXT,
    nPhone TEXT,
    nFax TEXT,
    nEmail TEXT)
RETURNS void AS $$
BEGIN
	INSERT INTO Employee (employeeid, lastname, firstname, title
						  reportsto, birthdate, hiredate, address, city, 
						  state, country, postalcode,phone,fax,email)
	VALUES (nemployeeid, nlastname, nfirstname, ntitle
						  nreportsto, nbirthdate, nhiredate, naddress, ncity, 
						  nstate, ncountry, npostalcode,nphone,nfax,nemail);
END;
$$ LANGUAGE plpgsql;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE TRIGGER after_employee_trig
AFTER INSERT ON employee
FOR EACH ROW
EXECUTE PROCEDURE after_employee_trig_function();

CREATE OR REPLACE FUNCTION after_employee_trig_function()
RETURNS TRIGGER AS $$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		INSERT INTO employee (
			new_employeeid,
			new_lastname,
			new_firstname,
			new_title,
			new_reportsto,
			new_birthdate,
			new_hiredate,
			new_address,
			new_city,
			new_state,
			new_country,
			new_postalcode,
			new_phone,
			new_fax,
			new_email
		) VALUES (
			NEW.employeeid,
			NEW.lastname,
			NEW.firstname,
			NEW.title,
			NEW.reportsto,
			NEW.birthdate,
			NEW.hiredate,
			NEW.address,
			NEW.city,
			NEW.state,
			NEW.country,
			NEW.postalcode,
			NEW.phone,
			NEW.fax,
			NEW.email
		);
	END IF;
	RETURN NEW; -- return new so that it will put the data into the users table still
END;
$$ LANGUAGE plpgsql;
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE TRIGGER after_album_trig
AFTER UPDATE ON album
FOR EACH ROW
EXECUTE PROCEDURE after_album_trig_function();

CREATE OR REPLACE FUNCTION after_album_trig_function()
RETURNS TRIGGER AS $$
BEGIN
	IF(TG_OP = 'UPDATE') THEN
		INSERT INTO album (
			old_albumid,
			old_title,
			old_artistid,
			new_albumid,
			new_title,
			new_artistid
		) VALUES (
			OLD.albumid,
			OLD.title,
			OLD.artistid,
			NEW.albumid,
			NEW.title,
			NEW.artistid
		);
	END IF;
	RETURN NEW; -- return new so that it will put the data into the users table still
END;
$$ LANGUAGE plpgsql;
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TRIGGER after_customer_trig
AFTER DELETE ON customer
FOR EACH ROW
EXECUTE PROCEDURE after_customer_trig_function();

CREATE OR REPLACE FUNCTION after_customer_trig_function()
RETURNS TRIGGER AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		INSERT INTO customer (
			old_customerid,
			old_firstname,
			old_lastname,
			old_company,
			old_address,
			old_city,
			old_state,
			old_country,
			old_postalcode,
			old_customerid,
			old_phone,
			old_fax,
			old_email,
			old_supportrepid
		) VALUES (
			OLD.customerid,
			OLD.firtsname,
			OLD.lastname,
			OLD.company,
			OLD.address,
			OLD.city,
			OLD.state,
			OLD.country,
			OLD.postalcode,
			OLD.phone,
			OLD.fax,
			OLD.email,
			OLD.supportrepid
		);
	END IF;
	RETURN NEW; -- return new so that it will put the data into the users table still
END;
$$ LANGUAGE plpgsql;
-- 6.2 Before
-- Task – Create a before trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE TRIGGER before_restric_trig
BEFORE DELETE ON customer
FOR EACH ROW
EXECUTE PROCEDURE before_restric_trig_function();

CREATE OR REPLACE FUNCTION before_restric_trig_function()
RETURNS TRIGGER AS $$
BEGIN 
	IF (NEW.total < 50) THEN
		DELETE FROM  invoice WHERE OLD.invoiceid = NEW.invoiceid;
	END IF;
	IF (NEW.TOTAL >=50) THEN
		INSERT INTO invoice (invoiceid, customerid, invoicedate, billingaddress,
						billingcity, billingstate, billingcountry, billingpostalcode,
						total) VALUES (OLD.invoiceid, OLD.customerid, OLD.invoicedate,
									  OLD.billingaddress, OLD.billingcity, OLD.billingstate,
									  OLD.billingcountry, OLD.billingpostalcode, OLD.total);
	END IF;
	RETURN NEW; -- return new so that it will put the data into the users table still
END;
$$ LANGUAGE plpgsql;
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT customer.lastname, customer.firstname, invoice.invoiceid 
FROM customer INNER JOIN invoice ON customer.customerid = invoice.customerid;
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, customer.lastname, customer.firstname, invoice.invoiceid, invoice.total 
FROM customer FULL OUTER JOIN invoice ON customer.customerid = invoice.customerid;
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title
FROM artist RIGHT JOIN album ON artist.artistid = album.artistid;
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM artist CROSS JOIN album ORDER BY artist.name ASC;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM employee e1, employee e2 WHERE e1.reportsto = e2.reportsto;