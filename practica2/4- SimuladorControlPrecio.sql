CREATE TRIGGER tr_SimularControlPrecios
ON Products
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(UnitPrice)
    BEGIN
        DECLARE @ProductID INT, @OldPrice MONEY, @NewPrice MONEY, @CategoryID INT
        DECLARE @MaxPercentChange DECIMAL(5,2)

        SELECT @ProductID = i.ProductID, @OldPrice = d.UnitPrice, @NewPrice = i.UnitPrice, @CategoryID = i.CategoryID
        FROM inserted i
        JOIN deleted d ON i.ProductID = d.ProductID

        SET @MaxPercentChange = 
            CASE @CategoryID
                WHEN 1 THEN 0.05 -- Bebidas
                WHEN 2 THEN 0.10 -- Condimentos
                WHEN 3 THEN 0.15 -- Confecciones
                WHEN 4 THEN 0.20 -- Lácteos
                ELSE 0.25
            END

        DECLARE @PercentChange DECIMAL(5,2) = ABS((@NewPrice - @OldPrice) / @OldPrice)

        IF @PercentChange <= @MaxPercentChange
        BEGIN
            PRINT 'Se actualizaría el precio para el producto ' + CAST(@ProductID AS VARCHAR) + 
                  ' de $' + CAST(@OldPrice AS VARCHAR) + ' a $' + CAST(@NewPrice AS VARCHAR)
        END
        ELSE
        BEGIN
            DECLARE @MaxAllowedChange MONEY = @OldPrice * (1 + @MaxPercentChange)
            DECLARE @MinAllowedChange MONEY = @OldPrice * (1 - @MaxPercentChange)

            PRINT 'Cambio de precio rechazado para el producto ' + CAST(@ProductID AS VARCHAR)
            PRINT 'El cambio máximo permitido es de ' + CAST(@MaxPercentChange * 100 AS VARCHAR) + '%'
            PRINT 'Rango de precios permitido: $' + CAST(@MinAllowedChange AS VARCHAR) + ' - $' + CAST(@MaxAllowedChange AS VARCHAR)
        END
    END
END

select * from Products

update Products SET UnitPrice = 10 WHERE ProductID = 1