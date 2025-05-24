-- 1. What is the total amount each customer spent in the restaurant?
SELECT
  s.customer_id,
  SUM(m.price) AS total_spent
FROM
  sales s
JOIN
  menu m ON s.product_id = m.product_id
GROUP BY
  s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS visit_days
FROM
  sales
GROUP BY
  customer_id;

-- 3. What was the first item from the menu purchased by each customer?
-- 3. What was the first item from the menu purchased by each customer?
SELECT
  s.customer_id,
  MIN(s.order_date) AS first_order_date,
  m.product_name AS first_item
FROM
  sales s
JOIN
  menu m ON s.product_id = m.product_id
WHERE
  s.order_date = (
    SELECT MIN(order_date)
    FROM sales
    WHERE customer_id = s.customer_id
  )
GROUP BY
  s.customer_id, m.product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  s.customer_id,
  m.product_name,
  COUNT(*) AS times_ordered
FROM
  sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN (
    SELECT
      m2.product_id
    FROM
      sales s2
      JOIN menu m2 ON s2.product_id = m2.product_id
    GROUP BY
      m2.product_id
    ORDER BY
      COUNT(*) DESC
    LIMIT 1
  ) most_purchased ON s.product_id = most_purchased.product_id
GROUP BY
  s.customer_id, m.product_name;

-- 5. Which item was the most popular for each customer?
WITH customer_item_counts AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS purchase_count,
    ROW_NUMBER() OVER (
      PARTITION BY s.customer_id
      ORDER BY COUNT(s.product_id) DESC
    ) AS rn
  FROM
    sales s
  JOIN
    menu m ON s.product_id = m.product_id
  GROUP BY
    s.customer_id, m.product_name
)
SELECT
  customer_id,
  product_name,
  purchase_count
FROM
  customer_item_counts
WHERE
  rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT
  s.customer_id,
  s.order_date AS first_purchase_date,
  m.product_name AS first_item_after_member
FROM
  sales s
JOIN
  members mem ON s.customer_id = mem.customer_id
JOIN
  menu m ON s.product_id = m.product_id
WHERE
  s.order_date = (
    SELECT MIN(order_date)
    FROM sales
    WHERE customer_id = s.customer_id
      AND order_date >= mem.join_date
  )
  AND s.order_date >= mem.join_date
ORDER BY
  s.customer_id;

-- 7. Which item was purchased just before the customer became a member?
SELECT
  s.customer_id,
  s.order_date AS last_purchase_date_before_member,
  m.product_name AS last_item_before_member
FROM
  sales s
JOIN
  members mem ON s.customer_id = mem.customer_id
JOIN
  menu m ON s.product_id = m.product_id
WHERE
  s.order_date = (
    SELECT MAX(order_date)
    FROM sales
    WHERE customer_id = s.customer_id
      AND order_date < mem.join_date
  )
  AND s.order_date < mem.join_date
ORDER BY
  s.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
  s.customer_id,
  COUNT(*) AS total_items,
  SUM(m.price) AS total_amount_spent
FROM
  sales s
JOIN
  members mem ON s.customer_id = mem.customer_id
JOIN
  menu m ON s.product_id = m.product_id
WHERE
  s.order_date < mem.join_date
GROUP BY
  s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
      ELSE m.price * 10
    END
  ) AS total_points
FROM
  sales s
JOIN
  menu m ON s.product_id = m.product_id
GROUP BY
  s.customer_id;
  
/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January? */
SELECT
  s.customer_id,
  SUM(
    CASE
      -- First week after joining: 2x points for all items
      WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 10 * 2
      -- Sushi outside first week: 2x points
      WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
      -- All other cases: normal points
      ELSE m.price * 10
    END
  ) AS total_points
FROM
  sales s
JOIN
  members mem ON s.customer_id = mem.customer_id
JOIN
  menu m ON s.product_id = m.product_id
WHERE
  s.customer_id IN ('A', 'B')
  AND s.order_date <= '2021-01-31'
GROUP BY
  s.customer_id;