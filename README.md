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

| order_id | order_date  | total_amount |
|----------|-------------|--------------|
| 1001     | 2024-01-15  | 124.99       |
| 1002     | 2024-01-16  | 89.00        |
| 1003     | 2024-01-17  | 150.75       |

*Result preview:* [`/output/business_overview.csv`](output/business overview.csv)

#### Dashboard
Explore the interactive view here: **[Business Overview Dashboard](https://public.tableau.com/views/BusinessOverview_17529259584830/BusinessOverview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications
The analysis confirms a pronounced holiday surge in November-December, with AOV expanding more rapidly than order volume—evidence that upsell bundles were effective. Management should therefore maintain bundle placements and continue A/B-testing price breaks that encourage larger baskets.

### Chapter 2 – Fulfillment Analysis

#### Rationale
Cancelled or returned orders erode revenue and inflate logistics costs; industry benchmarks place e-commerce return rates above 16 percent. Understanding when and where these events spike is essential for operational efficiency.

#### SQL Excerpt




