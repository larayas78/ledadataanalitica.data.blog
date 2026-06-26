-- ============================================================
-- GFD26 Peru | Demo Beta: 1 Pipeline, Infinitas Tablas
-- 4 Stored Procedures en sql_Sales_AW (esquema SalesLT)
-- Cada SP retorna UNA tabla completa sin filtros
-- ============================================================

-- SP 1 | Clientes
CREATE OR ALTER PROCEDURE dbo.usp_GetCustomers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CustomerID,
        NameStyle,
        Title,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        CompanyName,
        SalesPerson,
        EmailAddress,
        Phone,
        PasswordHash,
        PasswordSalt,
        rowguid,
        ModifiedDate
    FROM SalesLT.Customer;
END;
GO

-- SP 2 | Productos
CREATE OR ALTER PROCEDURE dbo.usp_GetProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ProductID,
        Name,
        ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        ProductCategoryID,
        ProductModelID,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ThumbnailPhotoFileName,
        rowguid,
        ModifiedDate
    FROM SalesLT.Product;
END;
GO

-- SP 3 | Cabeceras de Orden de Venta
CREATE OR ALTER PROCEDURE dbo.usp_GetSalesOrderHeaders
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        OnlineOrderFlag,
        'SO' + CONVERT(nvarchar(23), SalesOrderID) AS SalesOrderNumber,
        PurchaseOrderNumber,
        AccountNumber,
        CustomerID,
        ShipToAddressID,
        BillToAddressID,
        ShipMethod,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmt,
        Freight,
        ISNULL(SubTotal + TaxAmt + Freight, 0)     AS TotalDue,
        Comment,
        rowguid,
        ModifiedDate
    FROM SalesLT.SalesOrderHeader;
END;
GO

-- SP 4 | Detalle de Orden de Venta
CREATE OR ALTER PROCEDURE dbo.usp_GetSalesOrderDetails
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        ProductID,
        UnitPrice,
        UnitPriceDiscount,
        ISNULL(UnitPrice * (1.0 - UnitPriceDiscount) * OrderQty, 0.0) AS LineTotal,
        rowguid,
        ModifiedDate
    FROM SalesLT.SalesOrderDetail;
END;
GO
