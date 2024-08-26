CREATE OR ALTER PROCEDURE sp_SimularActualizacionDescuentos
AS
BEGIN
    DECLARE @ProductID INT, @UnitsInStock INT, @TotalSales MONEY, @Discount DECIMAL(4,2)
    DECLARE @Counter INT = 1

    WHILE @Counter <= (SELECT MAX(ProductID) FROM Products)
    BEGIN
        SELECT @ProductID = ProductID, @UnitsInStock = UnitsInStock
        FROM Products
        WHERE ProductID = @Counter

        SELECT @TotalSales = SUM(UnitPrice * Quantity)
        FROM [Order Details]
        WHERE ProductID = @ProductID

        SET @Discount = 
            CASE
                WHEN @UnitsInStock > 100 AND @TotalSales < 10000 THEN 0.10
                WHEN @UnitsInStock BETWEEN 50 AND 100 AND @TotalSales BETWEEN 10000 AND 50000 THEN 0.15
                WHEN @UnitsInStock < 50 AND @TotalSales > 50000 THEN 0.20
                ELSE 0.05
            END

        IF @Discount > 0
        BEGIN
            PRINT 'Se actualizaría el Producto ' + CAST(@ProductID AS VARCHAR) + ' con venta total de '+ CAST(@TotalSales AS VARCHAR) + ' y Stock de ' + CAST(@UnitsInStock AS VARCHAR) + ' a un descuento de ' + CAST(@Discount AS VARCHAR)
        END
        ELSE
        BEGIN
            PRINT 'El Producto ' + CAST(@ProductID AS VARCHAR) + ' no tendría cambios en el descuento'
        END

        SET @Counter = @Counter + 1
    END
END

-- exec sp_SimularActualizacionDescuentos