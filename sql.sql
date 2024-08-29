-- Creating all tables 


CREATE TABLE etf_weights (
	etf VARCHAR(10),
	holding VARCHAR(200),
	symbol VARCHAR(101),
	weighting VARCHAR(200)
)

CREATE TABLE etf_historical (
	etf VARCHAR(200),
	"date" VARCHAR(200),
	close NUMERIC,
	volume NUMERIC,
	dividends NUMERIC
)
	
CREATE TABLE etf_info (
	etf VARCHAR(10),
	inception_date DATE,
	AUM NUMERIC,
	expense_ratio VARCHAR(200),
	tracked_index VARCHAR(200)
)

CREATE TABLE index_returns (
	"year" VARCHAR(200),
	yoy NUMERIC,
	index VARCHAR(200)
)

CREATE TABLE stock_industry (
	symbol VARCHAR(200),
	industry VARCHAR(200),
	sector VARCHAR(200)
)

CREATE TABLE stock_20_historical (
	etf VARCHAR(200),
	inception_date VARCHAR(200),
	close NUMERIC,
	volume NUMERIC
)

	
-- Getting the top 20 distinct stocks based on weights of all etfs. Then using Python / yfinance to get historical data

	
with cte as (
	SELECT
		etf, symbol, (REPLACE(weighting, '%', ''))::numeric as weight
	FROM
		etf_weights
), cte2 as (
	SELECT
		etf, symbol, weight, DENSE_RANK() OVER(PARTITION BY etf ORDER BY weight desc) rnk
	FROM
		cte
	WHERE
		symbol != '2330'
		and
		symbol != 'Other'
)
SELECT
	DISTINCT symbol
FROM
	cte2
WHERE
	rnk < 20

	
-- Getting stocks based on weights to get industry and sector data on YFinance on Python

	
SELECT
    DISTINCT symbol
FROM
    etf_weights
WHERE
    symbol ~ '^[A-Za-z]+$'


-- Cleaning all the tables


SELECT
	REPLACE(REPLACE(etf, 'yfinance.Ticker object <', ''), '>', ''), "date"::date, close, volume, dividends
FROM
	etf_historical


SELECT
	etf, inception_date, aum, (REPLACE(expense_ratio, '%', ''))::numeric, tracked_index
FROM
	etf_info

	
SELECT
	etf, holding, symbol, (REPLACE(weighting, '%', ''))::numeric
FROM
	etf_weights


SELECT	
	REPLACE(REPLACE(etf, 'yfinance.Ticker object <', ''), '>', ''), inception_date::date, close, volume
FROM
	stock_20_historical


SELECT
	REPLACE(REPLACE(symbol, 'yfinance.Ticker object <', ''), '>', ''), industry, sector
FROM
	stock_industry


-- Calculating the YoY return of etf_historical and stock20_historical and tracking error

	
CREATE  TABLE tracking_error as (
	with cte as (
		SELECT
			etf, MIN(date) min_date, MAX(date) max_date
		FROM
			etf_historical
		GROUP BY 
			etf, EXTRACT(year FROM date)
		ORDER BY
			etf, min_date
	), cte2 as (
		SELECT
			c.etf as etf, 
			EXTRACT(year from c.min_date) as "year", 
			min_date, max_date, 
			me.close as min_close, 
			mxe.close as max_close, 
			((mxe.close - me.close) / me.close) * 100 as etf_yoy,
			ei.tracked_index,
			ir.yoy as index_yoy
		FROM
			cte c 
		JOIN
			etf_historical me ON c.etf = me.etf and c.min_date = me.date
		JOIN
			etf_historical mxe ON c.etf = mxe.etf and c.max_date = mxe.date
		JOIN
			etf_info ei ON c.etf = ei.etf
		JOIN
			index_returns ir ON ir.index = ei.tracked_index and ir.year = (EXTRACT(year from c.min_date))::varchar
	), cte3 as (
		SELECT
			etf, tracked_index, "year", etf_yoy, index_yoy, etf_yoy - index_yoy as yoy_diff
		FROM
			cte2
	)
	SELECT
		etf,
		STDDEV(yoy_diff) as tracking_error
	FROM
		cte3
	GROUP BY
		etf
)


-- Find the industry makeup of all etfs


CREATE  TABLE industry_makeup as (
with cte as (
	SELECT
		etf, 
		industry, 
		SUM(weight) weighted_industry,
		DENSE_RANK() OVER(PARTITION BY etf ORDER BY SUM(weight) DESC) rnk
	FROM
		etf_weights ew
	JOIN
		stock_industry si ON ew.symbol = si.symbol
	GROUP BY
		etf, industry
	ORDER BY
		etf, weighted_industry DESC
)
SELECT	
	etf, industry, weighted_industry
FROM
	cte
WHERE
	rnk <= 20
)


-- Find the avg and median of dividends for each ticker


CREATE  TABLE dividends as (
	SELECT
		etf, ROUND(AVG(dividends), 2) average, ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dividends))::numeric, 2) as median
	FROM
		etf_historical
	WHERE
		dividends > 0
	GROUP BY
		etf
)

-- Finding the average weighted performance of top 20 stock of each etf, average return of etf, and deviatoin


CREATE  TABLE stock20_etf_deviation as (
	with stock_cte as (
		SELECT
			symbol, MIN(date) min_date, MAX(date) max_date
		FROM
			stock20_historical
		GROUP BY 
			symbol, EXTRACT(year FROM "date")
	), stock_cte2 as (
		SELECT
			c.symbol as symbol, 
			EXTRACT(year from c.min_date) as "year",  
			((sxe.close - se.close) / se.close) * 100 as yoy
		FROM
			stock_cte c 
		JOIN
			stock20_historical se ON c.symbol = se.symbol and c.min_date = se.date
		JOIN
			stock20_historical sxe ON c.symbol = sxe.symbol and c.max_date = sxe.date
	), stock_cte3 as (
		SELECT
			symbol, 
			AVG(yoy) as yoy
		FROM
			stock_cte2
		GROUP BY
			symbol
	), stock_cte4 as (
		SELECT
			ew.etf, 
			c.symbol,
			c.yoy,
			ew.weight, 
			c.yoy * (ew.weight / 100) as weight_yoy
		FROM
			stock_cte3 c
		JOIN
			etf_weights ew ON c.symbol = ew.symbol
	), stock_cte5 as (
		SELECT	
			etf, 
			SUM(weight_yoy) return_stocks20 
		FROM	
			stock_cte4
		GROUP BY
			etf
	), etf_cte1 as (
		SELECT
			etf, MIN(date) min_date, MAX(date) max_date
		FROM
			etf_historical
		GROUP BY 
			etf, EXTRACT(year FROM date)
		ORDER BY
			etf, min_date
	), etf_cte2 as (
		SELECT
			c.etf as etf, 
			EXTRACT(year from c.min_date) as "year", 
			((mxe.close - me.close) / me.close) * 100 as etf_yoy
		FROM
			etf_cte1 c 
		JOIN
			etf_historical me ON c.etf = me.etf and c.min_date = me.date
		JOIN
			etf_historical mxe ON c.etf = mxe.etf and c.max_date = mxe.date
	), etf_cte3 as (
		SELECT
			etf, AVG(etf_yoy) return_etf
		FROM
			etf_cte2
		GROUP BY
			etf
	)
	SELECT	
		s.etf, 
		ROUND(return_stocks20,2) as return_stocks20, 
		ROUND(return_etf,2) as return_etf,
		ROUND(((return_stocks20 - return_etf) / return_etf), 2) as deviation
	FROM
		stock_cte5 s 
	JOIN
		etf_cte3 e ON s.etf = e.etf
)
	

-- Finding periods of negative returns for each etf with their index counterpart


CREATE  TABLE negative_returns as (
	with cte as (
		SELECT
			etf, MIN(date) min_date, MAX(date) max_date
		FROM
			etf_historical
		GROUP BY 
			etf, EXTRACT(year FROM date)
		ORDER BY
			etf, min_date
	), cte2 as (
		SELECT
			c.etf as etf, 
			EXTRACT(year from c.min_date) as "year", 
			min_date, max_date, 
			me.close as min_close, 
			mxe.close as max_close, 
			((mxe.close - me.close) / me.close) * 100 as etf_yoy,
			ei.tracked_index,
			ir.yoy as index_yoy
		FROM
			cte c 
		JOIN
			etf_historical me ON c.etf = me.etf and c.min_date = me.date
		JOIN
			etf_historical mxe ON c.etf = mxe.etf and c.max_date = mxe.date
		JOIN
			etf_info ei ON c.etf = ei.etf
		JOIN
			index_returns ir ON ir.index = ei.tracked_index and ir.year = (EXTRACT(year from c.min_date))::varchar
	), cte3 as (
		SELECT
			etf, tracked_index, "year", etf_yoy, index_yoy, etf_yoy - index_yoy as yoy_diff
		FROM
			cte2
	)
	SELECT
		etf, tracked_index, "year", etf_yoy, index_yoy
	FROM
		cte3
	WHERE
		index_yoy < 0
		or
		index_yoy < 0
)


-- Finding the average return 


CREATE TABLE etf_avg_return as (
	with cte as (
		SELECT
			etf, MIN(date) min_date, MAX(date) max_date
		FROM
			etf_historical
		GROUP BY 
			etf, EXTRACT(year FROM date)
		ORDER BY
			etf, min_date
	), cte2 as (
		SELECT
			c.etf as etf, 
			EXTRACT(year from c.min_date) as "year", 
			min_date, max_date, 
			me.close as min_close, 
			mxe.close as max_close, 
			((mxe.close - me.close) / me.close) * 100 as etf_yoy,
			ei.tracked_index,
			ir.yoy as index_yoy
		FROM
			cte c 
		JOIN
			etf_historical me ON c.etf = me.etf and c.min_date = me.date
		JOIN
			etf_historical mxe ON c.etf = mxe.etf and c.max_date = mxe.date
		JOIN
			etf_info ei ON c.etf = ei.etf
		JOIN
			index_returns ir ON ir.index = ei.tracked_index and ir.year = (EXTRACT(year from c.min_date))::varchar
	)
	SELECT
		etf, AVG(etf_yoy)
	FROM
		cte2
	GROUP BY
		etf
)


-- Creating the copy line in query tool to then copy and paste in PSQL tool
	
\copy (SELECT * FROM negative_returns) TO '/Users/admin/Desktop/stock research/final output csvs/negative returns.csv' WITH CSV HEADER;

