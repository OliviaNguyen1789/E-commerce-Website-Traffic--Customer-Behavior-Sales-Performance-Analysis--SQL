 --Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month) 
  
  SELECT 
      FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month
      ,SUM(totals.visits) AS visits
      ,SUM(totals.pageviews) AS pageviews
      ,SUM(totals.transactions) AS transactions
      ,ROUND(SUM(totals.totalTransactionRevenue/1000000),2) AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
  GROUP BY 1
  ORDER BY 1;


--Query 02: Bounce rate per traffic source in July 2017

SELECT
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.Bounces) AS total_no_of_bounces,
    ROUND(SUM(totals.Bounces)/SUM(totals.visits)* 100.00,2) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY 1
ORDER BY 2 DESC;


-- Query 3: Revenue by traffic source by week, by month in June 2017

  WITH monthly_revenue AS (
    SELECT 
        'Month' AS time_type
        ,FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS time
        ,trafficSource.source AS source
        ,ROUND(SUM(product.productRevenue)/1000000, 2) AS revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
        ,UNNEST  (hits) AS hits
        ,UNNEST (hits.product) AS product
    WHERE product.productRevenue IS NOT NULL
    GROUP BY  1, 2, 3
    ORDER BY 3
)
, weekly_revenue AS (
    SELECT
        'Week' AS time_type
        ,FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d',date)) AS time
        ,trafficSource.source AS source
        ,ROUND(SUM(product.productRevenue)/1000000, 2) AS revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
        ,UNNEST (hits) AS hits
        ,UNNEST (hits.product) AS product
    WHERE product.productRevenue IS NOT NULL
    GROUP BY 1, 2, 3
    ORDER BY 3, 2
)

  SELECT *
  FROM monthly_revenue
  UNION ALL
  SELECT *
  FROM weekly_revenue
  ORDER BY revenue DESC;



-- Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.

WITH
purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) as month,
      ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid),2) AS avg_pageviews_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
        ,UNNEST(hits) hits
        ,UNNEST(product) product
  WHERE  _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions>=1
  AND product.productRevenue IS NOT NULL
  GROUP BY 1
),

non_purchaser_data AS(
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) as month,
      ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid),2) AS avg_pageviews_non_purchase,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
       ,UNNEST(hits) hits
       ,UNNEST(product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  AND totals.transactions IS NULL
  AND product.productRevenue IS NULL
  GROUP BY 1
)

SELECT
    pd.*,
    avg_pageviews_non_purchase
FROM purchaser_data pd
FULL JOIN non_purchaser_data USING(month)
ORDER BY pd.month;



-- Query 05: Average number of transactions per user that made a purchase in July 2017

  SELECT
      FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS Month
      ,ROUND(SUM(totals.transactions)/COUNT (DISTINCT fullVisitorId),4) AS Avg_total_transactions_per_user
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
      ,UNNEST (hits) AS hits
      ,UNNEST (hits.product) AS product
  WHERE eCommerceAction.action_type = '6'
        AND product.productRevenue IS NOT NULL
  GROUP BY 1;


-- Query 06: Average amount of money spent per session. Only include purchaser data in July 2017

  SELECT 
      FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS Month
      ,ROUND(SUM(product.productRevenue)/SUM(totals.visits)/1000000,2) AS avg_revenue_by_user_per_visit
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
      ,UNNEST (hits) AS hits
      ,UNNEST (hits.product) AS product
  WHERE totals.transactions IS NOT NULL 
        AND product.productRevenue IS NOT NULL
  GROUP BY 1;


-- Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017.

  SELECT 
      product.v2ProductName AS other_purchased_products
      ,sum(product.productQuantity) AS quantity
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
        ,UNNEST (hits) AS hits
        ,UNNEST (hits.product) AS product
  WHERE product.productRevenue IS NOT NULL 
      AND product.v2ProductName <> "YouTube Men's Vintage Henley"
      AND fullVisitorId IN (
            SELECT 
                DISTINCT fullVisitorId
            FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
                ,UNNEST (hits) AS hits
                ,UNNEST (hits.product) AS product
            WHERE v2ProductName = "YouTube Men's Vintage Henley"
            AND  product.productRevenue IS NOT NULL 
            ORDER BY fullVisitorId
        )
  GROUP BY 1
  ORDER BY 2 DESC;


-- "Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. 
  
WITH product_data AS(
SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) AS num_product_view,
    COUNT(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) AS num_add_to_cart,
    COUNT(CASE WHEN eCommerceAction.action_type = '6' AND product.productRevenue IS NOT NULL THEN product.v2ProductName END) AS num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    ,UNNEST(hits) AS hits
    ,UNNEST (hits.product) AS product
WHERE _table_suffix BETWEEN '20170101' AND '20170331'
      AND eCommerceAction.action_type IN ('2','3','6')
GROUP BY 1
ORDER BY 1
)

SELECT
    *,
    ROUND(num_add_to_cart/num_product_view * 100, 2) AS add_to_cart_rate,
    ROUND(num_purchase/num_product_view * 100, 2) AS purchase_rate
FROM product_data;



