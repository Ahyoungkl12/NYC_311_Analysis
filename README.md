# NYC 311 Operational Strain Analysis

Python + SQL analysis of NYC 311 complaint operations using NOAA weather data.

## Research Question

Is NYC 311 operational strain driven primarily by weather disruptions or by complaint complexity?

## Key Findings

* Complaint complexity drives delays more than complaint volume.
* The Bronx has the highest complaint burden per resident.
* Extreme weather affects resolution times more than total complaint volume.
* Bad operational days persist over time and are not solely weather-driven.
* Weather helps predict slow operational days, but only partially explains system strain.

## Methods

* NYC 311 complaint data + NOAA weather data
* Python, SQL, pandas, matplotlib, scikit-learn
* EDA, feature engineering, linear regression, logistic regression

## Modeling Results

* Linear Regression R²: 0.316
* Logistic Regression Accuracy: 71.2%
* Logistic Regression Precision: 75.9%

## Repository Contents

* `NYC 311 Analysis_Final.ipynb` → Final analysis notebook
* `sql_queries.sql` → SQL query file
* `NYC 311 Analysis_Presentation.pdf` → Final presentation deck
