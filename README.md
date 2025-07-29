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

*Result preview:* [`/output/business_overview.csv`](output/business_overview.csv)

#### Dashboard
Explore the interactive view here: **[Business Overview Dashboard](https://public.tableau.com/views/BusinessOverview_17529259584830/BusinessOverview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

#### Business Implications

The data reveals a **remarkable growth trajectory followed by predictable seasonal contraction** in this personalized stationery business. Revenue peaked in **June at $648,797** before experiencing a dramatic **59.3% decline to $264,215 in July**—a pattern consistent with academic calendar dependencies where students prepare for new semesters during spring and early summer months.

**Average Order Value demonstrates exceptional optimization success**, climbing from $1,262 in January to a peak of **$1,359 in May—a 7.7% improvement** that indicates effective upselling strategies and premium product positioning. The company achieved **$3.93 million in total revenue across 3,000 orders** over seven months, establishing a solid $1,305 average AOV that significantly exceeds typical e-commerce benchmarks.

**Quarterly performance shows strategic momentum**, with Q2 delivering **6.0% higher average monthly revenue ($628,203) compared to Q1 ($592,388)**. However, the July decline of 56.4% in order volume alongside the revenue drop signals heavy dependence on academic seasonality—a critical vulnerability requiring strategic diversification.

**Strategic recommendations include**: (1) Developing counter-seasonal product lines targeting corporate clients during summer months to smooth revenue volatility, (2) Implementing pre-order campaigns in late summer to capture back-to-school demand earlier, (3) Leveraging the proven AOV growth strategies more aggressively during peak months, and (4) Building inventory management systems that can handle the dramatic seasonal swings while maintaining profitability during slower periods.

## Chapter 2 – Fulfillment Analysis

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

The fulfillment data exposes a **critical operational challenge** that undermines the company's otherwise strong performance metrics. With a **combined return and cancellation rate of 21.2%**, the business faces substantial revenue leakage totaling an estimated **$833,618 across 637 problematic orders**—representing more than 21% of all transactions requiring costly reverse logistics.

**Returns average 10.1% while cancellations average 11.0%**, with the pattern intensifying during peak demand periods. **May showed the worst performance at 23.8% combined issues** during the highest revenue month, suggesting operational stress during scaling periods. Conversely, **June achieved the best performance at 19.7%**, indicating that peak season lessons were successfully applied.

The **4.1 percentage point swing between best and worst months** demonstrates that fulfillment quality is manageable but requires systematic intervention. For a personalized stationery business, high return rates likely indicate sizing/specification mismatches, quality control issues during rush periods, or inadequate product descriptions that fail to set proper customer expectations.

**Immediate operational priorities should focus on**: (1) Implementing enhanced quality control protocols during high-volume months to prevent the May spike pattern, (2) Developing more detailed product specifications and sizing guides to reduce customer disappointment, (3) Creating seasonal staffing plans that maintain quality standards during peak academic preparation periods, and (4) Introducing automated quality checkpoints that can scale with demand fluctuations. The **$833,618 annual revenue recovery opportunity** justifies significant investment in fulfillment optimization initiatives.

## Chapter 3 – Customer Analysis

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

The customer retention data reveals one of the most **extraordinary loyalty transformations in e-commerce**, with repeat customers surging from **19.3% in January to 94.3% in July—a remarkable 75 percentage point improvement** that fundamentally repositioned this business from acquisition-dependent to retention-driven.

**The transition occurred rapidly**, with repeat customers becoming the majority by **February at 50.1%** and reaching exceptional loyalty levels by **April at 79.8%**. This dramatic shift coincides with declining new customer acquisition, dropping from **393 new customers in January to just 12 in July**—a 97% decrease that signals either seasonal demand patterns or potential acquisition channel challenges.

**The 94.3% repeat rate achieved in July represents world-class retention performance**, particularly impressive for a stationery business where customers typically exhibit project-based purchasing behavior. This suggests the personalized nature of the products creates strong emotional attachment and habit formation among academic customers.

**Strategic implications require balanced execution**: (1) The exceptional retention success should be leveraged through loyalty program expansion, including tiered rewards for students completing multiple semesters, (2) The dramatic decline in new customer acquisition demands investigation—determining whether this reflects natural seasonal patterns or indicates marketing channel optimization needs, (3) Counter-seasonal acquisition campaigns should target professional markets during summer months when academic demand declines, and (4) The proven retention model should be documented and systematized to ensure consistency as the business scales. The transformation from 19% to 94% repeat customers provides a blueprint for sustainable, retention-driven growth that reduces dependence on costly acquisition marketing.

## Chapter 4 – Product (SKU) Analysis

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

The data reveals **critical performance disparities** across the 25-SKU product portfolio that demand immediate strategic attention. **Gainsboro Notebook (SKU: Ak-48739) emerges as the standout performer**, generating $211,380 in total revenue from 780 units sold—representing the highest revenue contribution across all products. However, this success story coexists with concerning category-level imbalances.

**Notebooks demonstrate superior monetization**, commanding an average price of $236.97 per unit compared to Planners at $184.17—a **28.7% price premium** that suggests stronger perceived value among customers. The DarkBlue Notebook (kB-53902) exemplifies this trend, achieving $303.02 per unit revenue, the highest unit economics in the entire catalog. Conversely, **three Planner SKUs underperform significantly**: the Coral Planner variants (nv-84293 and Ai-65737) generate only $99,391 and $103,887 respectively, despite selling 743-746 units each—indicating potential quality concerns or market positioning issues.

The **combined return and cancellation rate of 21.23%** across all orders represents a substantial revenue leak, peaking at 23.79% in May when both metrics spiked simultaneously. This suggests operational stress during high-demand periods, potentially linked to inventory management or quality control challenges during peak academic planning seasons.

**Strategic recommendations include**: (1) Conducting a comprehensive quality audit of the three lowest-performing Planner SKUs to identify discontinuation candidates, (2) Reallocating marketing spend toward the top-performing Notebook category, which demonstrates both high unit economics and customer acceptance, and (3) Implementing enhanced quality control measures during peak seasons to reduce the substantial 21% combined return/cancellation rate that currently undermines profitability.

## Conclusion – From Insight to Action

The comprehensive analysis across four analytical dimensions reveals a **stationery business in transition**, exhibiting both remarkable strengths and addressable operational challenges. The company achieved extraordinary **customer retention improvement from 19.3% to 93.0% repeat customers** over six months—a 73.7 percentage point increase that represents best-in-class performance for e-commerce retention. This retention success, combined with **Average Order Value growth from $1,262 to $1,359** (peak), demonstrates effective customer relationship management and successful upselling strategies.

However, the business faces **pronounced seasonality**, with a 55.8% decline from May peak to July, indicating heavy dependence on academic calendar cycles typical of the stationery sector. The **$3.93 million revenue generated from 3,000 orders** over seven months establishes a solid foundation, yet the 21.23% combined return/cancellation rate represents nearly $835,000 in potential revenue recovery opportunity.

**Category strategy requires immediate optimization**: Journals lead revenue share at 41.7%, but Notebooks deliver the highest unit economics at $236.97 average price. The data strongly suggests consolidating the SKU portfolio by discontinuing underperforming Planner variants and doubling down on the proven Notebook category where customer willingness-to-pay is demonstrably higher.

**Executive priorities for the next planning cycle should focus on**: (1) Capitalizing on the exceptional 93% repeat customer rate through targeted retention campaigns during off-peak months, (2) Addressing the substantial 21% return/cancellation issue through enhanced product descriptions and quality improvements, (3) Preparing inventory and operational capacity for the predictable seasonal surge, and (4) Reallocating product development resources toward the high-margin Notebook category while strategically pruning low-performing Planner SKUs. Because every insight derives from transparent SQL analysis and verified data outputs, leadership can execute these strategic pivots with confidence in their analytical foundation.

###Note: The analysis is based on 7 months of transactional data (January-July 2024) encompassing 25 SKUs across three product categories (Notebooks, Journals, Planners) with complete order, return, and customer behavior tracking.


