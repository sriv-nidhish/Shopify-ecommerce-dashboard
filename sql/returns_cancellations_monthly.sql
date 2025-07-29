WITH monthly_base AS (
  SELECT
    DATE_FORMAT(order_datetime, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN status = 'Returned' THEN order_id END) AS returned_orders,
    COUNT(DISTINCT CASE WHEN status = 'Cancelled' THEN order_id END) AS cancelled_orders
  FROM orders
  GROUP BY DATE_FORMAT(order_datetime, '%Y-%m')
),

monthly_percentages AS (
  SELECT
    month,
    total_orders,
    returned_orders,
    cancelled_orders,
    ROUND(returned_orders / total_orders * 100, 2) AS return_pct,
    ROUND(cancelled_orders / total_orders * 100, 2) AS cancel_pct
  FROM monthly_base
)

SELECT * FROM monthly_percentages
ORDER BY month;
