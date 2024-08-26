USE NORTHWND
GO

CREATE TRIGGER tr_SimularActualizacionInventario
ON [Order Details]
AFTER INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @UnitsInStock INT, @ReorderLevel INT
    DECLARE @OrderID INT

    SELECT @OrderID = OrderID FROM inserted

    DECLARE cur_OrderDetails CURSOR FOR
    SELECT ProductID, Quantity FROM inserted WHERE OrderID = @OrderID

    OPEN cur_OrderDetails
    FETCH NEXT FROM cur_OrderDetails INTO @ProductID, @Quantity

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
        FROM Products
        WHERE ProductID = @ProductID

        IF @UnitsInStock >= @Quantity
        BEGIN
            PRINT 'Se actualizaría el inventario para el producto ' + CAST(@ProductID AS VARCHAR) + 
                  '. Nuevo stock sería: ' + CAST((@UnitsInStock - @Quantity) AS VARCHAR)

            DECLARE @NeedReorder VARCHAR(20) = 
                CASE
                    WHEN (@UnitsInStock - @Quantity) <= @ReorderLevel THEN 'Sí'
                    ELSE 'No'
                END

            IF @NeedReorder = 'Sí'
            BEGIN
                PRINT 'Sería necesario realizar un nuevo pedido para el producto ' + CAST(@ProductID AS VARCHAR)
            END
        END
        ELSE
        BEGIN
            PRINT 'No habría suficiente stock del producto ' + CAST(@ProductID AS VARCHAR)
        END

        FETCH NEXT FROM cur_OrderDetails INTO @ProductID, @Quantity
    END

    CLOSE cur_OrderDetails
    DEALLOCATE cur_OrderDetails
END

select * from Products

insert into [Order Details] values (11077, 11, 14.00, 5, 0)