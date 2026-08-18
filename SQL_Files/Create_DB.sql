CREATE DATABASE StockMarketDB;
GO

USE StockMarketDB;
GO

-- 1. Create the Companies (Metadata) Table
CREATE TABLE Companies(
    Ticker VARCHAR(10) PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    Sector VARCHAR(50),
    Industry VARCHAR(50)
);
GO

-- 2. Create the StockPrices (Fact) Table
CREATE TABLE StockPrices(
    PriceID INT IDENTITY(1,1) PRIMARY KEY,
    Ticker VARCHAR(10) NOT NULL,
    TradeDate DATE NOT NULL,
    OpenPrice DECIMAL(18, 4),
    HighPrice DECIMAL(18, 4),
    LowPrice DECIMAL(18, 4),
    ClosePrice DECIMAL(18, 4),
    AdjClosePrice DECIMAL(18, 4),
    Volume BIGINT,
    
    -- Ensure we don't accidentally import duplicate dates for the same stock
    CONSTRAINT UQ_Ticker_Date UNIQUE (Ticker, TradeDate),
    
    -- Foreign key relationship to Companies table
    CONSTRAINT FK_StockPrices_Companies FOREIGN KEY (Ticker) 
        REFERENCES Companies(Ticker) ON DELETE CASCADE
);
GO

-- 3. Create Indexes for High-Performance Queries
-- Since we will filter by Ticker and sort by TradeDate constantly, indexing them speeds up queries.
CREATE INDEX IX_StockPrices_Ticker_Date 
ON StockPrices(Ticker, TradeDate);
GO