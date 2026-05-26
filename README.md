# NYC 311 Operational Strain Analysis

Python + SQL analysis of NYC 311 complaint operations using NOAA weather data.

## Research Question

Is NYC 311 operational strain driven primarily by weather disruptions, or by complaint complexity and operational coordination challenges?

---

# Key Findings

* Operational strain is driven more by complaint complexity than complaint volume.
* The Bronx has the highest complaint burden per resident despite Brooklyn having the highest raw volume.
* Extreme weather affects resolution times more than total complaint volume.
* Heat-related and sanitation-related complaints increase disproportionately during extreme weather.
* Bad operational days persist over time and are not driven solely by weather.
* Weather helps predict slow operational days, but explains only part of system strain.

---

# Methods

## Data Sources

* NYC 311 complaint data
* NOAA weather data

## Tools

* Python
* SQL
* pandas
* matplotlib / seaborn
* scikit-learn

## Techniques

* Exploratory data analysis (EDA)
* SQL joins + aggregations
* Feature engineering
* Linear regression
* Logistic regression

---

# Modeling Results

| Model               | Result            |
| ------------------- | ----------------- |
| Linear Regression   | R² = 0.316        |
| Logistic Regression | Accuracy = 71.2%  |
| Logistic Regression | Precision = 75.9% |

Weather contains meaningful predictive signal, but operational strain is still heavily influenced by non-weather factors such as complaint mix and agency coordination.

---

# Repository Contents

* `notebook.ipynb` → Full analysis and visualizations
* `presentation.pdf` → Final project presentation
* `sql_queries.sql` → SQL analysis queries
* `data/` → Processed datasets

---

# Final Conclusion

NYC 311 strain is fundamentally a complexity problem, not simply a volume problem. Operational performance is driven more by complaint mix and coordination requirements than by weather alone.
