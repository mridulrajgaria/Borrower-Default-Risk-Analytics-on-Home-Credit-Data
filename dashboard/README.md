# Power BI Credit Risk Dashboard Documentation

## Executive Summary

The interactive Power BI dashboard (`credit_risk_dashboard.pbix`) provides executive-level monitoring and diagnostic drill-downs into the credit performance of **307,511 loan applications** from Home Credit.

It is structured into two core analytical views:
1. **Page 1: Credit Risk Overview** — High-level portfolio KPIs, default distribution, and income segment payment-burden metrics.
2. **Page 2: Behavioral Risk Signals** — Granular default risk breakdowns across occupation categories and credit bureau inquiry frequency.

---

## Dashboard Architecture & Views

> **Note on Visual Previews:** The figures below are **illustrative layout previews** reconstructed directly from the Power BI report specifications, data model schema, and underlying portfolio metrics. The live, interactive report is preserved in [`credit_risk_dashboard.pbix`](credit_risk_dashboard.pbix). All monetary quantities reflect dataset currency units as provided in the source data.

### Page 1: Credit Risk Overview
![Illustrative Dashboard Layout Preview: Page 1 — Credit Risk Overview](../images/dashboard_page1_overview.png)

#### Visual Elements:
* **KPI Card 1: Total Applicants**
  * *Metric:* `307,511`
  * *Business Context:* Total evaluated portfolio population.
* **KPI Card 2: Overall Default Rate**
  * *Metric:* `8.07%` (24,825 defaulters)
  * *Business Context:* Baseline benchmark (exceeds typical prime retail banking benchmarks of 5.0% - 7.0%).
* **KPI Card 3: Average Payment Burden**
  * *Metric:* `18.1%` (Fee-to-Income / Annuity-to-Income)
  * *Business Context:* Average share of monthly income dedicated to servicing the loan installment.
* **Clustered Bar Chart: Default Rate % by Income Segment**
  * Low Income (< 100,000): **8.20%**
  * Middle Income (100,000 - 200,000): **8.55%**
  * High Income (> 200,000): **7.14%**
* **Clustered Bar Chart: Payment Burden (Fee-to-Income %) by Income Segment**
  * Low Income: **23.99%**
  * Middle Income: **18.23%**
  * High Income: **13.58%**
* **Donut Chart: Portfolio Distribution**
  * Non-Default (`TARGET = 0`): `282,686` (91.9%)
  * Default (`TARGET = 1`): `24,825` (8.1%)

---

### Page 2: Behavioral Risk Signals
![Illustrative Dashboard Layout Preview: Page 2 — Behavioral Risk Signals](../images/dashboard_page2_behavioral_signals.png)

#### Visual Elements:
* **Horizontal Bar Chart: Top 10 Riskiest Occupations by Default Rate %**
  * Includes a benchmark reference line at **8.07%** (portfolio average).
  * *Low-skill Laborers:* **17.15%** (2.1x portfolio baseline)
  * *Drivers:* **11.33%**
  * *Waiters/barmen staff:* **11.28%**
  * *Security staff:* **10.74%**
  * *Laborers:* **10.58%**
  * *Cooking staff:* **10.44%**
  * *Sales staff:* **9.87%**
  * *Cleaning staff:* **9.61%**
* **Column Chart: Default Rate % by Credit Bureau Inquiry Level**
  * Evaluates inquiries during the preceding 12 months (`AMT_REQ_CREDIT_BUREAU_YEAR`).
  * *No Inquiries (0):* **7.13%** (71,801 clients)
  * *Low (1–3):* **7.74%** (147,225 clients)
  * *Medium (4–6):* **8.42%** (39,733 clients)
  * *High (7+):* **9.28%** (7,233 clients — 30% default surge over 0 inquiries)

---

## DAX Measures & Calculated Columns

The dashboard relies on the following DAX calculations:

### Key Measures
```dax
Total Clients = 
COUNTROWS('credit_risk_powerbi')

Total Defaults = 
CALCULATE(
    COUNTROWS('credit_risk_powerbi'),
    'credit_risk_powerbi'[TARGET] = 1
)

Default Rate % = 
DIVIDE([Total Defaults], [Total Clients], 0) * 100

Avg Fee to Income % = 
AVERAGE('credit_risk_powerbi'[fee_to_income_pct])

Avg Credit Amount = 
AVERAGE('credit_risk_powerbi'[AMT_CREDIT])

Avg Annuity Amount = 
AVERAGE('credit_risk_powerbi'[AMT_ANNUITY])
```

### Calculated Columns
```dax
fee_to_income_pct = 
DIVIDE('credit_risk_powerbi'[AMT_ANNUITY], 'credit_risk_powerbi'[AMT_INCOME_TOTAL], 0) * 100

income_segment = 
SWITCH(
    TRUE(),
    'credit_risk_powerbi'[AMT_INCOME_TOTAL] < 100000, "Low Income",
    'credit_risk_powerbi'[AMT_INCOME_TOTAL] <= 200000, "Middle Income",
    "High Income"
)

default_label = 
IF('credit_risk_powerbi'[TARGET] = 1, "Default", "No Default")

inquiries_tier = 
SWITCH(
    TRUE(),
    ISBLANK('credit_risk_powerbi'[AMT_REQ_CREDIT_BUREAU_YEAR]), "Unknown",
    'credit_risk_powerbi'[AMT_REQ_CREDIT_BUREAU_YEAR] = 0, "No Inquiries",
    'credit_risk_powerbi'[AMT_REQ_CREDIT_BUREAU_YEAR] <= 3, "Low Inquiries (1-3)",
    'credit_risk_powerbi'[AMT_REQ_CREDIT_BUREAU_YEAR] <= 6, "Medium Inquiries (4-6)",
    "High Inquiries (7+)"
)
```

---

## Technical Specifications & How to Open

* **File:** `credit_risk_dashboard.pbix`
* **File Size:** ~6.4 MB (contains embedded VertiPaq database with the processed dataset)
* **Compatibility:** Microsoft Power BI Desktop (Windows 10/11)
* **Data Refresh Instructions:**
  1. Open `dashboard/credit_risk_dashboard.pbix` in Microsoft Power BI Desktop.
  2. If repointing to a newly generated `credit_risk_powerbi.csv`:
     * Go to **Home > Transform Data > Data Source Settings**.
     * Select the file source and update the path to your local `data/credit_risk_powerbi.csv`.
     * Click **Apply Changes**.
  3. All visuals, DAX measures, and filters will automatically update.
