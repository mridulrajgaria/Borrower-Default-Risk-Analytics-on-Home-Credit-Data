# Credit Risk Analytics: Key Findings & Business Recommendations

**Target Audience:** Credit Risk Committee, Chief Risk Officer (CRO), Underwriting Policy Team, and BI Analytics Leadership  
**Dataset:** Home Credit Default Risk (307,511 Loan Applications)  
**Methodology:** Descriptive & Diagnostic Analytics via SQL (SQLite), Python (Pandas), and Power BI  
**Monetary Note:** All financial quantities (`AMT_INCOME_TOTAL`, `AMT_CREDIT`, `AMT_ANNUITY`) reflect raw dataset currency units as provided in the source competition data.

---

## 1. Executive Summary

This report synthesizes empirical findings from a credit risk evaluation of **307,511 consumer loan applications**. The overall portfolio exhibits an **8.07% default rate** (24,825 non-performing loans), which sits substantially above conventional prime retail banking benchmarks (5.0% – 7.0%). 

The primary business challenge is that uniform loan origination standards expose the institution to outsized credit losses, particularly among low-income earners, specific vulnerable labor occupations, and borrowers demonstrating repeated credit-seeking stress.

By applying structured SQL segmentation, debt-burden ratio analysis, and behavioral inquiry tracking, we isolate high-risk borrower clusters and provide exploratory findings to inform underwriting policy discussions.

---

## 2. Core Empirical Findings

### Finding 1: Portfolio Default Baseline and Class Imbalance
* **Total Applications:** 307,511
* **Repaid Loans (`TARGET = 0`):** 282,686 (91.93%)
* **Defaulted Loans (`TARGET = 1`):** 24,825 (8.07%)
* **Diagnostic Implication:** The strong 92:8 class imbalance underscores that aggregate performance metrics can mask pockets of severe risk. Credit scoring cannot rely on naive approval rules; granular policy cutoffs are required.

### Finding 2: The Payment-Burden Paradox Across Income Tiers
Analysis of monthly debt servicing relative to annual gross income (`fee_to_income_pct = (AMT_ANNUITY / AMT_INCOME_TOTAL) * 100`) reveals an acute structural vulnerability across income segments:

| Income Tier | Annual Income Range (Units) | Borrower Volume | Default Rate | Avg Fee-to-Income % | Avg Loan Size (Units) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Low Income** | < 100,000 | 63,698 (20.7%) | **8.20%** | **23.99%** | 341,200 |
| **Middle Income**| 100,000 – 200,000 | 155,898 (50.7%) | **8.55%** | **18.23%** | 604,800 |
| **High Income** | > 200,000 | 87,915 (28.6%) | **7.14%** | **13.58%** | 775,400 |

* **Empirical Takeaway:** Low-income borrowers dedicate **24.0%** of their annual income to loan installments—nearly **1.8x the debt service burden** of high-income peers (13.6%). 
* Defaulters receive lower absolute credit amounts on average (557,779 units vs 602,648 units for non-defaulters) yet pay virtually identical monthly annuities (~26,482 vs ~27,164). This observed association indicates that defaults correlate with **disproportionate monthly installment strain**, rather than gross borrowing size alone.

### Finding 3: Occupation Category as a Critical Risk Stratifier
When segmenting by verified occupation, default rates vary across a wide spectrum from **1.7% to 17.2%**:

| Rank | Occupation | Total Applicants | Default Rate % | Risk Multiple vs Baseline (8.07%) |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Low-skill Laborers** | 2,093 | **17.15%** | **2.12x** |
| **2** | **Drivers** | 18,603 | **11.33%** | **1.40x** |
| **3** | **Waiters / Barmen Staff** | 1,348 | **11.28%** | **1.40x** |
| **4** | **Security Staff** | 6,721 | **10.74%** | **1.33x** |
| **5** | **Laborers** | 55,186 | **10.58%** | **1.31x** |
| **6** | **Cooking Staff** | 5,946 | **10.44%** | **1.29x** |
| **7** | **Sales Staff** | 32,102 | **9.87%** | **1.22x** |
| **8** | **Cleaning Staff** | 4,653 | **9.61%** | **1.19x** |
| ... | *Portfolio Average* | *307,511* | *8.07%* | *1.00x* |
| **Lowest**| **Accountants & Managers** | 22,238 | **4.9% – 5.8%** | **0.61x – 0.72x** |

* **Empirical Takeaway:** Blue-collar and hourly service workers (Low-skill Laborers, Drivers, Hospitality) exhibit default rates substantially above portfolio average, consistent with potential wage volatility and reduced liquidity buffers.

### Finding 4: Credit Bureau Inquiry Frequency Signals Elevated Default Risk
Tracking credit bureau inquiries in the 12 months preceding application (`AMT_REQ_CREDIT_BUREAU_YEAR`) demonstrates an increasing default trend with search volume:

| Inquiry Tier | Annual Inquiries | Applicant Volume | Segment Share | Default Rate % |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 0 (No Inquiries)** | 0 | 71,801 | 27.0% | **7.13%** |
| **Tier 1 (Low)** | 1 – 3 | 147,225 | 55.4% | **7.74%** |
| **Tier 2 (Medium)** | 4 – 6 | 39,733 | 14.9% | **8.42%** |
| **Tier 3 (High)** | 7+ | 7,233 | 2.7% | **9.28%** |

* **Empirical Takeaway:** Borrowers with 7+ annual inquiries exhibit a **9.28% default rate**, compared to **7.13%** for applicants with zero inquiries (a 30.1% relative elevation). 

### Finding 5: Contract Type and Pre-Screening Dynamics
* **Cash Loans:** 278,232 applicants | **8.35% default rate**
* **Revolving Loans:** 29,279 applicants | **5.48% default rate**
* **Empirical Takeaway:** Revolving credit displays a default rate 2.87 percentage points lower than standard cash installment loans. Rather than revolving credit inherently carrying lower risk, this difference likely reflects stricter pre-qualification criteria historically applied to revolving credit approvals.

---

## 3. Methodological Note: Association vs. Causation

The analyses presented in this report are **descriptive and observational**. 
* **Statistical associations do not establish causal relationships:** For instance, while a higher debt-to-income ratio strongly correlates with default, this does not prove that modifying loan tenure or monthly payments will causally reduce defaults by a specific percentage. 
* Unobserved confounding variables (e.g., macroeconomic headwinds, sudden job loss, unexpected medical expenses, or credit-seeking behavior from distress) may simultaneously influence both borrower attributes and default outcomes.
* Consequently, all recommendations below represent **proposed business hypotheses** that require rigorous pilot testing, randomized trial verification, or multivariate modeling before enterprise policy adoption.

---

## 4. Underwriting Recommendations & Hypotheses for Testing

### Recommendation 1: Test Debt-to-Income (DTI) Caps for Low-Income Tiers
* **Proposed Policy:** Evaluate introducing a policy cap on `fee_to_income_pct` (e.g., at 20.0%) for applicants earning under 100,000 units.
* **Operational Hypothesis:** Rather than rejecting applicants outright, explore term extensions (lengthening repayment tenure) to reduce monthly annuity obligations.
* **Testing Requirement:** Implement a controlled pilot across selected regional branches to measure whether term restructuring genuinely improves repayment rates without increasing cumulative lifetime default hazard.

### Recommendation 2: Evaluate Risk-Based Pricing for Volatile Occupations
* **Proposed Policy:** For occupation categories with observed default rates exceeding 10.0% (e.g., Low-skill Laborers, Drivers, Hospitality):
  * Explore risk-adjusted interest rate tiers or enhanced income verification.
  * Require co-signers or direct-deposit salary verification for credit amounts above 500,000 units.
* **Operational Hypothesis:** Risk premiums could improve margin coverage for elevated portfolio loss rates, while stricter verification mitigates fraudulent or misstated income applications.

### Recommendation 3: Implement Tiered Gating for Bureau Inquiries
* **Proposed Policy:** Test automated gating rules tied to credit bureau inquiry volume:
  * **0 – 3 Inquiries:** Standard automated processing.
  * **4 – 6 Inquiries:** Secondary income and liability documentation required.
  * **7+ Inquiries within 12 Months:** Route to manual underwriter review.
* **Operational Hypothesis:** Multi-lender credit shopping often indicates imminent liquidity strain; manual inspection may intercept over-indebted borrowers.

### Recommendation 4: Pilot Targeted Revolving Credit Products for Prime Segments
* **Proposed Policy:** Evaluate offering pre-approved revolving credit products to applicants in high-income tiers (> 200,000 units) and low-risk occupations (Accountants, Managers).
* **Operational Hypothesis:** Given the historical 5.48% default rate in revolving facilities, targeted expansion in lower-risk segments could grow portfolio revenue while maintaining disciplined portfolio risk.

---

## 5. Summary & Next Steps

Descriptive analytics provides crucial visibility into portfolio loss concentration. To progress from diagnostic insights to operational policy changes:
1. Conduct controlled Champion/Challenger pilot tests for proposed DTI caps and bureau inquiry gating rules.
2. Continually monitor segment KPIs via the companion Power BI dashboard (`dashboard/credit_risk_dashboard.pbix`).
3. Incorporate longitudinal payment records and credit bureau histories to assess borrower repayment behavior across time.
