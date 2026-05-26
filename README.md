# NYC 311 Operational Strain Analysis

Python + SQL analysis of NYC 311 complaint operations using NOAA weather data.

## Research Question

Is NYC 311 operational strain driven primarily by weather disruptions, or by complaint complexity and operational coordination challenges?

---

# Key Findings

* Operational strain is driven more by complaint complexity than complaint volume.
* The Bronx has the highest complaint burden per resident despite Brooklyn having the highest raw complaint volume.
* Weather affects resolution times more than total complaint volume.
* Extreme weather shifts complaint composition toward heat-, sanitation-, and infrastructure-related complaints.
* Bad operational days persist over time and are not driven solely by weather.
* Weather helps predict slow operational days, but explains only part of system strain.

---

# Methods

## Data Sources

* NYC 311 complaint data
* NOAA daily weather data

## Tools

* Python
* SQL
* pandas
* matplotlib / seaborn
* scikit-learn

## Techniques

* Exploratory data analysis (EDA)
* SQL joins, CTEs, aggregations, and window functions
* Feature engineering
* Linear regression
* Logistic regression

---

# Modeling Results

| Model               | Metric    | Result |
| ------------------- | --------- | ------ |
| Linear Regression   | R²        | 0.316  |
| Logistic Regression | Accuracy  | 71.2%  |
| Logistic Regression | Precision | 75.9%  |

Weather contains meaningful predictive signal, but operational strain is still heavily influenced by complaint mix, staffing, and agency coordination constraints.

---

# Repository Contents

* `NYC 311 Analysis_Final.ipynb` → Final polished notebook
* `sql_queries.sql` → SQL query file with explanations
* `NYC 311 Analysis_Presentation.pdf` → Final presentation deck

---

# Final Conclusion

NYC 311 strain is fundamentally a complexity problem, not simply a volume problem. Complaint mix and operational coordination drive delays more strongly than weather alone.
