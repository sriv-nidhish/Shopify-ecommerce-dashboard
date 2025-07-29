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
),
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
Visual details are available in **[Fulfillment Analysis Dashboard]([<your-Tableau-link-2>](https://public.tableau.com/views/FulfillmentAnalysis_17529260505260/FulfillmentDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link))**

#### Business Implications
Return and cancellation volumes peak immediately after the holiday surge—classic “January remorse.” The data recommends enhancing fit guides and size charts before the next seasonal promotion, and implementing automated return-label workflows to cut processing costs and protect customer satisfaction.

### Chapter 3 – Customer Analysis

#### Rationale
Retaining an existing buyer is typically five times less costly than acquiring a new one. A rising proportion of repeat customers is therefore a leading indicator of sustainable lifetime value (LTV).

#### SQL Excerpt






