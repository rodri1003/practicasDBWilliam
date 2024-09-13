use Northwind
GO

/*---------------------------------------------------------
					Ejercicio 1
---------------------------------------------------------*/

/*
IF OBJECT_ID('tempdb..#VentasTotales') IS NOT NULL
BEGIN
	DROP TABLE #VentasTotales
END
*/

DECLARE @FechaReferencia DATE = '1998-05-31';

SELECT 
    P.ProductID,
    P.ProductName,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
INTO #VentasTotales
FROM 
    Products P
    JOIN [Order Details] OD ON P.ProductID = OD.ProductID
    JOIN Orders O ON OD.OrderID = O.OrderID
WHERE 
    O.OrderDate >= DATEADD(MONTH, -1, @FechaReferencia)
    AND O.OrderDate <= @FechaReferencia
GROUP BY 
    P.ProductID, P.ProductName


SELECT TOP 5 * 
FROM #VentasTotales 
ORDER BY TotalSales DESC
GO

/*---------------------------------------------------------
					Ejercicio 2
---------------------------------------------------------*/

/*
IF OBJECT_ID('tempdb..##ClientesActivos') IS NOT NULL
BEGIN
	DROP TABLE ##ClientesActivos
END
*/

-- Primero, encontremos la fecha m?s reciente en la base de datos
DECLARE @UltimaFecha DATE = (SELECT MAX(OrderDate) FROM Orders);

-- Ahora, usemos esta fecha para calcular el "?ltimo a?o" de datos
SELECT 
    C.CustomerID,
    C.CompanyName,
    COUNT(DISTINCT O.OrderID) AS NumeroOrdenes,
    SUM(OD.Quantity * OD.UnitPrice) AS TotalPurchases,
    MAX(O.OrderDate) AS LastPurchase
INTO ##ClientesActivos
FROM 
    Customers C
    JOIN Orders O ON C.CustomerID = O.CustomerID
    JOIN [Order Details] OD ON O.OrderID = OD.OrderID
WHERE 
    O.OrderDate >= DATEADD(YEAR, -1, @UltimaFecha)
GROUP BY 
    C.CustomerID, C.CompanyName
HAVING 
    COUNT(DISTINCT O.OrderID) > 5  -- Consideramos activos a los que tienen m?s de 5 ?rdenes

-- Ejemplo de uso
SELECT * FROM ##ClientesActivos
WHERE TotalPurchases > (SELECT AVG(TotalPurchases) FROM ##ClientesActivos)
ORDER BY TotalPurchases DESC
GO

/*---------------------------------------------------------
					Ejercicio 3
---------------------------------------------------------*/


CREATE PROCEDURE CalcularComisiones
    @MesCalculo INT,
    @AnioCalculo INT
AS
BEGIN
    SELECT 
        E.EmployeeID,
        E.FirstName + ' ' + E.LastName AS EmployeeName,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
    INTO #ComisionesEmpleados
    FROM 
        Employees E
        JOIN Orders O ON E.EmployeeID = O.EmployeeID
        JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    WHERE 
        MONTH(O.OrderDate) = @MesCalculo AND YEAR(O.OrderDate) = @AnioCalculo
    GROUP BY 
        E.EmployeeID, E.FirstName, E.LastName

    SELECT 
        EmployeeID,
        EmployeeName,
        TotalSales,
        CASE 
            WHEN TotalSales < 10000 THEN TotalSales * 0.05
            WHEN TotalSales BETWEEN 10000 AND 50000 THEN TotalSales * 0.07
            ELSE TotalSales * 0.10
        END AS Comision
    FROM #ComisionesEmpleados
    ORDER BY TotalSales DESC
END

-- Ejecutar el procedimiento
EXEC CalcularComisiones 7, 1996