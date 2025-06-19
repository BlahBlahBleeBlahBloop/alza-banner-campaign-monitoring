-- b) Campaign Balance (Revenue – Cost)
--    We compute total ad cost (CPD + CPC) and total order revenue per campaign,
--    then take the difference as the campaign “balance.”

WITH
-- 1) Cost for CPD‐priced banners: price * number of campaign days per banner
CostCPD AS (
    SELECT
        c.ID        AS CampaignID,
        SUM(
            bp.Price
            * (DATEDIFF(day, c.StartDate, c.EndDate) + 1)
        ) AS Cost
    FROM dbo.Campaign AS c
    JOIN dbo.Banner   AS b  ON b.CampaignID = c.ID
    JOIN dbo.BannerPosition AS bp
        ON b.PositionID = bp.ID
       AND bp.PricingType = 'CPD' -- only day-priced (cost per day) banners
    GROUP BY c.ID
),

-- 2) Cost for CPC‐priced banners: price * total clicks per banner
-- 2a) Pre-aggregate clicks per banner for CPC
ClickCounts AS (
    SELECT
        BannerID,
        COUNT(*) AS ClickCount
    FROM dbo.Click
    GROUP BY BannerID
),

 -- 2b) Calculate CPC cost: price per click × number of clicks
CostCPC AS (
    SELECT
        c.ID      AS CampaignID,
        SUM(
            bp.Price
            * ISNULL(cc.ClickCount, 0)
        ) AS Cost
    FROM dbo.Campaign AS c
    JOIN dbo.Banner   AS b  ON b.CampaignID = c.ID
    JOIN dbo.BannerPosition AS bp
        ON b.PositionID = bp.ID
       AND bp.PricingType = 'CPC'
    LEFT JOIN ClickCounts AS cc
        ON cc.BannerID = b.ID
    GROUP BY c.ID
),

-- 3) Merge both CPD and CPC costs into one per-campaign total
Costs AS (
    SELECT
        c.ID                        AS CampaignID,
        ISNULL(cp.Cost,0) + ISNULL(cc.Cost,0) AS Cost
    FROM dbo.Campaign AS c
    LEFT JOIN CostCPD AS cp ON cp.CampaignID = c.ID
    LEFT JOIN CostCPC AS cc ON cc.CampaignID = c.ID
),

 -- 4) Sum up revenues by campaign via the OrderBanner linking table
Revenues AS (
    SELECT
        c.ID        AS CampaignID,
        SUM(o.Revenue) AS Revenue
    FROM dbo.Campaign AS c
    JOIN dbo.Banner AS b
      ON b.CampaignID = c.ID
    JOIN dbo.OrderBanner AS ob
      ON ob.BannerID = b.ID
    JOIN dbo.[Order] AS o
      ON o.ID = ob.OrderID
    GROUP BY c.ID
)

-- 5) Final balance
SELECT
    c.ID       AS CampaignID,
    c.Name,
    ISNULL(r.Revenue, 0)
      - ISNULL(co.Cost, 0) AS Balance
FROM dbo.Campaign AS c
LEFT JOIN Revenues r ON r.CampaignID = c.ID
LEFT JOIN Costs    co ON co.CampaignID = c.ID
ORDER BY Balance DESC;
