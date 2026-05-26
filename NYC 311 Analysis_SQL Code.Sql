SECTION 4
_________________________________________________________________________________________________________________________________
General Note

pd.read_sql("""
SELECT ...
""", connection)

pd=pandas
read_sql()= pandas functiont aht runs a SQL query
""" """= multi line python string containing SQL
connection=connection to SQLite database

Essentially this code says to run SQL query on the database connection and return the result as a pandas dataframe 
_________________________________________________________________________________________________________________________________
# Good vs bad weather days

pd.read_sql("""

SELECT
    good_weather_day,

    AVG(complaint_count) AS avg_complaints,

    AVG(mean_hours_to_close) AS avg_resolution_time,

    AVG(median_hours_to_close) AS median_resolution_time

FROM master_df

GROUP BY good_weather_day;

""", connection)

Uses GROUP BY with aggregate functions AVG()to compare daily complaint volume and average resolution time on good vs. bad weather days. Tests whether favorable weather conditions are associated with lower complaint volume or faster resolution time. Both volume and resolution time were relatively similar across good and bad days, which suggests weather alone is not a major driver of 311 demand or delays.
_________________________________________________________________________________________________________________________________

# Rainy vs non-rainy days

pd.read_sql("""

SELECT
    rainy_day,

    AVG(complaint_count) AS avg_complaints,

    AVG(mean_hours_to_close) AS avg_resolution_time

FROM master_df

GROUP BY rainy_day;

""", connection)

Uses GROUP BY with aggregate functions AVG()to compare daily complaint volume and average resolution time on rainy vs non-rainy days. Tests whether rain is associated with higher complaints or slower response time. Rainy days did not meaningfully impact complaint volume or resolution time,  which suggests rain alone is not a major driver of 311 demand or delays.
_________________________________________________________________________________________________________________________________
# Snow days

pd.read_sql("""

SELECT
    snow_day,

    AVG(complaint_count) AS avg_complaints,

    AVG(mean_hours_to_close) AS avg_resolution_time

FROM master_df

GROUP BY snow_day;

""", connection)

Uses GROUP BY with aggregate functions AVG()to compare daily complaint volume and average resolution time on snowy vs non-snowy days. Snow could disrupt operations and cause delays so this tests whether snow is associated with higher complaints or slower response time. Snowy days did not meaningfully impact complaint volume or resolution time,  which suggests snow alone is not a major driver of 311 demand or delays.
_________________________________________________________________________________________________________________________________

# Impact of wind

pd.read_sql("""

SELECT
    windy_day,

    AVG(complaint_count) AS avg_complaints,

    AVG(mean_hours_to_close) AS avg_resolution_time

FROM master_df

GROUP BY windy_day;

""", connection)

Uses GROUP BY with aggregate functions AVG()to compare daily complaint volume and average resolution time on windy vs non-windy days. Tests whether wind is associated with higher complaints or slower response time. Windy days did not meaningfully impact complaint volume or resolution time, which suggests wind alone is not a major driver of 311 demand or delays.
_________________________________________________________________________________________________________________________________
pd.read_sql("""

SELECT
    CASE
        WHEN avg_temp >= 80 THEN 'Hot'
        WHEN avg_temp <= 40 THEN 'Cold'
        ELSE 'Moderate'
    END AS temp_group,

    COUNT(*) AS num_days,

    AVG(complaint_count) AS avg_complaints,

    AVG(mean_hours_to_close) AS avg_resolution_time

FROM master_df

GROUP BY temp_group;

""", connection)

Uses CASE WHEN to create hot, cold, or moderate temperature categories based on various temperature cutoffs and then uses GROUP BY and aggregate functions to compare complaint volume and average resolution time. Tests whether temperature extremes are associated with changes in complaint demand or resolution speed. Less than 1/3 of the days annually were a temperature extreme. Broad temperature groups alone do not fully explain complaint volume or resolution time.
_________________________________________________________________________________________________________________________________
# Best days in NYC
pd.read_sql("""

SELECT
    date_only,

    complaint_count,

    median_hours_to_close,

    avg_temp,

    precipitation,

    avg_wind_speed

FROM master_df

WHERE good_weather_day = 1

ORDER BY
    complaint_count ASC,
    median_hours_to_close ASC

LIMIT 10;

""", connection)

Filters good weather days and orders by complaint count and median resolution time to identify best operational days. This identifies days where both external conditions and resolution speed were favorable. The best days combined low complaint volume with fast resolution, but were not solely explained by weather. This suggests strong operational performance depends on more than favorable external conditions.
_________________________________________________________________________________________________________________________________
# Worst days in NYC

pd.read_sql("""

SELECT
    date_only,

    complaint_count,

    median_hours_to_close,

    avg_temp,

    precipitation,

    snowfall

FROM master_df

ORDER BY
    complaint_count DESC,
    median_hours_to_close DESC

LIMIT 10;

""", connection)

Uses ORDER BY and LIMIT to identify the highest complaint-volume days and their weather conditions. Tests whether the highest complaint days overlap with poor weather. Results suggests that large spikes in 311 demand may be driven more by underlying city events, operational factors, or specific complaint categories than by weather alone.
_________________________________________________________________________________________________________________________________
# Monthly trend analysis

pd.read_sql("""

SELECT
    SUBSTR(date_only, 6, 2) AS month,

    AVG(complaint_count) AS avg_complaints,

    AVG(avg_temp) AS avg_temp,

    AVG(precipitation) AS avg_precipitation,

    AVG(mean_hours_to_close) AS avg_resolution_time

FROM master_df

GROUP BY month

ORDER BY month;

""", connection)

Uses SUBSTR() to extract month from the date, then uses GROUP BY and AVG() to summarize complaint volume, temperature, precipitation, and resolution time by month. Tests whether seasonal weather patterns align with changes in complaint volume or resolution time. Monthly patterns provide context, but changes in resolution time appear more related to complaint mix than weather alone.
_________________________________________________________________________________________________________________________________
# Create complaint day categories in SQL

query = """
DROP TABLE IF EXISTS master_labeled;
"""

cursor.execute(query)

query = """
CREATE TABLE master_labeled AS
WITH thresholds AS (
    SELECT
        AVG(complaint_count) AS avg_complaints,
        AVG(median_hours_to_close) AS avg_resolution
    FROM master_df
)
SELECT
    m.*,

    CASE
        WHEN m.complaint_count < t.avg_complaints
             AND m.median_hours_to_close < t.avg_resolution
        THEN 'Good Complaint Day'

        WHEN m.complaint_count > t.avg_complaints
             AND m.median_hours_to_close > t.avg_resolution
        THEN 'Bad Complaint Day'

        ELSE 'Normal Complaint Day'
    END AS complaint_day_category

FROM master_df AS m
CROSS JOIN thresholds AS t;
"""

cursor.execute(query)
connection.commit()

pd.read_sql("SELECT * FROM master_labeled LIMIT 10;", connection)

Uses a subquery with AVG to calculate overall average complaint volume and median resoltuion time. A CROSS JOIN attaches these  values to every row in master_df, and CASE WHEN classifies each day as Good Complaint Day, Bad Complaint Day, or Normal Complaint Day. This code uses a non-correlated subquery such that it calculates one overall benchmark from the master_df table. It does not reference any column from the outer query and can run by itself.

This creates a standardized way to compare operational performance across days using both complaint volume and resolution time together. The resulting categories showed meaningful variation across days, creating a framework for comparing operational performance under different weather and complaint conditions.
_________________________________________________________________________________________________________________________________
# Cross-tab: weather category vs complaint day category

pd.read_sql("""
SELECT
    weather_category,
    complaint_day_category,
    COUNT(*) AS num_days
FROM master_labeled
GROUP BY
    weather_category,
    complaint_day_category
ORDER BY
    weather_category,
    complaint_day_category;
""", connection)

Uses GROUP BY and COUNT() to cross-tab (counts combinations of two categories) weather categories against complaint day performance categories. This tests whether bad complaint days are concentrated in certain weather categories or occur across many weather conditions. Bad complaint days were not exclusively concentrated in extreme weather. This suggests poor operational days are not simply a weather problem and are likely shaped by complaint mix or operational processes.
_________________________________________________________________________________________________________________________________
# Average complaint metrics by weather and complaint category

pd.read_sql("""
SELECT
    weather_category,
    complaint_day_category,

    COUNT(*) AS num_days,
    AVG(complaint_count) AS avg_complaints,
    AVG(median_hours_to_close) AS avg_median_resolution,
    AVG(mean_hours_to_close) AS avg_mean_resolution,
    AVG(avg_temp) AS avg_temperature,
    AVG(precipitation) AS avg_precipitation

FROM master_labeled

GROUP BY
    weather_category,
    complaint_day_category

ORDER BY
    weather_category,
    complaint_day_category;
""", connection)

Uses GROUP BY with COUNT() and AVG() to summarize complaint volume, resolution time, temperature, and precipitation by both weather category and complaint day category. This combines weather dataset with complaint day categories to see whether bad complaint days are concentrated in certain weather conditions. Weather adds useful context, but bad complaint days do not appear to be explained by weather alone.
_________________________________________________________________________________________________________________________________
# Best days: good weather + good complaint day

pd.read_sql("""
SELECT
    date_only,
    weather_category,
    complaint_day_category,
    complaint_count,
    median_hours_to_close,
    avg_temp,
    precipitation,
    avg_wind_speed

FROM master_labeled

WHERE weather_category = 'Good Weather'
  AND complaint_day_category = 'Good Complaint Day'

ORDER BY
    complaint_count ASC,
    median_hours_to_close ASC

LIMIT 10;
""", connection)

Filters dataset using WHERE to identify days that were both good weather and good complaint days. This identifies best cases where external conditions and 311 performance was favorable. The best-performing days generally combined lower complaint volume with faster resolution times, but this does not prove weather caused the better performance.
_________________________________________________________________________________________________________________________________
# Worst days: extreme weather + bad complaint day

pd.read_sql("""
SELECT
    date_only,
    weather_category,
    complaint_day_category,
    complaint_count,
    median_hours_to_close,
    avg_temp,
    precipitation,
    snowfall,
    avg_wind_speed

FROM master_labeled

WHERE weather_category = 'Extreme Weather'
  AND complaint_day_category = 'Bad Complaint Day'

ORDER BY
    complaint_count DESC,
    median_hours_to_close DESC

LIMIT 10;
""", connection)

Filters dataset using WHERE to identify days that were both bad weather and bad complaint days. This identifies best cases where external conditions and 311 performance was least favorable. Some bad complaint days occurred during extreme weather, but the broader analysis suggests extreme weather alone does not consistently explain poor 311 performance.

_________________________________________________________________________________________________________________________________
#Rainy vs. non-rainy complaint volume and resolution time

pd.read_sql("""

WITH daily_complaints AS (
    SELECT
        date_only,
        COUNT(unique_key) AS total_complaints,
        AVG(hours_to_close) AS avg_hours_to_close
    FROM nyc_complaints
    WHERE hours_to_close IS NOT NULL
    GROUP BY date_only
)

SELECT
    w.rainy_day,
    COUNT(d.date_only) AS num_days,
    ROUND(AVG(d.total_complaints), 2) AS avg_daily_complaints,
    ROUND(AVG(d.avg_hours_to_close), 2) AS avg_hours_to_close
FROM daily_complaints d
JOIN weather_final w
    ON d.date_only = w.date_only
GROUP BY w.rainy_day
ORDER BY w.rainy_day DESC;
""", connection)

Uses a CTE to first aggregate complaints at the daily level, then joins those daily complaint totals to the wather table and groups by rain day. Looking at the daily level creates a fairer comparison (vs. raw totals) given there are more non rainy days than rainy days. Average daily complaints and average resolution times were similar on rainy and non-rainy days, suggesting rain does not broadly drive citywide 311 demand or delays.   

_________________________________________________________________________________________________________________________________
#Identify days with highest complaint volume and show their weather conditions

pd.read_sql("""

WITH daily_weather_complaints AS (
    SELECT
        c.date_only,
        COUNT(c.unique_key) AS daily_complaints,
        AVG(c.hours_to_close) AS avg_hours_to_close,
        w.rainy_day,
        w.hot_day,
        w.cold_day,
        w.snow_day,
        w.extreme_weather_day,
        w.weather_category
    FROM nyc_complaints c
    JOIN weather_final w
        ON c.date_only = w.date_only
    WHERE c.hours_to_close IS NOT NULL
    GROUP BY
        c.date_only,
        w.rainy_day,
        w.hot_day,
        w.cold_day,
        w.snow_day,
        w.extreme_weather_day,
        w.weather_category
)

SELECT
    date_only,
    weather_category,
    rainy_day,
    hot_day,
    cold_day,
    snow_day,
    extreme_weather_day,
    daily_complaints,
    ROUND(avg_hours_to_close, 2) AS avg_hours_to_close,
    RANK() OVER (
        ORDER BY daily_complaints DESC
    ) AS complaint_volume_rank
FROM daily_weather_complaints
ORDER BY complaint_volume_rank
LIMIT 15;
#""", connection)

Uses a JON between complaints and weather data, aggregates complaints by day, and applies RANK() OVER to rank days by complaint volume. This identifies whether the highest-demand days tend to occur under certain weather conditions. Some high complaint days overlap with extreme weather may cause short term operational strain, but pattern is not strong enough to make a meaningful conclusion about operational delays
_________________________________________________________________________________________________________________________________

#Identifies complaint types that take longer to resolve on rainy days than they do overall.

pd.read_sql("""

SELECT
    c.complaint_type,
    COUNT(c.unique_key) AS rainy_day_complaints,
    ROUND(AVG(c.hours_to_close), 2) AS rainy_avg_hours_to_close,
    ROUND((
        SELECT AVG(c2.hours_to_close)
        FROM nyc_complaints c2
        WHERE c2.complaint_type = c.complaint_type
          AND c2.hours_to_close IS NOT NULL
    ), 2) AS overall_type_avg_hours_to_close,
    ROUND(
        AVG(c.hours_to_close) -
        (
            SELECT AVG(c2.hours_to_close)
            FROM nyc_complaints c2
            WHERE c2.complaint_type = c.complaint_type
              AND c2.hours_to_close IS NOT NULL
        ),
        2
    ) AS rainy_day_difference
FROM nyc_complaints c
JOIN weather_final w
    ON c.date_only = w.date_only
WHERE c.hours_to_close IS NOT NULL
  AND w.rainy_day = 1
GROUP BY c.complaint_type
HAVING COUNT(c.unique_key) >= 25
   AND AVG(c.hours_to_close) >
       (
           SELECT AVG(c2.hours_to_close)
           FROM nyc_complaints c2
           WHERE c2.complaint_type = c.complaint_type
             AND c2.hours_to_close IS NOT NULL
       )
ORDER BY rainy_day_difference DESC;

""", connection)

Uses a JOIN between complaints and weather data, GROUP BY complaint_type, and correlated subqueries (subquery references c.complaint_type from the outer query, such that the subquery average is recalculated for each complaint type). This tests whether rain affects specific complaint categories that specifically take longer to resolve on rainy days. On rainy days, noise related complaints take longest (vs. average) to resolve. Correlation does not entail causation however, as rainy day resolution times for noise complaints may be realted to operational prioritization, behavioral changes, etc.  A possible explanation however is that resources prioritization shifts to weather realted complaints (e.g., flooding, traffic) and low priority complaints on noise take longer

_________________________________________________________________________________________________________________________________
#Measures which complaint types increase disproportionately during extreme weather days

pd.read_sql("""

WITH overall_complaints AS (
    SELECT
        complaint_type,
        COUNT(*) AS overall_count
    FROM nyc_complaints
    GROUP BY complaint_type
),

extreme_weather_complaints AS (
    SELECT
        c.complaint_type,
        COUNT(*) AS extreme_count
    FROM nyc_complaints c
    JOIN weather_final w
        ON c.date_only = w.date_only
    WHERE w.extreme_weather_day = 1
    GROUP BY c.complaint_type
)

SELECT
    e.complaint_type,
    e.extreme_count,
    o.overall_count,
    ROUND(
        CAST(e.extreme_count AS FLOAT) / o.overall_count,
        3
    ) AS extreme_weather_ratio
FROM extreme_weather_complaints e
JOIN overall_complaints o
    ON e.complaint_type = o.complaint_type
WHERE o.overall_count >= 100
ORDER BY extreme_weather_ratio DESC
LIMIT 15;

""", connection)

Uses CTE to calcualte each complaint type's total count and count during extreme weather, then joining these to calculate an extreme-weather ratio. This ratio shows which complaint types are disproportionately represented during extreme weather periods. On extreme weather days, complaints around heat/hot water disproportionately increase which intuitively makes sense as extreme weather includes extreme heat. Unsanitary conditions and food poisoning as 2nd and 3rd also make sense given heat can cause rotting trash, food spoilage, etc.
_________________________________________________________________________________________________________________________________
#Complaint types that slow down the most during rainy weather

pd.read_sql("""

SELECT
    c.complaint_type,

    ROUND(AVG(
        CASE
            WHEN w.rainy_day = 1
            THEN c.hours_to_close
        END
    ), 2) AS rainy_avg_hours,

    ROUND(AVG(
        CASE
            WHEN w.rainy_day = 0
            THEN c.hours_to_close
        END
    ), 2) AS non_rainy_avg_hours,

    ROUND(
        AVG(
            CASE
                WHEN w.rainy_day = 1
                THEN c.hours_to_close
            END
        )
        -
        AVG(
            CASE
                WHEN w.rainy_day = 0
                THEN c.hours_to_close
            END
        ),
        2
    ) AS rainy_delay_difference

FROM nyc_complaints c
JOIN weather_final w
    ON c.date_only = w.date_only

WHERE c.hours_to_close IS NOT NULL

GROUP BY c.complaint_type

HAVING COUNT(*) >= 50

ORDER BY rainy_delay_difference DESC
LIMIT 15;

""", connection)

Uses JOIN, GROUP BY, and conditional aggregation with CASE WHEN to compare rainy day vs non-rainy day average resolution times within each complaint type. This measures which complaint categories experience the largest rain related change in resolution time. Rain does not uniformly slow down city operations, but certain complaint categories experience substantially larger delays during rainy conditions than others. However, plumbing complaints already tend to have relatively long baseline resolution times because they often require more technically complex repairs. Rainy weather may further exacerbate these delays.

_________________________________________________________________________________________________________________________________
#Borough with biggest weather related slowdown

pd.read_sql("""

SELECT
    c.borough,

    ROUND(AVG(
        CASE
            WHEN w.extreme_weather_day = 1
            THEN c.hours_to_close
        END
    ), 2) AS extreme_weather_hours,

    ROUND(AVG(
        CASE
            WHEN w.extreme_weather_day = 0
            THEN c.hours_to_close
        END
    ), 2) AS normal_weather_hours,

    ROUND(
        AVG(
            CASE
                WHEN w.extreme_weather_day = 1
                THEN c.hours_to_close
            END
        )
        -
        AVG(
            CASE
                WHEN w.extreme_weather_day = 0
                THEN c.hours_to_close
            END
        ),
        2
    ) AS weather_delay_difference

FROM nyc_complaints c
JOIN weather_final w
    ON c.date_only = w.date_only

WHERE c.hours_to_close IS NOT NULL

GROUP BY c.borough

ORDER BY weather_delay_difference DESC;

""", connection)

Uses JOIN, GROUP BY, and conditional aggregation with CASE WHEN to compare extreme-weather and normal-weather resolution times by borough. This tests whether weather-related impacts vary across NYC boroughs. Weather-related operational impacts are not evenly distributed across boroughs. Likely due to infrastrucutre, complaint mix, resource allocation that shapes responsiveness across NYC.Staten Island has the biggest weather related slowdown. Again correlation is not causation, but potential explanation is that given its further proximity from Manhattan, crews may have to travel further and make this borough more vulnerable to weather events

_________________________________________________________________________________________________________________________________
#See whether bad complaint days tend to follow other bad complaint days.

pd.read_sql("""

WITH lagged_days AS (

    SELECT
        date_only,
        complaint_day_category,

        LAG(complaint_day_category)
        OVER (ORDER BY date_only)
            AS previous_day_category

    FROM master_labeled
)

SELECT
    previous_day_category,
    complaint_day_category,
    COUNT(*) AS num_days

FROM lagged_days

GROUP BY
    previous_day_category,
    complaint_day_category

ORDER BY
    num_days DESC;

""", connection)

_________________________________________________________________________________________________________________________________
#See whether bad complaint days tend to follow other bad complaint days.

pd.read_sql("""

WITH lagged_days AS (

    SELECT
        date_only,
        complaint_day_category,

        LAG(complaint_day_category)
        OVER (ORDER BY date_only)
            AS previous_day_category

    FROM master_labeled
)

SELECT
    previous_day_category,
    complaint_day_category,
    COUNT(*) AS num_days

FROM lagged_days

GROUP BY
    previous_day_category,
    complaint_day_category

ORDER BY
    num_days DESC;

""", connection)

Uses a CTE to create a temp table of each day and prior day's complaint category. The LAG() window function looks backward one row based on date order, so we can compare each day's category to the previous day's category. The final SELECT uses GROUP BY and COUNT () to summarize how often each pairing of complaint day categories occuried. This checks whether bad complaint days tend to cluster together, which could suggest a backlor or presistent operational strain rather than isolated bad days.

Good operational days were more likely to be followed by other good days, suggesting that stable operational periods may reinforce themselves over time.Because bad complaint days do not appear persistent, the results suggest that operational slowdowns may be driven more by temporary concentrations of complex complaint types rather than long-term system backlog.

_________________________________________________________________________________________________________________________________
