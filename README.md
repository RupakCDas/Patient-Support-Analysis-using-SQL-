# Patient-Support-Analysis &nbsp;(Using SQL)
UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate and receive support for their health care needs – whether that's claims and benefits support, drug coverage, pre- and post-authorisation, medical records, emergency assistance, or member portal services.
### Project Objectives

### Key Questions Answered
- PART 1. &ensp; Find which UHG policy holders made three, or more calls, assuming each call is identified
by the case_id column.


- PART 2. &ensp;  Calculate the percentage of calls that cannot be categorised. 
Round your answer to 1 decimal place.


- PART3. &ensp; Obtain the number of unique callers who made calls 
within a 7-day interval of their previous calls. 
If a caller made more than two calls within the 7-day period, count them only once.


- PART 4. &ensp; Determine the month-over-month growth rate specifically for long-calls. 
A long-call is defined as any call lasting more than 5 minutes (300 seconds).
Output the year and month in numerical format and chronological order, number of calls in each month, 
along with the growth percentage rounded to 1 decimal place.


- PART 5. &ensp; Determines which call categories dominate a specific user's interaction time. 
It calculates the total time spent per category and uses a window function to find the percentage 
that category represents relative to the user's total call time.


- PART 6. &ensp; Classifies policy holders into engagement tiers (High, Medium, Low) based on their 
total call volume, and then ranks users within each tier based on their longest single call duration.
### Data Description

#### Data Dictionary 
### Tool Used
## SQL Analysis and Questions
##### PART 1. &ensp; Find which UHG policy holders made three, or more calls, assuming each call is identified by the case_id column.

```sql
SELECT 
policy_holder_id,
COUNT(case_id) AS calls 
FROM data_b
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3 ;
```
