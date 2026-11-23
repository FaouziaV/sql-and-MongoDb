/*
NORMALISATION EXPLANATION

Original table contained:
SKU, ProductName, Category, SupplierName, SupplierPhone, Warehouse, Quantity, ReorderLevel.

1NF:
All attributes contain atomic values. 
Each row represents one product's stock in one warehouse.

2NF:
All non-key attributes depend on the complete primary key. 
In Inventory, Quantity and ReorderLevel depend on both SKU and WarehouseID.

3NF:
Transitive dependencies are removed. Supplier details are stored in Supplier.
Category details are stored in Category.
Warehouse details are stored in Warehouse.
Product stores only the corresponding foreign keys.

*/

--database creation

create database RetailInventoryDB;

use RetailInventoryDB


--tables creation

create table Category(
	CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);
GO

select * from Category;

create table Supplier
(
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(120) NOT NULL,
    SupplierPhone VARCHAR(20) NOT NULL UNIQUE
);
GO

select * from Supplier;

create table Warehouse(
	WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL UNIQUE
);
GO

select * from Warehouse;

create table Product(
	SKU VARCHAR(20) PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,

    CONSTRAINT FK_Product_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    CONSTRAINT FK_Product_Supplier
        FOREIGN KEY (SupplierID)
        REFERENCES Supplier(SupplierID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

select * from Product;

create table Inventory(
	SKU VARCHAR(20) NOT NULL,
    WarehouseID INT NOT NULL,

    Quantity INT NOT NULL
        CONSTRAINT DF_Inventory_Quantity DEFAULT 0,

    ReorderLevel INT NOT NULL
        CONSTRAINT DF_Inventory_ReorderLevel DEFAULT 5,

    CONSTRAINT PK_Inventory
        PRIMARY KEY (SKU, WarehouseID),

    CONSTRAINT CK_Inventory_Quantity
        CHECK (Quantity >= 0),

    CONSTRAINT CK_Inventory_ReorderLevel
        CHECK (ReorderLevel >= 0),

    CONSTRAINT FK_Inventory_Product
        FOREIGN KEY (SKU)
        REFERENCES Product(SKU)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT FK_Inventory_Warehouse
        FOREIGN KEY (WarehouseID)
        REFERENCES Warehouse(WarehouseID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

--value insertion

select * from Inventory;

insert into Category(CategoryName)values('Electronics'),('Home Appliances'),('Clothing'),('Books'),('Sports'),('Toys'),('Furniture'),('Beauty'),('Groceries'),('Accessories');

select * from Category;

insert into Supplier(SupplierName, SupplierPhone)values('BrightTech Supplies', '9000000001'),('HomeEase Distributors', '9000000002'),('UrbanWear Traders', '9000000003'),('PageTurner Wholesale', '9000000004'),('ActiveLife Sports', '9000000005'),('PlayWorks Imports', '9000000006'),('ComfortLiving Co', '9000000007'),('GlowCare Suppliers', '9000000008'),('FreshCart Wholesale', '9000000009'),('AccessPoint Trading', '9000000010');

select * from Supplier;

insert into Warehouse(WarehouseName)values('Coimbatore Central'),('Chennai North'),('Bengaluru East'),('Hyderabad Hub'),('Kochi Storage'),('Madurai Depot'),('Tiruppur Store'),('Salem Warehouse'),('Trichy Hub'),('Mysuru Depot');

select * from Warehouse;

insert into Product(SKU, ProductName, CategoryID, SupplierID)values('SKU001', 'Wireless Mouse', 1, 1),('SKU002', 'Electric Kettle', 2, 2),('SKU003', 'Cotton T-Shirt', 3, 3),('SKU004', 'Data Structures Book', 4, 4),('SKU005', 'Yoga Mat', 5, 5),('SKU006', 'Building Blocks Set', 6, 6),('SKU007', 'Office Chair', 7, 7),('SKU008', 'Face Moisturiser', 8, 8),('SKU009', 'Organic Oats', 9, 9),('SKU010', 'Phone Case', 10, 10);

select * from Product;

select p.SKU, p.ProductName, c.CategoryName, s.SupplierName
from Product p
join Category c on p.CategoryID = c.CategoryID
join Supplier s on p.SupplierID = s.SupplierID;

insert into Inventory (SKU, WarehouseID, Quantity, ReorderLevel) values ('SKU001', 1, 45, 10),('SKU002', 2, 18, 5),('SKU003', 3, 60, 15),('SKU004', 4, 25, 8),('SKU005', 5, 32, 10),('SKU006', 6, 14, 5),('SKU007', 7, 9, 3),('SKU008', 8, 40, 10),('SKU009', 9, 55, 12),('SKU010', 10, 20, 5);

select * from Inventory;

--insertion anomaly

insert into Product(SKU, ProductName, CategoryID, SupplierID)values('SKU001', 'Gaming Mouse', 1, 1);

insert into Product(SKU, ProductName, CategoryID, SupplierID)values('SKU011', 'Bluetooth Speaker', 999, 1);

insert into Inventory(SKU, WarehouseID, Quantity, ReorderLevel)values('SKU001', 1, -5, 10);

insert into Product (SKU, ProductName, CategoryID, SupplierID)values('SKU012', NULL, 1, 1);

--update value

update Supplier set SupplierPhone = '9111111111' where supplierID = 1;

select SupplierID, SupplierName, SupplierPhone from Supplier where SupplierID = 1;

--deletion

select p.SKU, ProductName, i.WarehouseID, i.Quantity from Product p 
left join Inventory i
on p.SKU = i.SKU
where p.SKU = 'SKU010';

delete from Product where SKU = 'SKU010';

select p.SKU, p.ProductName, i.WarehouseID, i.Quantity from Product p
left join Inventory i
on p.SKU = i.SKU
where p.SKU = 'SKU010';

select * from Inventory where SKU = 'SKU010';

