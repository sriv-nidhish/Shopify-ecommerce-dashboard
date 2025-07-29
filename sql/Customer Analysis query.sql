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
