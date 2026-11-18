--creating databases
create database InsurancePolicyDB;
USE InsurancePolicyDB;

--create tables
create table Customers (CustomerID INT PRIMARY KEY,CustomerName VARCHAR(100) NOT NULL,DateOfBirth DATE NOT NULL,City VARCHAR(60));

create table Products ( ProductID INT PRIMARY KEY, ProductName VARCHAR(80) NOT NULL);

create table Agents ( AgentID INT PRIMARY KEY, AgentName VARCHAR(100) NOT NULL);

create table Policies ( PolicyID INT PRIMARY KEY, PolicyNumber VARCHAR(30) NOT NULL UNIQUE, CustomerID INT NOT NULL, ProductID INT NOT NULL, AgentID INT NOT NULL, StartDate DATE NOT NULL, EndDate DATE NOT NULL,
PremiumAmount DECIMAL(12,2) NOT NULL CHECK (PremiumAmount >= 0), PremiumCollected DECIMAL(12,2) NOT NULL CHECK (PremiumCollected >= 0), PolicyStatus VARCHAR(20) NOT NULL, FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID), FOREIGN KEY (ProductID) REFERENCES Products(ProductID), FOREIGN KEY (AgentID) REFERENCES Agents(AgentID));

create table Claims ( ClaimID INT PRIMARY KEY, PolicyID INT NOT NULL, ClaimDate DATE NOT NULL, ClaimAmount DECIMAL(12,2) NOT NULL CHECK (ClaimAmount >= 0), ClaimStatus VARCHAR(20) NOT NULL,
SettlementDate DATE NULL, DamageCategory VARCHAR(60) NOT NULL, FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID));

--inserting values
insert into Customers values
(1,'Arun Kumar','1988-04-12','Coimbatore'),
(2,'Meera Nair','1995-09-23','Chennai'),
(3,'Ravi Shah','1972-02-08','Bengaluru'),
(4,'Divya Menon','2001-06-17','Coimbatore'),
(5,'Karthik Rao','1960-11-30','Chennai'),
(6,'Sara Thomas','1982-01-05','Madurai');

insert into Products values
(1,'Health Plus'),(2,'Motor Secure'),(3,'Home Protect'),(4,'Life Shield');

insert into Agents values
(1,'Anita'),(2,'Bala'),(3,'Charan'),(4,'Deepa'),(5,'Eshan'),(6,'Farah');

insert into Policies values
(101,'HLT-10001',1,1,1,'2025-12-01','2026-12-01',12000,12000,'Active'),
(102,'MTR-10002',1,2,2,'2026-03-01','2027-03-01',8000,8000,'Active'),
(103,'HOM-10003',2,3,1,'2026-01-15','2026-11-25',15000,15000,'Active'),
(104,'LIF-10004',3,4,3,'2024-06-01','2027-06-01',20000,20000,'Active'),
(105,'HLT-10005',4,1,4,'2026-02-01','2026-12-10',10000,10000,'Active'),
(106,'MTR-10006',5,2,2,'2025-11-01','2026-11-20',9000,9000,'Active'),
(107,'HOM-10007',6,3,5,'2026-04-01','2027-04-01',18000,18000,'Active'),
(108,'HLT-10008',2,1,6,'2025-05-01','2026-05-01',11000,11000,'Expired'),
(109,'LIF-10009',5,4,3,'2026-07-01','2027-07-01',25000,25000,'Active'),
(110,'MTR-10010',3,2,4,'2026-08-01','2027-08-01',7000,5000,'Active'),
(111,'HOM-10011',1,3,5,'2026-09-01','2027-09-01',14000,14000,'Active'),
(112,'HLT-10012',6,1,1,'2026-10-01','2027-10-01',13000,13000,'Active');

insert into Claims values
(201,101,'2026-02-10',3000,'Settled','2026-02-20','Medical'),
(202,102,'2026-05-12',2500,'Settled','2026-05-22','Collision'),
(203,103,'2026-10-02',5000,'Approved',NULL,'Fire'),
(204,104,'2026-03-15',7000,'Settled','2026-04-04','Medical'),
(205,105,'2026-08-20',2000,'Rejected',NULL,'Medical'),
(206,106,'2026-11-05',3500,'Under Review',NULL,'Collision'),
(207,107,'2026-06-18',6000,'Settled','2026-07-03','Water Damage'),
(208,109,'2026-09-10',4000,'Approved',NULL,'Medical'),
(209,110,'2026-10-25',1500,'Settled','2026-11-04','Collision'),
(210,111,'2026-11-01',8000,'Under Review',NULL,'Fire');

declare @ReportDate DATE = '2026-11-17';

--Policies expiring in the next 30 days.
select PolicyID, CONCAT(left(PolicyNumber,3),'-*****-',right(PolicyNumber,4)) as MaskedPolicyNumber, EndDate, DATEDIFF(DAY,@ReportDate,EndDate) as DaysToExpiry
from Policies where EndDate >= @ReportDate and EndDate < DATEADD(DAY,31,@ReportDate)
order by EndDate;

-- Premium collected per product.
select pr.ProductName, SUM(po.PremiumCollected) as TotalPremiumCollected from Policies po JOIN Products pr on po.ProductID = pr.ProductID
group by pr.ProductName
order by TotalPremiumCollected desc;

--Customers with more than one active policy.
select c.CustomerID, UPPER(c.CustomerName) as CustomerName, COUNT(*) as ActivePolicyCount from Customers c join Policies p on c.CustomerID = p.CustomerID
where p.PolicyStatus = 'Active'
group by c.CustomerID, c.CustomerName
having COUNT(*) > 1
order by ActivePolicyCount desc;

-- Claim ratio per product: total claim amount divided by premium collected.
with PremiumTotals as ( select ProductID, SUM(PremiumCollected) as PremiumCollected from Policies group by ProductID),
ClaimTotals as ( select p.ProductID, SUM(cl.ClaimAmount) as TotalClaimAmount from Policies p JOIN Claims cl on p.PolicyID = cl.PolicyID group by p.ProductID)
select pr.ProductName, ISNULL(ct.TotalClaimAmount,0) as TotalClaimAmount, pt.PremiumCollected, CAST(100.0 * ISNULL(ct.TotalClaimAmount,0) / NULLIF(pt.PremiumCollected,0) as decimal(8,2)) as ClaimRatioPercent
from Products pr
join PremiumTotals pt on pr.ProductID = pt.ProductID
left join ClaimTotals ct on pr.ProductID = ct.ProductID
order by ClaimRatioPercent desc;

--Policies without claims.
select p.PolicyID, CONCAT(left(p.PolicyNumber,3),'-*****-',right(p.PolicyNumber,4)) as MaskedPolicyNumber, c.CustomerName, pr.ProductName from Policies p
join Customers c on p.CustomerID = c.CustomerID
join Products pr on p.ProductID = pr.ProductID
left join Claims cl on p.PolicyID = cl.PolicyID
where cl.ClaimID is null
order by p.PolicyID;

--Average premium by customer age band.
select case
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 30 then 'Under 30'
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 45 then '30-44'
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 60 then '45-59'
else '60+' end as AgeBand,
CAST(AVG(p.PremiumAmount) as decimal(10,2)) as AveragePremium
from Policies p join Customers c on p.CustomerID = c.CustomerID
group by case
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 30 then 'Under 30'
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 45 then '30-44'
when DATEDIFF(YEAR,c.DateOfBirth,@ReportDate) - case when DATEADD(YEAR,DATEDIFF(YEAR,c.DateOfBirth,@ReportDate),c.DateOfBirth) > @ReportDate then 1 else 0 end < 60 then '45-59'
else '60+' end
order by AgeBand;

--Monthly new policies.
select FORMAT(StartDate,'yyyy-MM') as PolicyMonth, COUNT(*) as NewPolicyCount from Policies
group by FORMAT(StartDate,'yyyy-MM') order by PolicyMonth;

--Top five agents by premium collected.
select top 5 a.AgentName, SUM(p.PremiumCollected) as TotalPremiumCollected
from Agents a join Policies p on a.AgentID = p.AgentID
group by a.AgentID, a.AgentName
order by TotalPremiumCollected desc, a.AgentName;

--Policy
select PolicyID,
CONCAT(left(PolicyNumber,3),'-*****-',right(PolicyNumber,4)) as MaskedPolicyNumber,
DATEDIFF(DAY,StartDate,@ReportDate) as PolicyAgeDays,
case
when DATEDIFF(DAY,StartDate,@ReportDate) < 365 then 'Less than 1 year'
when DATEDIFF(DAY,StartDate,@ReportDate) < 1095 then '1-2 years'
else '3+ years'
end as PolicyAgeBand
from Policies order by PolicyID;
