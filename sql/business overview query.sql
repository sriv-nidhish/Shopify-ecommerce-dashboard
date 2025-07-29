WITH monthly_data AS (
  SELECT
    DATE_FORMAT(order_datetime, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(SUM(total_amount) / COUNT(DISTINCT order_id), 2) AS avg_order_value
  FROM orders
  GROUP BY DATE_FORMAT(order_datetime, '%Y-%m')
),

monthly_growths AS (
  SELECT
    month,
    total_orders,
    total_revenue,
    avg_order_value,

    ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0) * 100, 2) AS revenue_growth_pct,
    ROUND((total_orders - LAG(total_orders) OVER (ORDER BY month)) / NULLIF(LAG(total_orders) OVER (ORDER BY month), 0) * 100, 2) AS order_growth_pct,
    ROUND((avg_order_value - LAG(avg_order_value) OVER (ORDER BY month)) / NULLIF(LAG(avg_order_value) OVER (ORDER BY month), 0) * 100, 2) AS aov_growth_pct

  FROM monthly_data
)

SELECT * FROM monthly_growths;
