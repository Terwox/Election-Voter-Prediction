# =============================================================================
# 02_derive_variables.R - Variable Derivation
# GSS Explicit Racism & Trump Voting Analysis
# =============================================================================

source("scripts/00_setup.R")

# Load merged data
message("Loading merged data...")
joint_data <- readRDS(file.path(data_processed, "joint_data.rds"))

# =============================================================================
# 2a. Explicit Racism Measures (GSS stereotype items)
# 7-point scales: 1 = negative trait, 7 = positive trait
# Gap scores: positive = more negative view of Blacks relative to Whites
# =============================================================================
message("Creating explicit racism measures...")

analytic_data <- joint_data %>%
  mutate(
    # Use wave 2 (2020) measures where available, fall back to wave 1
    intlwhts = coalesce(intlwhts_2, intlwhts_1a, intlwhts_1b),
    intlblks = coalesce(intlblks_2, intlblks_1a, intlblks_1b),
    workwhts = coalesce(workwhts_2, workwhts_1a, workwhts_1b),
    workblks = coalesce(workblks_2, workblks_1a, workblks_1b),

    # Gap scores
    intl_gap = intlwhts - intlblks,
    work_gap = workwhts - workblks,

    # Combined explicit racism index (average of gap scores)
    explicit_racism = (intl_gap + work_gap) / 2
  )

message("Explicit racism: N with data = ", sum(!is.na(analytic_data$explicit_racism)))

# =============================================================================
# 2b. Symbolic Racism Measures (GSS items)
# =============================================================================
message("Creating symbolic racism measures...")

analytic_data <- analytic_data %>%
  mutate(
    # Use wave 2 where available
    wrkwayup = coalesce(wrkwayup_2, wrkwayup_1a, wrkwayup_1b),
    racdif1 = coalesce(racdif1_2, racdif1_1a, racdif1_1b),
    racdif2 = coalesce(racdif2_2, racdif2_1a, racdif2_1b),
    racdif3 = coalesce(racdif3_2, racdif3_1a, racdif3_1b),
    racdif4 = coalesce(racdif4_2, racdif4_1a, racdif4_1b),

    # Recode for symbolic racism index
    # WRKWAYUP: reverse so higher = more symbolic racism (original 1-5, 1=agree strongly)
    wrkwayup_r = 6 - wrkwayup,

    # RACDIF items: recode to 0/1 where 1 = more symbolic racism
    racdif1_r = if_else(racdif1 == 2, 1, 0),  # 1 if denies discrimination
    racdif2_r = if_else(racdif2 == 1, 1, 0),  # 1 if endorses ability
    racdif3_r = if_else(racdif3 == 1, 1, 0),  # 1 if endorses motivation
    racdif4_r = if_else(racdif4 == 2, 1, 0)   # 1 if denies education
  ) %>%
  rowwise() %>%
  mutate(
    # Create symbolic racism index (standardized mean)
    symbolic_racism = mean(c(
      scale(wrkwayup_r)[1],
      racdif1_r,
      racdif2_r,
      racdif3_r,
      racdif4_r
    ), na.rm = TRUE)
  ) %>%
  ungroup()

message("Symbolic racism: N with data = ", sum(!is.na(analytic_data$symbolic_racism)))

# =============================================================================
# 2c. Outcome Variables
# =============================================================================
message("Creating outcome variables...")

analytic_data <- analytic_data %>%
  mutate(
    # 2016 vote from GSS (check actual coding in data)
    # Typically: 1=Clinton, 2=Trump, 3=Other, 4=Didn't vote
    pres16 = coalesce(pres16_2, pres16_1a, pres16_1b),
    trump16 = case_when(
      pres16 == 2 ~ 1,  # Trump
      pres16 == 1 ~ 0,  # Clinton
      TRUE ~ NA_real_
    ),

    # 2020 vote from GSS (whovote1_2)
    # From data exploration: 1=Trump, 2=Biden based on partyid crosstab
    trump20_gss = case_when(
      whovote1_2 == 1 ~ 1,  # Trump
      whovote1_2 == 2 ~ 0,  # Biden
      TRUE ~ NA_real_
    ),

    # 2020 vote from ANES (v202073) - validated vote
    # ANES coding: 1=Biden, 2=Trump (standard ANES coding)
    trump20_anes = case_when(
      v202073 == 2 ~ 1,  # Trump
      v202073 == 1 ~ 0,  # Biden
      TRUE ~ NA_real_
    ),

    # Use ANES vote if available, else GSS
    trump20 = coalesce(trump20_anes, trump20_gss)
  )

message("Trump 2016: N = ", sum(!is.na(analytic_data$trump16)),
        " (", sum(analytic_data$trump16 == 1, na.rm = TRUE), " Trump)")
message("Trump 2020: N = ", sum(!is.na(analytic_data$trump20)),
        " (", sum(analytic_data$trump20 == 1, na.rm = TRUE), " Trump)")

# =============================================================================
# 2d. Covariates
# =============================================================================
message("Creating covariate variables...")

analytic_data <- analytic_data %>%
  mutate(
    # Demographics (prefer wave 2, fall back to wave 1)
    age = coalesce(age_2, age_1a, age_1b),
    sex = coalesce(sex_2, sex_1a, sex_1b),
    female = if_else(sex == 2, 1, 0),

    race = coalesce(race_1a, race_1b),  # Race only in wave 1
    white = if_else(race == 1, 1, 0),
    black = if_else(race == 2, 1, 0),

    educ = coalesce(educ_2, educ_1a, educ_1b),
    degree = coalesce(degree_2, degree_1a, degree_1b),
    realinc = coalesce(realinc_2, realinc_1a, realinc_1b),
    region = coalesce(region_2, region_1a, region_1b),

    # Social Trust (1=yes/can trust, 2=no/can't trust -> recode to 1=trusting)
    trust = coalesce(trust_2, trust_1a, trust_1b),
    trust_r = if_else(trust == 1, 1, 0),
    fair = coalesce(fair_2, fair_1a, fair_1b),
    fair_r = if_else(fair == 1, 1, 0),
    helpful = coalesce(helpful_2, helpful_1a, helpful_1b),
    helpful_r = if_else(helpful == 1, 1, 0),

    # Authoritarianism proxies (child-rearing values)
    # OBEY and THNKSELF are rankings (1-5, lower = more important)
    obey = coalesce(obey_2, obey_1a, obey_1b),
    thnkself = coalesce(thnkself_2, thnkself_1a, thnkself_1b),
    # Higher auth_index = more authoritarian (obey more important than thnkself)
    auth_index = thnkself - obey,

    # Institutional Confidence (1=great deal, 2=some, 3=hardly any)
    # Recode so higher = more confidence
    consci = coalesce(consci_2, consci_1a, consci_1b),
    consci_r = 4 - consci,
    conpress = coalesce(conpress_2, conpress_1a, conpress_1b),
    conpress_r = 4 - conpress,
    confed = coalesce(confed_2, confed_1a, confed_1b),
    confed_r = 4 - confed,
    coneduc = coalesce(coneduc_2, coneduc_1a, coneduc_1b),
    coneduc_r = 4 - coneduc,

    # Religious
    attend = coalesce(attend_2, attend_1a, attend_1b),  # 0-8, higher = more
    relig = coalesce(relig_1a, relig_1b),
    fund = coalesce(fund_1a, fund_1b),

    # Economic attitudes
    eqwlth = coalesce(eqwlth_2, eqwlth_1a, eqwlth_1b),  # 1-7, 1=govt reduce diff
    finrela = coalesce(finrela_2, finrela_1a, finrela_1b),
    satfin = coalesce(satfin_2, satfin_1a, satfin_1b),

    # Political
    polviews = coalesce(polviews_2, polviews_1a, polviews_1b),  # 1-7, 1=extremely lib
    partyid = coalesce(partyid_2, partyid_1a, partyid_1b),  # 0-6, 0=strong dem

  )

# =============================================================================
# 2d-extended. Extended fishing expedition variables
# Helper function to safely coalesce columns that may not exist
# =============================================================================
safe_coalesce <- function(df, ...) {
  cols <- c(...)
  existing <- cols[cols %in% names(df)]
  if (length(existing) == 0) return(rep(NA_real_, nrow(df)))
  if (length(existing) == 1) return(df[[existing]])
  reduce(df[existing], coalesce)
}

analytic_data <- analytic_data %>%
  mutate(
    # --- Spending priorities (1=too little, 2=about right, 3=too much) ---
    natspac = safe_coalesce(., "natspac_2", "natspac_1a", "natspac_1b"),
    natenvir = safe_coalesce(., "natenvir_2", "natenvir_1a", "natenvir_1b"),
    natheal = safe_coalesce(., "natheal_2", "natheal_1a", "natheal_1b"),
    natcity = safe_coalesce(., "natcity_2", "natcity_1a", "natcity_1b"),
    natcrime = safe_coalesce(., "natcrime_2", "natcrime_1a", "natcrime_1b"),
    natdrug = safe_coalesce(., "natdrug_2", "natdrug_1a", "natdrug_1b"),
    nateduc = safe_coalesce(., "nateduc_2", "nateduc_1a", "nateduc_1b"),
    natrace = safe_coalesce(., "natrace_2", "natrace_1a", "natrace_1b"),
    natarms = safe_coalesce(., "natarms_2", "natarms_1a", "natarms_1b"),
    nataid = safe_coalesce(., "nataid_2", "nataid_1a", "nataid_1b"),
    natfare = safe_coalesce(., "natfare_2", "natfare_1a", "natfare_1b"),
    natsci = safe_coalesce(., "natsci_2", "natsci_1a", "natsci_1b"),

    # --- Civil liberties / Free speech (1=yes, 2=no) ---
    spkath = safe_coalesce(., "spkath_2", "spkath_1a", "spkath_1b"),
    spkrac = safe_coalesce(., "spkrac_2", "spkrac_1a", "spkrac_1b"),
    spkcom = safe_coalesce(., "spkcom_2", "spkcom_1a", "spkcom_1b"),
    spkmil = safe_coalesce(., "spkmil_2", "spkmil_1a", "spkmil_1b"),
    spkhomo = safe_coalesce(., "spkhomo_2", "spkhomo_1a", "spkhomo_1b"),

    # --- Social attitudes ---
    cappun = safe_coalesce(., "cappun_2", "cappun_1a", "cappun_1b"),
    gunlaw = safe_coalesce(., "gunlaw_2", "gunlaw_1a", "gunlaw_1b"),
    courts = safe_coalesce(., "courts_2", "courts_1a", "courts_1b"),
    grass = safe_coalesce(., "grass_2", "grass_1a", "grass_1b"),

    # --- Religion deep dive ---
    reliten = safe_coalesce(., "reliten_2", "reliten_1a", "reliten_1b"),
    postlife = safe_coalesce(., "postlife_2", "postlife_1a", "postlife_1b"),
    pray = safe_coalesce(., "pray_2", "pray_1a", "pray_1b"),
    bible = safe_coalesce(., "bible_2", "bible_1a", "bible_1b"),

    # --- Gender role attitudes ---
    fehome = safe_coalesce(., "fehome_2", "fehome_1a", "fehome_1b"),
    fework = safe_coalesce(., "fework_2", "fework_1a", "fework_1b"),
    fepol = safe_coalesce(., "fepol_2", "fepol_1a", "fepol_1b"),
    fepres = safe_coalesce(., "fepres_2", "fepres_1a", "fepres_1b"),

    # --- Abortion ---
    abany = safe_coalesce(., "abany_2", "abany_1a", "abany_1b"),
    abdefect = safe_coalesce(., "abdefect_2", "abdefect_1a", "abdefect_1b"),
    abrape = safe_coalesce(., "abrape_2", "abrape_1a", "abrape_1b"),
    abpoor = safe_coalesce(., "abpoor_2", "abpoor_1a", "abpoor_1b"),

    # --- Sexual morality ---
    premarsx = safe_coalesce(., "premarsx_2", "premarsx_1a", "premarsx_1b"),
    homosex = safe_coalesce(., "homosex_2", "homosex_1a", "homosex_1b"),
    xmarsex = safe_coalesce(., "xmarsex_2", "xmarsex_1a", "xmarsex_1b"),

    # --- Happiness/wellbeing ---
    happy = safe_coalesce(., "happy_2", "happy_1a", "happy_1b"),
    health = safe_coalesce(., "health_2", "health_1a", "health_1b"),
    life = safe_coalesce(., "life_2", "life_1a", "life_1b"),
    hapmar = safe_coalesce(., "hapmar_2", "hapmar_1a", "hapmar_1b"),

    # --- Work/economic ---
    class = safe_coalesce(., "class_2", "class_1a", "class_1b"),
    getahead = safe_coalesce(., "getahead_2", "getahead_1a", "getahead_1b"),
    satjob = safe_coalesce(., "satjob_2", "satjob_1a", "satjob_1b"),
    wrkslf = safe_coalesce(., "wrkslf_2", "wrkslf_1a", "wrkslf_1b"),
    wrkstat = safe_coalesce(., "wrkstat_2", "wrkstat_1a", "wrkstat_1b"),
    union = safe_coalesce(., "union_2", "union_1a", "union_1b"),

    # --- Confidence in MORE institutions ---
    conbus = safe_coalesce(., "conbus_2", "conbus_1a", "conbus_1b"),
    conclerg = safe_coalesce(., "conclerg_2", "conclerg_1a", "conclerg_1b"),
    conlabor = safe_coalesce(., "conlabor_2", "conlabor_1a", "conlabor_1b"),
    conmedic = safe_coalesce(., "conmedic_2", "conmedic_1a", "conmedic_1b"),
    contv = safe_coalesce(., "contv_2", "contv_1a", "contv_1b"),
    conjudge = safe_coalesce(., "conjudge_2", "conjudge_1a", "conjudge_1b"),
    conlegis = safe_coalesce(., "conlegis_2", "conlegis_1a", "conlegis_1b"),
    conarmy = safe_coalesce(., "conarmy_2", "conarmy_1a", "conarmy_1b"),

    # --- Racial contact ---
    closeblk = safe_coalesce(., "closeblk_2", "closeblk_1a", "closeblk_1b"),
    closewht = safe_coalesce(., "closewht_2", "closewht_1a", "closewht_1b"),
    racmar = safe_coalesce(., "racmar_2", "racmar_1a", "racmar_1b"),
    affrmact = safe_coalesce(., "affrmact_2", "affrmact_1a", "affrmact_1b"),

    # --- Oddballs / Long shots ---
    tvhours = safe_coalesce(., "tvhours_2", "tvhours_1a", "tvhours_1b"),
    news = safe_coalesce(., "news_2", "news_1a", "news_1b"),
    socbar = safe_coalesce(., "socbar_2", "socbar_1a", "socbar_1b"),
    socfrend = safe_coalesce(., "socfrend_2", "socfrend_1a", "socfrend_1b"),
    socrel = safe_coalesce(., "socrel_2", "socrel_1a", "socrel_1b"),
    childs = safe_coalesce(., "childs_2", "childs_1a", "childs_1b"),
    sibs = safe_coalesce(., "sibs_2", "sibs_1a", "sibs_1b"),
    divorce = safe_coalesce(., "divorce_2", "divorce_1a", "divorce_1b"),
    marital = safe_coalesce(., "marital_2", "marital_1a", "marital_1b"),
    born = safe_coalesce(., "born_2", "born_1a", "born_1b"),
    granborn = safe_coalesce(., "granborn_2", "granborn_1a", "granborn_1b"),
    hunt = safe_coalesce(., "hunt_2", "hunt_1a", "hunt_1b"),
    owngun = safe_coalesce(., "owngun_2", "owngun_1a", "owngun_1b"),
    spanking = safe_coalesce(., "spanking_2", "spanking_1a", "spanking_1b"),
    letdie1 = safe_coalesce(., "letdie1_2", "letdie1_1a", "letdie1_1b"),
    suicide1 = safe_coalesce(., "suicide1_2", "suicide1_1a", "suicide1_1b"),
    fear = safe_coalesce(., "fear_2", "fear_1a", "fear_1b"),
    anomia5 = safe_coalesce(., "anomia5_2", "anomia5_1a", "anomia5_1b"),
    workhard = safe_coalesce(., "workhard_2", "workhard_1a", "workhard_1b")
  )

# =============================================================================
# 2e. Summary statistics
# =============================================================================
message("\nKey variable summary:")

key_vars <- c("completed_anes", "trump16", "trump20",
              "explicit_racism", "symbolic_racism",
              "age", "female", "white", "educ", "polviews", "partyid")

var_summary <- analytic_data %>%
  select(all_of(key_vars)) %>%
  summarise(across(everything(), list(
    n = ~sum(!is.na(.)),
    mean = ~mean(., na.rm = TRUE),
    sd = ~sd(., na.rm = TRUE)
  ))) %>%
  pivot_longer(everything(), names_to = "stat", values_to = "value") %>%
  separate(stat, into = c("variable", "statistic"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = statistic, values_from = value)

print(var_summary)

# =============================================================================
# 2f. Save analytic data
# =============================================================================
message("\nSaving analytic data...")

saveRDS(analytic_data, file.path(data_processed, "analytic_data.rds"))
write_csv(var_summary, file.path(output_tables, "02_variable_summary.csv"))

message("\n02_derive_variables.R complete!")
