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


## Why VOO?:

### Deviation Percentage Calculation

There are a few reason I chose VOO over the other US based etfs. Below is a screenshot of what I call "Deviation Percentage" where I calculated the average yoy return of the etfs, and their top 20 stocks based on portfolio weight. I then subracted the stocks return by the etf return, divide that by 
etf return to get the percentage. The code can be found in the file called [sql.sql](https://github.com/JasonSTLee/Retirement-Analysis/blob/main/sql.sql). A lower deviation percentage indicates the etf performance is more closely aligned with the performance of its top holdings; I interpreted that
as a sign of lower risk and volatility.
![Deviation of top 20 stocks](https://github.com/user-attachments/assets/473fc30e-bcda-462e-95d2-614d80484205)

### Tracking Error

Speaking of volatility and performance alignment. Where "Deviation Percentage" tracked the etf's stocks holdings, tracking error tracks the index that the etf follows. This is ' a statistical measure that quantifies the volatility of the difference in returns between the ETF and its underlying index'.
Using, aggregates and standard deviation, tracking error aims to show how consistent an etf is with tracking the index's performance, a lower tracking error the bettwe. Similar to "Deviation Percentage", VOO has the lowest tracking error.
![Tracking Error](https://github.com/user-attachments/assets/4757f103-17a0-418b-af5c-a995ea60f2ea)

### Industry Makeup

To continue with risk reduction, I then found the industry makeup of each etf by finding the distinct company symbol, reading that csv into Python and extracing the industry data with yfinance and loops. Code can by found in the file [US_etfs.ipynb](https://github.com/JasonSTLee/Retirement-Analysis/blob/main/US_etfs.ipynb). In the stacked bar graph below, only the top 20 industries based on weight are visuzlied because I wanted to see how concentrated the top 20 are. VOO is in the middle compared with the other etfs, only being beaten by a total US market etf, and international etf. VOO is again the winner here.
![Industry Makeup per ETF](https://github.com/user-attachments/assets/391b936f-ee70-476d-b9f7-17a4ce3d4914)


For these reasons, I have chosen VOO to chose as my US based etf to invest in for my retirement plan.

## Putting it all together

As mentioned in the beginning, I also chose AVUV (small cap US based etf) and VXUS (international etf, excluding US) as the other etfs to invest in. AVUV has strong yoy returns and a diverse industry makeup that doesn't include tech in their top 20 as shown below. This was particularly attractive to me because VOO has a fair bit of tech concentration.
![AVUV top 20 industries](https://github.com/user-attachments/assets/7df5ad61-313c-48bb-a00f-4121e2730491)
After finding the avg yoy return of AVUV and VXUS I was able to calculate the retirement amount based on my personal allocation of each etf, monthly contributions, initial investment and capital gains tax. Below is a screenshot of the yoy return. This shows how important compound growth is to a retirement portfolio, even the initial invesment and monthly contributions are relatively low. Calculations can be found in the file [retirement.ipynb](https://github.com/JasonSTLee/Retirement-Analysis/blob/main/retirement.ipynb). 

![Compound Growth](https://github.com/user-attachments/assets/0baa7739-c012-4f0f-b109-b843b4020fbe)
I wanted to calculate the gross, taxed, and net amount as well. Information regarding capital gains tax in California can be found [here](https://smartasset.com/investing/california-capital-gains-tax).

![Net Amount](https://github.com/user-attachments/assets/7db786a4-d8af-4f85-b819-6d371860593c)
