"""
01_clean_data.py
-----------------
Cleans the IBM HR Analytics Attrition dataset and adds derived fields used
throughout the analysis (estimated hire year, salary bands, tenure buckets).

Note on "hiring trends": this dataset has no literal hire-date column.
We derive an approximate hire year as (reference_year - YearsAtCompany),
using 2024 as the reference/snapshot year (noted here and in the README).
This is a standard, clearly-documented workaround for this well-known
benchmark dataset, not a data quality issue to silently paper over.
"""

import pandas as pd
import numpy as np

RAW_PATH = "hr_project/data/hr_raw.csv"
CLEAN_PATH = "hr_project/data/hr_clean.csv"
REFERENCE_YEAR = 2024


def load_raw(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, encoding="utf-8-sig")
    print(f"Raw shape: {df.shape}")
    return df


def clean(df: pd.DataFrame) -> pd.DataFrame:
    before = len(df)
    df = df.drop_duplicates(subset=["EmployeeNumber"])

    # Columns that are constant across every row in this dataset and add
    # no analytical value (checked: Over18 always 'Y', EmployeeCount always 1,
    # StandardHours always 80)
    constant_cols = [c for c in ["Over18", "EmployeeCount", "StandardHours"] if c in df.columns]
    df = df.drop(columns=constant_cols)

    # No missing values in this dataset, but guard anyway for numeric cols
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    df[numeric_cols] = df[numeric_cols].fillna(df[numeric_cols].median())

    # --- Derived fields ---
    df["AttritionFlag"] = (df["Attrition"] == "Yes").astype(int)
    df["HireYear"] = REFERENCE_YEAR - df["YearsAtCompany"]

    df["SalaryBand"] = pd.cut(
        df["MonthlyIncome"],
        bins=[0, 3000, 6000, 10000, 15000, np.inf],
        labels=["<3K", "3K-6K", "6K-10K", "10K-15K", "15K+"],
    )

    df["TenureBand"] = pd.cut(
        df["YearsAtCompany"],
        bins=[-1, 1, 3, 6, 10, np.inf],
        labels=["0-1 yr", "2-3 yrs", "4-6 yrs", "7-10 yrs", "10+ yrs"],
    )

    after = len(df)
    print(f"Clean shape: {df.shape} (removed {before - after} rows)")
    return df


if __name__ == "__main__":
    raw = load_raw(RAW_PATH)
    clean_df = clean(raw)
    clean_df.to_csv(CLEAN_PATH, index=False)
    print(f"Saved clean data to {CLEAN_PATH}")
    print(f"Overall attrition rate: {clean_df['AttritionFlag'].mean():.2%}")
