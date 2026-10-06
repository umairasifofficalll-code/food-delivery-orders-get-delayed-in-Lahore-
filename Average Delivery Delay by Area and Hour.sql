-- CREATE DATABASE Lahore;
#SELECT * FROM Lahore.csv_records;
#RENAME TABLE csv_records TO orders;
-- 1. Average Delivery Delay by Area and Hour
USE Lahore;
WITH normalized_orders AS (
    SELECT 
        TRIM(UPPER(area)) AS cleaned_area,
        order_hour,
        delivery_time_min,
        total_duration_min,
        CASE 
            WHEN UPPER(TRIM(CAST(is_delayed AS CHAR))) IN ('TRUE', '1', 'T') THEN 1 
            ELSE 0 
        END AS delayed_flag
    FROM orders
    WHERE LOWER(TRIM(order_status)) NOT IN ('cancelled', 'canceled', 'cancel')
      AND (
          is_cancelled IS NULL 
          OR UPPER(TRIM(CAST(is_cancelled AS CHAR))) IN ('FALSE', '0', 'F', '')
      )
      AND area IS NOT NULL
      AND TRIM(area) NOT IN ('-', 'Unknow')
)
SELECT 
    cleaned_area AS area,
    order_hour,
    COUNT(*) AS total_delivered_orders,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time_min,
    ROUND(AVG(total_duration_min), 2) AS avg_total_duration_min,
    ROUND(AVG(delayed_flag) * 100, 2) AS delay_rate_pct
FROM normalized_orders
GROUP BY cleaned_area, order_hour
ORDER BY cleaned_area, order_hour;