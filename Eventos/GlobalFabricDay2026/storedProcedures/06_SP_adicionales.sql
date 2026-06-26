-- ============================================================
-- GFD26 Peru | Demo v2: SPs adicionales para YAML
-- 3 SPs nuevos que se suman a los 4 de la Beta
-- ============================================================

-- SP 5 | Direcciones
CREATE OR ALTER PROCEDURE dbo.usp_GetAddresses
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvince,
        CountryRegion,
        PostalCode,
        rowguid,
        ModifiedDate
    FROM SalesLT.Address;
END;
GO

-- SP 6 | Relación Cliente-Dirección
CREATE OR ALTER PROCEDURE dbo.usp_GetCustomerAddresses
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CustomerID,
        AddressID,
        AddressType,
        rowguid,
        ModifiedDate
    FROM SalesLT.CustomerAddress;
END;
GO

-- SP 7 | Categorías de Producto
CREATE OR ALTER PROCEDURE dbo.usp_GetProductCategories
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ProductCategoryID,
        ParentProductCategoryID,
        Name,
        rowguid,
        ModifiedDate
    FROM SalesLT.ProductCategory;
END;
GO

-- SP 8 | Modelos de Producto
CREATE OR ALTER PROCEDURE dbo.usp_GetProductModels
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ProductModelID,
        Name,
        rowguid,
        ModifiedDate
    FROM SalesLT.ProductModel;
END;
GO
