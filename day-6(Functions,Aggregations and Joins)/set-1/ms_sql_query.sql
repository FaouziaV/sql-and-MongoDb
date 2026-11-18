--create database
create database RetailSalesDB;
use RetailSalesDB;

--create tables
create table Customers (CustomerID INT IDENTITY(1,1) PRIMARY KEY, CustomerName VARCHAR(100) NOT NULL, City VARCHAR(50) NOT NULL, Email VARCHAR(100) NOT NULL UNIQUE);

create table Products (ProductID INT IDENTITY(1,1) PRIMARY KEY, ProductName VARCHAR(100) NOT NULL, Category VARCHAR(50) NOT NULL, UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0));

create table Orders (OrderID INT IDENTITY(1,1) PRIMARY KEY, CustomerID INT NOT NULL, OrderDate DATE NOT NULL, CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID));

create table Order_Items (OrderItemID INT IDENTITY(1,1) PRIMARY KEY, OrderID INT NOT NULL, ProductID INT NOT NULL, Quantity INT NOT NULL CHECK (Quantity > 0), UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0), CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE, CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID));

create table Payments (PaymentID INT IDENTITY(1,1) PRIMARY KEY, OrderID INT NOT NULL UNIQUE, PaymentDate DATE NULL, Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0), PaymentMethod VARCHAR(30) NOT NULL, CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE);

--insert values
insert into Customers (CustomerName, City, Email) values ('Arun Kumar','Coimbatore','arun@example.com'),('Priya Sharma','Chennai','priya@example.com'),('Rahul Verma','Bengaluru','rahul@example.com'),('Sneha Reddy','Coimbatore','sneha@example.com'),('Karthik Raj','Chennai','karthik@example.com'),('Meera Iyer','Madurai','meera@example.com');

insert into Products (ProductName, Category, UnitPrice) values ('Wireless Mouse','Electronics',800),('Mechanical Keyboard','Electronics',2500),('Cotton T-Shirt','Clothing',600),('Water Bottle','Accessories',350),('Laptop Stand','Accessories',1200);

insert into Orders (CustomerID, OrderDate) values (1,'2026-01-05'),(1,'2026-01-18'),(1,'2026-02-10'),(1,'2026-02-22'),(2,'2026-01-12'),(2,'2026-02-14'),(3,'2026-02-05'),(4,'2026-03-02'),(5,'2026-03-10'),(5,'2026-03-15');

insert into Order_Items (OrderID, ProductID, Quantity, UnitPrice) values (1,1,2,800),(1,4,1,350),(2,2,1,2500),(3,1,1,800),(3,5,1,1200),(4,3,2,600),(5,2,1,2500),(5,4,2,350),(6,3,3,600),(7,5,2,1200),(8,1,1,800),(8,3,1,600),(9,4,3,350),(10,2,1,2500),(10,5,1,1200);

insert into Payments (OrderID, PaymentDate, Amount, PaymentMethod) values (1,'2026-01-05',1950,'UPI'),(2,'2026-01-18',2500,'Card'),(4,'2026-02-22',1200,'UPI'),(5,'2026-01-12',3200,'Card'),(6,'2026-02-14',1800,'UPI'),(7,'2026-02-05',2400,'Net Banking'),(9,'2026-03-10',1050,'UPI'),(10,'2026-03-15',3700,'Card');

select 'Customers' as TableName, COUNT(*) as TotalRows from Customers union all select 'Products',COUNT(*) from Products union all select 'Orders',COUNT(*) from Orders union all select 'Order_Items',COUNT(*) from Order_Items union all select 'Payments',COUNT(*) from Payments;

--Top five products by revenue.
select top 5 p.ProductID, p.ProductName, SUM(oi.Quantity * oi.UnitPrice) as Revenue from Products p join Order_Items oi on p.ProductID = oi.ProductID group by p.ProductID, p.ProductName order by Revenue desc;

--Month-wise sales.
select FORMAT(o.OrderDate,'yyyy-MM') as SalesMonth, ROUND(SUM(oi.Quantity * oi.UnitPrice),2) as MonthlySales from Orders o join Order_Items oi on o.OrderID = oi.OrderID group by FORMAT(o.OrderDate,'yyyy-MM') order by SalesMonth;

--Customers with more than three orders.
select c.CustomerID, c.CustomerName, COUNT(o.OrderID) as OrderCount from Customers c join Orders o on c.CustomerID = o.CustomerID group by c.CustomerID, c.CustomerName having COUNT(o.OrderID) > 3;

--Average basket value by city .
with OrderBaskets as (select o.OrderID, o.CustomerID, SUM(oi.Quantity * oi.UnitPrice) as BasketValue from Orders o join Order_Items oi on o.OrderID = oi.OrderID group by o.OrderID, o.CustomerID)
select c.City, ROUND(AVG(ob.BasketValue),2) as AverageBasketValue from OrderBaskets ob join Customers c on ob.CustomerID = c.CustomerID group by c.City order by c.City;

-- Orders without a payment.
select o.OrderID, o.CustomerID, o.OrderDate from Orders o left join Payments p on o.OrderID = p.OrderID where p.PaymentID is null order by o.OrderID;

--Customers with no orders.
select c.CustomerID, c.CustomerName, c.City from Customers c left join Orders o on c.CustomerID = o.CustomerID where o.OrderID is null;

--Product-category revenue share.
with CategorySales as (select p.Category, SUM(oi.Quantity * oi.UnitPrice) as CategoryRevenue from Products p join Order_Items oi on p.ProductID = oi.ProductID group by p.Category)
select Category, CategoryRevenue, ROUND(100.0 * CategoryRevenue / SUM(CategoryRevenue) over (),2) as RevenueSharePercent from CategorySales order by CategoryRevenue desc;

--Day with the highest sales.
select top 1 o.OrderDate, SUM(oi.Quantity * oi.UnitPrice) as DailySales from Orders o join Order_Items oi on o.OrderID = oi.OrderID group by o.OrderDate order by DailySales desc, o.OrderDate;

--Customer-friendly output 
select c.CustomerID, UPPER(c.CustomerName) as CustomerNameUpper, CONCAT(c.CustomerName,' - ',c.City) as CustomerLabel, FORMAT(o.OrderDate,'dd MMM yyyy') as FormattedOrderDate, DATEDIFF(DAY,o.OrderDate,CAST(GETDATE() as date)) as DaysSinceOrder, ROUND(SUM(oi.Quantity * oi.UnitPrice),2) as OrderTotal from Customers c join Orders o on c.CustomerID = o.CustomerID join Order_Items oi on o.OrderID = oi.OrderID group by c.CustomerID,c.CustomerName,c.City,o.OrderDate,o.OrderID order by o.OrderDate;

--NULL behaviour
select COUNT(*) as TotalRows, COUNT(PaymentDate) as NonNullPaymentDates, AVG(CAST(Amount as decimal(10,2))) as AveragePaymentAmount from Payments;

--Ignores the NULL amount
select COUNT(*) as TotalRows, COUNT(PaymentDate) as NonNullDates, AVG(Amount) as AverageNonNullAmount
from (values (CAST('2026-01-01' as date),CAST(100.00 as decimal(10,2))),(CAST(NULL as date),CAST(200.00 as decimal(10,2))),(CAST('2026-01-03' as date),CAST(NULL as decimal(10,2)))) as SampleData(PaymentDate,Amount);
