import sqlite3
import pandas as pd

df = pd.read_csv("hr_project/data/hr_clean.csv")
conn = sqlite3.connect("hr_project/hr_analytics.db")
df.to_sql("employees", conn, if_exists="replace", index=False)
conn.execute("CREATE INDEX IF NOT EXISTS idx_dept ON employees(Department);")
conn.execute("CREATE INDEX IF NOT EXISTS idx_attr ON employees(Attrition);")
conn.commit()
print(f"Loaded {conn.execute('SELECT COUNT(*) FROM employees').fetchone()[0]} rows")
conn.close()
