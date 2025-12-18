# ESOP Tax Credit Research Project

## Purpose
This repository houses data, analysis, and reports examining the causal effect of Colorado's HB17-1214, an employee ownership support program enacted in 2017, on firm-level ESOP participation and asset accumulation.

**Research Question:** _What is the effect of Colorado's HB17-1214 employee ownership support program on firm-level ESOP participation and asset accumulation?_

## Key Findings

Our analysis using Department of Labor Form 5500 filings (2012-2025) with a difference-in-differences design comparing Colorado to Utah reveals:

For full details, see the [final paper](report/tex/esop_paper_final.pdf).



- **Limited policy effects**: Small and mostly statistically insignificant increases in ESOP participation and assets
- **Marginal significance**: Only total ESOP assets showed marginal significance at the 10% level (~$2.9 million increase, representing ~9% relative to baseline)
- **Participation outcomes**: ESOP firm indicator increased 0.6 percentage points (insignificant); total participants and active participants showed ~9% point estimates but lacked statistical precision
- **Synthetic control analysis**: Suggested larger effects, but poor pre-treatment fit undermines confidence in these estimates

Our findings suggest education-based and financing-focused employee ownership policies may require longer time horizons or more direct financial incentives to generate substantial ESOP adoption among small and medium-sized businesses.

## Policy Context

Colorado's HB17-1214 (signed by Governor Hickenlooper in 2017) focused on:
- Educational support through contracted nonprofit organizations specializing in employee ownership
- Loan program capitalized with $200,000 annual state appropriations (2017-2022) to finance ESOP transitions
- Eligibility: Small businesses (< $5 million revenue), at least 2 years old with ≥3 employees

Reported outcomes: 20-25 businesses per year transitioned to employee ownership with program support.

## Methodology

**Difference-in-Differences (DiD):** We compare Colorado firms (treatment, post-2017) to Utah firms (control) and Colorado firms (pre-2017) before and after the 2017 policy implementation. This removes time-invariant differences between states and common macroeconomic shocks.

**Identification Assumptions:**

- *Parallel Trends:* Event study analysis confirms Colorado and Utah exhibited parallel trends during pre-treatment period (2012-2016)
- *Compliance:* HB17-1214 provisions exclusively available in Colorado; Utah enacted no comparable policies
- *SUTVA (No Spillovers):* Program benefits require Colorado residency; ESOP transitions unlikely influenced by neighboring state policies
- *Exclusion Restriction:* Policy narrowly targeted education and ESOP-specific financing with modest funding; unlikely to generate substantial spillovers

**Robustness Check:** Synthetic control methodology constructing counterfactual "synthetic Colorado" from weighted combinations of other U.S. states (Iowa and Missouri excluded due to own ESOP legislation).

## Important Limitations

- **Inference constraints**: Treatment assigned at state level while outcomes measured at firm level; with only two states, state-level clustering is infeasible, potentially overstating precision of firm-level estimates
- **Limited statistical power**: Single treatment state and control state provides minimal variation to distinguish treatment effects from Colorado-specific shocks
- **Confounding variables**: Pension plan participation depends on firm profitability, employee turnover, competing benefits, and management preferences—state-specific time-varying factors cannot be controlled
- **Data limitations**: Form 5500 lacks detailed firm characteristics; cannot examine heterogeneous effects by firm size or ESOP structure
- **Missing coverage**: Analysis may miss smaller ESOPs below Form 5500 reporting thresholds (typically plans with 100+ participants or more complex structures)
