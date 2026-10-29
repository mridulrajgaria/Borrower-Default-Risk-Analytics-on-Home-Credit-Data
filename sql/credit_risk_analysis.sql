-- ==============================================================================
-- PROJECT: Borrower Default Risk Analytics on Home Credit Data
-- MODULE: Comprehensive Credit Risk Analysis in SQL (SQLite Compatible)
-- AUTHOR: Portfolio Project
-- PURPOSE: Descriptive & Diagnostic Risk Segmentation, Payment Burden Analysis,
--          and High-Risk Borrower Identification.
-- ==============================================================================
--
-- EXECUTION INSTRUCTIONS:
-- 1. Prerequisites:
--    Ensure the 'applications' table is loaded into your SQLite database.
--    In Python:
--        import sqlite3, pandas as pd
--        conn = sqlite3.connect('credit_risk.db')
--        df = pd.read_csv('data/application_train.csv')
--        df.to_sql('applications', conn, if_exists='replace', index=False)
--
-- 2. Running Queries via SQLite CLI:
--        sqlite3 credit_risk.db < sql/credit_risk_analysis.sql
--
-- 3. Schema Reference:
--    - SK_ID_CURR: Application unique ID
--    - TARGET: 1 = Default / Payment difficulty, 0 = Repaid loan
--    - AMT_INCOME_TOTAL: Total annual income
--    - AMT_CREDIT: Total loan amount
--    - AMT_ANNUITY: Monthly payment / annuity
--    - NAME_CONTRACT_TYPE: 'Cash loans' or 'Revolving loans'
--    - OCCUPATION_TYPE: Borrower occupation category
--    - AMT_REQ_CREDIT_BUREAU_YEAR: Number of credit bureau queries in last 12 months
-- ==============================================================================


-- ==============================================================================
-- QUERY 1: Portfolio Benchmark & Target Class Distribution
-- Purpose: Establish baseline default rate and portfolio volume.
-- Business Context: Essential benchmark for comparing all sub-segment default rates.
-- ==============================================================================
SELECT 
    TARGET,
    CASE 
        WHEN TARGET = 1 THEN 'Default' 
        ELSE 'Non-Default' 
    END AS default_status,
    COUNT(1) AS total_borrowers,
    ROUND(COUNT(1) * 100.0 / (SELECT COUNT(1) FROM applications), 2) AS portfolio_share_pct
FROM applications
GROUP BY TARGET;


-- ==============================================================================
-- QUERY 2: Financial Profile Comparison by Default Status
-- Purpose: Compare average income, credit size, annuity, and payment burden between
--          defaulters and non-defaulters.
-- Business Context: Reveals whether loan size or debt burden relative to income 
--                   is the primary differentiator.
-- ==============================================================================
SELECT 
    TARGET,
    CASE 
        WHEN TARGET = 1 THEN 'Default' 
        ELSE 'Non-Default' 
    END AS default_status,
    COUNT(1) AS borrower_count,
    ROUND(AVG(AMT_INCOME_TOTAL), 2) AS avg_annual_income,
    ROUND(AVG(AMT_CREDIT), 2) AS avg_credit_amount,
    ROUND(AVG(AMT_ANNUITY), 2) AS avg_monthly_annuity,
    ROUND(AVG(AMT_ANNUITY / NULLIF(AMT_INCOME_TOTAL, 0)) * 100.0, 2) AS avg_fee_to_income_pct,
    ROUND(AVG(AMT_CREDIT / NULLIF(AMT_INCOME_TOTAL, 0)), 2) AS avg_credit_to_income_ratio
FROM applications
WHERE AMT_INCOME_TOTAL > 0
GROUP BY TARGET;


-- ==============================================================================
-- QUERY 3: Income Segmentation & Payment Burden (Fee-to-Income) Analysis
-- Purpose: Segment borrowers into Low (<100k), Middle (100k-200k), and High (>200k) tiers
--          to analyze default rate and debt service burden.
-- Business Context: Tests the hypothesis that lower-income borrowers face unsustainable 
--                   debt servicing ratios.
-- ==============================================================================
SELECT 
    CASE 
        WHEN AMT_INCOME_TOTAL < 100000 THEN '1. Low Income (< $100k)'
        WHEN AMT_INCOME_TOTAL BETWEEN 100000 AND 200000 THEN '2. Middle Income ($100k - $200k)'
        ELSE '3. High Income (> $200k)'
    END AS income_segment,
    COUNT(1) AS total_borrowers,
    SUM(TARGET) AS total_defaults,
    ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct,
    ROUND(AVG(AMT_ANNUITY / NULLIF(AMT_INCOME_TOTAL, 0)) * 100.0, 2) AS avg_fee_to_income_pct,
    ROUND(AVG(AMT_CREDIT), 2) AS avg_loan_size
FROM applications
WHERE AMT_INCOME_TOTAL > 0
GROUP BY income_segment
ORDER BY income_segment ASC;


-- ==============================================================================
-- QUERY 4: Default Rate by Loan Contract Type (Cash vs. Revolving)
-- Purpose: Assess portfolio performance across loan products.
-- Business Context: Evaluates product-level credit performance and selection dynamics.
-- ==============================================================================
SELECT 
    NAME_CONTRACT_TYPE AS contract_type,
    COUNT(1) AS total_applications,
    SUM(TARGET) AS default_count,
    ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct,
    ROUND(AVG(AMT_CREDIT), 2) AS avg_loan_amount,
    ROUND(AVG(AMT_ANNUITY), 2) AS avg_annuity
FROM applications
GROUP BY NAME_CONTRACT_TYPE
ORDER BY default_rate_pct DESC;


-- ==============================================================================
-- QUERY 5: Credit Bureau Inquiry Analysis (Inquiry Intensity vs Default Risk)
-- Purpose: Classify annual inquiry volume into stress tiers and evaluate default correlation.
-- Business Context: Bureau search intensity is a primary behavioral distress signal.
-- ==============================================================================
WITH bureau_segmentation AS (
    SELECT 
        SK_ID_CURR,
        TARGET,
        AMT_REQ_CREDIT_BUREAU_YEAR,
        CASE 
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR = 0 THEN '0. No Inquiries (0)'
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR BETWEEN 1 AND 3 THEN '1. Low Inquiries (1-3)'
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR BETWEEN 4 AND 6 THEN '2. Medium Inquiries (4-6)'
            ELSE '3. High Inquiries (7+)'
        END AS inquiry_tier
    FROM applications
    WHERE AMT_REQ_CREDIT_BUREAU_YEAR IS NOT NULL
)
SELECT 
    inquiry_tier,
    COUNT(1) AS borrower_count,
    SUM(TARGET) AS default_count,
    ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct,
    ROUND(COUNT(1) * 100.0 / (SELECT COUNT(1) FROM bureau_segmentation), 2) AS segment_share_pct
FROM bureau_segmentation
GROUP BY inquiry_tier
ORDER BY inquiry_tier ASC;


-- ==============================================================================
-- QUERY 6: Top 10 Riskiest Occupations (Using CTE and Window Functions)
-- Purpose: Rank occupation categories by default rate using RANK() window function.
-- Business Context: Informs underwriting rules and targeted risk premiums for volatile roles.
-- ==============================================================================
WITH occupation_metrics AS (
    SELECT 
        OCCUPATION_TYPE AS occupation,
        COUNT(1) AS total_borrowers,
        SUM(TARGET) AS defaults,
        ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct,
        ROUND(AVG(AMT_INCOME_TOTAL), 2) AS avg_income,
        ROUND(AVG(AMT_ANNUITY / NULLIF(AMT_INCOME_TOTAL, 0)) * 100.0, 2) AS avg_debt_burden_pct
    FROM applications
    WHERE OCCUPATION_TYPE IS NOT NULL
    GROUP BY OCCUPATION_TYPE
    HAVING COUNT(1) >= 500  -- Filter for statistically robust sample sizes
),
ranked_occupations AS (
    SELECT 
        occupation,
        total_borrowers,
        defaults,
        default_rate_pct,
        avg_income,
        avg_debt_burden_pct,
        RANK() OVER (ORDER BY default_rate_pct DESC) AS risk_rank,
        DENSE_RANK() OVER (ORDER BY default_rate_pct DESC) AS dense_risk_rank
    FROM occupation_metrics
)
SELECT 
    risk_rank,
    occupation,
    total_borrowers,
    defaults,
    default_rate_pct,
    avg_income,
    avg_debt_burden_pct
FROM ranked_occupations
WHERE risk_rank <= 10
ORDER BY risk_rank ASC;


-- ==============================================================================
-- QUERY 7: Multi-Dimensional Risk Matrix (Income Segment x Bureau Inquiries)
-- Purpose: Combine income capacity with credit-seeking behavior to identify compounded risk.
-- Business Context: Demonstrates that interaction between financial capacity and behavior 
--                   yields substantially higher default pockets.
-- ==============================================================================
WITH multi_risk_cte AS (
    SELECT 
        SK_ID_CURR,
        TARGET,
        CASE 
            WHEN AMT_INCOME_TOTAL < 100000 THEN 'Low Income'
            WHEN AMT_INCOME_TOTAL <= 200000 THEN 'Middle Income'
            ELSE 'High Income'
        END AS income_tier,
        CASE 
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR = 0 THEN '0 Inquiries'
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR BETWEEN 1 AND 3 THEN '1-3 Inquiries'
            WHEN AMT_REQ_CREDIT_BUREAU_YEAR BETWEEN 4 AND 6 THEN '4-6 Inquiries'
            ELSE '7+ Inquiries'
        END AS bureau_inquiries_tier
    FROM applications
    WHERE AMT_INCOME_TOTAL > 0 
      AND AMT_REQ_CREDIT_BUREAU_YEAR IS NOT NULL
)
SELECT 
    income_tier,
    bureau_inquiries_tier,
    COUNT(1) AS borrower_count,
    SUM(TARGET) AS default_count,
    ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct
FROM multi_risk_cte
GROUP BY income_tier, bureau_inquiries_tier
ORDER BY income_tier, default_rate_pct DESC;


-- ==============================================================================
-- QUERY 8: Identification of Extreme High-Risk Segments for Underwriting Review
-- Purpose: Cross-tabulate occupation and contract type, ranking sub-segments with default
--          rates exceeding the 8.07% portfolio benchmark.
-- Business Context: Actionable intelligence for setting strict underwriting policy cutoffs.
-- ==============================================================================
WITH segment_eval AS (
    SELECT 
        OCCUPATION_TYPE AS occupation,
        NAME_CONTRACT_TYPE AS contract_type,
        COUNT(1) AS segment_size,
        SUM(TARGET) AS defaults,
        ROUND(AVG(TARGET) * 100.0, 2) AS default_rate_pct,
        ROUND(AVG(AMT_ANNUITY / NULLIF(AMT_INCOME_TOTAL, 0)) * 100.0, 2) AS avg_payment_burden_pct
    FROM applications
    WHERE OCCUPATION_TYPE IS NOT NULL
    GROUP BY OCCUPATION_TYPE, NAME_CONTRACT_TYPE
    HAVING COUNT(1) >= 200
)
SELECT 
    DENSE_RANK() OVER (ORDER BY default_rate_pct DESC) AS risk_priority,
    occupation,
    contract_type,
    segment_size,
    defaults,
    default_rate_pct,
    avg_payment_burden_pct,
    ROUND(default_rate_pct - 8.07, 2) AS excess_risk_vs_portfolio_pct
FROM segment_eval
WHERE default_rate_pct > 8.07
ORDER BY risk_priority ASC
LIMIT 15;
