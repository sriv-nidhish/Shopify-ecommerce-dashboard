-- CTE 1: Monthly Sales per SKU
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

-- CTE 2: Total Sales per SKU
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

-- Final Join
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
