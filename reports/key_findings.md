# Credit Risk Analytics: Key Findings & Business Recommendations

**Target Audience:** Credit Risk Committee, Chief Risk Officer (CRO), Underwriting Policy Team, and BI Analytics Leadership  
**Dataset:** Home Credit Default Risk (307,511 Loan Applications)  
**Methodology:** Descriptive & Diagnostic Analytics via SQL (SQLite), Python (Pandas), and Power BI  

---

## 1. Executive Summary

This report synthesizes findings from a comprehensive credit risk evaluation of **307,511 consumer loan applications**. The overall portfolio exhibits an **8.07% default rate** (24,825 non-performing loans), which sits substantially above conventional prime retail banking benchmarks (5.0% – 7.0%). 

The primary business problem is that uniform loan origination standards expose the institution to outsized credit losses, particularly among low-income earners, specific vulnerable labor occupations, and borrowers demonstrating repeated credit-seeking stress.

By applying structured SQL segmentation, debt-burden ratio analysis, and behavioral inquiry tracking, we isolate high-risk borrower clusters and provide concrete, quantifiable underwriting adjustments to compress default rates while maintaining loan book growth.

---

## 2. Core Empirical Findings

### Finding 1: Portfolio Default Baseline and Class Imbalance
* **Total Applications:** 307,511
* **Repaid Loans (`TARGET = 0`):** 282,686 (91.93%)
* **Defaulted Loans (`TARGET = 1`):** 24,825 (8.07%)
* **Diagnostic Implication:** The strong 92:8 class imbalance underscores that aggregate performance metrics can mask pockets of severe risk. Credit scoring cannot rely on naive approval rules; granular policy cutoffs are required.

### Finding 2: The Payment-Burden Paradox Across Income Tiers
Analysis of monthly debt servicing relative to annual gross income (`fee_to_income_pct = (AMT_ANNUITY / AMT_INCOME_TOTAL) * 100`) reveals an acute structural vulnerability:

| Income Tier | Annual Income Range | Borrower Volume | Default Rate | Avg Fee-to-Income % | Avg Loan Size |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Low Income** | < $100,000 | 63,698 (20.7%) | **8.20%** | **23.99%** | $341,200 |
| **Middle Income**| $100,000 – $200,000 | 155,898 (50.7%) | **8.55%** | **18.23%** | $604,800 |
| **High Income** | > $200,000 | 87,915 (28.6%) | **7.14%** | **13.58%** | $775,400 |

* **Key Takeaway:** Low-income borrowers dedicate **24.0%** of their annual income to loan installments—nearly **1.8x the debt service burden** of high-income peers (13.6%). 
* Defaulters receive lower absolute credit amounts on average ($557,778 vs $602,648 for non-defaulters) yet pay virtually identical monthly annuities (~$26,482 vs ~$27,163). This confirms that defaults are driven by **disproportionate monthly installment strain**, not gross borrowing size.

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
| ... | *Benchmark* | *307,511* | *8.07%* | *1.00x* |
| **Lowest**| **Accountants & Managers** | 22,238 | **4.9% – 5.8%** | **0.61x – 0.72x** |

* **Key Takeaway:** Blue-collar and hourly service workers (Low-skill Laborers, Drivers, Hospitality) experience more than double the credit distress of salaried professionals, driven by wage volatility, lack of emergency cash reserves, and irregular shifts.

### Finding 4: Credit Bureau Inquiry Frequency Signals Acute Liquidity Distress
Tracking credit bureau inquiries in the 12 months preceding application (`AMT_REQ_CREDIT_BUREAU_YEAR`) reveals a direct monotonic relationship with default probability:

| Inquiry Tier | Annual Inquiries | Applicant Volume | Segment Share | Default Rate % |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 0 (No Inquiries)** | 0 | 71,801 | 27.0% | **7.13%** |
| **Tier 1 (Low)** | 1 – 3 | 147,225 | 55.4% | **7.74%** |
| **Tier 2 (Medium)** | 4 – 6 | 39,733 | 14.9% | **8.42%** |
| **Tier 3 (High)** | 7+ | 7,233 | 2.7% | **9.28%** |

* **Key Takeaway:** Borrowers shopping aggressively for credit (7+ inquiries) suffer a **30.1% higher default rate** compared to applicants with no inquiries (9.28% vs 7.13%). Excessive recent credit inquiries serve as an observable leading indicator of liquidity shortfalls.

### Finding 5: Contract Type and Selection Bias
* **Cash Loans:** 278,232 applicants | **8.35% default rate**
* **Revolving Loans:** 29,279 applicants | **5.48% default rate**
* **Key Takeaway:** Revolving credit displays a default rate 2.87 percentage points lower than standard cash installment loans. Rather than revolving credit being fundamentally safer, this reflects stricter pre-qualification criteria historically applied to revolving credit approvals.

---

## 3. Actionable Business & Underwriting Recommendations

### Recommendation 1: Implement Dynamic Debt-to-Income (DTI) Caps
* **Policy Change:** Institute a hard cap on `fee_to_income_pct` at **20.0%** for all applicants earning under $100,000/year.
* **Mechanism:** Rather than rejecting applicants outright, offer term extensions (lengthening repayment tenure from 24 to 36 or 48 months), effectively reducing monthly annuities to sustainable levels (< 15% of monthly income).
* **Projected Impact:** Could prevent up to 15%–20% of defaults within the low-income segment without forfeiting fee income.

### Recommendation 2: Risk-Based Pricing & Tiered Reserves for High-Risk Occupations
* **Policy Change:** For occupations exceeding 10.0% default rates (Drivers, Hospitality, Security, Low-skill labor):
  * Introduce a **150 – 250 bps risk premium** to compensate for expected credit loss (ECL).
  * Require co-signers or verifiable direct-deposit salary accounts for loan amounts > $500,000.
* **Projected Impact:** Generates incremental margin to absorb elevated provisions while incentivizing responsible borrowing.

### Recommendation 3: Automated Credit Bureau Inquiry Velocity Rules
* **Policy Change:** Establish automated underwriting gating based on bureau inquiry volume:
  * **0 – 3 Inquiries:** Standard automated processing.
  * **4 – 6 Inquiries:** Secondary income validation required.
  * **7+ Inquiries within 12 Months:** Mandatory manual underwriting review; loan amount capped at 75% of requested principal.
* **Projected Impact:** Eliminates high-velocity credit stacking where distressed borrowers take out multiple loans across lenders concurrently.

### Recommendation 4: Expand Revolving Loan Product Access to Prime Segments
* **Policy Change:** Given the low 5.48% default rate on revolving loans, launch pre-approved revolving credit lines for high-income applicants (> $200k) and low-risk occupations (Accountants, Managers).
* **Projected Impact:** Drives portfolio expansion in prime segments with superior repayment performance.

---

## 4. Conclusion & Governance Alignment

By moving from uniform credit policies to **segment-specific, burden-conscious underwriting**, Home Credit can compress its portfolio default rate from 8.07% closer to the 6.0% industry standard. The accompanying SQL pipeline and Power BI dashboard empower portfolio managers to monitor these segment thresholds in near real-time.
