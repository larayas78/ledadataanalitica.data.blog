-- Eliminar todos los registros existentes en DimDate (opcional)
-- DELETE FROM dbo.DimDate;

-- Declarar variables
DECLARE @StartDate DATE = '2025-01-01';  -- Fecha de inicio
DECLARE @EndDate DATE = '2025-12-31';    -- Fecha final
DECLARE @CurrentDate DATE = @StartDate;

-- Bucle para insertar fechas
WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO dbo.DimDate (
        DateKey,
        FullDateAlternateKey,
        DayNumberOfWeek,
        EnglishDayNameOfWeek,
        SpanishDayNameOfWeek,
        FrenchDayNameOfWeek,
        DayNumberOfMonth,
        DayNumberOfYear,
        WeekNumberOfYear,
        EnglishMonthName,
        SpanishMonthName,
        FrenchMonthName,
        MonthNumberOfYear,
        CalendarQuarter,
        CalendarYear,
        CalendarSemester,
        FiscalQuarter,
        FiscalYear,
        FiscalSemester
    )
    VALUES (
        CONVERT(INT, CONVERT(VARCHAR(8), @CurrentDate, 112)),  -- DateKey como YYYYMMDD
        @CurrentDate,                                         -- Fecha completa
        DATEPART(WEEKDAY, @CurrentDate),                     -- Día de la semana (1-7)
        DATENAME(WEEKDAY, @CurrentDate),                     -- Nombre del día en inglés
        CASE DATEPART(WEEKDAY, @CurrentDate)                -- Nombre del día en español
            WHEN 1 THEN 'domingo'
            WHEN 2 THEN 'lunes'
            WHEN 3 THEN 'martes'
            WHEN 4 THEN 'miércoles'
            WHEN 5 THEN 'jueves'
            WHEN 6 THEN 'viernes'
            WHEN 7 THEN 'sábado'
        END,
        CASE DATEPART(WEEKDAY, @CurrentDate)                -- Nombre del día en francés
            WHEN 1 THEN 'dimanche'
            WHEN 2 THEN 'lundi'
            WHEN 3 THEN 'mardi'
            WHEN 4 THEN 'mercredi'
            WHEN 5 THEN 'jeudi'
            WHEN 6 THEN 'vendredi'
            WHEN 7 THEN 'samedi'
        END,
        DAY(@CurrentDate),                                   -- Número del día del mes
        DATEPART(DAYOFYEAR, @CurrentDate),                  -- Número del día del año
        DATEPART(WEEK, @CurrentDate),                        -- Número de la semana del año
        DATENAME(MONTH, @CurrentDate),                       -- Nombre del mes en inglés
        CASE MONTH(@CurrentDate)                              -- Nombre del mes en español
            WHEN 1 THEN 'enero'
            WHEN 2 THEN 'febrero'
            WHEN 3 THEN 'marzo'
            WHEN 4 THEN 'abril'
            WHEN 5 THEN 'mayo'
            WHEN 6 THEN 'junio'
            WHEN 7 THEN 'julio'
            WHEN 8 THEN 'agosto'
            WHEN 9 THEN 'septiembre'
            WHEN 10 THEN 'octubre'
            WHEN 11 THEN 'noviembre'
            WHEN 12 THEN 'diciembre'
        END,
        CASE MONTH(@CurrentDate)                              -- Nombre del mes en francés
            WHEN 1 THEN 'janvier'
            WHEN 2 THEN 'février'
            WHEN 3 THEN 'mars'
            WHEN 4 THEN 'avril'
            WHEN 5 THEN 'mai'
            WHEN 6 THEN 'juin'
            WHEN 7 THEN 'juillet'
            WHEN 8 THEN 'août'
            WHEN 9 THEN 'septembre'
            WHEN 10 THEN 'octobre'
            WHEN 11 THEN 'novembre'
            WHEN 12 THEN 'décembre'
        END,
        MONTH(@CurrentDate),                                  -- Número del mes
        DATEPART(QUARTER, @CurrentDate),                     -- Trimestre del calendario
        YEAR(@CurrentDate),                                   -- Año del calendario
        CASE WHEN MONTH(@CurrentDate) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,  -- Semestre del calendario
        DATEPART(QUARTER, @CurrentDate),                     -- Trimestre fiscal (asumiendo el mismo que el calendario)
        YEAR(@CurrentDate),                                   -- Año fiscal (asumiendo el mismo que el calendario)
        CASE WHEN MONTH(@CurrentDate) BETWEEN 1 AND 6 THEN 1 ELSE 2 END   -- Semestre fiscal
    );

    -- Incrementar la fecha actual por un día
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- Confirmar que se han insertado las fechas
SELECT COUNT(*) AS TotalFechas FROM dbo.DimDate;
