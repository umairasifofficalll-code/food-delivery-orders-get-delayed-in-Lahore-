# Lahore Food Delivery: Demand & Delay Analysis

An end-to-end data analytics project that answers one business question:

> **Where and when do food delivery orders in Lahore get delayed or cancelled, and what should a delivery platform do about it?**

The project uses **Excel, Python (pandas), MySQL and Power BI** on a deliberately messy dataset of **51,150 orders (Jan 2024 to Dec 2025)**.

> **Note:** The dataset is **synthetic**, generated for portfolio practice. It is not real company data. Built-in patterns include Ramadan iftar spikes, monsoon rain delays and longer distances in outer areas.

---

## Tech stack

| Stage | Tool | Purpose |
|---|---|---|
| Inspection | Excel | First look at the raw file: mixed dates, text numbers, spelling variants |
| Cleaning | Python (pandas, matplotlib, seaborn) | Clean data, engineer features, chart bottlenecks |
| Storage and analysis | MySQL (via SQLAlchemy) | Aggregations and window-function queries |
| Reporting | Power BI | One-page interactive dashboard |

---

## Dataset

- **Rows / columns:** 51,150 rows, 20 columns
- **Period:** 1 Jan 2024 to 31 Dec 2025
- **Key columns:** `order_id`, `order_datetime`, `customer_id`, `area`, `restaurant_category`, `restaurant_name`, `items_count`, `order_value_pkr`, `delivery_fee_pkr`, `distance_km`, `payment_method`, `rider_id`, `vehicle_type`, `weather`, `prep_time_min`, `delivery_time_min`, `order_status`, `customer_rating`, `is_ramadan`, `cancel_reason`

### Data quality problems in the raw file

- Mixed date formats (real dates plus text such as `08/07/2024 14:08` and `23-Oct-25`)
- Numbers stored as text (`Rs. 1,750`, `1750/-`, `5.2 km`, `45 mins`)
- Missing values and placeholders (`N/A`, `unknown`, `NULL`)
- Inconsistent spellings of areas, categories, payment methods and statuses
- Impossible values (negative times, 999-minute deliveries, ratings of 0 and 7)
- Duplicate rows and logic conflicts (cancelled orders with delivery times)

---

## Pipeline

### 1. Cleaning in Python (`Lahore_Food_Delivery_Demand___Delay_Analysis.ipynb`)

- Parsed `order_datetime` with `pd.to_datetime(format="mixed", dayfirst=True)`
- Stripped `Rs.` text and converted value and fee columns to numbers
- Removed brackets and units from `distance_km`, `prep_time_min`, `delivery_time_min`, `items_count`
- Filled missing values: medians (overall and by area / category), mode for `weather`, `"Unknown"` for missing categories, `"Unassigned"` for missing riders, `"Not canceled"` for blank cancel reasons
- Engineered features: `order_hour`, `day_name`, `is_iftar_rush` (17:00 to 19:59 in Ramadan), `is_dinner_peak` (20:00 to 23:59), `total_duration_min` (prep + delivery), `is_delayed` (delivered and over 45 minutes), `is_cancelled`
- Plotted delay rate against cancellation rate by area

### 2. Loading into MySQL

The cleaned data is pushed to a MySQL database (`Lahore`, table `csv_records`) with pandas and SQLAlchemy:

```python
df.to_sql(name="csv_records", con=engine, if_exists="replace", index=False, chunksize=2000)
```

> Keep database credentials out of the repo. Use environment variables instead of hard-coding them in the notebook.

### 3. SQL analysis

| Query | What it returns |
|---|---|
| Delay by area and hour | Delivered orders, average delivery time, average total duration and delay rate % per area and hour |
| Rider performance | Trips, average delivery time, minutes per km and a percentile tier per rider and vehicle |
| Cancellation rate by category | Total, completed and cancelled orders per standardized category |
| Month-over-month growth | Monthly orders and gross revenue with growth against the previous month |

Screenshots of the results are in the repo: `SQL1.PNG` to `SQL4.PNG`.

### 4. Power BI dashboard (`Lahore.pbix`)

A single-page report titled **Lahore Food Delivery Performance Dashboard**:

- **KPI cards:** Total Orders, total order value (PKR), Cancellation Rate, On-Time %
- **Rider table:** rider, vehicle type, total orders, On-Time %, rating
- **Hourly demand curve:** orders by hour, one line per weekday
- **Heat map:** total orders by area

---

## Findings

- **Demand:** Orders rose 26.5% in March 2024 (2,434 vs 1,924 in February), which overlaps with Ramadan, then held steady at about 2,030 to 2,080 orders a month from May to September.
- **Revenue is noisy:** Monthly revenue moved between about -45% and +61% while order counts stayed flat, which points to outliers in `order_value_pkr`.
- **Riders:** The rider query ranks riders by average delivery time, for example R062 (car) at 63.8 minutes.

---

## Known limitations and next steps

These were found while checking query output against the raw data:

1. **Cancellation rate shows 100% for every category.** Status labels such as `Complete` and `Canceled` are not mapped to a single value before the query runs. Standardize `order_status` first, then rebuild the query.
2. **Spike at hour 0.** Date-only entries parse to midnight, which inflates the 00:00 slot (for example 457 orders in one area). Treat date-only rows as having no time and exclude them from hourly analysis.
3. **Outliers and duplicates remain.** A 516-minute average delivery time and large revenue swings point to impossible values such as 999 minutes. The notebook does not drop duplicate rows or merge area spelling variants (for example "Iqbal Town" and "Allama Iqbal Town").
4. **Next:** fix the items above, re-run the SQL on the fully cleaned data, refresh the dashboard, and add a recommendations page with estimated impact (for example, extra riders for the busiest slots).

---

## Repository structure

```
.
├── Lahore_Food_Delivery_Demand___Delay_Analysis.ipynb   # cleaning, features, MySQL load
├── Lahore.pbix                                          # Power BI dashboard
├── lahore_food_delivery_raw_2024_2025.csv               # raw synthetic dataset
├── SQL1.PNG ... SQL4.PNG                                # SQL query results
├── Lahore_Food_Delivery_Analysis.pptx                   # project presentation
└── README.md
```

## How to run

1. Install dependencies: `pip install pandas numpy matplotlib seaborn openpyxl sqlalchemy mysql-connector-python`
2. Create a MySQL database named `Lahore` and set your own credentials.
3. Run the notebook top to bottom to clean the data and load it into MySQL.
4. Run the SQL queries against the `csv_records` table.
5. Open `Lahore.pbix` in Power BI Desktop and refresh the data source.

## Author

**Umair Asif**, Lahore, Pakistan. Aspiring data analyst (Python, SQL, Power BI, Tableau, Excel).
