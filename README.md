<img width="1000" alt="Screen Shot 2025-03-15 at 11 02 40 PM" src="https://github.com/user-attachments/assets/8610ec6a-da97-4de0-9b21-527e2b32f6d3" />



# E-commerce Website Traffic - Customer Behavior & Sales Performance Analysis | SQL
Author: [Uyen Nguyen]  
Date: September 2024  
Tools Used: SQL 

---

## 📑 Table of Contents  
I. [📌 Background & Overview](#-background--overview)  
II. [📂 Dataset Description](#-dataset-description)  
III. [📊 Exploring the Dataset](#-exploring-the-dataset)  
IV. [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## 📌 Background & Overview

### 📖 What is this project about?
The objective of this project is to analyze website traffic on an e-commerce platform to gain deeper insights into customer behavior and sales performance. This involves conducting a comprehensive traffic analysis and multi-channel evaluation, leveraging SQL techniques on Google BigQuery - Subquery, CTEs, and date-time manipulatio - to extract meaningful insights. The findings will be used to provide data-driven recommendations aimed at optimizing marketing strategies and enhancing overall business performance.

### 👤 Who is this project for?  
Marketing and Sales teams


## 📂 Dataset Description

### 🌐 Source: 
- The e-commerce dataset is stored in a public Google BigQuery dataset.
To access the dataset, we log in to Google Cloud Platform, navigate to the BigQuery console and enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions".
- Size: Over 5000 rows 
### 🔀  Data Structure:
  <details>
    <summary>Show data structure </summary>
    
  | Field Name                       | Data Type | Description                                                                                                                 |
|----------------------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| fullVisitorId                    | STRING    | The unique visitor ID. |
| date                             | STRING    | The date of the session in YYYYMMDD format.|
| totals                           | RECORD    | This section contains aggregate values across the session. |
| totals.bounces                   | INTEGER   | Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null. |
| totals.hits                      | INTEGER   | Total number of hits within the session. |
| totals.pageviews                 | INTEGER   | Total number of pageviews within the session. |
| totals.visits                    | INTEGER   | The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session.|
| totals.transactions              | INTEGER   | Total number of ecommerce transactions within the session.|
| trafficSource.source             | STRING    | The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the utm_source URL parameter. |
| hits                             | RECORD    | This row and nested fields are populated for any and all types of hits.|
| hits.eCommerceAction             | RECORD    | This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected. |
| hits.eCommerceAction.action_type | STRING    | The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0. Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view"). Example query to calculate number of products in list views: SELECT COUNT(hits.product.v2ProductName) FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.product.isImpression == TRUE Example query to calculate number of products in detailed view: SELECT COUNT(hits.product.v2ProductName), FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.ecommerceaction.action_type = '2' AND ( BOOLEAN(hits.product.isImpression) IS NULL OR BOOLEAN(hits.product.isImpression) == FALSE ) |
| hits.product                     | RECORD    | This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data.|
| hits.product.productQuantity     | INTEGER   | The quantity of the product purchased.   |
| hits.product.productRevenue      | INTEGER   | The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000).|
| hits.product.productSKU          | STRING    | Product SKU. |
| hits.product.v2ProductName       | STRING    | Product Name.|

  </details>

## 📊 Exploring the Dataset

### Query 01: Calculate total visit, pageview, transaction and revenue for January, February and March 2017 order by month
> Provide an overview of recent trends over the past few months to assess engagement levels by analyzing total visits, page views, transactions, and revenue.

```sql
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
```
<img width="644" alt="Screen Shot 2025-03-03 at 10 36 35 AM" src="https://github.com/user-attachments/assets/72fa1185-5867-44fb-9a03-7e4874374f92" />

🚀 The results indicate that website traffic witnessed a significant rise in March (933), suggesting either enhanced conversion rates or seasonal influences.

### Query 02: Bounce rate per traffic source in July 2017
> A bounce rate indicates that customers who visited the website left without making a purchase.

```sql
SELECT
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.Bounces) AS total_no_of_bounces,
    ROUND(SUM(totals.Bounces)/SUM(totals.visits)* 100.00,2) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY 1
ORDER BY 2 DESC;
```

<img width="658" alt="Screen Shot 2025-03-03 at 10 37 27 AM" src="https://github.com/user-attachments/assets/379c7391-77b1-405f-86fe-8e696e93a860" />

🚀 The majority of traffic (80%) comes from Google and direct sources. Traffic from Google is twice that of direct sources, but the bounce rate for direct traffic is lower (43% vs. 52%). 

### Query 03: Revenue by traffic source by week, by month in June 2017
> Calculate revenue by traffic source helps assess marketing effectiveness, identify trends, and optimize resource allocation.

```sql
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
```

<img width="470" alt="Screen Shot 2025-03-03 at 10 38 14 AM" src="https://github.com/user-attachments/assets/ae8aaca2-0f91-493e-ad0e-8088454c9f27" />

🚀 Regarding revenue, direct traffic consistently drives the highest value weekly and monthly, while Google rank as the second-largest source.

### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
> Analyze user engagement differences between purchasers and non-purchasers to optimize conversion strategies.

```sql
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
```

<img width="650" alt="Screen Shot 2025-03-03 at 10 38 31 AM" src="https://github.com/user-attachments/assets/f0f8ff39-d229-45aa-afcd-94500af1f5b1" />

🚀 On average, the number of pageviews for non-purchasers is double that of purchasers. In July, both groups experienced a sharp increase in average pageviews, with purchasers experiencing a larger relative rise. 

🚀 Non-purchasers tend to browse many pages without making a purchase, indicating potential issues with usability, pricing, or the checkout process.

### Query 05: Average number of transactions per user that made a purchase in July 2017
>  Assess customer loyalty and repeat purchase behavior via calculating average number of transactions.
```sql
SELECT
      FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS Month
      ,ROUND(SUM(totals.transactions)/COUNT (DISTINCT fullVisitorId),4) AS Avg_total_transactions_per_user
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
      ,UNNEST (hits) AS hits
      ,UNNEST (hits.product) AS product
  WHERE eCommerceAction.action_type = '6'
        AND product.productRevenue IS NOT NULL
  GROUP BY 1;
```

<img width="499" alt="Screen Shot 2025-03-03 at 10 38 49 AM" src="https://github.com/user-attachments/assets/04e76e46-34a3-4648-aa34-84da0a9f2304" />

🚀 On average, users who made a purchase in July 2017 completed 4.16 transactions.

### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
> Evaluate the spending behavior and profitability of customers during their sessions.

```sql
SELECT 
      FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS Month
      ,ROUND(SUM(product.productRevenue)/SUM(totals.visits)/1000000,2) AS avg_revenue_by_user_per_visit
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
      ,UNNEST (hits) AS hits
      ,UNNEST (hits.product) AS product
  WHERE totals.transactions IS NOT NULL 
        AND product.productRevenue IS NOT NULL
  GROUP BY 1;
```

<img width="460" alt="Screen Shot 2025-03-03 at 10 39 04 AM" src="https://github.com/user-attachments/assets/ceef365d-cdcf-4aaa-998c-34b4a6723e45" />

🚀 In July 2017, purchasers spent an average of $43.86 per session. This figure offers valuable insights into website performance and consumer spending behaviors. 


### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017
> Identify cross-selling opportunities and customer preferences to optimize product recommendations.

```sql
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
```

<img width="539" alt="Screen Shot 2025-03-03 at 10 39 32 AM" src="https://github.com/user-attachments/assets/c6984b1d-2d63-485a-9400-0df2febdc23e" />

🚀 In July 2017, an analysis of customer behavior revealed that individuals who purchased the YouTube Men's Vintage Henley also showed a strong preference for other Google-branded casual wear and accessories, particularly sunglasses. 

🚀 This trend indicates a high level of brand loyalty among customers who use Google's product lines, including Google, YouTube, and Android.


### Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017
> To analyze the efficiency of the buying process and customers' behavior from product view to add-to-cart to purchase within a specific time period 

```sql
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
```

<img width="956" alt="Screen Shot 2025-03-03 at 10 40 03 AM" src="https://github.com/user-attachments/assets/9e7b1445-5d2d-4cc2-83c7-dd0e132baf9f" />

🚀 Between January and March 2017, conversion rates from product views to add-to-cart actions and purchases improved steadily, even though there was a slight decline in the number of products viewed. March experienced the highest engagement, with a 37.29% add-to-cart rate and a 12.64% purchase rate. This enhanced efficiency in converting browsers to buyers may result from improved marketing strategies or a better user experience.

## 🔎 Final Conclusion & Recommendations 

This analysis offers valuable insights into customer behavior, sales patterns, and website performance, enabling businesses to identify effective marketing and sales strategies to optimize their performance. To enhance revenue, the following recommendations are proposed:

- Enhancing customer's experience by improving website' usability, checkout process.. since this could lead to higher conversion rates and lower bounce rate.
- Boosting cross-selling opportunities among branded items.
- Identifying marketing channels that attract the most profitable visitors (Google, direct), facilitating the optimization of marketing strategies and budget distribution.

By leveraging big data analytics, businesses can make data-driven decisions, enhancing their performance and fostering their growth.
