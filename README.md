[SQL]: Explore Ecommerce Dataset  
Author: [Uyen Nguyen]  
Date: September 2024  
Tools Used: SQL 

---

## 📑 Table of Contents  
I.  [Introduction](#i-introduction)  
II. [Dataset Description](#ii-dataset-description)  
III. [Exploring the Dataset](#iii-exploring-the-dataset)  
IV. [Key Insights & Visualizations](#-key-insights--visualizations)  
V. [Final Conclusion & Recommendations](#-final-conclusion--recommendations)

---

## I. Introduction

This project analyzes an e-commerce dataset using advanced SQL techniques on Google BigQuery, including sliding windows, CTEs, and date-time manipulation.
The objectives are:
- Improving the company's revenue.
- Understanding customer behavior.

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

<img width="635" alt="Screen Shot 2025-03-03 at 6 29 52 AM" src="https://github.com/user-attachments/assets/548e3f83-f046-46b2-b8c3-8b384a3001d4" />

<img width="751" alt="Screen Shot 2025-03-03 at 6 34 29 AM" src="https://github.com/user-attachments/assets/ee3368da-de50-4528-ae1b-f4668217c140" />

The results indicate that website traffic remained steady in Q1 2017, with a significant rise in transactions in March (933), suggesting either enhanced conversion rates or seasonal influences.

### Query 02: Bounce rate per traffic source in July 2017

<img width="752" alt="Screen Shot 2025-03-02 at 3 10 07 PM" src="https://github.com/user-attachments/assets/ff1c6040-39d9-4e3b-b85a-4c5546365955" />

<img width="672" alt="Screen Shot 2025-03-03 at 6 41 33 AM" src="https://github.com/user-attachments/assets/93b104cf-9237-4321-8e20-656918f941e0" />

The majority of traffic (80%) comes from Google and direct sources. Traffic from Google is twice that of direct sources, but the bounce rate for direct traffic is lower (43% vs. 52%). 

### Query 03: Revenue by traffic source by week, by month in June 2017

<img width="816" alt="Screen Shot 2025-03-02 at 2 31 36 PM" src="https://github.com/user-attachments/assets/1adb7a1f-cc38-4b17-b588-806c2e3d0468" />

<img width="816" alt="Screen Shot 2025-03-02 at 2 33 04 PM" src="https://github.com/user-attachments/assets/cae00493-8665-4c18-9d74-e7c8b5ef3e59" />

<img width="552" alt="Screen Shot 2025-03-03 at 7 00 52 AM" src="https://github.com/user-attachments/assets/af661e0a-af04-4b7a-8b9e-cd5ca8141812" />

Regarding revenue, direct traffic consistently drives the highest value weekly and monthly, while Google rank as the second-largest source.

### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017

<img width="719" alt="Screen Shot 2025-03-03 at 7 18 13 AM" src="https://github.com/user-attachments/assets/79c98182-52fd-4bfa-9a75-deb300bc2ae4" />

<img width="717" alt="Screen Shot 2025-03-03 at 7 19 08 AM" src="https://github.com/user-attachments/assets/a896241a-42cc-4ce0-ba34-cf6ce6549eaa" />

<img width="779" alt="Screen Shot 2025-03-02 at 2 57 44 PM" src="https://github.com/user-attachments/assets/8185796a-bb75-4a5e-b90d-f35e83a4e6f3" />

On average, the number of pageviews for non-purchasers is double that of purchasers. In July, both groups experienced a sharp increase in average pageviews, with purchasers experiencing a larger relative rise. 

Non-purchasers tend to browse many pages without making a purchase, indicating potential issues with usability, pricing, or the checkout process.

### Query 05: Average number of transactions per user that made a purchase in July 2017
<img width="1064" alt="Screen Shot 2025-03-02 at 2 46 10 PM" src="https://github.com/user-attachments/assets/beceb328-81ea-427b-a73e-5a1205897c76" />

<img width="568" alt="Screen Shot 2025-03-02 at 2 47 11 PM" src="https://github.com/user-attachments/assets/19dec8d9-5f63-4745-a074-4a0755306802" />



### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
<img width="1043" alt="Screen Shot 2025-03-02 at 2 43 51 PM" src="https://github.com/user-attachments/assets/89901927-3b7d-4896-8104-33f8c2870ba3" />

<img width="525" alt="Screen Shot 2025-03-02 at 2 45 21 PM" src="https://github.com/user-attachments/assets/f5424a3b-3d22-4720-bc43-77a10aa0bc93" />





### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017

<img width="845" alt="Screen Shot 2025-03-02 at 3 06 56 PM" src="https://github.com/user-attachments/assets/1c3441fb-8ad8-40c0-b014-98f7d72194c8" />


<img width="642" alt="Screen Shot 2025-03-02 at 2 42 58 PM" src="https://github.com/user-attachments/assets/156fd04f-1387-4fbf-b2af-b766fe0be36b" />

### Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017
<img width="1065" alt="Screen Shot 2025-03-02 at 3 04 53 PM" src="https://github.com/user-attachments/assets/77458655-87a3-483c-b910-6cf7880615c5" />

<img width="938" alt="Screen Shot 2025-03-02 at 2 38 40 PM" src="https://github.com/user-attachments/assets/59363f95-36b9-4e3a-8ae7-c80d8bc7fe33" />


## Key Insights & Visualizations  

### 🔍 Dashboard Preview  

#### 1️⃣ Dashboard 1 Preview  
👉🏻 Insert Power BI dashboard screenshots here  

📌 Analysis 1:  
- Observation: _Describe trends, key metrics, and patterns._  
- Recommendation: _Suggest actions based on insights._  

#### 2️⃣ Dashboard 2 Preview  
👉🏻 Insert Power BI dashboard screenshots here

📌 Analysis 2:   
- Observation: _Describe trends, key metrics, and patterns._  
- Recommendation: _Suggest actions based on insights._  

#### 3️⃣ Dashboard 3 Preview  
👉🏻 Insert Power BI dashboard screenshots here  

📌 Analysis 3:  
- Observation: _Describe trends, key metrics, and patterns._  
- Recommendation: _Suggest actions based on insights._  

---

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
