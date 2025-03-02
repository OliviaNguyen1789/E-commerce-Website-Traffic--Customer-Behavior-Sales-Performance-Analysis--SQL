[SQL]: Explore Ecommerce Dataset  
Author: [Uyen Nguyen]  
Date: September 2024  
Tools Used: SQL 

---

## 📑 Table of Contents  
I. [Introduction](#i-introduction)  
II. [Dataset Description](#ii-dataset-description)  
III. [Exploring the Dataset](#iii-exploring-the-dataset)  
IV. [Final Conclusion & Recommendations](#iv-final-conclusion--recommendations)

---

## I. Introduction

This project analyzes an e-commerce dataset using advanced SQL techniques on Google BigQuery, including sliding windows, CTEs, and date-time manipulation.
The objectives are:
- Improving the company's revenue.
- Understanding customer behavior to optimize conversion rates 

This analysis will help the Marketing and Sales teams make strategic, data-driven decisions to enhance business outcomes.

## II. Dataset Description

- Source: The e-commerce dataset is stored in a public Google BigQuery dataset.
  
  https://console.cloud.google.com/bigquery?project=extreme-course-435303-q8&ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801
-  Data Structure:
  
  | Field Name                       | Data Type | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|----------------------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
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



## III. Exploring the Dataset

### Query 01: Calculate total visit, pageview, transaction and revenue for January, February and March 2017 order by month

<img width="642" alt="Screen Shot 2025-03-03 at 10 17 40 AM" src="https://github.com/user-attachments/assets/90863a21-ac42-4f00-8c05-30ef29471cc3" />

<img width="644" alt="Screen Shot 2025-03-03 at 10 36 35 AM" src="https://github.com/user-attachments/assets/72fa1185-5867-44fb-9a03-7e4874374f92" />


The results indicate that website traffic witnessed a significant rise in March (933), suggesting either enhanced conversion rates or seasonal influences.

### Query 02: Bounce rate per traffic source in July 2017

<img width="676" alt="Screen Shot 2025-03-03 at 10 19 39 AM" src="https://github.com/user-attachments/assets/d7ecc565-56a1-4710-a104-d7e945a62334" />

<img width="658" alt="Screen Shot 2025-03-03 at 10 37 27 AM" src="https://github.com/user-attachments/assets/379c7391-77b1-405f-86fe-8e696e93a860" />

The majority of traffic (80%) comes from Google and direct sources. Traffic from Google is twice that of direct sources, but the bounce rate for direct traffic is lower (43% vs. 52%). 

### Query 03: Revenue by traffic source by week, by month in June 2017

<img width="674" alt="Screen Shot 2025-03-03 at 10 24 02 AM" src="https://github.com/user-attachments/assets/99def861-1b85-4b42-ad6c-4ddd54ed65ac" />

<img width="682" alt="Screen Shot 2025-03-03 at 10 24 30 AM" src="https://github.com/user-attachments/assets/f577cf45-0d75-4fcb-abbb-b32c72ec9b34" />

<img width="470" alt="Screen Shot 2025-03-03 at 10 38 14 AM" src="https://github.com/user-attachments/assets/ae8aaca2-0f91-493e-ad0e-8088454c9f27" />


Regarding revenue, direct traffic consistently drives the highest value weekly and monthly, while Google rank as the second-largest source.

### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017

<img width="645" alt="Screen Shot 2025-03-03 at 10 25 44 AM" src="https://github.com/user-attachments/assets/a1560a5f-48d0-4682-b70b-fb317acad941" />

<img width="642" alt="Screen Shot 2025-03-03 at 10 26 19 AM" src="https://github.com/user-attachments/assets/a7ef29fd-3d7e-470a-90b4-b86cd49fa0d3" />

<img width="650" alt="Screen Shot 2025-03-03 at 10 38 31 AM" src="https://github.com/user-attachments/assets/f0f8ff39-d229-45aa-afcd-94500af1f5b1" />


On average, the number of pageviews for non-purchasers is double that of purchasers. In July, both groups experienced a sharp increase in average pageviews, with purchasers experiencing a larger relative rise. 

Non-purchasers tend to browse many pages without making a purchase, indicating potential issues with usability, pricing, or the checkout process.

### Query 05: Average number of transactions per user that made a purchase in July 2017

<img width="659" alt="Screen Shot 2025-03-03 at 10 27 32 AM" src="https://github.com/user-attachments/assets/a4c7e4d8-68c3-484a-8aac-7d7fe4f5f5c3" />

<img width="499" alt="Screen Shot 2025-03-03 at 10 38 49 AM" src="https://github.com/user-attachments/assets/04e76e46-34a3-4648-aa34-84da0a9f2304" />

On average, users who made a purchase in July 2017 completed 4.16 transactions.

### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017

<img width="654" alt="Screen Shot 2025-03-03 at 10 29 04 AM" src="https://github.com/user-attachments/assets/862304d9-02dc-42fc-97c9-a86f91b0caef" />

<img width="460" alt="Screen Shot 2025-03-03 at 10 39 04 AM" src="https://github.com/user-attachments/assets/ceef365d-cdcf-4aaa-998c-34b4a6723e45" />

In July 2017, purchasers spent an average of $43.86 per session. This figure offers valuable insights into website performance and consumer spending behaviors. 


### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017

<img width="735" alt="Screen Shot 2025-03-03 at 10 30 28 AM" src="https://github.com/user-attachments/assets/7ac32662-1608-499d-966a-2ea7f03cc6fe" />

<img width="539" alt="Screen Shot 2025-03-03 at 10 39 32 AM" src="https://github.com/user-attachments/assets/c6984b1d-2d63-485a-9400-0df2febdc23e" />

In July 2017, an analysis of customer behavior revealed that individuals who purchased the YouTube Men's Vintage Henley also showed a strong preference for other Google-branded casual wear and accessories, particularly sunglasses. 

This trend indicates a high level of brand loyalty among customers who use Google's product lines, including Google, YouTube, and Android.


### Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017

<img width="964" alt="Screen Shot 2025-03-03 at 10 33 57 AM" src="https://github.com/user-attachments/assets/8d058741-1dbc-4897-be5b-e03257bb99d6" />

<img width="956" alt="Screen Shot 2025-03-03 at 10 40 03 AM" src="https://github.com/user-attachments/assets/9e7b1445-5d2d-4cc2-83c7-dd0e132baf9f" />

Between January and March 2017, conversion rates from product views to add-to-cart actions and purchases improved steadily, even though there was a slight decline in the number of products viewed. March experienced the highest engagement, with a 37.29% add-to-cart rate and a 12.64% purchase rate. This enhanced efficiency in converting browsers to buyers may result from improved marketing strategies or a better user experience.

## IV. Final Conclusion & Recommendations 

This analyis offer an insight into customer behavior, sales pattern, and website performance, thereby enabling business to dentify effective marketing and sales trategies to optimize their performance. Particularly, this e-commerce company can apply below recommendations to increase their revenue:

- Improving customer's experience via improving website' usability, checkout process.. since this could lead to higher conversion rates and lower bounce rate.
- Boosting cross-selling opportunities among branded items.
- Identifying marketing channels that attract the most profitable visitors (Google, direct), facilitating the optimization of marketing strategies and budget distribution.

Overall, by leveraging big data analytics, the project provides a foundation for data-driven decision-making, enabling the business to enhance their performance and growth in the competitive e-commerce landscape.





