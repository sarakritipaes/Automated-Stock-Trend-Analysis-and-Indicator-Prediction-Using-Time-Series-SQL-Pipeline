CREATE PROCEDURE sp_GetTickerSummary
    @TickerSymbol VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * 
    FROM vw_StockPerformance
    WHERE Ticker = @TickerSymbol
    ORDER BY Date DESC;
END;