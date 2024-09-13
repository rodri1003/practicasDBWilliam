

USE Northwind
GO

/*
	Ejercicio 1
*/

CREATE OR ALTER VIEW vw_VentasPorCategoria1997 AS
SELECT 
    c.CategoryName,
    SUM(od.Quantity * od.UnitPrice) AS TotalVentas
FROM 
    Categories c
    JOIN Products p ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
WHERE 
    YEAR(o.OrderDate) = 1997
GROUP BY 
    c.CategoryName;
GO

SELECT * FROM vw_VentasPorCategoria1997
GO

/*
	EJERCICIO 2
*/

CREATE OR ALTER VIEW vw_EmpleadosConJefes AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS NombreEmpleado,
    m.FirstName + ' ' + m.LastName AS NombreJefe
FROM 
    Employees e
    LEFT JOIN Employees m ON e.ReportsTo = m.EmployeeID;
GO

SELECT * FROM vw_EmpleadosConJefes
GO

/*
	EJERCICIO 3
*/

CREATE OR ALTER VIEW vw_Top3ProductosPorPais AS
WITH RankedProducts AS (
    SELECT 
        c.Country,
        p.ProductName,
        SUM(od.Quantity) AS TotalVendido,
        ROW_NUMBER() OVER (PARTITION BY c.Country ORDER BY SUM(od.Quantity) DESC) AS Ranking
    FROM 
        Customers c
        JOIN Orders o ON c.CustomerID = o.CustomerID
        JOIN [Order Details] od ON o.OrderID = od.OrderID
        JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY 
        c.Country, p.ProductName
)
SELECT 
    Country,
    ProductName,
    TotalVendido
FROM 
    RankedProducts
WHERE 
    Ranking <= 3;
GO

SELECT * FROM vw_Top3ProductosPorPais
GO