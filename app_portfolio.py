import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import urllib

st.set_page_config(page_title="Personal Portfolio Analytics", page_icon="📈", layout="wide")
st.title("✨ Personal Portfolio Analytics Engine ✨")
st.caption("Tracking NSE Holdings | Powered by FAIRYDUST\\SQLEXPRESS & Python")

@st.cache_resource
def get_db_connection():
    params = urllib.parse.quote_plus(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=FAIRYDUST\\SQLEXPRESS;"
        "DATABASE=StockMarketDB;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

engine = get_db_connection()

# Sidebar: Select Ticker from Portfolio
st.sidebar.header("📁 Holdings")
tickers_df = pd.read_sql("SELECT DISTINCT Ticker FROM PortfolioPrices ORDER BY Ticker", engine)
selected_ticker = st.sidebar.selectbox("Choose a Holding:", tickers_df["Ticker"])

# Fetch metrics using our portfolio stored procedure
query = f"EXEC sp_GetPortfolioSummary @TickerSymbol = '{selected_ticker}'"
df = pd.read_sql(query, engine)
df["Date"] = pd.to_datetime(df["Date"])
df = df.sort_values("Date")

# KPI Summary Cards (formatted in INR ₹)
latest = df.iloc[-1]
col1, col2, col3, col4 = st.columns(4)
col1.metric("Latest Close", f"₹{latest['ClosePrice']:,.2f}", f"{latest['DailyReturnPct']:.2f}%")
col2.metric("14-Day RSI", f"{latest['RSI_14']:.2f}", delta=latest['MomentumSignal'])
col3.metric("20-Day Volatility", f"₹{latest['Volatility_20']:,.2f}")
col4.metric("7-Day SMA", f"₹{latest['SMA_7']:,.2f}")

st.markdown("---")

# Chart 1: Price and Moving Average Crossovers
st.subheader(f"📈 Price Trends & Moving Averages ({selected_ticker})")
st.line_chart(df.set_index("Date")[["ClosePrice", "SMA_7", "SMA_30"]])

# Chart 2: RSI
st.subheader("📊 14-Day RSI (Momentum)")
st.line_chart(df.set_index("Date")[["RSI_14"]])

# Raw Historical Records
with st.expander("🔍 View Raw History"):
    st.dataframe(df.sort_values("Date", ascending=False), use_container_width=True)