# Item-Level Analysis: Which Racial Attitude Items Predict Trump Voting?

## Summary

Decomposing the composite racism measures into individual items reveals that **not all racial attitudes are equally predictive** of Trump voting. Excluding the tautological predictors (partyid, polviews), we find that denial of discrimination and bootstrap ideology dominate; genetic attribution and intelligence stereotypes matter little.

## Results

### Variable Importance Ranking (Bootstrap-Stabilized, N=450)

*Excluding partyid and polviews - "Republicans voted Republican" is not insight.*

| Rank | Variable | Importance | Type | Content |
|------|----------|------------|------|---------|
| 1 | eqwlth | 0.088 | Economic | Govt should reduce inequality |
| 2 | confed_r | 0.063 | Institutional | Confidence in fed govt |
| **3** | **racdif1** | **0.058** | **Symbolic** | **Discrimination causes inequality** |
| 4 | conpress_r | 0.055 | Institutional | Confidence in press |
| **5** | **wrkwayup** | **0.049** | **Symbolic** | **Work way up without favors** |
| 6 | white | 0.021 | Demographic | Race (white) |
| **7** | **racdif3** | **0.020** | **Symbolic** | **Lack of motivation** |
| 8 | age | 0.019 | Demographic | Age |
| 9 | realinc | 0.017 | Demographic | Income |
| 10 | auth_index | 0.015 | Psychological | Authoritarianism |
| **11** | **work_gap** | **0.015** | **Explicit** | **Work ethic stereotype** |
| **12** | **racdif4** | **0.014** | **Symbolic** | **Lack of education** |
| 13 | thnkself | 0.013 | Psychological | Think for self (auth) |
| **14** | **explicit_racism** | **0.010** | **Explicit** | **Composite stereotypes** |
| 15 | fund | 0.010 | Religious | Fundamentalism |
| 16 | consci_r | 0.009 | Institutional | Confidence in science |
| **17** | **symbolic_racism** | **0.009** | **Symbolic** | **Composite symbolic** |
| 18 | coneduc_r | 0.008 | Institutional | Confidence in education |

**Rejected by Boruta** (not significant predictors): intl_gap, racdif2, educ, attend, region, satfin, finrela, helpful_r, trust_r, female

### Racism Items Only

| Rank | Item | Importance | Boruta | Interpretation |
|------|------|------------|--------|----------------|
| 1 | racdif1 | 0.058 | Confirmed | Denying discrimination causes inequality → Trump |
| 2 | wrkwayup | 0.049 | Confirmed | "Work way up without favors" → Trump |
| 3 | racdif3 | 0.020 | Confirmed | Attributing inequality to lack of motivation → Trump |
| 4 | work_gap | 0.015 | Confirmed | "Blacks are lazy" stereotype → Trump |
| 5 | racdif4 | 0.014 | Confirmed | Attributing inequality to lack of education → Trump |
| 6 | intl_gap | — | **Rejected** | "Blacks are less intelligent" → **NOT A PREDICTOR** |
| 7 | racdif2 | — | **Rejected** | Genetic/inborn ability → **NOT A PREDICTOR** |

## Key Insights

### 1. Economic Redistribution is #1

Once we remove partisan identity, **eqwlth** (government should reduce income differences) emerges as the top predictor. This isn't about race directly, but connects to the deservingness narrative below.

### 2. Institutional Distrust Matters

Confidence in federal government (#2) and press (#4) are major predictors. Trump voting is associated with institutional skepticism.

### 3. Denial of Discrimination (#3) > All Stereotypes

The strongest racial attitude predictor is **racdif1**: whether you believe discrimination causes Black-White inequality. Saying "no" strongly predicts Trump voting.

This is a *symbolic racism* item, not explicit prejudice.

### 4. Work Ethic > Intelligence (Intelligence Doesn't Matter)

Among explicit stereotype measures:
- **Work ethic gap**: importance = 0.015, Boruta **Confirmed**
- **Intelligence gap**: Boruta **Rejected** - not a significant predictor

The "lazy" stereotype predicts Trump voting. The "unintelligent" stereotype does not.

### 5. Genetic Attribution Doesn't Matter At All

**racdif2** (inborn ability/genetic explanation) was **rejected by Boruta** as a predictor, despite being conceptually the most "explicitly racist" belief.

This means overt biological racism isn't what differentiates Trump from Biden voters. Instead, it's:
- Denying structural barriers (racdif1)
- Endorsing bootstrap ideology (wrkwayup)
- Attributing inequality to effort/motivation (racdif3, work_gap)

### 6. The Meritocracy Narrative

The pattern points to a **meritocracy-based racial resentment**:
- "Discrimination isn't holding Black people back"
- "They just need to work harder like everyone else"
- "They're lazy, not victims of circumstance"

This is **completely distinct** from:
- "Black people are genetically inferior" (racdif2 - rejected as predictor)
- "Black people are less intelligent" (intl_gap - rejected as predictor)

## Implications

1. **Composite measures obscure critical variation**: The "explicit racism" composite averaged items with very different predictive power. The intelligence stereotype pulls weight, but it's not doing anything for Trump prediction.

2. **The IQ debate is politically irrelevant**: Much political discussion focuses on whether IQ differences are genetic. But neither this belief (racdif2) nor the intelligence stereotype (intl_gap) predict Trump voting. These are empirically dead ends for understanding the racial politics of 2020.

3. **Symbolic racism items outperform explicit stereotypes**: This strongly supports the symbolic racism literature - it's about racial resentment of "undeserved" benefits, not old-fashioned stereotypes.

4. **The economic connection**: eqwlth (redistribution) ranks #1 overall. The racial attitudes that matter most are those tied to deservingness and effort - the same logic underlying opposition to redistribution.

5. **For measurement**: Future research should consider whether composite racism scales obscure more than they reveal. Individual items differ dramatically in their political relevance.

---

*Analysis: Random Forest with Boruta feature selection + 50 bootstrap samples for stability. N = 450 complete cases. Test AUC = 0.931. Excluding partyid and polviews as tautological.*

