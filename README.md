# HR People Analytics Dashboard

**Tools:** SQL (SQLite) · Python (pandas) · Interactive HTML/JS dashboard (Chart.js) · 1,470 employees

**Live dashboard:** https://claude.ai/artifact/SXXe6MgzDpqMKhd9X1MoiY

## Business Question

People Ops wants one place to see where attrition risk is concentrated, how
hiring has trended over time, whether pay is fair across groups, and how
departments compare on performance signals — filterable by department.

## 1. Data

[IBM HR Analytics Employee Attrition dataset](https://raw.githubusercontent.com/pplonski/datasets-for-start/refs/heads/master/employee_attrition/HR-Employee-Attrition-All.csv)
— 1,470 employees, 35 fields, fictional/benchmark data.

**Cleaning** (`scripts/01_clean_data.py`): deduplicated on EmployeeNumber,
dropped 3 constant columns that carried zero analytical value, derived
`AttritionFlag`, `SalaryBand`, `TenureBand`, and an estimated `HireYear`
(2024 − YearsAtCompany, since the dataset has no literal hire-date field —
documented clearly in code and here, not hidden).

## 2. SQL Analysis

Full queries in [`sql/analysis_queries.sql`](sql/analysis_queries.sql) — CTEs
and window functions (`RANK`, `SUM OVER`, `AVG OVER`, `LAG`) answering 7
questions across the four areas requested.

### Key findings

**Attrition** — Sales has the highest department attrition rate (20.6%),
Human Resources second (19.1%), R&D lowest (13.8%). At the job-role level,
**Sales Representatives have by far the highest individual attrition rate
at 39.8%**, and alone account for 14% of everyone who left the company.

**The single strongest attrition signal is overtime, not department or
role:** employees working overtime leave at **30.5%**, almost **3× the
rate** of those who don't (10.4%).

**Salary analysis — no meaningful gender pay gap.** Comparing average
monthly income by gender *within* the same job level (the fair comparison —
controls for seniority) shows differences under 3% at every level, and the
gap direction isn't even consistent — sometimes men earn slightly more,
sometimes women do. This is a clean, reportable finding, not a dodge.

**Tenure and pay do scale together:** employees with 10+ years average
$10,887/month vs. a company-wide average of $6,503 — pay progression looks
healthy, not flat.

**Hiring trend:** hiring was heavier in the 2010–2015 window than in recent
years in this snapshot (derived from tenure, so read directionally rather
than as exact annual hiring counts).

## 3. Interactive Dashboard

Built as a self-contained HTML/JS page (`hr_dashboard.html`) using Chart.js —
published live at the link above. Includes:
- KPI strip (headcount, attrition rate, avg. income, avg. satisfaction)
- **Department filter** that live-updates the KPIs and the job-role attrition
  breakdown — the main interactive element
- Attrition by department, attrition by job role, hiring trend, salary by
  job level & gender, overtime-vs-attrition callout, department scorecard

## 4. Recommendations

1. **Target Sales Representative retention specifically**, not Sales broadly
   — this one role drives a disproportionate share of all attrition.
2. **Investigate overtime policy and workload in high-overtime teams.** This
   is the strongest signal in the entire dataset — a near-3x attrition
   multiplier is worth a focused intervention before pay or role-level fixes.
3. **No gender pay-equity action needed based on this data** — worth stating
   explicitly in any report, since confirming a negative is as useful as
   finding a problem.
4. **R&D's lower attrition and strong satisfaction scores are worth studying**
   as an internal benchmark — what's working there that Sales/HR could adopt?

## Recreating This in Power BI or Tableau

This project was built as SQL + a code-based dashboard so it runs anywhere
without a desktop license. To rebuild it as an actual `.pbix` or `.twbx` for
a resume screenshot:

1. Open Power BI Desktop / Tableau Desktop (or Tableau Public, free).
2. Import `data/hr_clean.csv` directly, or connect to `hr_analytics.db`
   (Power BI: SQLite via ODBC driver; Tableau: built-in SQLite connector).
3. Recreate the visuals 1:1 using the SQL query results in `sql/results/` as
   your source aggregations, or build the same measures using DAX
   (Power BI) / calculated fields (Tableau):
   - Attrition Rate = `DIVIDE([Leavers], [Headcount])`
   - Use the `Department` field as a slicer/filter, mirroring the dashboard here
4. Publish to Power BI Service or Tableau Public and link it on your resume
   alongside this repo — having both the code-based version (shows SQL/Python
   skill) and the BI-tool version (shows the specific tool) is a stronger
   combination than either alone.
5. A Power BI version of this dashboard is also included in powerbi/HR-Analytics-Dashboard.pbix, with DAX measures and a department
   slicer, alongside the original interactive web dashboard above.
   
## Project Structure

```
hr_project/
├── data/
│   ├── hr_raw.csv
│   └── hr_clean.csv
├── sql/
│   ├── analysis_queries.sql
│   └── results/
├── scripts/
│   ├── 01_clean_data.py
│   ├── 02_load_to_sql.py
│   ├── 03_run_sql_analysis.py
│   └── 05_prep_dashboard_data.py
├── hr_analytics.db
├── hr_dashboard.html
└── README.md
```

---
*Dataset: IBM HR Analytics Employee Attrition (fictional, educational use).*
