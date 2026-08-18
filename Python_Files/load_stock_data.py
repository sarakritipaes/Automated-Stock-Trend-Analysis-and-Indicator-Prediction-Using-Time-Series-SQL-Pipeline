print("Script is running!")
import yfinance as yf
import pandas as pd
from sqlalchemy import create_engine

print("🚀 Starting stock data download...")

# 1. Define tickers and date range
tickers = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA']
data = yf.download(tickers, start="2023-01-01", end="2026-01-01")['Close']

# 2. Reshape data into long format
df = data.reset_index().melt(id_vars=['Date'], var_name='Ticker', value_name='ClosePrice')
df.dropna(inplace=True)

print(f"✅ Fetched {len(df)} records. Connecting to SQL Server...")

# 3. Connection string to your local SQL Server instance
# Adjust Server name if needed (e.g., localhost or your PC name)
engine = create_engine("mssql+pyodbc://@FAIRYDUST\\SQLEXPRESS/StockMarketDB?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes")

# 4. Push data to SSMS table
df.to_sql('StockPrices', con=engine, if_exists='replace', index=False)

print("🎉 Data ingestion complete! Stock prices are now in SSMS.")