# Analyzing ETFs and calculating my retirement
This project is all about extracting data from yfinance and etfdb.com and cleaning it using Python and SQL, then analyzing and visualizing the etfs onto Tableau. Link to the Tableau dashboard can be found [here](https://public.tableau.com/app/profile/jason.lee2654/viz/ETFResearchProject/Dashboard1). 
The goal is to provide an example of how I used data analytic tools to solve a real life issue: how to plan for retirement.

## How It's Made:

**Tech used:** Python (libraries include Pandas, OS, time, matplotlib, and yfinance), PostgreSQL, and Tableau

I started off by reading articles and Reddit posts on most popular national ETFs and compiled a list of the most popular ones that tracked indexes and/or markets within the US. After that I was able to get information about the etf's holdings on etfdb.com and financial data on yfinance. 
Once I finished gathering and cleaning the data, I calculated the tracking error, average yoy performance, industry makeup, and more on SQL and created tables for each output. Each table was then copied on CSVs using the PSQL tool to be later read onto Tableau where I visualized the data.
I ended up choosing VOO, an etf from Vanguard that tracks the S&P 500 because of its low tracking error, expense ratio, high returns and asset under management. To diversify my portfolio, I also needed to include an international etf and small cap for which I chose VXUS and AVUV respectively. 
I skipped analyzing them because it would be a repeat of analyzing US etfs which wouldn't add much to the analysis. Moving forward, I wanted to calculate my expected compound growth based on an initial investment and monthly contributions. 
This can be found in the notebook titled [retirement.ipynb](https://github.com/JasonSTLee/retirement-analysis/blob/main/retirement.ipynb). At the very bottom I plotted 2 bar charts, one for showing the year over year growth with a stacked bar chart and another to show my gross and net amount after taxes.

## Lessons Learned:

The biggest lesson I learned was utilizing different tools to accomplish the project, even if it meant switching from Python to SQL, and back to Python. Whichever tech got the job done efficiently and accurately, was the tech of choice. 
