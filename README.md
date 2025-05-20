## Customer Lifetime Value (CLV) & RFM Analysis

This project analyzes user behavior using cohort-based CLV and RFM segmentation. The analysis is based on event-level data from the `turing_data_analytics.raw_events` table in BigQuery. The objective is to estimate long-term value for all users (not just purchasers) and segment them for strategic decision-making.

### Project Objectives

* Perform cohort-based **Customer Lifetime Value (CLV)** analysis over a 12-week period
* Calculate **weekly and cumulative ARPU (Average Revenue Per User)** per cohort
* Use **forecasting methods** to estimate revenue for recent cohorts
* Conduct **RFM (Recency, Frequency, Monetary)** segmentation for customer profiling
* Visualize findings in spreadsheets and dashboards

### Deliverables

#### SQL Queries

* `CLV.sql` – Identifies registration cohorts and calculates weekly ARPU
* `Cumulative CLV.sql` – Computes cumulative ARPU over time
* `RFM.sql` – Segments users based on recency, frequency, and monetary value

#### Supporting Files

* `RFM and CLV Projects.xlsx` – Contains tables, charts, and formatting for CLV and RFM analysis
* Tableau Dashboard (RFM) – Interactive visualization of RFM segmentation
  👉 [View Dashboard](https://public.tableau.com/views/RFMAnalysis_17289049911390/Dashboard1?:language=es-ES&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
  
### Tools Used

* **BigQuery SQL** – Data extraction and cohort analysis
* **Excel/Google Sheets** – Visualization, formatting, and forecasting
* **Tableau** – Interactive dashboard for RFM segmentation

