use NORTHWND
GO

CREATE OR ALTER PROCEDURE sp_ReporteVentasPorCategoria
AS
BEGIN
    DECLARE @CategoryID INT, @CategoryName NVARCHAR(15), @TotalSales MONEY
    DECLARE @Counter INT = 1

    WHILE @Counter <= (SELECT MAX(CategoryID) FROM Categories)
    BEGIN
        SELECT @CategoryID = CategoryID, @CategoryName = CategoryName
        FROM Categories
        WHERE CategoryID = @Counter

        SELECT @TotalSales = SUM(OD.UnitPrice * OD.Quantity)
        FROM [Order Details] OD
        JOIN Products P ON OD.ProductID = P.ProductID
        WHERE P.CategoryID = @CategoryID

        IF @TotalSales IS NOT NULL
        BEGIN
            DECLARE @Performance NVARCHAR(20) = 
                CASE
                    WHEN @TotalSales >= 200000 THEN 'Excelente'
                    WHEN @TotalSales BETWEEN 150000 AND 199999 THEN 'Bueno'
                    WHEN @TotalSales BETWEEN 100000 AND 149999 THEN 'Regular'
                    ELSE 'Bajo'
                END

            PRINT 'Categoría: ' + @CategoryName + 
                  ', Ventas Totales: $' + CAST(@TotalSales AS VARCHAR) + 
                  ', Rendimiento: ' + @Performance

            IF @Performance IN ('Bajo', 'Regular')
            BEGIN
                PRINT 'Se recomienda revisar la estrategia de marketing para la categoría ' + @CategoryName
            END
            ELSE
            BEGIN
                PRINT 'La categoría ' + @CategoryName + ' está teniendo un buen desempeño'
            END
        END
        ELSE
        BEGIN
            PRINT 'No hay ventas registradas para la categoría ' + @CategoryName
        END

        SET @Counter = @Counter + 1
    END
END

exec sp_ReporteVentasPorCategoria