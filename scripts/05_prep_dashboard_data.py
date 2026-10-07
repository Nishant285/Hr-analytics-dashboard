import pandas as pd
import json

df = pd.read_csv("hr_project/data/hr_clean.csv")

cols = ["Department", "JobRole", "Gender", "JobLevel", "MonthlyIncome",
        "AttritionFlag", "OverTime", "HireYear", "YearsAtCompany",
        "JobSatisfaction", "PerformanceRating", "TenureBand"]

records = df[cols].to_dict(orient="records")

with open("hr_project/hr_dashboard_data.json", "w") as f:
    json.dump(records, f)

print(f"Wrote {len(records)} records")
print("Departments:", df["Department"].unique().tolist())
