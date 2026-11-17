--create database
create database BankBranchDB;

use BankBranchDB;

--create tables

create table Branch (BranchID INT IDENTITY(1,1) PRIMARY KEY, BranchCode VARCHAR(10) NOT NULL UNIQUE, BranchName VARCHAR(100) NOT NULL, City VARCHAR(50) NOT NULL);

create table Customer (CustomerID INT IDENTITY(1,1) PRIMARY KEY, CustomerName VARCHAR(100) NOT NULL, Address VARCHAR(200) NOT NULL, Phone VARCHAR(15) NOT NULL UNIQUE, Email VARCHAR(100) NOT NULL UNIQUE);

create table RelationshipManager (ManagerID INT IDENTITY(1,1) PRIMARY KEY, EmployeeCode VARCHAR(15) NOT NULL UNIQUE, ManagerName VARCHAR(100) NOT NULL, BranchID INT NOT NULL, CONSTRAINT FK_Manager_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON UPDATE CASCADE ON DELETE NO ACTION);

create table Account (AccountID INT IDENTITY(1,1) PRIMARY KEY, AccountNumber VARCHAR(20) NOT NULL UNIQUE, AccountType VARCHAR(20) NOT NULL CHECK (AccountType IN ('Savings','Current','Fixed Deposit')), BranchID INT NOT NULL, ManagerID INT NOT NULL, Balance DECIMAL(15,2) NOT NULL DEFAULT 0, OpenedDate DATE NOT NULL DEFAULT GETDATE(), CONSTRAINT CK_Savings_Balance CHECK (AccountType <> 'Savings' OR Balance >= 0), CONSTRAINT FK_Account_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON UPDATE NO ACTION ON DELETE NO ACTION, CONSTRAINT FK_Account_Manager FOREIGN KEY (ManagerID) REFERENCES RelationshipManager(ManagerID) ON UPDATE NO ACTION ON DELETE NO ACTION);

create table AccountHolder (AccountID INT NOT NULL, CustomerID INT NOT NULL, CONSTRAINT PK_AccountHolder PRIMARY KEY (AccountID, CustomerID), CONSTRAINT FK_Holder_Account FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON UPDATE CASCADE ON DELETE CASCADE, CONSTRAINT FK_Holder_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION);

select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE';

--inserting values

insert into Branch (BranchCode, BranchName, City) values ('BR001','Main Branch','Coimbatore'),('BR002','North Branch','Chennai'),('BR003','East Branch','Bangalore'),('BR004','West Branch','Mumbai'),('BR005','Central Branch','Hyderabad'),('BR006','City Branch','Madurai'),('BR007','Market Branch','Salem'),('BR008','Lake Branch','Kochi'),('BR009','Park Branch','Pune'),('BR010','South Branch','Trichy');

insert into Customer (CustomerName, Address, Phone, Email) values ('Arun Kumar','Gandhipuram, Coimbatore','9000000001','arun@gmail.com'),('Priya Sharma','RS Puram, Coimbatore','9000000002','priya@gmail.com'),('Rahul Verma','Anna Nagar, Chennai','9000000003','rahul@gmail.com'),('Sneha Reddy','Adyar, Chennai','9000000004','sneha@gmail.com'),('Karthik Raj','Whitefield, Bangalore','9000000005','karthik@gmail.com'),('Divya Nair','Kakkanad, Kochi','9000000006','divya@gmail.com'),('Vijay Kumar','Banjara Hills, Hyderabad','9000000007','vijay@gmail.com'),('Ananya Das','Andheri, Mumbai','9000000008','ananya@gmail.com'),('Manoj Singh','Camp, Pune','9000000009','manoj@gmail.com'),('Meera Iyer','KK Nagar, Trichy','9000000010','meera@gmail.com');

insert into RelationshipManager (EmployeeCode, ManagerName, BranchID) values ('EMP001','Suresh Kumar',1),('EMP002','Lakshmi Devi',2),('EMP003','Ramesh Babu',3),('EMP004','Anil Sharma',4),('EMP005','Geetha Rao',5),('EMP006','Prakash Nair',6),('EMP007','Deepak Raj',7),('EMP008','Kavitha Menon',8),('EMP009','Naveen Kumar',9),('EMP010','Shalini Das',10);

insert into RelationshipManager (EmployeeCode, ManagerName, BranchID) values ('EMP001','Suresh Kumar',1),('EMP002','Lakshmi Devi',2),('EMP003','Ramesh Babu',3),('EMP004','Anil Sharma',4),('EMP005','Geetha Rao',5),('EMP006','Prakash Nair',6),('EMP007','Deepak Raj',7),('EMP008','Kavitha Menon',8),('EMP009','Naveen Kumar',9),('EMP010','Shalini Das',10);

insert into Account (AccountNumber, AccountType, BranchID, ManagerID, Balance, OpenedDate) values ('ACC1001','Savings',1,1,25000,'2026-07-05'),('ACC1002','Current',2,2,75000,'2026-07-15'),('ACC1003','Savings',3,3,12000,'2026-08-10'),('ACC1004','Fixed Deposit',4,4,100000,'2026-08-20'),('ACC1005','Savings',5,5,45000,'2026-09-05'),('ACC1006','Current',6,6,8000,'2026-09-15'),('ACC1007','Savings',7,7,3000,'2026-06-10'),('ACC1008','Fixed Deposit',8,8,150000,'2026-05-12'),('ACC1009','Savings',9,9,60000,'2026-10-05'),('ACC1010','Current',10,10,20000,'2026-04-20');

insert into AccountHolder (AccountID, CustomerID) values (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);

select 'Branch' as TableName, COUNT(*) as TotalRecords from Branch union ALL select 'Customer', COUNT(*) from Customer union ALL select 'RelationshipManager', COUNT(*) from RelationshipManager union ALL select 'Account', COUNT(*) from Account union ALL select 'AccountHolder', COUNT(*) from AccountHolder;

--update and delete operations

update Account set Balance = 35000 where AccountNumber = 'ACC1001';

select AccountNumber, AccountType, Balance from Account where AccountNumber = 'ACC1001';

select * from Account where AccountNumber = 'ACC1010';

delete from Account where AccountNumber = 'ACC1010';

select * from Account where AccountNumber = 'ACC1010';

select AccountNumber, AccountType, Balance, OpenedDate from Account where OpenedDate >= '2026-07-01' and OpenedDate < '2026-10-01' and Balance > 10000 and (AccountType in ('Savings','Current','Fixed Deposit') or BranchID between 1 and 5);

--drop,truncate,delete

create table TestOperations (ID INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(50));

insert into TestOperations (Name) values ('Arun'),('Priya'),('Rahul');

select * from TestOperations;

delete from TestOperations where ID = 2;

select * from TestOperations;

insert into TestOperations (Name) values ('Sneha');

select * from TestOperations;

truncate table TestOperations;

select * from TestOperations;

insert into TestOperations (Name) values ('Vijay');

select * from TestOperations;

drop table TestOperations;

select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'TestOperations';

create table RollbackTest (ID INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(50));

insert into RollbackTest (Name) values ('Arun'),('Priya'),('Rahul');

begin transaction;
delete from RollbackTest;
Rollback transaction;
select * from RollbackTest;

begin transaction;
truncate table RollbackTest;
rollback transaction;
select * from RollbackTest;

begin transaction;
drop table RollbackTest;
rollback transaction;
select * from RollbackTest;

drop table RollbackTest;



/*
NORMALISATION:

1NF:
Each column stores atomic values and each record is uniquely identifiable.

2NF:
AccountHolder uses a composite key (AccountID, CustomerID). No non-key attribute depends on only part of this key.

3NF:
Customer, Branch and RelationshipManager information are stored separately. Account stores their foreign keys instead of repeating their details.

BCNF:
Each non-trivial functional dependency has a candidate key as its determinant, assuming the declared unique business identifiers.

CANDIDATE KEYS:
Account: AccountID, AccountNumber.
Branch: BranchID, BranchCode.
Customer: CustomerID, Email, Phone.
RelationshipManager: ManagerID, EmployeeCode.
AccountHolder: (AccountID, CustomerID).

COMPOSITE KEY:
AccountHolder uses AccountID and CustomerID together as its primary key.

ANOMALIES:

INSERT ANOMALY:
A branch manager cannot be stored independently in the original sheet without account information.

UPDATE ANOMALY:
Changing a customer's address requires updating multiple account rows in the original sheet.

DELETE ANOMALY:
Deleting a customer's last account could accidentally remove their only stored customer information.
*/

