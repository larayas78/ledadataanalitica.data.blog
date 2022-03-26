--PASO A: Crear una tabla para el prespuesto
--REQUISITO: Tener la base de datos AdventureWorksDW2014
USE AdventureWorksDW2014

DROP TABLE IF EXISTS dbo.FactInternetBudget;


DROP TABLE IF EXISTS dbo.FactInternetBudget;

CREATE TABLE [dbo].[FactInternetBudget](
	[ProductKey] [int] NOT NULL,
	[OrderDateKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[Budget] [money] NOT NULL
	
 CONSTRAINT [PK_FactInternetBudget] PRIMARY KEY CLUSTERED 
(
	[OrderDateKey] ASC,
	[ProductKey] ASC,[CustomerKey] ASC,[SalesTerritoryKey]  ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FactInternetBudget]  
	WITH CHECK ADD  CONSTRAINT [FK_FactInternetBudget_DimCustomer] FOREIGN KEY([CustomerKey])
REFERENCES [dbo].[DimCustomer] ([CustomerKey])
GO

ALTER TABLE [dbo].[FactInternetBudget] CHECK CONSTRAINT [FK_FactInternetBudget_DimCustomer]
GO

ALTER TABLE [dbo].[FactInternetBudget]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetBudget_DimDate]
	FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])
GO

ALTER TABLE [dbo].[FactInternetBudget] CHECK CONSTRAINT [FK_FactInternetBudget_DimDate]
GO
 
 

ALTER TABLE [dbo].[FactInternetBudget]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetBudget_DimProduct] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[DimProduct] ([ProductKey])
GO

ALTER TABLE [dbo].[FactInternetBudget] CHECK CONSTRAINT [FK_FactInternetBudget_DimProduct]
GO
 

ALTER TABLE [dbo].[FactInternetBudget]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetBudget_DimSalesTerritory] FOREIGN KEY([SalesTerritoryKey])
REFERENCES [dbo].[DimSalesTerritory] ([SalesTerritoryKey])
GO

ALTER TABLE [dbo].[FactInternetBudget] CHECK CONSTRAINT [FK_FactInternetBudget_DimSalesTerritory]
GO
----------------------------------------------------------------------------------------------
--PASO 2
--AGREGAR DATOS, SOLO DE PRUEBA

;WITH Base AS
(
SELECT 
 CASE WHEN ProductKey%5 >=4 THEN OrderQuantity
	WHEN ProductKey%2 =1 THEN  OrderQuantity*2
	WHEN ProductKey%3 =1 THEN  OrderQuantity 
	ELSE 0.3 * OrderQuantity
	END AS NewOrderQuantity 

,ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, 
                  UnitPriceDiscountPct, DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate
FROM Dbo.FactInternetSales
)
INSERT INTO dbo.FactInternetBudget (ProductKey, OrderDateKey,CustomerKey,SalesTerritoryKey,OrderQuantity,Budget)
SELECT ProductKey, OrderDateKey,CustomerKey
	, SalesTerritoryKey
	, SUM(NewOrderQuantity) AS OrderQuantity
	, SUM(UnitPrice * NewOrderQuantity) AS Budget
FROM Base
GROUP BY ProductKey, OrderDateKey,CustomerKey, SalesTerritoryKey;
