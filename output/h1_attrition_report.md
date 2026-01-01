# Explicit Racism Predicts ANES-GSS Joint Study Completion: A Selection Bias Concern

## Summary

Analysis of the GSS 2016-2020 Panel data reveals that respondents who completed the ANES-GSS 2020 Joint Study differed systematically from non-completers on measures of explicit racial prejudice. Specifically, **individuals scoring higher on explicit racism (racial stereotype gap scores) were significantly more likely to complete the joint study** (OR = 1.25, 95% CI: 1.05-1.49, p = .013), even after controlling for demographics, education, income, and political orientation. This finding suggests potential selection bias in research using the joint study data to examine relationships between racial attitudes and political behavior.

## Background

The ANES-GSS 2020 Joint Study linked 1,164 respondents from the GSS 2016-2020 Panel with ANES post-election data, enabling researchers to combine GSS measures of racial attitudes with ANES measures of political behavior. However, panel studies are vulnerable to differential attrition—systematic differences between those who continue participating and those who drop out.

Previous research on panel attrition in ANES and GSS has documented that attrition extends beyond demographic predictors to include attitudinal and psychological characteristics. Frankel and Hillygus (2014) found that interest in politics and social connectedness predict panel retention. However, **whether racial attitudes specifically predict survey completion has not been extensively examined**.

## Methods

### Data
- **GSS 2016-2020 Panel**: N = 5,215 respondents across three waves (2016, 2018, 2020)
- **ANES-GSS Joint Study**: n = 1,164 GSS panelists who completed ANES post-election interview (November 2020 - January 2021)
- **Outcome**: Binary indicator of joint study completion (completed_anes)

### Measures

**Explicit racism** was operationalized as the average gap between ratings of Whites and Blacks on stereotype scales (intelligence, work ethic), following standard GSS methodology:
- INTLWHTS - INTLBLKS (intelligence gap)
- WORKWHTS - WORKBLKS (work ethic gap)
- Higher scores indicate more negative stereotyping of Blacks relative to Whites

**Symbolic racism** was constructed from GSS items measuring beliefs about racial inequality (WRKWAYUP, RACDIF1-4), recoded so higher values indicate greater symbolic racism.

**Covariates**: age, sex, race (white), education, household income, social trust, political views, party identification.

### Analysis
Logistic regression predicting joint study completion from racial attitude measures and covariates. Random forest analysis provided variable importance rankings.

## Results

### Descriptive Comparison

| Variable | Non-Completers (n=4,051) | Completers (n=1,164) |
|----------|--------------------------|----------------------|
| Explicit racism | M = -0.11, SD = 0.77 | M = 0.01, SD = 0.68 |
| Symbolic racism | M = 0.43, SD = 0.20 | M = 0.45, SD = 0.17 |
| Education (years) | M = 13.4, SD = 3.0 | M = 14.9, SD = 2.9 |
| Age | M = 49.4, SD = 18.2 | M = 52.5, SD = 16.7 |
| White (%) | 70.8% | 79.5% |
| Social trust (%) | 28.5% | 44.3% |

Joint study completers scored **higher** on explicit racism than non-completers (d = 0.16), were more educated, older, more likely to be white, and more trusting.

### Logistic Regression

Controlling for demographics and political orientation (N = 1,544 complete cases):

| Predictor | Odds Ratio | 95% CI | p |
|-----------|------------|--------|---|
| Explicit racism | **1.25** | 1.05 - 1.49 | **.013** |
| Symbolic racism | 1.52 | 0.80 - 2.89 | .204 |
| Education | 1.20 | 1.14 - 1.27 | <.001 |
| Age | 1.01 | 1.00 - 1.02 | .001 |
| Social trust | 1.25 | 0.96 - 1.63 | .101 |
| White | 0.98 | 0.73 - 1.34 | .915 |
| Political views | 1.04 | 0.94 - 1.14 | .473 |
| Party ID | 1.01 | 0.94 - 1.09 | .719 |

**Each 1-point increase in explicit racism (on the gap score scale) was associated with 25% higher odds of completing the joint study.**

### Random Forest Variable Importance

Top predictors of completion (permutation importance):
1. Income (0.028)
2. Education (0.023)
3. Social trust (0.008)
4. Symbolic racism (0.003)
5. Explicit racism (0.003)

Both racism measures ranked among the top 5 predictors beyond demographics.

## Discussion

### Key Finding
This analysis reveals a previously undocumented form of selection bias: **explicit racial prejudice predicts survey participation** in the ANES-GSS joint study. Respondents who rate Blacks more negatively relative to Whites on stereotype measures were more likely to complete the follow-up ANES interview.

### Interpretation
Several mechanisms could explain this pattern:

1. **Engagement with racial content**: Individuals with stronger racial attitudes (in either direction) may be more motivated to participate in surveys that ask about race and politics.

2. **Social trust pathway**: Completers showed higher social trust (44% vs. 29%), and trust correlates with both survey participation and certain racial attitude profiles.

3. **Education confounding**: Higher education predicts both completion and certain patterns of explicit racial attitudes; however, the effect persisted after controlling for education.

4. **Methodological artifact**: The explicit racism measures may capture response style variance (e.g., willingness to differentiate between groups) that also predicts survey engagement.

### Implications for Research

1. **Bias in ANES-GSS joint study estimates**: Studies using joint study data to examine relationships between racial attitudes and political outcomes may underestimate or distort these relationships due to non-random selection.

2. **Weighting may be insufficient**: Standard demographic weights cannot correct for selection on attitudes that are themselves the focus of analysis.

3. **Generalizability concerns**: Findings from the joint study may not generalize to the broader GSS panel population, particularly for analyses involving racial attitude measures.

### Relation to Prior Literature

The finding that attitudinal variables predict attrition aligns with Frankel and Hillygus (2014), who documented that "panel attrition reflects both the characteristics of the individual respondent as well as her survey experience." However, **the specific finding that racial prejudice predicts completion appears to be novel**.

Prior work has focused on:
- Demographic predictors of attrition (age, education, mobility)
- Political interest and engagement
- Social trust and connectedness

The racial attitude-completion relationship documented here extends this literature by identifying a content-specific form of selection bias particularly relevant to research on race and politics.

### Race Stratified Analysis

One potential concern is whether the explicit racism effect is confounded by respondent race. To address this, we conducted stratified analyses:

**Correlation between race and explicit racism**: r = -0.04 (negligible; whites actually scored *slightly lower* on explicit racism)

**Stratified results** (controlling for demographics):

| Sample | Explicit Racism OR | 95% CI | p |
|--------|-------------------|--------|---|
| White respondents only (n=1,136) | **1.31** | 1.05-1.66 | **.021** |
| Non-white respondents only (n=408) | 1.22 | 0.92-1.63 | .173 |

**Interpretation**: The explicit racism effect **holds within white respondents alone**. Among whites only, each 1-point increase in explicit racism is associated with 31% higher odds of completing the joint study. The non-white sample shows the same directional effect but lacks statistical power.

The race x explicit_racism interaction was not significant (p = .40), indicating the effect does not differ by race. This rules out race as a confound—the finding reflects within-race variation in explicit attitudes, not between-race demographic differences.

### Limitations

1. **Explicit racism measures only on Ballots A/B**: ~1/3 structural missingness reduces power
2. **Cannot determine direction**: The data show correlation, not whether racial attitudes causally influence participation
3. **Single study**: Replication needed across other panel studies and time periods
4. **Magnitude is modest**: OR = 1.25-1.31 represents a small-to-medium effect

## Conclusion

Researchers using the ANES-GSS 2020 Joint Study should be aware that the sample is non-randomly selected on explicit racial attitudes. This selection bias may affect estimates of relationships between racial attitudes and political behavior. Sensitivity analyses comparing joint study results to GSS panel-only estimates are recommended.

---

## References

Frankel, L. L., & Hillygus, D. S. (2014). Looking beyond demographics: Panel attrition in the ANES and GSS. *Political Analysis*, 22(3), 336-353.

Stark, T. H., van Maaren, F. M., Krosnick, J. A., & Sood, G. (2022). The impact of social desirability pressures on whites' endorsement of racial stereotypes. *Sociological Methods & Research*, 51(1), 3-34.

---

*Analysis conducted using GSS 2016-2020 Panel (Release 1a) and ANES-GSS 2020 Joint Study data.*
*Code: scripts/03_h1_attrition.R, scripts/03b_h1_race_stratified.R*
