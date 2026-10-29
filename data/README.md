# Dataset Information & Setup Guide

## Dataset Overview

The dataset used in this project is from the **Home Credit Default Risk** competition hosted on Kaggle. It contains real-world loan application records for unbanked and underbanked individuals, providing comprehensive demographic, financial, and behavioral attributes.

* **Source:** [Kaggle — Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk)
* **Primary File:** `application_train.csv`
* **File Size:** ~166 MB uncompressed
* **Dimensions:** 307,511 rows × 122 columns
* **Target Variable:** `TARGET` (Binary: `0` = Loan repaid on time, `1` = Client had payment difficulties / defaulted)

---

## Download & Placement Instructions

Due to GitHub's file size limits and Kaggle licensing terms, raw competition data files are **not committed to this repository**. 

To reproduce the analysis locally:

1. Visit the Kaggle competition page: [Home Credit Default Risk Data](https://www.kaggle.com/competitions/home-credit-default-risk/data).
2. Download `application_train.csv` (or the complete archive).
3. Place `application_train.csv` inside this directory:
   ```text
   data/application_train.csv
   ```
4. Verify the file path structure:
   ```text
   Borrower-Default-Risk-Analytics-on-Home-Credit-Data/
   ├── data/
   │   ├── application_train.csv    <-- Place downloaded file here
   │   └── README.md
   ├── notebooks/
   │   └── credit_risk_analysis.ipynb
   └── ...
   ```

---

## Key Columns Used in Analytics

| Column Name | Type | Description |
| :--- | :--- | :--- |
| `SK_ID_CURR` | Integer | Unique identifier for each loan application. |
| `TARGET` | Binary (0/1) | Target indicator: `1` = Default / payment difficulty, `0` = All other cases. |
| `NAME_CONTRACT_TYPE` | Categorical | Contract product type: `Cash loans` or `Revolving loans`. |
| `CODE_GENDER` | Categorical | Gender of the applicant (`M`, `F`, `XNA`). |
| `FLAG_OWN_CAR` | Categorical | Flag if applicant owns a car (`Y`, `N`). |
| `FLAG_OWN_REALTY` | Categorical | Flag if applicant owns a house or flat (`Y`, `N`). |
| `CNT_CHILDREN` | Integer | Number of children the applicant has. |
| `AMT_INCOME_TOTAL` | Numerical | Annual gross income of the applicant. |
| `AMT_CREDIT` | Numerical | Total credit / loan amount approved. |
| `AMT_ANNUITY` | Numerical | Monthly loan annuity (installment payment). |
| `AMT_GOODS_PRICE` | Numerical | Price of goods for which consumer loan is given. |
| `NAME_INCOME_TYPE` | Categorical | Client's income source (Working, State servant, Pensioner, etc.). |
| `NAME_EDUCATION_TYPE` | Categorical | Level of highest education completed. |
| `NAME_FAMILY_STATUS` | Categorical | Family / marital status of the client. |
| `DAYS_BIRTH` | Numerical | Age in days at the time of application (negative value). |
| `DAYS_EMPLOYED` | Numerical | Employment duration in days (negative value; 365243 denotes unemployed/pensioner). |
| `OCCUPATION_TYPE` | Categorical | Staff occupation category (18 distinct roles). |
| `AMT_REQ_CREDIT_BUREAU_YEAR` | Numerical | Number of inquiries to Credit Bureau about the client within the last year. |
| `EXT_SOURCE_1 / 2 / 3` | Numerical | Normalized external credit scoring bureau scores. |

---

## Derived & Calculated Fields

During exploratory analysis and SQL segmentation, the following fields are engineered:

* **`fee_to_income_pct`**: Monthly payment burden calculated as `(AMT_ANNUITY / AMT_INCOME_TOTAL) * 100`.
* **`income_segment`**: Categorical tier based on `AMT_INCOME_TOTAL`:
  * `Low Income`: < $100,000
  * `Middle Income`: $100,000 to $200,000
  * `High Income`: > $200,000
* **`inquiries_segment`**: Tier based on `AMT_REQ_CREDIT_BUREAU_YEAR`:
  * `No Inquiries`: 0
  * `Low Inquiries`: 1 – 3
  * `Medium Inquiries`: 4 – 6
  * `High Inquiries`: 7+
* **`default_label`**: Text translation of target (`Default` vs `No Default`).
