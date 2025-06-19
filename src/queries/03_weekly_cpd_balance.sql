-- c) Balance per weekday for CPD banners

-- 1) Build a list of dates from 2025-06-16 (Monday) through 2025-06-22 (Sunday)
;WITH DateSeries AS (
    -- Anchor member: start with the first date
    SELECT CAST('2025-06-16' AS DATE) AS Dt
    UNION ALL
    -- Recursive member: add 1 day each time, stop when we hit 2025-06-22
    SELECT DATEADD(DAY, 1, Dt) FROM DateSeries WHERE Dt < '2025-06-22'
)

 -- 2) Main query: for each date in our DateSeries, pair it with every CPD-priced banner
SELECT
    -- Numeric weekday (1 = Mon … 7 = Sun)
    DATEPART(WEEKDAY, ds.Dt)         AS Weekday,

    -- Textual weekday name (“Monday”, “Tuesday”, …)
    DATENAME(WEEKDAY, ds.Dt)         AS DayName,

    -- Total cost: for each banner/day we charge 1 × Price
    SUM(bp.Price)                    AS TotalCost,

    -- Sum of any order revenues that happened on that banner on that date
    ISNULL(SUM(o.Revenue), 0)        AS TotalRevenue,

    -- Balance = Revenue – Cost
    ISNULL(SUM(o.Revenue), 0) - SUM(bp.Price) AS Balance
FROM DateSeries ds

-- Cross join to get every combination of (date × banner)
CROSS JOIN dbo.Banner AS b
JOIN dbo.BannerPosition AS bp
  ON bp.ID = b.PositionID
 AND bp.PricingType = 'CPD' -- only "click per day" banners

-- Link in any orders on that banner that happened that day
LEFT JOIN dbo.OrderBanner ob
  ON ob.BannerID = b.ID
LEFT JOIN dbo.[Order] o
  ON o.ID = ob.OrderID
 AND CAST(o.OrderDate AS DATE) = ds.Dt -- Match only orders whose OrderDate (date portion) equals our current Dt

-- 3) Aggregate by weekday
GROUP BY
    DATEPART(WEEKDAY, ds.Dt),
    DATENAME(WEEKDAY, ds.Dt)

-- 4) Order the output chronologically
ORDER BY
    DATEPART(WEEKDAY, ds.Dt);
GO
