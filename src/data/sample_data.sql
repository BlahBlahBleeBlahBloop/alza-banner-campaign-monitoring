-- 1) Declare IDs
DECLARE
  @camp1   UNIQUEIDENTIFIER = NEWID(), -- Summer Sale
  @camp2   UNIQUEIDENTIFIER = NEWID(), -- Flash Deals
  @camp3   UNIQUEIDENTIFIER = NEWID(), -- Black Friday
  @site1   UNIQUEIDENTIFIER = NEWID(), -- seznam.cz
  @site2   UNIQUEIDENTIFIER = NEWID(), -- heureka.cz
  @pos1    UNIQUEIDENTIFIER = NEWID(), -- Seznam CPD
  @pos2    UNIQUEIDENTIFIER = NEWID(), -- Seznam CPC
  @pos3    UNIQUEIDENTIFIER = NEWID(), -- Heureka CPD
  @pos4    UNIQUEIDENTIFIER = NEWID(), -- Heureka CPC
  @banner1 UNIQUEIDENTIFIER = NEWID(),
  @banner2 UNIQUEIDENTIFIER = NEWID(),
  @banner3 UNIQUEIDENTIFIER = NEWID(),
  @banner4 UNIQUEIDENTIFIER = NEWID();

-- 2) Insert Campaigns, Sites, Positions, Banners
INSERT INTO dbo.Campaign (ID, Name, StartDate, EndDate)
VALUES
  (@camp1, 'Summer Sale',       '2025-06-01', '2025-06-30'),
  (@camp2, 'Flash Deals',     '2025-06-10', '2025-06-30'),
  (@camp3, 'Black Friday','2025-06-10', '2025-06-30');

INSERT INTO dbo.Site (ID, Domain)
VALUES
  (@site1, 'seznam.cz'),
  (@site2, 'heureka.cz');

INSERT INTO dbo.BannerPosition (ID, SiteID, Width, Height, PricingType, Price)
VALUES
  (@pos1, @site1, 728,  90,  'CPD', 100.00),
  (@pos2, @site1, 300, 250,  'CPC',   5.00),
  (@pos3, @site2, 728,  90,  'CPD',  80.00),
  (@pos4, @site2, 300, 600,  'CPC',   3.00);

INSERT INTO dbo.Banner (ID, PositionID, CampaignID, Width, Height)
VALUES
  (@banner1, @pos1, @camp1, 728,  90),
  (@banner2, @pos2, @camp1, 300, 250),
  (@banner3, @pos3, @camp2, 728,  90),
  (@banner4, @pos4, @camp3, 300, 600);

-- 3) Clicks: 2 per day for CPC banners (@banner2, @banner4)
-- Builds one-row-per-day from 2025-06-16 through 2025-06-22 = 28 clicks
;WITH DateSeries AS (
    SELECT CAST('2025-06-16' AS DATE) AS Dt
    UNION ALL
    SELECT DATEADD(DAY, 1, Dt) FROM DateSeries WHERE Dt < '2025-06-22'
)
, Banners AS (
    SELECT @banner2 AS BannerID
    UNION ALL
    SELECT @banner4
)
-- TWO clickS per day/banner
INSERT INTO dbo.Click (ID, BannerID, ClickDate)
SELECT NEWID(), BannerID, Dt
FROM DateSeries ds
CROSS JOIN Banners b

UNION ALL

SELECT NEWID(), BannerID, Dt
FROM DateSeries ds
CROSS JOIN Banners b;

-- 4) Orders & OrderBanner: 1 order per banner per day = 28 orders
DECLARE
  @Orders TABLE (
    OrderID    UNIQUEIDENTIFIER,
    CustomerID UNIQUEIDENTIFIER,
    OrderDate  DATETIME2,
    Revenue    DECIMAL(12,2),
    BannerID   UNIQUEIDENTIFIER
  );

;WITH DateSeries AS (
    SELECT CAST('2025-06-16' AS DATE) AS Dt
    UNION ALL
    SELECT DATEADD(DAY, 1, Dt) FROM DateSeries WHERE Dt < '2025-06-22'
)

INSERT INTO @Orders(OrderID, CustomerID, OrderDate, Revenue, BannerID)
SELECT
  NEWID(),                                           -- OrderID
  NEWID(),                                           -- CustomerID
  ds.Dt,                                             -- OrderDate
  ROUND(RAND(CHECKSUM(NEWID())) * 700 + 300, 2),     -- Revenue between 300.00 and 1 000.00
  b.BannerID                                        -- associated Banner
FROM DateSeries ds
CROSS JOIN (VALUES
    (@banner1),(@banner2),(@banner3),(@banner4)
) AS b(BannerID);

-- 3) insert into Order
INSERT INTO dbo.[Order](ID, CustomerID, OrderDate, Revenue)
SELECT OrderID, CustomerID, OrderDate, Revenue
FROM @Orders;

-- 4) insert into OrderBanner
INSERT INTO dbo.OrderBanner(OrderID, BannerID)
SELECT OrderID, BannerID
FROM @Orders;
GO