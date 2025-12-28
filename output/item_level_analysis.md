# Item-Level Analysis: Which Racial Attitude Items Predict Trump Voting?

## Summary

Decomposing the composite racism measures into individual items reveals that **not all racial attitudes are equally predictive** of Trump voting. The "lazy" stereotype and denial of discrimination dominate; genetic attribution and intelligence stereotypes matter little.

## Results

### Variable Importance Ranking (Bootstrap-Stabilized)

| Rank | Variable | Importance | Type | Content |
|------|----------|------------|------|---------|
| 1 | partyid | 0.293 | Control | Party identification |
| 2 | polviews | 0.137 | Control | Liberal-conservative |
| 3 | eqwlth | 0.102 | Economic | Govt should reduce inequality |
| 4 | conpress | 0.083 | Institutional | Confidence in press |
| **5** | **racdif1** | **0.072** | **Symbolic** | **Discrimination causes inequality** |
| **6** | **wrkwayup** | **0.059** | **Symbolic** | **Work way up without favors** |
| 7 | confed | 0.056 | Institutional | Confidence in fed govt |
| 8 | age | 0.030 | Demographic | Age |
| 9 | realinc | 0.026 | Demographic | Income |
| **10** | **work_gap** | **0.026** | **Explicit** | **Work ethic stereotype** |
| 11 | educ | 0.022 | Demographic | Education |
| **12** | **racdif3** | **0.020** | **Symbolic** | **Lack of motivation** |
| **13** | **intl_gap** | **0.018** | **Explicit** | **Intelligence stereotype** |
| 14 | attend | 0.018 | Religious | Church attendance |
| 15 | white | 0.016 | Demographic | Race (white) |
| **16** | **racdif4** | **0.011** | **Symbolic** | **Lack of education** |
| 17 | female | 0.007 | Demographic | Gender |
| **18** | **racdif2** | **0.005** | **Explicit** | **Inborn ability (genetic)** |

### Racism Items Only

| Rank | Item | Importance | Interpretation |
|------|------|------------|----------------|
| 1 | racdif1 | 0.072 | Denying discrimination causes inequality → Trump |
| 2 | wrkwayup | 0.059 | "Work way up without favors" → Trump |
| 3 | work_gap | 0.026 | "Blacks are lazy" stereotype → Trump |
| 4 | racdif3 | 0.020 | Attributing inequality to lack of motivation → Trump |
| 5 | intl_gap | 0.018 | "Blacks are less intelligent" stereotype → Trump |
| 6 | racdif4 | 0.011 | Denying education gap → Trump |
| 7 | racdif2 | 0.005 | Genetic/inborn ability attribution → (barely matters) |

## Key Insights

### 1. Denial of Discrimination (#1) > Stereotypes

The strongest racial attitude predictor isn't a stereotype at all - it's **racdif1**: whether you believe discrimination causes Black-White inequality. Saying "no" strongly predicts Trump voting.

This is a *symbolic racism* item, not explicit prejudice.

### 2. Work Ethic > Intelligence

Among explicit stereotype measures:
- **Work ethic gap**: importance = 0.026
- **Intelligence gap**: importance = 0.018

The "lazy" stereotype is 44% more predictive than the "unintelligent" stereotype.

### 3. Genetic Attribution Barely Matters

**racdif2** (inborn ability/genetic explanation) ranks **dead last** among all racism items, despite being conceptually the most "explicitly racist" belief.

This suggests that overt biological racism isn't what differentiates Trump from Biden voters. Instead, it's:
- Denying structural barriers (racdif1)
- Endorsing bootstrap ideology (wrkwayup)
- Attributing inequality to effort/motivation (racdif3, work_gap)

### 4. The Meritocracy Narrative

The pattern points to a **meritocracy-based racial resentment**:
- "Discrimination isn't holding Black people back"
- "They just need to work harder like everyone else"
- "They're lazy, not victims of circumstance"

This is distinct from:
- "Black people are genetically inferior" (racdif2 - doesn't predict)
- "Black people are less intelligent" (intl_gap - weak predictor)

## Implications

1. **Composite measures obscure important variation**: The "explicit racism" composite averaged items with very different predictive power.

2. **The intelligence/IQ debate may be a distraction**: Much political discussion focuses on whether IQ differences are genetic. But this belief (racdif2) doesn't predict voting. What matters is whether you think Black people are *lazy* and whether *discrimination is real*.

3. **Symbolic racism items outperform explicit stereotypes**: This supports the symbolic racism literature - it's about racial resentment of "undeserved" benefits, not old-fashioned stereotypes.

4. **Connects to welfare state attitudes**: Note that eqwlth (redistribution) ranks #3 overall. The racial attitudes that matter most are those tied to deservingness and effort.

---

*Analysis: Random Forest with 50 bootstrap samples for stability. N = 437 complete cases. Test AUC = 0.991.*
