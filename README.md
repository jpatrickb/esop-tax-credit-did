# ESOP Tax Credit Research Project

## Purpose
This repository houses data, analysis, and reports to answer the following causal questions:

**Primary:** _What is the effect of the Colorado Employee Ownership Tax Credit on firm-level ESOP participation and asset accumulation?_

**Secondary:** _Does an exogenous increase in ESOP participation (induced by the tax credit) increase firm-level employment or wages?_

## Identification Strategies
To do this, we employ the following identification strategies:

**Difference-in-Differences (DiD):** We compare Colorado firms (Treatment) to Utah firms (Control) before and after the policy implementation.

* Why?: This removes time-invariant differences between the states (e.g., Utah is generally more conservative) and common macroeconomic shocks affecting both states (e.g., a national recession). By keeping the data at the firm level, we can also control for specific firm characteristics if available.

**Instrumental Variables (2SLS):** If the DiD confirms the tax credit increased participation (a strong First Stage), we use the Tax Credit as an instrument for ESOP Participation.

* Why: We want to know if ESOPs create jobs. A direct regression is biased because successful, growing firms are more likely to start ESOPs. The Tax Credit could serve as "random" variation in ESOP adoption unrelated to a specific firm's health.

## Identifying Assumptions:
Each identification strategy requires specific assumptions to be met.

**Diff-In-Diff:** 

- *Parallel Trends:* In the absence of the tax credit, the trajectory of ESOP participation for firms in Colorado would have tracked that of firms in Utah.  
- *Compliance:*  
- *SUTVA:*

**IV**

- *Relevance:* The tax credit significantly lowers cost, causing a measurable increase in ESOP adoption.  
- *Exogeneity:* The specific timing of the tax credit's passage is unrelated to time-varying, firm-specific unobserved shocks (e.g., a sudden firm-level productivity boom).  
- *Exclusion:* The tax credit affects the outcome (Employment/Wages) only through the channel of increasing ESOP participation, not directly.  
- *Monotonicity:* No firm is less likely to start an ESOP simply because the tax credit exists.

