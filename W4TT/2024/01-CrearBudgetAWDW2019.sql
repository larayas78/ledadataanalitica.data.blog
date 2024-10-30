DROP TABLE IF EXISTS dbo.FactInternetBudget;
 --Crear la tabla FactInternetBudget con todas las claves primarias y foráneas en la definición
CREATE TABLE dbo.FactInternetBudget (
	ProductKey int NOT NULL,
	OrderDateKey int NOT NULL,
	CustomerKey int NOT NULL,
	SalesTerritoryKey int NOT NULL,
	OrderQuantity smallint NOT NULL,
	Budget money NOT NULL,	
	-- Clave primaria
	CONSTRAINT PK_FactInternetBudget PRIMARY KEY CLUSTERED (
		OrderDateKey ASC,
		ProductKey ASC,
		CustomerKey ASC,
		SalesTerritoryKey ASC
	) ,
	-- Claves foráneas
	CONSTRAINT FK_FactInternetBudget_DimCustomer FOREIGN KEY (CustomerKey)
		REFERENCES dbo.DimCustomer (CustomerKey),
	CONSTRAINT FK_FactInternetBudget_DimDate FOREIGN KEY (OrderDateKey)
		REFERENCES dbo.DimDate (DateKey),
	CONSTRAINT FK_FactInternetBudget_DimProduct FOREIGN KEY (ProductKey)
		REFERENCES dbo.DimProduct (ProductKey),
	CONSTRAINT FK_FactInternetBudget_DimSalesTerritory FOREIGN KEY (SalesTerritoryKey)
		REFERENCES dbo.DimSalesTerritory (SalesTerritoryKey)
) 
GO

-- Insertar datos de prueba en FactInternetBudget
;WITH SalesData AS (
	SELECT 
		ProductKey,
		OrderDateKey,
		CustomerKey,
		SalesTerritoryKey,
		SUM(OrderQuantity) AS TotalOrderQuantity,
		SUM(UnitPrice * OrderQuantity) AS TotalSalesAmount,
		YEAR(OrderDateKey) AS SalesYear
	FROM dbo.FactInternetSales
	WHERE YEAR(OrderDate) >= YEAR(GETDATE()) - 3  -- Últimos 3 años
	GROUP BY ProductKey, OrderDateKey, CustomerKey, SalesTerritoryKey, YEAR(OrderDate)
),
BudgetData AS (
	SELECT 
		ProductKey,
		OrderDateKey,
		CustomerKey,
		SalesTerritoryKey,
		TotalOrderQuantity,
		TotalSalesAmount,
		-- Calcular el presupuesto basado en el promedio de los últimos 3 años
		AVG(TotalSalesAmount) OVER (PARTITION BY ProductKey ORDER BY OrderDateKey ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS AverageSales
	FROM SalesData
)
INSERT INTO dbo.FactInternetBudget (ProductKey, OrderDateKey, CustomerKey, SalesTerritoryKey, OrderQuantity, Budget)
SELECT 
	ProductKey,
	OrderDateKey,
	CustomerKey,
	SalesTerritoryKey,
	-- Usar un ajuste aleatorio de ±10% del presupuesto
	ROUND(AverageSales / (SELECT AVG(AverageSales) FROM BudgetData) * 1.1, 0) AS OrderQuantity,
	ROUND(AverageSales * (1 + ((RAND(CHECKSUM(NEWID())) * 0.2) - 0.1)), 2) AS Budget
FROM BudgetData
--WHERE OrderDateKey = CAST(YEAR(GETDATE()) + '0101' AS INT);  -- Asumir que el presupuesto es para el primer día del nuevo año

GO
