-- 1) Ensure that on each Site we don’t have two positions of the same size
--    (i.e. one unique banner slot per width×height per site)
ALTER TABLE dbo.BannerPosition
ADD CONSTRAINT UQ_BannerPosition_Site_Width_Height
    UNIQUE (SiteID, Width, Height);
GO

-- 2) Restrict PricingType to the two allowed values: CPD or CPC
ALTER TABLE dbo.BannerPosition
ADD CONSTRAINT CK_BannerPosition_PricingType
    CHECK (PricingType IN ('CPD','CPC'));
GO

-- 3) Prices must never be negative
ALTER TABLE dbo.BannerPosition
ADD CONSTRAINT CK_BannerPosition_Price
    CHECK (Price >= 0);
GO


-- 4) Orders must have non‐negative Revenue
ALTER TABLE dbo.[Order]
ADD CONSTRAINT CK_Order_Revenue
    CHECK (Revenue >= 0);
GO