import datetime
import pandas as pd
from sqlalchemy import create_engine
import urllib
import yfinance as yf

print("🚀 Starting robust portfolio data download...")

# 1. Official Yahoo Finance Tickers for your holdings:
# (Note: Ather Energy hasn't listed publicly yet, so we track the rest!)
ticker_dict = {
    'HINDALCO.NS': 'Hindalco Industries',
    'ETERNAL.NS': 'Eternal (Zomato)',
    'TATAGOLD.NS': 'TATAGOLD ETF',
    'CUPID.NS': 'Cupid Limited',
    'HDFCBANK.NS': 'HDFC Bank',
    'CIPLA.NS': 'Cipla Limited',
    'ADANIPOWER.NS': 'Adani Power',
    'OLAELEC.NS': 'Ola Electric Mobility',
    'ATHERENERG.NS': 'Ather Energy (NSE)'
}

records = []

for symbol, name in ticker_dict.items():
    print(f"📥 Fetching data for {name} ({symbol})...")
    try:
        # Download individually so one stock never breaks the others
        df_ticker = yf.download(symbol, start="2023-01-01", progress=False)
        
        if not df_ticker.empty:
            # Flatten columns if multi-indexed
            if isinstance(df_ticker.columns, pd.MultiIndex):
                df_ticker.columns = df_ticker.columns.get_level_values(0)
                
            df_ticker = df_ticker.reset_index()
            df_ticker['Ticker'] = symbol
            
            # Keep required columns
            df_ticker = df_ticker[['Date', 'Ticker', 'Close']].rename(columns={'Close': 'ClosePrice'})
            records.append(df_ticker)
            print(f"   ✅ Successfully fetched {len(df_ticker)} rows for {symbol}")
        else:
            print(f"   ⚠️ No data found for {symbol}")
    except Exception as e:
        print(f"   ❌ Error fetching {symbol}: {e}")

# Combine all ticker records into one DataFrame
df = pd.concat(records, ignore_index=True)
df.dropna(subset=['ClosePrice'], inplace=True)
df['Date'] = pd.to_datetime(df['Date']).dt.date

print(f"\n📊 Total records collected: {len(df)}. Ingesting into SQL Server...")

# 2. Connect to SQL Server
connection_url = (
    "mssql+pyodbc://@FAIRYDUST\\SQLEXPRESS/StockMarketDB"
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)
engine = create_engine(connection_url)

# 3. Overwrite PortfolioPrices with ALL holdings
df.to_sql('PortfolioPrices', con=engine, if_exists='replace', index=False)

print("🎉 Complete! All available portfolio stocks are now in PortfolioPrices.")