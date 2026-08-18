USE StockMarketDB;

EXEC sp_help 'StockPrices';

SELECT COUNT(*) AS TotalRows, 
       COUNT(Date) AS ValidDates, 
       COUNT(Ticker) AS ValidTickers
FROM StockPrices;

ALTER TABLE StockPrices ALTER COLUMN Date DATE NOT NULL;
ALTER TABLE StockPrices ALTER COLUMN Ticker VARCHAR(10) NOT NULL;

ALTER TABLE StockPrices
ADD CONSTRAINT PK_StockPrices PRIMARY KEY (Date, Ticker);

