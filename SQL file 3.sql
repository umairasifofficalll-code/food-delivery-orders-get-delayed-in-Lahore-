USE Lahore;

WITH rider_stats AS (
    SELECT
        rider_id,
        vehicle_type,
        COUNT(*) AS total_trips,
        ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time_min,
        ROUND(AVG(delivery_time_min / NULLIF(distance_km, 0)), 2) AS avg_min_per_km
    FROM orders
    WHERE LOWER(TRIM(order_status)) NOT IN ('cancelled', 'canceled', 'cancel')
      AND delivery_time_min IS NOT NULL
    GROUP BY rider_id, vehicle_type
    HAVING COUNT(*) >= 50
),
ranked_riders AS (
    SELECT
        rider_id,
        vehicle_type,
        total_trips,
        avg_delivery_time_min,
        avg_min_per_km,
        CUME_DIST() OVER (ORDER BY avg_delivery_time_min DESC) AS slowness_cume_dist
    FROM rider_stats
)
SELECT
    rider_id,
    vehicle_type,
    total_trips,
    avg_delivery_time_min,
    avg_min_per_km,
    ROUND(slowness_cume_dist * 100.0, 2) AS percentile_tier
FROM ranked_riders
WHERE slowness_cume_dist <= 0.10
ORDER BY avg_delivery_time_min DESC;