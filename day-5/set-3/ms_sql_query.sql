
-- Create database
create database HospitalDB;

use HospitalDB;

-- Create tables
create table Patient (PatientID INT IDENTITY(1,1) PRIMARY KEY, PatientName VARCHAR(100) NOT NULL, Address VARCHAR(200) NOT NULL, Phone VARCHAR(15) NOT NULL UNIQUE, Email VARCHAR(100) UNIQUE);

create table Department (DepartmentID INT IDENTITY(1,1) PRIMARY KEY, DepartmentName VARCHAR(100) NOT NULL UNIQUE);

create table Doctor (DoctorID INT IDENTITY(1,1) PRIMARY KEY, DoctorName VARCHAR(100) NOT NULL, Specialization VARCHAR(100) NOT NULL, DepartmentID INT NOT NULL, CONSTRAINT FK_Doctor_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID) ON UPDATE CASCADE ON DELETE NO ACTION);

create table Visit (VisitID INT IDENTITY(1,1) PRIMARY KEY, PatientID INT NOT NULL, DoctorID INT NOT NULL, VisitDate DATE NOT NULL DEFAULT GETDATE(), Diagnosis VARCHAR(200) NOT NULL, Prescription VARCHAR(300), Status VARCHAR(20) NOT NULL DEFAULT 'Open', CONSTRAINT CK_Visit_Date CHECK (VisitDate >= '19000101' AND VisitDate <= '21001231'), CONSTRAINT CK_Visit_Status CHECK (Status IN ('Open','Closed','Cancelled')), CONSTRAINT FK_Visit_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON UPDATE CASCADE ON DELETE NO ACTION, CONSTRAINT FK_Visit_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON UPDATE CASCADE ON DELETE NO ACTION);

create table Billing (BillingID INT IDENTITY(1,1) PRIMARY KEY, VisitID INT NOT NULL UNIQUE, BillAmount DECIMAL(12,2) NOT NULL DEFAULT 0, PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Pending', CONSTRAINT CK_Billing_Amount CHECK (BillAmount >= 0), CONSTRAINT CK_Billing_PaymentStatus CHECK (PaymentStatus IN ('Pending','Paid','Partially Paid')), CONSTRAINT FK_Billing_Visit FOREIGN KEY (VisitID) REFERENCES Visit(VisitID) ON UPDATE CASCADE ON DELETE NO ACTION);

--alter tables
alter table Patient ADD insurance_id VARCHAR(30);

alter table Patient ADD CONSTRAINT CK_Patient_Insurance CHECK (insurance_id IS NULL OR LEN(insurance_id) >= 4);

exec sp_rename 'Department', 'HospitalDepartment';

alter table Patient DROP CONSTRAINT CK_Patient_Insurance;


-- Inserting values
insert into Patient (PatientName, Address, Phone, Email, insurance_id) values ('Arun Kumar','Gandhipuram, Coimbatore','9000000001','arun@gmail.com','INS001'),('Priya Sharma','RS Puram, Coimbatore','9000000002','priya@gmail.com','INS002'),('Rahul Verma','Anna Nagar, Chennai','9000000003','rahul@gmail.com','INS003'),('Sneha Reddy','Adyar, Chennai','9000000004','sneha@gmail.com','INS004'),('Karthik Raj','Whitefield, Bangalore','9000000005','karthik@gmail.com','INS005'),('Divya Nair','Kakkanad, Kochi','9000000006','divya@gmail.com','INS006'),('Vijay Kumar','Banjara Hills, Hyderabad','9000000007','vijay@gmail.com','INS007'),('Ananya Das','Andheri, Mumbai','9000000008','ananya@gmail.com','INS008'),('Manoj Singh','Camp, Pune','9000000009','manoj@gmail.com','INS009'),('Meera Iyer','KK Nagar, Trichy','9000000010','meera@gmail.com','INS010');

insert into HospitalDepartment (DepartmentName) values ('Cardiology'),('Neurology'),('Orthopedics'),('Pediatrics'),('Dermatology'),('ENT'),('Oncology'),('General Medicine'),('Gynecology'),('Psychiatry');

insert into Doctor (DoctorName, Specialization, DepartmentID) values ('Dr. Suresh','Heart Specialist',1),('Dr. Priya','Neurologist',2),('Dr. Kumar','Orthopedic Surgeon',3),('Dr. Divya','Child Specialist',4),('Dr. Arun','Skin Specialist',5),('Dr. Meena','ENT Specialist',6),('Dr. Raj','Cancer Specialist',7),('Dr. Lakshmi','General Physician',8),('Dr. Anitha','Gynecologist',9),('Dr. Ravi','Psychiatrist',10);

insert into Visit (PatientID, DoctorID, VisitDate, Diagnosis, Prescription, Status) values (1,1,'2026-10-05','High Blood Pressure','Blood pressure medication','Closed'),(2,2,'2026-10-08','Migraine','Pain relief medication','Closed'),(3,3,'2026-10-12','Knee Pain','Physiotherapy','Open'),(4,4,'2026-10-15','Fever','Paracetamol','Closed'),(5,5,'2026-10-20','Skin Allergy','Antihistamine','Open'),(6,6,'2026-09-10','Ear Infection','Ear drops','Closed'),(7,7,'2026-09-15','Tumor Screening','Further tests required','Open'),(8,8,'2026-10-22','Common Cold','Cough syrup','Closed'),(9,9,'2026-11-02','Hormonal Imbalance','Medication prescribed','Open'),(10,10,'2026-11-05','Anxiety','Counselling','Open');

insert into Billing (VisitID, BillAmount, PaymentStatus) values (1,2500,'Paid'),(2,1800,'Paid'),(3,3000,'Pending'),(4,800,'Paid'),(5,1500,'Pending'),(6,2200,'Paid'),(7,5000,'Pending'),(8,700,'Paid'),(9,3500,'Pending'),(10,2000,'Paid');

select * from Patient;
select * from HospitalDepartment;
select * from Doctor;
select * from Visit;
select * from Billing;

select 'Patient' as TableName, COUNT(*) as TotalRecords from Patient union all select 'HospitalDepartment', COUNT(*) from HospitalDepartment union all select 'Doctor', COUNT(*) from Doctor union all select 'Visit', COUNT(*) from Visit union all select 'Billing', COUNT(*) from Billing;

--update and delete

update Patient set Address = 'Peelamedu, Coimbatore' where PatientID = 1;

select * from Patient where PatientID = 1;

select * from Visit where VisitID = 10;

delete from Billing where VisitID = 10;
delete from Visit where VisitID = 10;

select * from Visit where VisitID = 10;

--like and where queries
select p.PatientID, p.PatientName, v.VisitDate, v.Diagnosis from Patient p join Visit v on p.PatientID = v.PatientID where v.VisitDate >= '2026-10-01' and v.VisitDate < '2026-11-01';

select d.DoctorID, d.DoctorName, d.Specialization, h.DepartmentName from Doctor d join HospitalDepartment h on d.DepartmentID = h.DepartmentID where h.DepartmentName like '%Cardio%';

select * from Doctor where DoctorName like 'Dr. S%';



/*
NORMALISATION:

1NF:
All columns contain atomic values. Each visit is represented by a separate record.

2NF:
All tables use single-column primary keys except where a composite key is needed. Each non-key attribute depends on its complete key.

3NF:
Patient details are separated into Patient, doctor details into Doctor, department details into HospitalDepartment, visit information into Visit and billing information into Billing. This removes transitive dependencies.

DECOMPOSITION:
Patient and address are separated from visit information.
Doctor and specialization are separated from visit information.
Department information is separated from Doctor.
Billing information is separated from Visit.
Clinical notes with variable structures are stored in MongoDB.

ASSUMPTIONS:
1. Each visit belongs to exactly one patient and one doctor.
2. Each visit has at most one billing record.
3. A patient may have multiple visits, and a doctor may handle multiple visits.
*/
