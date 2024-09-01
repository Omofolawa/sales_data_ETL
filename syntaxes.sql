-- Syntax to Create New database for the Sales Data
CREATE DATABASE SalesAnalyticsELT;

USE SalesAnalyticsELT;


-- SyNtax to create staging area for the ingested data.
CREATE TABLE HeapSalesData (
    SaleID INT,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    CustomerName NVARCHAR(255),
    ProductName NVARCHAR(255),
    Region NVARCHAR(255),
    SalesRep NVARCHAR(255),
    TotalAmount DECIMAL(12,4),
    SalesDate DATE
);

-- AFter Data Ingestion from SSIS, the Heap table will be modelled to identify entities and relationships.
-- Entities Identified are Customers, Sales, Product, Regions, SalesReps

-- Each customer is stored uniquely.
CREATE TABLE Customers (
    CustomerID INT,
    CustomerName NVARCHAR(255)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(255)
);

-- Each product is stored uniquely.
CREATE TABLE Products (
    ProductID INT,
    ProductName NVARCHAR(255),
    Price DECIMAL(10,2)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(255),
    Price DECIMAL(10,2)
);

-- This Table Stores different sales regions.
CREATE TABLE Regions (
    RegionID INT PRIMARY KEY IDENTITY(1,1),
    RegionName NVARCHAR(255)
);

-- Stores information about the sales representatives.
CREATE TABLE SalesReps (
    SalesRepID INT PRIMARY KEY IDENTITY(1,1),
    SalesRepName NVARCHAR(255),
    RegionID INT FOREIGN KEY REFERENCES Regions(RegionID)
);

-- Stores sales transactions, linked to the other normalized tables.
CREATE TABLE Sales (
    SaleID INT,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    SalesRepID INT FOREIGN KEY REFERENCES SalesReps(SalesRepID),
    Quantity INT,
    TotalAmount DECIMAL(12,4),
    SalesDate DATE
);

DROP TABLE Sales;


-- Data Migration from Heap Table to Normalized Tables

INSERT INTO Customers (CustomerID, CustomerName)
SELECT DISTINCT CustomerID, CustomerName
FROM HeapSalesData;

-- Removing duplicate records using CTE 
WITH CTE_Duplicates AS (
    SELECT 
        CustomerID,
        CustomerName,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) AS RowNum
    FROM Customers
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;

-- Altering Customers table to make CustomerID a Primary Key.
ALTER TABLE Customers
ALTER COLUMN CustomerID INT NOT NULL;

ALTER TABLE Customers
ADD CONSTRAINT PK_Customers PRIMARY KEY (CustomerID);

DROP TABLE Customers;
DROP TABLE Products;

-- Syntax to find the number of counts of duplicates.
SELECT ProductID, COUNT(*) AS DuplicateCount
FROM Products
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Removing duplicate records from Products using CTE
WITH CTE_Duplicates AS (
    SELECT 
        ProductID,
        ProductName,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS RowNum
    FROM Products
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;

-- Altering Products table to make ProductID a Primary Key.
ALTER TABLE Products
ALTER COLUMN ProductID INT NOT NULL;

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY (ProductID);

INSERT INTO Products (ProductID, ProductName, Price)
SELECT DISTINCT ProductID, ProductName, Price
FROM HeapSalesData;

INSERT INTO Regions (RegionName)
SELECT DISTINCT Region
FROM HeapSalesData;

INSERT INTO SalesReps (SalesRepName, RegionID)
SELECT DISTINCT hs.SalesRep, r.RegionID
FROM HeapSalesData hs
JOIN Regions r ON hs.Region = r.RegionName;

INSERT INTO Sales (SaleID, CustomerID, ProductID, SalesRepID, Quantity, TotalAmount, SalesDate)
SELECT hs.SaleID, hs.CustomerID, hs.ProductID, sr.SalesRepID, hs.Quantity, hs.TotalAmount, hs.SalesDate
FROM HeapSalesData hs
JOIN SalesReps sr ON hs.SalesRep = sr.SalesRepName;

-- Altering Sales table to make SaleID a Primary Key.
ALTER TABLE Sales
ALTER COLUMN SaleID INT NOT NULL;

ALTER TABLE Sales
ADD CONSTRAINT PK_Sales PRIMARY KEY (SaleID);

-- Views for Specific Use Cases
-- Use Case 1: Sales Performance by Region
CREATE VIEW SalesByRegion AS
SELECT r.RegionName, SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN SalesReps sr ON s.SalesRepID = sr.SalesRepID
JOIN Regions r ON sr.RegionID = r.RegionID
GROUP BY r.RegionName;


-- Use Case 2: Sales Performance by Sales Representative
CREATE VIEW SalesByRep AS
SELECT sr.SalesRepName, SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN SalesReps sr ON s.SalesRepID = sr.SalesRepID
GROUP BY sr.SalesRepName;


-- Use Case 3: Top-Selling Products
CREATE VIEW TopSellingProducts AS
SELECT p.ProductName, SUM(s.Quantity) AS TotalQuantity, SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName;
--ORDER BY TotalSales DESC;



