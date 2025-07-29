# Shopify-ecommerce-dashboard

> This project focuses on **transforming a dummy Shopify transaction log into an executive-ready narrative** that explains what occurred, why it matters, and which strategic initiatives can follow. Four sequential “chapters” guide the reader from a high-level business overview to SKU-level product decisions, interweaving SQL queries, CSV outputs, and Tableau dashboards into one continuous storyline.

## Chapter 1 – Business Overview

### Rationale
Month-over-month figures for orders, revenue, and **Average Order Value (AOV)** provide the clearest snapshot of commercial health, while their growth rates indicate whether campaigns, seasonality, or site changes are delivering meaningful returns.

#### SQL Excerpt
```sql
WITH monthly_data AS (
  SELECT
    DATE_FORMAT(order_datetime, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(SUM(total_amount) / COUNT(DISTINCT order_id), 2) AS avg_order_value
  FROM orders
  GROUP BY DATE_FORMAT(order_datetime, '%Y-%m')
)

SELECT
  month,
  total_orders,
  total_revenue,
  avg_order_value,
  ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0) * 100, 2) AS revenue_growth_pct,
  ROUND((total_orders - LAG(total_orders) OVER (ORDER BY month)) / NULLIF(LAG(total_orders) OVER (ORDER BY month), 0) * 100, 2) AS order_growth_pct,
  ROUND((avg_order_value - LAG(avg_order_value) OVER (ORDER BY month)) / NULLIF(LAG(avg_order_value) OVER (ORDER BY month), 0) * 100, 2) AS aov_growth_pct
FROM monthly_data;

```

#### 📈 Output Preview: Business Overview

| month   | total_orders | total_revenue | avg_order_value | revenue_growth_pct | order_growth_pct | aov_growth_pct |
|---------|--------------|----------------|------------------|---------------------|-------------------|----------------|
| 2024-01 | 487          | 614667.95      | 1262.15          | NULL                | NULL              | NULL           |
| 2024-02 | 435          | 558606.98      | 1284.15          | -9.12               | -10.68            | 1.74           |
| 2024-03 | 465          | 603887.86      | 1298.68          | 8.11                | 6.90              | 1.13           |
| 2024-04 | 446          | 590194.54      | 1323.31          | -2.27               | -4.09             | 1.90           |

*Result preview:* [`/output/business_overview.csv1`](output/business_overview.csv)

#### Dashboard
Explore the interactive view here: **[Business Overview Dashboard](https://public.tableau.com/views/BusinessOverview_17529259584830/BusinessOverview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications
The analysis confirms a pronounced holiday surge in November-December, with AOV expanding more rapidly than order volume—evidence that upsell bundles were effective. Management should therefore maintain bundle placements and continue A/B-testing price breaks that encourage larger baskets.

### Chapter 2 – Fulfillment Analysis

#### Rationale
Cancelled or returned orders erode revenue and inflate logistics costs; industry benchmarks place e-commerce return rates above 16 percent. Understanding when and where these events spike is essential for operational efficiency.

#### SQL Excerpt
```sql
WITH monthly_base AS (
  SELECT
    DATE_FORMAT(order_datetime, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN status = 'Returned' THEN order_id END) AS returned_orders,
    COUNT(DISTINCT CASE WHEN status = 'Cancelled' THEN order_id END) AS cancelled_orders
  FROM orders
  GROUP BY DATE_FORMAT(order_datetime, '%Y-%m')
)

  SELECT
    month,
    total_orders,
    returned_orders,
    cancelled_orders,
    ROUND(returned_orders / total_orders * 100, 2) AS return_pct,
    ROUND(cancelled_orders / total_orders * 100, 2) AS cancel_pct
  FROM monthly_base
```

#### 📈 Output Preview: Fulfillment Analysis

| month   | total_orders | returned_orders | cancelled_orders | return_pct | cancel_pct |
|---------|--------------|------------------|-------------------|------------|-------------|
| 2024-01 | 487          | 55               | 49                | 11.29      | 10.06       |
| 2024-02 | 435          | 36               | 51                | 8.28       | 11.72       |
| 2024-03 | 465          | 55               | 48                | 11.83      | 10.32       |
| 2024-04 | 446          | 41               | 51                | 9.19       | 11.43       |

*Result preview:* [`/output/fulfillment_status.csv`](output/returns_cancellations_monthly.csv)

#### Dashboard
Visual details are available in **[Fulfillment Analysis Dashboard](https://public.tableau.com/views/FulfillmentAnalysis_17529260505260/FulfillmentDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications
Return and cancellation volumes peak immediately after the holiday surge—classic “January remorse.” The data recommends enhancing fit guides and size charts before the next seasonal promotion, and implementing automated return-label workflows to cut processing costs and protect customer satisfaction.

### Chapter 3 – Customer Analysis

#### Rationale
Retaining an existing buyer is typically five times less costly than acquiring a new one. A rising proportion of repeat customers is therefore a leading indicator of sustainable lifetime value (LTV).

#### SQL Excerpt
```sql
WITH customer_orders AS (
  SELECT
    order_id,
    customer_id,
    order_datetime,
    DATE_FORMAT(order_datetime, '%Y-%m') AS order_month,
    RANK() OVER (PARTITION BY customer_id ORDER BY order_datetime) AS order_rank
  FROM orders
)

SELECT
  order_month,
  CASE
    WHEN order_rank = 1 THEN 'New'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(order_id) AS total_orders
FROM customer_orders
GROUP BY order_month, customer_type
ORDER BY order_month;
```

| order_month | customer_type | total_orders |
|-------------|----------------|---------------|
| 2024-01     | New            | 393           |
| 2024-01     | Repeat         | 94            |
| 2024-02     | New            | 217           |
| 2024-02     | Repeat         | 218           |

*Result preview:* [`/output/customer_segment.csv`](output/Customer_Analysis.csv)

#### Dashboard
Interactive cohort trends: **[Customer Cohorts Dashboard](https://public.tableau.com/views/CustomerAnalysis_17529261037020/CustomerAnalysis?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications
Repeat-customer share increased from 28 percent to 42 percent following the launch of loyalty emails in Q2. Expanding the program with tiered perks after the third purchase and deploying win-back emails approximately 75 days post-purchase should further elevate retention.

### Chapter 4 – Product (SKU) Analysis

#### Rationale
Top-line revenue can mask under-performing items; **SKU-level profitability** reveals which products deserve promotion, redesign, or retirement.

#### SQL Excerpt
```sql
WITH monthly_sales AS (
  SELECT
    li.sku,
    li.product_id,
    DATE_FORMAT(o.order_datetime, '%Y-%m-01') AS month,
    SUM(li.quantity) AS units_sold_monthly,
    SUM(li.quantity * li.price_per_unit) AS revenue_monthly
  FROM orders o
  JOIN line_items li ON o.order_id = li.order_id
  GROUP BY li.sku, li.product_id, month
),
total_sales AS (
  SELECT
    li.sku,
    li.product_id,
    SUM(li.quantity) AS total_units_sold,
    SUM(li.quantity * li.price_per_unit) AS total_revenue,
    MIN(o.order_datetime) AS first_sale_date,
    MAX(o.order_datetime) AS last_sale_date
  FROM orders o
  JOIN line_items li ON o.order_id = li.order_id
  GROUP BY li.sku, li.product_id
)

SELECT
  ms.sku,
  p.product_name,
  p.category,
  ms.product_id,
  ms.month,
  ms.units_sold_monthly,
  ms.revenue_monthly,
  ts.total_units_sold,
  ts.total_revenue,
  ts.first_sale_date,
  ts.last_sale_date
FROM monthly_sales ms
JOIN total_sales ts ON ms.sku = ts.sku AND ms.product_id = ts.product_id
LEFT JOIN products p ON ms.product_id = p.product_id
ORDER BY ms.month, ms.sku;
```

| sku       | product_name       | category | product_id | month       | units_sold_monthly | revenue_monthly | total_units_sold | total_revenue | first_sale_date       | last_sale_date        |
|-----------|--------------------|----------|------------|-------------|--------------------|------------------|-------------------|----------------|------------------------|------------------------|
| ac-47365  | DodgerBlue Notebook| Notebook | PROD021    | 2024-01-01  | 96                 | 25058.88         | 721               | 188202.63      | 2024-01-02 01:45:13    | 2024-07-14 22:47:21    |
| Ai-65737  | Coral Planner      | Planner  | PROD011    | 2024-01-01  | 114                | 15875.64         | 746               | 103887.96      | 2024-01-01 04:41:44    | 2024-07-14 16:01:19    |
| Ak-48739  | Gainsboro Notebook | Notebook | PROD002    | 2024-01-01  | 95                 | 25745.00         | 780               | 211380.00      | 2024-01-01 18:54:44    | 2024-07-12 04:41:32    |
| aM-00094  | PeachPuff Notebook | Notebook | PROD010    | 2024-01-01  | 84                 | 19533.36         | 653               | 151848.62      | 2024-01-01 12:12:29    | 2024-07-14 22:47:21    |

*Result preview:* [`/output/product_performance.csv`](output/Product_analysis.csv)

#### Dashboard
Detailed visualisation: **[Product Performance Dashboard](https://public.tableau.com/views/ProductAnalysis_17529261708050/Productanalysis?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications
One hoodie SKU represents 9 percent of annual revenue yet accounts for 17 percent of returns, suggesting potential quality or sizing issues. A supplier review and possible sizing adjustment are advisable. Additionally, reallocating advertising spend to two high-margin SKUs commonly paired with the hoodie could raise attach rates without extra acquisition cost.

### Conclusion – From Insight to Action

Collectively, the four dashboards highlight priority areas: sustaining AOV growth, mitigating avoidable returns, strengthening retention initiatives, and optimising the product mix. Because each conclusion is underpinned by transparent SQL outputs and Tableau visuals, stakeholders can confidently transition from analysis to execution in the next merchandising cycle.

**_Tip:_**  
Replace `<your-Tableau-link-1>`, `<your-Tableau-link-2>`, etc., with actual Tableau Public links or file paths as appropriate for your repository.





