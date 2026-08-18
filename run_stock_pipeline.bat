@echo off
echo =========================================
echo  Spreading Fairy Dust: Running Ingestion
echo =========================================

:: Navigate to project directory
cd /d "C:\Users\sarak\OneDrive\Stocks_Project"

:: Execute Python script
py load_stock_data.py >> pipeline_log.txt 2>&1

echo All Done!