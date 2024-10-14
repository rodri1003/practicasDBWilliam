

/*
	Ejercicio 1
*/
WITH TopProducts AS (
    SELECT TOP 5 ProductName, UnitPrice
    FROM Products
    ORDER BY UnitPrice DESC
)
SELECT * FROM TopProducts;

/*
	Ejercicio 2
*/
WITH CategorySales AS (
    SELECT c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS TotalSales
    FROM Categories c
    JOIN Products p ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryName
)
SELECT CategoryName, TotalSales
FROM CategorySales
ORDER BY TotalSales DESC;

/*
	Ejercicio 3
*/
WITH EmployeeHierarchy AS (
    SELECT EmployeeID, FirstName, LastName, ReportsTo, 0 AS Level
    FROM Employees
    WHERE ReportsTo IS NULL
    
    UNION ALL
    
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.ReportsTo, eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ReportsTo = eh.EmployeeID
)
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Level
FROM EmployeeHierarchy
ORDER BY Level, EmployeeID;

/*
	Ejercicio 4
*/
WITH EmployeeSales (EmployeeID, FullName, TotalSales, NumberOfOrders) AS
(
    SELECT 
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)),
        COUNT(DISTINCT o.OrderID)
    FROM 
        Employees e
        INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
        INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY 
        e.EmployeeID, e.FirstName, e.LastName
)
SELECT 
    EmployeeID,
    FullName,
    FORMAT(TotalSales, 'C') AS TotalSales,
    NumberOfOrders
FROM 
    EmployeeSales
ORDER BY 
    TotalSales DESC;