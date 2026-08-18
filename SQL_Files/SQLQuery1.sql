CREATE VIEW vw_StockPerformance AS
WITH StockMetrics AS (
    SELECT 
        Ticker,
        Date,
        ClosePrice,
        LAG(ClosePrice, 1) OVER (
            PARTITION BY Ticker 
            ORDER BY Date
        ) AS PrevClosePrice,
        AVG(ClosePrice) OVER (
            PARTITION BY Ticker 
            ORDER BY Date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS SMA_7,
        AVG(ClosePrice) OVER (
            PARTITION BY Ticker 
            ORDER BY Date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS SMA_30
    FROM StockPrices
)
SELECT 
    Ticker,
    Date,
    ROUND(ClosePrice, 2) AS ClosePrice,
    ROUND(PrevClosePrice, 2) AS PrevClosePrice,
    ROUND(((ClosePrice - PrevClosePrice) / PrevClosePrice) * 100, 2) AS DailyReturnPct,
    ROUND(SMA_7, 2) AS SMA_7,
    ROUND(SMA_30, 2) AS SMA_30
FROM StockMetrics;

GO
ALTER VIEW vw_StockPerformance AS
WITH PriceChanges AS (
    SELECT 
        Ticker,
        Date,
        ClosePrice,
        -- 1. Daily Price Difference
        ClosePrice - LAG(ClosePrice, 1) OVER (
            PARTITION BY Ticker ORDER BY Date
        ) AS PriceDiff
    FROM StockPrices
),
GainsAndLosses AS (
    SELECT 
        Ticker,
        Date,
        ClosePrice,
        -- Split gains and losses for RSI calculation
        CASE WHEN PriceDiff > 0 THEN PriceDiff ELSE 0 END AS Gain,
        CASE WHEN PriceDiff < 0 THEN ABS(PriceDiff) ELSE 0 END AS Loss
    FROM PriceChanges
),
AvgGainsAndLosses AS (
    SELECT 
        Ticker,
        Date,
        ClosePrice,

        AVG(Gain) OVER (
            PARTITION BY Ticker ORDER BY Date 
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS AvgGain_14,

        AVG(Loss) OVER (
            PARTITION BY Ticker ORDER BY Date 
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        ) AS AvgLoss_14,
        
        AVG(ClosePrice) OVER (
            PARTITION BY Ticker ORDER BY Date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS SMA_7,

        AVG(ClosePrice) OVER (
            PARTITION BY Ticker ORDER BY Date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS SMA_30,

        STDEV(ClosePrice) OVER (
            PARTITION BY Ticker ORDER BY Date 
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ) AS Volatility_20
    FROM GainsAndLosses
),
RSICalculation AS (
    SELECT 
        Ticker,
        Date,
        ClosePrice,
        SMA_7,
        SMA_30,
        Volatility_20,
        CASE 
            WHEN AvgLoss_14 = 0 THEN 100
            ELSE 100 - (100 / (1 + (AvgGain_14 / AvgLoss_14)))
        END AS RSI_14
    FROM AvgGainsAndLosses
)
SELECT 
    Ticker,
    Date,
    ROUND(ClosePrice, 2) AS ClosePrice,
    ROUND(SMA_7, 2) AS SMA_7,
    ROUND(SMA_30, 2) AS SMA_30,
    ROUND(Volatility_20, 2) AS Volatility_20,
    ROUND(RSI_14, 2) AS RSI_14,
    CASE 
        WHEN RSI_14 >= 70 THEN 'Overbought'
        WHEN RSI_14 <= 30 THEN 'Oversold'
        ELSE 'Neutral'
    END AS MomentumSignal
FROM RSICalculation;