-- ============================================================
-- HR Analytics — SQL Queries
-- Table: employees (IBM HR Analytics Attrition dataset, cleaned)
-- ============================================================

-- ------------------------------------------------------------
-- Q1. Attrition rate by department, ranked  (window function: RANK)
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*)                                              AS headcount,
    SUM(AttritionFlag)                                    AS left_count,
    ROUND(AVG(AttritionFlag) * 100.0, 2)                  AS attrition_rate_pct,
    RANK() OVER (ORDER BY AVG(AttritionFlag) DESC)        AS attrition_rank
FROM employees
GROUP BY Department
ORDER BY attrition_rank;


-- ------------------------------------------------------------
-- Q2. Attrition rate by job role, with each role's share of
--     total company attrition  (CTE + window function: SUM OVER)
-- ------------------------------------------------------------
WITH role_attrition AS (
    SELECT
        JobRole,
        COUNT(*)                        AS headcount,
        SUM(AttritionFlag)              AS left_count,
        AVG(AttritionFlag) * 100.0      AS attrition_rate_pct
    FROM employees
    GROUP BY JobRole
)
SELECT
    JobRole,
    headcount,
    left_count,
    ROUND(attrition_rate_pct, 2)                                   AS attrition_rate_pct,
    ROUND(left_count * 100.0 / SUM(left_count) OVER (), 2)         AS pct_of_all_leavers
FROM role_attrition
ORDER BY attrition_rate_pct DESC;


-- ------------------------------------------------------------
-- Q3. Overtime vs. attrition — is working overtime linked to
--     people leaving?
-- ------------------------------------------------------------
SELECT
    OverTime,
    COUNT(*)                             AS headcount,
    ROUND(AVG(AttritionFlag) * 100.0, 2) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 0)         AS avg_monthly_income,
    ROUND(AVG(JobSatisfaction), 2)       AS avg_job_satisfaction
FROM employees
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;


-- ------------------------------------------------------------
-- Q4. Salary analysis — gender pay comparison within the same
--     job level (controls for seniority, so it's a fair comparison)
-- ------------------------------------------------------------
SELECT
    JobLevel,
    Gender,
    COUNT(*)                        AS headcount,
    ROUND(AVG(MonthlyIncome), 0)    AS avg_monthly_income,
    ROUND(MIN(MonthlyIncome), 0)    AS min_income,
    ROUND(MAX(MonthlyIncome), 0)    AS max_income
FROM employees
GROUP BY JobLevel, Gender
ORDER BY JobLevel, Gender;


-- ------------------------------------------------------------
-- Q5. Salary vs. tenure — are long-tenured employees actually
--     paid more, or is pay flat regardless of years at company?
--     (window function: AVG OVER for a company-wide baseline)
-- ------------------------------------------------------------
SELECT DISTINCT
    TenureBand,
    ROUND(AVG(MonthlyIncome) OVER (PARTITION BY TenureBand), 0) AS avg_income_this_band,
    ROUND(AVG(MonthlyIncome) OVER (), 0)                        AS company_avg_income
FROM employees
ORDER BY
    CASE TenureBand
        WHEN '0-1 yr' THEN 1 WHEN '2-3 yrs' THEN 2 WHEN '4-6 yrs' THEN 3
        WHEN '7-10 yrs' THEN 4 ELSE 5
    END;


-- ------------------------------------------------------------
-- Q6. Hiring trend by year  (derived HireYear; see 01_clean_data.py
--     for the methodology note) with year-over-year change
--     (window function: LAG)
-- ------------------------------------------------------------
WITH yearly AS (
    SELECT HireYear, COUNT(*) AS hires
    FROM employees
    GROUP BY HireYear
)
SELECT
    HireYear,
    hires,
    hires - LAG(hires) OVER (ORDER BY HireYear) AS change_vs_prior_year
FROM yearly
ORDER BY HireYear;


-- ------------------------------------------------------------
-- Q7. Department performance scorecard — combines attrition,
--     performance rating, job satisfaction and income in one view
--     (multiple aggregates + RANK)
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*)                                       AS headcount,
    ROUND(AVG(AttritionFlag) * 100.0, 2)            AS attrition_rate_pct,
    ROUND(AVG(PerformanceRating), 2)                AS avg_performance_rating,
    ROUND(AVG(JobSatisfaction), 2)                  AS avg_job_satisfaction,
    ROUND(AVG(MonthlyIncome), 0)                    AS avg_monthly_income,
    RANK() OVER (ORDER BY AVG(JobSatisfaction) DESC) AS satisfaction_rank
FROM employees
GROUP BY Department
ORDER BY satisfaction_rank;
