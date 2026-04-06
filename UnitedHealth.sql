SELECT * FROM united_health.data_b;

/*PART 1. Find which UHG policy holders made three, or more calls, assuming each call is identified 
by the case_id column.*/

SELECT 
policy_holder_id,
COUNT(case_id) AS calls 
FROM data_b
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3 ;

/*PART 2. Calculate the percentage of calls that cannot be categorised. 
Round your answer to 1 decimal place. */
WITH null_call AS (
SELECT COUNT(case_id) AS nc
FROM data_b
WHERE call_category IS NULL OR
call_category = 'n/a'
)
SELECT 
ROUND(100.0 * nc / (SELECT COUNT(case_id) FROM data_b),1 
) AS null_calls 
FROM null_call;

/* PART3. Obtain the number of unique callers who made calls 
within a 7-day interval of their previous calls. 
If a caller made more than two calls within the 7-day period, count them only once.
*/
WITH c AS (
SELECT policy_holder_id,
DATE_FORMAT(call_date,"%Y-%m-%d") AS f_call,
LEAD(DATE_FORMAT(call_date,"%Y-%m-%d")) OVER(PARTITION BY policy_holder_id ORDER BY call_date) AS next_call
FROM data_b
ORDER BY policy_holder_id, call_date ASC)
SELECT DISTINCT COUNT( policy_holder_id)
FROM c 
WHERE DATEDIFF( next_call, f_call) <= 7 AND next_call IS NOT NULL
ORDER BY policy_holder_id;

/*PART 4.Determine the month-over-month growth rate specifically for long-calls. 
A long-call is defined as any call lasting more than 5 minutes (300 seconds).
Output the year and month in numerical format and chronological order, number of calls in each month, 
along with the growth percentage rounded to 1 decimal place.
*/
WITH long_calls AS (
  SELECT 
    EXTRACT(YEAR FROM call_date) AS yr,
    EXTRACT(MONTH FROM call_date) AS mth,
    COUNT(case_id) AS curr_mth_calls,
    LAG(COUNT(case_id)) OVER (
      ORDER BY EXTRACT(MONTH FROM call_date)) AS prev_mth_calls
FROM data_b
WHERE call_duration_secs > 300
GROUP BY 
  EXTRACT(YEAR FROM call_date),
  EXTRACT(MONTH FROM call_date)
)
SELECT
  yr,
  mth,
  curr_mth_calls,
  ROUND(100.0 * 
    (curr_mth_calls - prev_mth_calls)/prev_mth_calls,1) AS long_calls_growth
FROM long_calls
ORDER BY yr, mth;

/* PART 5. Determines which call categories dominate a specific user's interaction time. 
It calculates the total time spent per category and uses a window function to find the percentage 
that category represents relative to the user's total call time.
*/
WITH category AS (
    SELECT 
        policy_holder_id,
        call_category,
        SUM(call_duration_secs) AS category_duration,
        SUM(SUM(call_duration_secs)) OVER (PARTITION BY policy_holder_id) AS total_call_duration_by_holder
    FROM data_b
    GROUP BY policy_holder_id, call_category
)
SELECT 
    policy_holder_id,
    call_category,
    category_duration,
    CONCAT( ROUND((100.0 * category_duration ) / total_call_duration_by_holder, 2)," "'%') AS call_duration_pct_by_holder
FROM category
WHERE total_call_duration_by_holder> 0
ORDER BY policy_holder_id ASC, call_duration_pct_by_holder DESC;

/* PART 6. Classify policy holders into engagement tiers (High, Medium, Low) based on their 
total call volume, and then ranks users within each tier based on their longest single call duration.
*/
WITH users AS (
    SELECT 
        policy_holder_id,
        SUM(call_duration_secs) as total_duration,
        MAX(call_duration_secs) as max_call_duration
    FROM data_b
    GROUP BY policy_holder_id
),
cases AS (
    SELECT 
        *,
        CASE 
            WHEN total_duration > 6000 THEN 'High Engagement'
            WHEN total_duration > 3000 THEN 'Medium Engagement'
            ELSE 'Low Engagement'
        END as engagement_tier
    FROM users
)
SELECT 
    policy_holder_id,
    total_duration,
    max_call_duration,
    engagement_tier,
    RANK() OVER (PARTITION BY engagement_tier ORDER BY max_call_duration DESC) as rank_in_tier,
    COUNT(policy_holder_id) OVER(PARTITION BY engagement_tier) AS total_in_tier
FROM cases
ORDER BY total_duration DESC, rank_in_tier;
