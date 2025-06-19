-- 1) Speed up lookups of banners by their position (used in joins Banner to BannerPosition)
CREATE NONCLUSTERED INDEX IX_Banner_PositionID
    ON dbo.Banner (PositionID);
GO

-- 2) Support queries and joins on clicks by banner and date
CREATE NONCLUSTERED INDEX IX_Click_BannerID_ClickDate
    ON dbo.Click (BannerID, ClickDate);
GO

-- 3) Speed up the join from OrderBanner to Banner
-- Table dbo.OrderBanner has a clustered primary key on (OrderID, BannerID),
-- but because most of our reporting is “find all orders for a given banner,” we need also that nonclustered index with BannerID
CREATE NONCLUSTERED INDEX IX_OrderBanner_BannerID_OrderID
    ON dbo.OrderBanner (BannerID, OrderID);
GO

-- 4) Support date-based reporting on orders
CREATE NONCLUSTERED INDEX IX_Order_OrderDate
    ON dbo.[Order] (OrderDate);
GO

-- 5) Support range checks on campaign active periods
CREATE NONCLUSTERED INDEX IX_Campaign_StartDate_EndDate
    ON dbo.Campaign (StartDate, EndDate);
GO