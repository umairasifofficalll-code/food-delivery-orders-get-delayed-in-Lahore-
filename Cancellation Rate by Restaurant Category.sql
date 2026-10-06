-- Cancellation Rate by Restaurant Category 
USE Lahore;
WITH clean_categories AS (
    SELECT
        CASE 
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%fast%' THEN 'Fast Food'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%pizza%' THEN 'Pizza'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%karahi%' THEN 'Karahi / Handi'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%biryani%' OR LOWER(TRIM(restaurant_category)) LIKE '%briyani%' THEN 'Biryani'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%desi%' OR LOWER(TRIM(restaurant_category)) LIKE '%bbq%' THEN 'Desi / BBQ'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%chinese%' THEN 'Chinese'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%cafe%' OR LOWER(TRIM(restaurant_category)) LIKE '%drink%' THEN 'Cafe & Drinks'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%dessert%' OR LOWER(TRIM(restaurant_category)) LIKE '%bakery%' THEN 'Desserts & Bakery'
            WHEN LOWER(TRIM(restaurant_category)) LIKE '%health%' OR LOWER(TRIM(restaurant_category)) LIKE '%salad%' THEN 'Healthy'
            ELSE TRIM(restaurant_category)
        END AS standardized_category,
        CASE 
            WHEN is_cancelled IN ('True', 'true', '1', 't') OR is_cancelled = TRUE 
                 OR LOWER(TRIM(order_status)) IN ('cancelled', 'canceled', 'cancel') THEN 1 
            ELSE 0 
        END AS is_cancelled_flag
    FROM orders
),
category_aggregates AS (
    SELECT
        standardized_category,
        COUNT(*) AS total_orders,
        SUM(is_cancelled_flag) AS cancelled_orders,
        COUNT(*) - SUM(is_cancelled_flag) AS completed_orders
    FROM clean_categories
    GROUP BY standardized_category
)
SELECT
    standardized_category,
    total_orders,
    completed_orders,
    cancelled_orders,
    ROUND((cancelled_orders * 100.0 / NULLIF(total_orders, 0)), 2) AS cancellation_rate_pct
FROM category_aggregates
ORDER BY cancellation_rate_pct DESC;