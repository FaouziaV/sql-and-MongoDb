--creating databases
create database TelecomBillingDB;
use TelecomBillingDB;

--creating tables
create table Plans ( PlanID INT PRIMARY KEY, PlanName VARCHAR(80) NOT NULL, DataLimitGB DECIMAL(8,2) NOT NULL, MonthlyFee DECIMAL(10,2) NOT NULL);

create table Subscribers ( SubscriberID INT PRIMARY KEY, SubscriberName VARCHAR(100) NOT NULL, PhoneNumber VARCHAR(15) NOT NULL UNIQUE, Circle VARCHAR(50) NOT NULL, PlanID INT NOT NULL, JoinDate DATE NOT NULL, SubscriberStatus VARCHAR(20) NOT NULL, FOREIGN KEY (PlanID) REFERENCES Plans(PlanID));

create table Call_Records ( CallID INT PRIMARY KEY, SubscriberID INT NOT NULL, CallDateTime DATETIME2 NOT NULL, DurationMinutes DECIMAL(8,2) NOT NULL, FOREIGN KEY (SubscriberID) REFERENCES Subscribers(SubscriberID));

create table Data_Usage ( UsageID INT PRIMARY KEY, SubscriberID INT NOT NULL, UsageDate DATE NOT NULL, DataUsedGB DECIMAL(8,2) NULL, FOREIGN KEY (SubscriberID) REFERENCES Subscribers(SubscriberID));

create table Invoices ( InvoiceID INT PRIMARY KEY, SubscriberID INT NOT NULL, InvoiceDate DATE NOT NULL, DueDate DATE NOT NULL, Amount DECIMAL(10,2) NULL, PaymentDate DATE NULL, FOREIGN KEY (SubscriberID) REFERENCES Subscribers(SubscriberID));

--inserting values
insert into Plans values
(1,'Basic 2GB',2.00,199.00),
(2,'Smart 5GB',5.00,399.00),
(3,'Unlimited 10GB',10.00,599.00),
(4,'Premium 20GB',20.00,799.00);

insert into Subscribers values
(1,'Aarav Kumar','9876500001','Tamil Nadu',1,'2025-01-10','Active'),
(2,'Diya Sharma','9876500002','Tamil Nadu',2,'2025-03-15','Active'),
(3,'Kabir Singh','9876500003','Karnataka',3,'2024-11-20','Active'),
(4,'Ananya Iyer','9876500004','Kerala',2,'2025-06-05','Active'),
(5,'Rohan Das','9876500005','Karnataka',4,'2024-08-12','Active'),
(6,'Isha Patel','9876500006','Tamil Nadu',1,'2026-01-02','Active'),
(7,'Vivaan Rao','9876500007','Kerala',3,'2025-09-18','Active'),
(8,'Mira Nair','9876500008','Karnataka',2,'2026-02-11','Active'),
(9,'Neil Joseph','9876500009','Tamil Nadu',4,'2025-12-01','Active'),
(10,'Sara Khan','9876500010','Kerala',1,'2026-04-21','Active'),
(11,'Dev Menon','9876500011','Tamil Nadu',3,'2026-05-01','Active');

insert into Call_Records values
(1,1,'2026-10-02T09:15:00',12),(2,1,'2026-10-05T18:20:00',8),
(3,2,'2026-10-03T11:00:00',25),(4,2,'2026-10-12T16:30:00',15),
(5,3,'2026-10-04T08:10:00',40),(6,3,'2026-10-14T20:00:00',35),
(7,4,'2026-10-07T13:45:00',18),(8,5,'2026-10-08T10:00:00',55),
(9,5,'2026-10-18T19:00:00',45),(10,6,'2026-10-20T09:30:00',10),
(11,7,'2026-10-21T14:15:00',30),(12,8,'2026-10-22T17:40:00',22),
(13,9,'2026-10-25T12:00:00',60),(14,10,'2026-10-27T15:10:00',14);

insert into Data_Usage values
(1,1,'2026-10-31',1.50),(2,2,'2026-10-31',6.20),(3,3,'2026-10-31',12.50),
(4,4,'2026-10-31',4.10),(5,5,'2026-10-31',18.70),(6,6,'2026-10-31',2.80),
(7,7,'2026-10-31',9.40),(8,8,'2026-10-31',5.60),(9,9,'2026-10-31',22.30),
(10,10,'2026-10-31',1.20);

insert into Invoices values
(1001,1,'2026-10-01','2026-10-15',199,'2026-10-12'),
(1002,2,'2026-10-01','2026-10-15',399,'2026-10-20'),
(1003,3,'2026-10-01','2026-10-15',599,'2026-10-14'),
(1004,4,'2026-10-01','2026-10-15',399,NULL),
(1005,5,'2026-10-01','2026-10-15',799,'2026-10-10'),
(1006,6,'2026-10-01','2026-10-15',199,NULL),
(1007,7,'2026-10-01','2026-10-15',599,'2026-10-18'),
(1008,8,'2026-10-01','2026-10-15',399,'2026-10-13'),
(1009,9,'2026-10-01','2026-10-15',799,NULL),
(1010,10,'2026-10-01','2026-10-15',199,'2026-10-15'),
(1011,1,'2026-11-01','2026-11-15',199,'2026-11-12'),
(1012,2,'2026-11-01','2026-11-15',399,NULL),
(1013,3,'2026-11-01','2026-11-15',599,'2026-11-14'),
(1014,4,'2026-11-01','2026-11-15',399,NULL),
(1015,5,'2026-11-01','2026-11-15',799,'2026-11-10'),
(1016,6,'2026-11-01','2026-11-15',199,NULL),
(1017,7,'2026-11-01','2026-11-15',599,'2026-11-16'),
(1018,8,'2026-11-01','2026-11-15',399,'2026-11-13'),
(1019,9,'2026-11-01','2026-11-15',799,NULL),
(1020,10,'2026-11-01','2026-11-15',199,'2026-11-15');

declare @ReportDate DATE = '2026-11-17';

--Total call minutes per plan.
select p.PlanName, SUM(cr.DurationMinutes) as TotalCallMinutes from Plans p
join Subscribers s on p.PlanID = s.PlanID
join Call_Records cr on s.SubscriberID = cr.SubscriberID
group by p.PlanName
order by TotalCallMinutes desc;

--Subscribers exceeding their plan data limit.
select s.SubscriberID, s.SubscriberName, p.PlanName, p.DataLimitGB, du.DataUsedGB
from Subscribers s
join Plans p on s.PlanID = p.PlanID
join Data_Usage du on s.SubscriberID = du.SubscriberID
where du.DataUsedGB > p.DataLimitGB
order by du.DataUsedGB desc;

--Month-wise invoice revenue.
select FORMAT(InvoiceDate,'yyyy-MM') as RevenueMonth, SUM(Amount) as MonthlyRevenue
from Invoices
group by FORMAT(InvoiceDate,'yyyy-MM')
order by RevenueMonth;

--Unpaid invoices overdue by more than 15 days.
select i.InvoiceID,
CONCAT('INV-',FORMAT(i.InvoiceID,'000000')) as FormattedInvoiceNumber,
s.SubscriberName, i.DueDate,
DATEDIFF(DAY,i.DueDate,@ReportDate) as DaysOverdue,
case
when i.PaymentDate is not null then 'Paid'
when DATEDIFF(DAY,i.DueDate,@ReportDate) > 15 then 'Overdue'
else 'Due'
end as DueDateStatus
from Invoices i
join Subscribers s on i.SubscriberID = s.SubscriberID
where i.PaymentDate is null
and DATEDIFF(DAY,i.DueDate,@ReportDate) > 15
order by DaysOverdue desc;

--Subscribers with no usage
select s.SubscriberID, s.SubscriberName, s.PhoneNumber from Subscribers s
where not exists (select 1 from Call_Records cr where cr.SubscriberID = s.SubscriberID)
and not exists (select 1 from Data_Usage du where du.SubscriberID = s.SubscriberID)
order by s.SubscriberID;

--Average revenue per user (ARPU) by circle.
with RevenueByCircle as (
select s.Circle, SUM(i.Amount) as TotalRevenue
from Subscribers s
join Invoices i on s.SubscriberID = i.SubscriberID
group by s.Circle
),
SubscribersByCircle as (
select Circle, COUNT(*) as SubscriberCount
from Subscribers
where SubscriberStatus = 'Active'
group by Circle
)
select r.Circle, r.TotalRevenue, c.SubscriberCount, CAST(r.TotalRevenue / NULLIF(c.SubscriberCount,0) AS DECIMAL(10,2)) AS ARPU
from RevenueByCircle r
join SubscribersByCircle c on r.Circle = c.Circle
order by ARPU desc;

--Plan popularity
select p.PlanName, COUNT(s.SubscriberID) as SubscriberCount from Plans p
left join Subscribers s on p.PlanID = s.PlanID
group by p.PlanName order by SubscriberCount desc, p.PlanName;

--Top 10 data consumers.
select top 10 s.SubscriberName, s.Circle, p.PlanName, du.DataUsedGB, p.DataLimitGB
from Data_Usage du
join Subscribers s on du.SubscriberID = s.SubscriberID
join Plans p on s.PlanID = p.PlanID
order by du.DataUsedGB desc;

--NULL demonstration
select COUNT(*) as TotalSubscribersWithUsageRows, COUNT(DataUsedGB) as NonNullUsageRows, SUM(DataUsedGB) AS TotalDataUsedGB, AVG(DataUsedGB) as AverageDataUsedGB
from (
select s.SubscriberID, du.DataUsedGB
from Subscribers s
left join Data_Usage du on s.SubscriberID = du.SubscriberID
) as UsageSummary;

--Compare with a value that includes zero for missing usage.
select AVG(COALESCE(du.DataUsedGB,0)) as AverageIncludingMissingAsZero from Subscribers s left join Data_Usage du on s.SubscriberID = du.SubscriberID;