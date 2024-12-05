use NORTHWND
GO

-- Ejercicio 1: Mostrar el nombre y apellido de todos los empleados junto con el n�mero de �rdenes que han procesado
DECLARE @EmployeeID INT
DECLARE @FirstName NVARCHAR(20)
DECLARE @LastName NVARCHAR(20)
DECLARE @OrderCount INT

DECLARE employee_cursor CURSOR FOR
SELECT EmployeeID, FirstName, LastName 
FROM Employees

OPEN employee_cursor
FETCH NEXT FROM employee_cursor INTO @EmployeeID, @FirstName, @LastName

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @OrderCount = COUNT(*) 
    FROM Orders
    WHERE EmployeeID = @EmployeeID

    PRINT CONCAT(@FirstName, ' ', @LastName, ' a procesado ', @OrderCount, ' ordenes.')

    FETCH NEXT FROM employee_cursor INTO @EmployeeID, @FirstName, @LastName
END

CLOSE employee_cursor
DEALLOCATE employee_cursor

-- Ejercicio 2: Mostrar el nombre de cada categor�a y la cantidad de productos que pertenecen a esa categor�a
DECLARE @CategoryID INT
DECLARE @CategoryName NVARCHAR(15)
DECLARE @ProductCount INT

DECLARE category_cursor CURSOR FOR
SELECT CategoryID, CategoryName 
FROM Categories

OPEN category_cursor
FETCH NEXT FROM category_cursor INTO @CategoryID, @CategoryName

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @ProductCount = COUNT(*)
    FROM Products 
    WHERE CategoryID = @CategoryID

    PRINT CONCAT('Categoria: ', @CategoryName, ', Productos: ', @ProductCount)

    FETCH NEXT FROM category_cursor INTO @CategoryID, @CategoryName
END

CLOSE category_cursor
DEALLOCATE category_cursor

-- Ejercicio 3: Mostrar el nombre de cada proveedor y el precio m�s alto y m�s bajo de los productos que proveen
DECLARE @SupplierID INT
DECLARE @CompanyName NVARCHAR(40)
DECLARE @HighestPrice MONEY
DECLARE @LowestPrice MONEY

DECLARE supplier_cursor CURSOR FOR
SELECT SupplierID, CompanyName
FROM Suppliers

OPEN supplier_cursor
FETCH NEXT FROM supplier_cursor INTO @SupplierID, @CompanyName

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT 
        @HighestPrice = MAX(UnitPrice),
        @LowestPrice = MIN(UnitPrice)
    FROM Products
    WHERE SupplierID = @SupplierID

    PRINT CONCAT('Proveedor: ', @CompanyName, ', precio mas alto: ', @HighestPrice, ', precio mas bajo: ', @LowestPrice)

    FETCH NEXT FROM supplier_cursor INTO @SupplierID, @CompanyName
END

CLOSE supplier_cursor
DEALLOCATE supplier_cursor