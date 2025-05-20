WITH
  cohort_data AS (
    -- Get the cohort start date (first visit week) for each user
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS cohort_start_date -- The date of their first visit
  FROM
    `tc-da-1.turing_data_analytics.raw_events`
  GROUP BY
    user_pseudo_id),
  weekly_revenue AS (
    -- Calculate the total revenue per user in each week after their cohort start date
  SELECT
    c.user_pseudo_id,
    c.cohort_start_date,
    DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS event_week, -- Truncate event date to the week
    DATE_DIFF(DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK), DATE_TRUNC(c.cohort_start_date, WEEK), WEEK) AS weeks_after_signup, -- Weeks after signup
    SUM(purchase_revenue_in_usd) AS total_weekly_revenue
  FROM
    `tc-da-1.turing_data_analytics.raw_events` e
  LEFT JOIN
    cohort_data c
  ON
    e.user_pseudo_id = c.user_pseudo_id
  GROUP BY
    c.user_pseudo_id,
    c.cohort_start_date,
    event_week,
    event_date),
  cohort_summary AS (
    -- Summarize the total revenue and user count per cohort start week
  SELECT
    DATE_TRUNC(cohort_start_date, WEEK) AS cohort_start_week,
    weeks_after_signup,
    SUM(total_weekly_revenue) AS total_revenue_per_week,
    COUNT(DISTINCT user_pseudo_id) AS users_per_cohort
  FROM
    weekly_revenue
  GROUP BY
    cohort_start_week,
    weeks_after_signup ),
  cohort_size AS (
  -- Get the cohort size (number of users) for each cohort start week
  SELECT
    DATE_TRUNC(cohort_start_date, WEEK) AS cohort_start_week,
    COUNT(DISTINCT user_pseudo_id) AS cohort_size
  FROM
    cohort_data
  GROUP BY
    cohort_start_week )
  --  Join cohort size and revenue data to show final cohort analysis
SELECT
  cs.cohort_start_week,
  cs.cohort_size,
  SUM(CASE
      WHEN weeks_after_signup = 0 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_0,
  SUM(CASE
      WHEN weeks_after_signup = 1 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_1,
  SUM(CASE
      WHEN weeks_after_signup = 2 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_2,
  SUM(CASE
      WHEN weeks_after_signup = 3 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_3,
  SUM(CASE
      WHEN weeks_after_signup = 4 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_4,
  SUM(CASE
      WHEN weeks_after_signup = 5 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_5,
  SUM(CASE
      WHEN weeks_after_signup = 6 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_6,
  SUM(CASE
      WHEN weeks_after_signup = 7 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_7,
  SUM(CASE
      WHEN weeks_after_signup = 8 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_8,
  SUM(CASE
      WHEN weeks_after_signup = 9 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_9,
  SUM(CASE
      WHEN weeks_after_signup = 10 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_10,
  SUM(CASE
      WHEN weeks_after_signup = 11 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_11,
  SUM(CASE
      WHEN weeks_after_signup = 12 THEN total_revenue_per_week / cohort_size
  END
    ) AS revenue_week_12
FROM
  cohort_size cs
LEFT JOIN
  cohort_summary cr
ON
  cs.cohort_start_week = cr.cohort_start_week
GROUP BY
  cs.cohort_start_week,
  cs.cohort_size
ORDER BY
  cs.cohort_start_week;
