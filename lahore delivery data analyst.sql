-- Month-Over-Month (MoM) Growth Analysis 
USE Lahore;

WITH formatted_orders AS (
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(order_datetime, '%c/%e/%Y'), 
            '%Y-%m'
        ) AS order_month,
        order_id,
        order_value_pkr,
        CASE 
            WHEN UPPER(TRIM(CAST(is_cancelled AS CHAR))) IN ('TRUE', '1', 'T')
                 OR LOWER(TRIM(order_status)) IN ('cancelled', 'canceled', 'cancel') THEN 1 
            ELSE 0 
        END AS is_cancelled_flag
    FROM orders
),
monthly_metrics AS (
    SELECT
        order_month,
        COUNT(order_id) AS total_orders,
        COUNT(CASE WHEN is_cancelled_flag = 0 THEN 1 END) AS completed_orders,
        SUM(order_value_pkr) AS gross_revenue_pkr
    FROM formatted_orders
    WHERE order_month IS NOT NULL
    GROUP BY order_month
),
monthly_trends AS (
    SELECT
        order_month,
        total_orders,
        completed_orders,
        gross_revenue_pkr,
        LAG(total_orders, 1) OVER (ORDER BY order_month) AS prev_month_orders,
        LAG(gross_revenue_pkr, 1) OVER (ORDER BY order_month) AS prev_month_revenue
    FROM monthly_metrics
)
SELECT
    order_month,
    total_orders,
    prev_month_orders,
    ROUND(((total_orders - prev_month_orders) * 100.0 / NULLIF(prev_month_orders, 0)), 2) AS mom_order_growth_pct,
    gross_revenue_pkr,
    prev_month_revenue,
    ROUND(((gross_revenue_pkr - prev_month_revenue) * 100.0 / NULLIF(prev_month_revenue, 0)), 2) AS mom_revenue_growth_pct
FROM monthly_trends
ORDER BY order_month ASC;