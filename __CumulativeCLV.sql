WITH cohort_data AS (
    -- Get the cohort start date (first visit week) for each user
    SELECT
        user_pseudo_id,
        DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS cohort_start_week,
        -- Truncate to the week of first visit
        MIN(PARSE_DATE('%Y%m%d', event_date)) AS cohort_start_date -- The date of their first visit
    FROM
        `tc-da-1.turing_data_analytics.raw_events`
    WHERE
        event_name = 'first_visit' -- Only consider first visit event
    GROUP BY
        user_pseudo_id,
        cohort_start_week
),
weekly_revenue AS (
    -- Calculate the total revenue per user in each week after their cohort start date
    SELECT
        c.user_pseudo_id,
        c.cohort_start_week,
        DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS event_week,
        DATE_DIFF(DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK), DATE_TRUNC(c.cohort_start_date, WEEK), WEEK) AS weeks_after_signup,
        SUM(purchase_revenue_in_usd) AS total_weekly_revenue
    FROM
        `tc-da-1.turing_data_analytics.raw_events` e
    JOIN
        cohort_data c ON e.user_pseudo_id = c.user_pseudo_id
    GROUP BY
        c.user_pseudo_id,
        c.cohort_start_week,
        event_week,
        weeks_after_signup
),
cohort_revenue AS (
 -- Summarize the total revenue per cohort week and calculate cumulative revenue
    SELECT
        cohort_start_week,
        weeks_after_signup,
        SUM(total_weekly_revenue) AS total_revenue_per_week,
        -- Calculate the cumulative sum of revenue over the weeks
        SUM(SUM(total_weekly_revenue)) OVER (
            PARTITION BY cohort_start_week
            ORDER BY weeks_after_signup ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM
        weekly_revenue
    GROUP BY
        cohort_start_week,
        weeks_after_signup
),
cohort_size AS (
    -- Get the cohort size (number of users) for each cohort start week
    SELECT
        cohort_start_week,
        COUNT(DISTINCT user_pseudo_id) AS cohort_size
    FROM
        cohort_data
    GROUP BY
        cohort_start_week
)
-- Join cohort size and revenue data to show final cohort analysis
SELECT
    cs.cohort_start_week,
    cs.cohort_size,
    SUM(CASE WHEN weeks_after_signup = 0 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_0,
    SUM(CASE WHEN weeks_after_signup = 1 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_1,
    SUM(CASE WHEN weeks_after_signup = 2 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_2,
    SUM(CASE WHEN weeks_after_signup = 3 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_3,
    SUM(CASE WHEN weeks_after_signup = 4 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_4,
    SUM(CASE WHEN weeks_after_signup = 5 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_5,
    SUM(CASE WHEN weeks_after_signup = 6 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_6,
    SUM(CASE WHEN weeks_after_signup = 7 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_7,
    SUM(CASE WHEN weeks_after_signup = 8 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_8,
    SUM(CASE WHEN weeks_after_signup = 9 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_9,
    SUM(CASE WHEN weeks_after_signup = 10 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_10,
    SUM(CASE WHEN weeks_after_signup = 11 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_11,
    SUM(CASE WHEN weeks_after_signup = 12 THEN cumulative_revenue / cohort_size END) AS cumulative_revenue_week_12
FROM
    cohort_size cs
LEFT JOIN
    cohort_revenue cr ON cs.cohort_start_week = cr.cohort_start_week
GROUP BY
    cs.cohort_start_week,
    cs.cohort_size
ORDER BY
    cs.cohort_start_week;
