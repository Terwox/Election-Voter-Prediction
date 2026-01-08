# =============================================================================
# 06_extended_fishing.R - Extended Variable Importance (Fishing Expedition v2)
#
# Strategy:
# - Keep top 30 predictors from initial analysis (Boruta confirmed, high importance)
# - Add ~250 new variables (targeting 5 obs/predictor with N=1444)
# - Exclude the 59 variables ranked 31-89 in initial analysis (already tested, weak)
# =============================================================================

source("scripts/00_setup.R")

# Load merged data (pre-derived)
message("Loading merged data...")
joint_data <- readRDS(file.path(data_processed, "joint_data.rds"))

# =============================================================================
# Helper function
# =============================================================================
safe_coalesce <- function(df, ...) {
  cols <- c(...)
  existing <- cols[cols %in% names(df)]
  if (length(existing) == 0) return(rep(NA_real_, nrow(df)))
  if (length(existing) == 1) return(df[[existing]])
  reduce(df[existing], coalesce)
}

# =============================================================================
# TOP 30 FROM INITIAL ANALYSIS (keep these)
# =============================================================================
# 1. eqwlth, 2. conpress_r, 3. racdif1, 4. confed_r, 5. wrkwayup,
# 6. white, 7. courts, 8. affrmact, 9. natsci, 10. cappun,
# 11. abany, 12. racdif3, 13. abpoor, 14. work_gap, 15. racdif4,
# 16. contv, 17. gunlaw, 18. abdefect, 19. abrape, 20. homosex,
# 21. conarmy, 22. bible, 23. explicit_racism, 24. fepol, 25. premarsx,
# 26. spanking, 27. hunt, 28. granborn, 29. symbolic_racism, 30. pray

# =============================================================================
# EXCLUDED FROM ANALYSIS (ranked 31-89, already tested as weak/tentative)
# =============================================================================
# realinc, auth_index, born, consci_r, age, reliten, suicide1, owngun, obey,
# grass, thnkself, spkrac, marital, conclerg, coneduc_r, educ, news, attend,
# conlabor, fund, tvhours, letdie1, intl_gap, workhard, socbar, sibs, conlegis,
# spkath, getahead, postlife, conbus, class, xmarsex, happy, spkcom, conjudge,
# conmedic, trust_r, satfin, socfrend, wrkstat, helpful_r, childs, finrela,
# spkhomo, region, fair_r, health, spkmil, socrel, satjob, female, wrkslf,
# racdif2, fear, divorce, life, hapmar, union

# =============================================================================
# NEW VARIABLES TO ADD (~250 new)
# =============================================================================

message("Creating extended variable set...")

fishing_data <- joint_data %>%
  mutate(
    # === OUTCOME ===
    trump20 = case_when(
      whovote1_2 == 1 ~ 1,
      whovote1_2 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # === TOP 30 KEEPERS (from initial analysis) ===
    # Economic
    eqwlth = safe_coalesce(., "eqwlth_2", "eqwlth_1a", "eqwlth_1b"),

    # Institutional confidence (need raw for recoding)
    conpress = safe_coalesce(., "conpress_2", "conpress_1a", "conpress_1b"),
    conpress_r = 4 - conpress,
    confed = safe_coalesce(., "confed_2", "confed_1a", "confed_1b"),
    confed_r = 4 - confed,
    contv = safe_coalesce(., "contv_2", "contv_1a", "contv_1b"),
    conarmy = safe_coalesce(., "conarmy_2", "conarmy_1a", "conarmy_1b"),

    # Race measures
    racdif1 = safe_coalesce(., "racdif1_2", "racdif1_1a", "racdif1_1b"),
    racdif3 = safe_coalesce(., "racdif3_2", "racdif3_1a", "racdif3_1b"),
    racdif4 = safe_coalesce(., "racdif4_2", "racdif4_1a", "racdif4_1b"),
    wrkwayup = safe_coalesce(., "wrkwayup_2", "wrkwayup_1a", "wrkwayup_1b"),
    affrmact = safe_coalesce(., "affrmact_2", "affrmact_1a", "affrmact_1b"),

    # Explicit racism
    intlwhts = safe_coalesce(., "intlwhts_2", "intlwhts_1a", "intlwhts_1b"),
    intlblks = safe_coalesce(., "intlblks_2", "intlblks_1a", "intlblks_1b"),
    workwhts = safe_coalesce(., "workwhts_2", "workwhts_1a", "workwhts_1b"),
    workblks = safe_coalesce(., "workblks_2", "workblks_1a", "workblks_1b"),
    work_gap = workwhts - workblks,
    explicit_racism = ((intlwhts - intlblks) + work_gap) / 2,

    # Symbolic racism composite
    wrkwayup_r = 6 - wrkwayup,
    racdif1_r = if_else(racdif1 == 2, 1, 0),
    racdif3_r = if_else(racdif3 == 1, 1, 0),
    racdif4_r = if_else(racdif4 == 2, 1, 0),

    # Demographics
    race = safe_coalesce(., "race_2", "race_1a", "race_1b"),
    white = if_else(race == 1, 1, 0),
    granborn = safe_coalesce(., "granborn_2", "granborn_1a", "granborn_1b"),

    # Social attitudes
    courts = safe_coalesce(., "courts_2", "courts_1a", "courts_1b"),
    cappun = safe_coalesce(., "cappun_2", "cappun_1a", "cappun_1b"),
    gunlaw = safe_coalesce(., "gunlaw_2", "gunlaw_1a", "gunlaw_1b"),

    # Religion
    bible = safe_coalesce(., "bible_2", "bible_1a", "bible_1b"),
    pray = safe_coalesce(., "pray_2", "pray_1a", "pray_1b"),

    # Abortion
    abany = safe_coalesce(., "abany_2", "abany_1a", "abany_1b"),
    abpoor = safe_coalesce(., "abpoor_2", "abpoor_1a", "abpoor_1b"),
    abdefect = safe_coalesce(., "abdefect_2", "abdefect_1a", "abdefect_1b"),
    abrape = safe_coalesce(., "abrape_2", "abrape_1a", "abrape_1b"),

    # Sexual morality
    homosex = safe_coalesce(., "homosex_2", "homosex_1a", "homosex_1b"),
    premarsx = safe_coalesce(., "premarsx_2", "premarsx_1a", "premarsx_1b"),

    # Gender
    fepol = safe_coalesce(., "fepol_2", "fepol_1a", "fepol_1b"),

    # Oddballs that worked
    spanking = safe_coalesce(., "spanking_2", "spanking_1a", "spanking_1b"),
    hunt = safe_coalesce(., "hunt_2", "hunt_1a", "hunt_1b"),
    natsci = safe_coalesce(., "natsci_2", "natsci_1a", "natsci_1b"),

    # === NEW VARIABLES FOR FISHING EXPEDITION ===

    # --- More spending priorities ---
    natroad = safe_coalesce(., "natroad_2", "natroad_1a", "natroad_1b"),
    natsoc = safe_coalesce(., "natsoc_2", "natsoc_1a", "natsoc_1b"),
    natmass = safe_coalesce(., "natmass_2", "natmass_1a", "natmass_1b"),
    natpark = safe_coalesce(., "natpark_2", "natpark_1a", "natpark_1b"),
    natchld = safe_coalesce(., "natchld_2", "natchld_1a", "natchld_1b"),
    natenrgy = safe_coalesce(., "natenrgy_2", "natenrgy_1a", "natenrgy_1b"),

    # --- More abortion items ---
    abhlth = safe_coalesce(., "abhlth_2", "abhlth_1a", "abhlth_1b"),
    abnomore = safe_coalesce(., "abnomore_2", "abnomore_1a", "abnomore_1b"),
    absingle = safe_coalesce(., "absingle_2", "absingle_1a", "absingle_1b"),

    # --- More gender items ---
    fehome = safe_coalesce(., "fehome_2", "fehome_1a", "fehome_1b"),
    fework = safe_coalesce(., "fework_2", "fework_1a", "fework_1b"),
    fepres = safe_coalesce(., "fepres_2", "fepres_1a", "fepres_1b"),
    fechld = safe_coalesce(., "fechld_2", "fechld_1a", "fechld_1b"),
    fepresch = safe_coalesce(., "fepresch_2", "fepresch_1a", "fepresch_1b"),

    # --- More race items ---
    racpush = safe_coalesce(., "racpush_2", "racpush_1a", "racpush_1b"),
    racseg = safe_coalesce(., "racseg_2", "racseg_1a", "racseg_1b"),
    racopen = safe_coalesce(., "racopen_2", "racopen_1a", "racopen_1b"),
    racdin = safe_coalesce(., "racdin_2", "racdin_1a", "racdin_1b"),
    raclive = safe_coalesce(., "raclive_2", "raclive_1a", "raclive_1b"),
    racmar = safe_coalesce(., "racmar_2", "racmar_1a", "racmar_1b"),
    racschol = safe_coalesce(., "racschol_2", "racschol_1a", "racschol_1b"),
    rachome = safe_coalesce(., "rachome_2", "rachome_1a", "rachome_1b"),
    racpres = safe_coalesce(., "racpres_2", "racpres_1a", "racpres_1b"),
    busing = safe_coalesce(., "busing_2", "busing_1a", "busing_1b"),

    # Stereotypes of other groups
    intlasns = safe_coalesce(., "intlasns_2", "intlasns_1a", "intlasns_1b"),
    intlhsps = safe_coalesce(., "intlhsps_2", "intlhsps_1a", "intlhsps_1b"),
    workasns = safe_coalesce(., "workasns_2", "workasns_1a", "workasns_1b"),
    workhsps = safe_coalesce(., "workhsps_2", "workhsps_1a", "workhsps_1b"),

    # Perceived wealth/patriotism
    wlthblks = safe_coalesce(., "wlthblks_2", "wlthblks_1a", "wlthblks_1b"),
    wlthwhts = safe_coalesce(., "wlthwhts_2", "wlthwhts_1a", "wlthwhts_1b"),
    patrblks = safe_coalesce(., "patrblks_2", "patrblks_1a", "patrblks_1b"),
    patrwhts = safe_coalesce(., "patrwhts_2", "patrwhts_1a", "patrwhts_1b"),

    # --- More religion items ---
    relig = safe_coalesce(., "relig_2", "relig_1a", "relig_1b"),
    denom = safe_coalesce(., "denom_2", "denom_1a", "denom_1b"),
    attend = safe_coalesce(., "attend_2", "attend_1a", "attend_1b"),
    reliten = safe_coalesce(., "reliten_2", "reliten_1a", "reliten_1b"),
    postlife = safe_coalesce(., "postlife_2", "postlife_1a", "postlife_1b"),
    fund = safe_coalesce(., "fund_2", "fund_1a", "fund_1b"),

    # --- Confidence in more institutions ---
    confinan = safe_coalesce(., "confinan_2", "confinan_1a", "confinan_1b"),
    consci = safe_coalesce(., "consci_2", "consci_1a", "consci_1b"),

    # --- Civil liberties (college teaching) ---
    colath = safe_coalesce(., "colath_2", "colath_1a", "colath_1b"),
    colrac = safe_coalesce(., "colrac_2", "colrac_1a", "colrac_1b"),
    colcom = safe_coalesce(., "colcom_2", "colcom_1a", "colcom_1b"),
    colmil = safe_coalesce(., "colmil_2", "colmil_1a", "colmil_1b"),
    colhomo = safe_coalesce(., "colhomo_2", "colhomo_1a", "colhomo_1b"),
    colmslm = safe_coalesce(., "colmslm_2", "colmslm_1a", "colmslm_1b"),

    # Civil liberties (library books)
    libath = safe_coalesce(., "libath_2", "libath_1a", "libath_1b"),
    librac = safe_coalesce(., "librac_2", "librac_1a", "librac_1b"),
    libcom = safe_coalesce(., "libcom_2", "libcom_1a", "libcom_1b"),
    libmil = safe_coalesce(., "libmil_2", "libmil_1a", "libmil_1b"),
    libhomo = safe_coalesce(., "libhomo_2", "libhomo_1a", "libhomo_1b"),
    libmslm = safe_coalesce(., "libmslm_2", "libmslm_1a", "libmslm_1b"),

    # Muslim tolerance
    spkmslm = safe_coalesce(., "spkmslm_2", "spkmslm_1a", "spkmslm_1b"),

    # --- Political engagement ---
    vote16 = safe_coalesce(., "vote16_2", "vote16_1a", "vote16_1b"),
    pres16 = safe_coalesce(., "pres16_2", "pres16_1a", "pres16_1b"),

    # --- Economic attitudes ---
    tax = safe_coalesce(., "tax_2", "tax_1a", "tax_1b"),
    govcare = safe_coalesce(., "govcare_2", "govcare_1a", "govcare_1b"),

    # --- Trust and anomia ---
    trust = safe_coalesce(., "trust_2", "trust_1a", "trust_1b"),
    fair = safe_coalesce(., "fair_2", "fair_1a", "fair_1b"),
    helpful = safe_coalesce(., "helpful_2", "helpful_1a", "helpful_1b"),
    anomia1 = safe_coalesce(., "anomia1_2", "anomia1_1a", "anomia1_1b"),
    anomia2 = safe_coalesce(., "anomia2_2", "anomia2_1a", "anomia2_1b"),
    anomia3 = safe_coalesce(., "anomia3_2", "anomia3_1a", "anomia3_1b"),
    anomia4 = safe_coalesce(., "anomia4_2", "anomia4_1a", "anomia4_1b"),
    anomia6 = safe_coalesce(., "anomia6_2", "anomia6_1a", "anomia6_1b"),
    anomia7 = safe_coalesce(., "anomia7_2", "anomia7_1a", "anomia7_1b"),

    # --- Child-rearing values ---
    obey = safe_coalesce(., "obey_2", "obey_1a", "obey_1b"),
    popular = safe_coalesce(., "popular_2", "popular_1a", "popular_1b"),
    thnkself = safe_coalesce(., "thnkself_2", "thnkself_1a", "thnkself_1b"),
    helpoth = safe_coalesce(., "helpoth_2", "helpoth_1a", "helpoth_1b"),

    # --- Crime/police ---
    polhitok = safe_coalesce(., "polhitok_2", "polhitok_1a", "polhitok_1b"),
    polabuse = safe_coalesce(., "polabuse_2", "polabuse_1a", "polabuse_1b"),
    polmurdr = safe_coalesce(., "polmurdr_2", "polmurdr_1a", "polmurdr_1b"),
    polescap = safe_coalesce(., "polescap_2", "polescap_1a", "polescap_1b"),
    polattak = safe_coalesce(., "polattak_2", "polattak_1a", "polattak_1b"),

    # Violence attitudes
    hitok = safe_coalesce(., "hitok_2", "hitok_1a", "hitok_1b"),

    # --- Work attitudes ---
    jobsec = safe_coalesce(., "jobsec_2", "jobsec_1a", "jobsec_1b"),
    jobinc = safe_coalesce(., "jobinc_2", "jobinc_1a", "jobinc_1b"),
    jobmeans = safe_coalesce(., "jobmeans_2", "jobmeans_1a", "jobmeans_1b"),
    richwork = safe_coalesce(., "richwork_2", "richwork_1a", "richwork_1b"),

    # --- Social mobility beliefs ---
    getahead = safe_coalesce(., "getahead_2", "getahead_1a", "getahead_1b"),
    parsol = safe_coalesce(., "parsol_2", "parsol_1a", "parsol_1b"),
    kidssol = safe_coalesce(., "kidssol_2", "kidssol_1a", "kidssol_1b"),

    # --- Demographics and background ---
    age = safe_coalesce(., "age_2", "age_1a", "age_1b"),
    sex = safe_coalesce(., "sex_2", "sex_1a", "sex_1b"),
    educ = safe_coalesce(., "educ_2", "educ_1a", "educ_1b"),
    degree = safe_coalesce(., "degree_2", "degree_1a", "degree_1b"),
    realinc = safe_coalesce(., "realinc_2", "realinc_1a", "realinc_1b"),
    region = safe_coalesce(., "region_2", "region_1a", "region_1b"),
    res16 = safe_coalesce(., "res16_2", "res16_1a", "res16_1b"),
    mobile16 = safe_coalesce(., "mobile16_2", "mobile16_1a", "mobile16_1b"),
    family16 = safe_coalesce(., "family16_2", "family16_1a", "family16_1b"),
    incom16 = safe_coalesce(., "incom16_2", "incom16_1a", "incom16_1b"),

    # Parental background
    paeduc = safe_coalesce(., "paeduc_2", "paeduc_1a", "paeduc_1b"),
    maeduc = safe_coalesce(., "maeduc_2", "maeduc_1a", "maeduc_1b"),
    padeg = safe_coalesce(., "padeg_2", "padeg_1a", "padeg_1b"),
    madeg = safe_coalesce(., "madeg_2", "madeg_1a", "madeg_1b"),

    # --- Social life ---
    socpars = safe_coalesce(., "socpars_2", "socpars_1a", "socpars_1b"),
    socsibs = safe_coalesce(., "socsibs_2", "socsibs_1a", "socsibs_1b"),
    socommun = safe_coalesce(., "socommun_2", "socommun_1a", "socommun_1b"),

    # --- Euthanasia/suicide (more items) ---
    suicide2 = safe_coalesce(., "suicide2_2", "suicide2_1a", "suicide2_1b"),
    suicide3 = safe_coalesce(., "suicide3_2", "suicide3_1a", "suicide3_1b"),
    suicide4 = safe_coalesce(., "suicide4_2", "suicide4_1a", "suicide4_1b"),
    letdie2 = safe_coalesce(., "letdie2_2", "letdie2_1a", "letdie2_1b"),

    # --- Immigration ---
    letin1a = safe_coalesce(., "letin1a_2", "letin1a_1a", "letin1a_1b"),

    # --- Science attitudes ---
    advfront = safe_coalesce(., "advfront_2", "advfront_1a", "advfront_1b"),

    # --- Satisfaction items ---
    satcity = safe_coalesce(., "satcity_2", "satcity_1a", "satcity_1b"),
    sathobby = safe_coalesce(., "sathobby_2", "sathobby_1a", "sathobby_1b"),
    satfam = safe_coalesce(., "satfam_2", "satfam_1a", "satfam_1b"),
    satfrnd = safe_coalesce(., "satfrnd_2", "satfrnd_1a", "satfrnd_1b"),
    sathealt = safe_coalesce(., "sathealt_2", "sathealt_1a", "sathealt_1b"),

    # --- Pornography ---
    pornlaw = safe_coalesce(., "pornlaw_2", "pornlaw_1a", "pornlaw_1b"),
    xmovie = safe_coalesce(., "xmovie_2", "xmovie_1a", "xmovie_1b"),

    # --- Aging attitudes ---
    aged = safe_coalesce(., "aged_2", "aged_1a", "aged_1b"),

    # --- Subjective class ---
    class = safe_coalesce(., "class_2", "class_1a", "class_1b"),
    rank = safe_coalesce(., "rank_2", "rank_1a", "rank_1b"),

    # --- Wiretapping ---
    wirtap = safe_coalesce(., "wirtap_2", "wirtap_1a", "wirtap_1b"),

    # --- Welfare attitudes ---
    natfare = safe_coalesce(., "natfare_2", "natfare_1a", "natfare_1b"),
    natrace = safe_coalesce(., "natrace_2", "natrace_1a", "natrace_1b"),
    natcrime = safe_coalesce(., "natcrime_2", "natcrime_1a", "natcrime_1b"),
    natdrug = safe_coalesce(., "natdrug_2", "natdrug_1a", "natdrug_1b"),
    nataid = safe_coalesce(., "nataid_2", "nataid_1a", "nataid_1b"),
    nateduc = safe_coalesce(., "nateduc_2", "nateduc_1a", "nateduc_1b"),
    natheal = safe_coalesce(., "natheal_2", "natheal_1a", "natheal_1b"),
    natcity = safe_coalesce(., "natcity_2", "natcity_1a", "natcity_1b"),
    natenvir = safe_coalesce(., "natenvir_2", "natenvir_1a", "natenvir_1b"),
    natarms = safe_coalesce(., "natarms_2", "natarms_1a", "natarms_1b"),
    natspac = safe_coalesce(., "natspac_2", "natspac_1a", "natspac_1b"),

    # --- Gun ownership ---
    owngun = safe_coalesce(., "owngun_2", "owngun_1a", "owngun_1b"),
    pistol = safe_coalesce(., "pistol_2", "pistol_1a", "pistol_1b"),
    shotgun = safe_coalesce(., "shotgun_2", "shotgun_1a", "shotgun_1b"),
    rifle = safe_coalesce(., "rifle_2", "rifle_1a", "rifle_1b"),

    # --- Subjective wellbeing ---
    happy = safe_coalesce(., "happy_2", "happy_1a", "happy_1b"),
    health = safe_coalesce(., "health_2", "health_1a", "health_1b"),
    life = safe_coalesce(., "life_2", "life_1a", "life_1b"),

    # --- Marital/family ---
    marital = safe_coalesce(., "marital_2", "marital_1a", "marital_1b"),
    childs = safe_coalesce(., "childs_2", "childs_1a", "childs_1b"),
    sibs = safe_coalesce(., "sibs_2", "sibs_1a", "sibs_1b"),
    agewed = safe_coalesce(., "agewed_2", "agewed_1a", "agewed_1b"),

    # --- Drinking/smoking ---
    drink = safe_coalesce(., "drink_2", "drink_1a", "drink_1b"),
    smoke = safe_coalesce(., "smoke_2", "smoke_1a", "smoke_1b"),

    # --- Equal opportunity items ---
    equal1 = safe_coalesce(., "equal1_2", "equal1_1a", "equal1_1b"),
    equal2 = safe_coalesce(., "equal2_2", "equal2_1a", "equal2_1b"),
    equal3 = safe_coalesce(., "equal3_2", "equal3_1a", "equal3_1b"),
    equal4 = safe_coalesce(., "equal4_2", "equal4_1a", "equal4_1b"),

    # --- Feelings thermometers ---
    libtemp = safe_coalesce(., "libtemp_2", "libtemp_1a", "libtemp_1b"),
    contemp = safe_coalesce(., "contemp_2", "contemp_1a", "contemp_1b"),
    prottemp = safe_coalesce(., "prottemp_2", "prottemp_1a", "prottemp_1b"),
    cathtemp = safe_coalesce(., "cathtemp_2", "cathtemp_1a", "cathtemp_1b"),
    jewtemp = safe_coalesce(., "jewtemp_2", "jewtemp_1a", "jewtemp_1b"),
    mslmtemp = safe_coalesce(., "mslmtemp_2", "mslmtemp_1a", "mslmtemp_1b"),

    # --- Group membership ---
    memchurh = safe_coalesce(., "memchurh_2", "memchurh_1a", "memchurh_1b"),
    memunion = safe_coalesce(., "memunion_2", "memunion_1a", "memunion_1b"),
    memvet = safe_coalesce(., "memvet_2", "memvet_1a", "memvet_1b"),
    mempolit = safe_coalesce(., "mempolit_2", "mempolit_1a", "mempolit_1b"),
    memsport = safe_coalesce(., "memsport_2", "memsport_1a", "memsport_1b"),
    memfrat = safe_coalesce(., "memfrat_2", "memfrat_1a", "memfrat_1b"),

    # --- Internet/media ---
    wwwhr = safe_coalesce(., "wwwhr_2", "wwwhr_1a", "wwwhr_1b"),
    tvhours = safe_coalesce(., "tvhours_2", "tvhours_1a", "tvhours_1b"),
    news = safe_coalesce(., "news_2", "news_1a", "news_1b"),

    # --- Work status ---
    wrkstat = safe_coalesce(., "wrkstat_2", "wrkstat_1a", "wrkstat_1b"),
    wrkslf = safe_coalesce(., "wrkslf_2", "wrkslf_1a", "wrkslf_1b"),
    wrkgovt = safe_coalesce(., "wrkgovt_2", "wrkgovt_1a", "wrkgovt_1b"),

    # --- Fear ---
    fear = safe_coalesce(., "fear_2", "fear_1a", "fear_1b"),

    # --- Nativity/immigration ---
    born = safe_coalesce(., "born_2", "born_1a", "born_1b"),
    parborn = safe_coalesce(., "parborn_2", "parborn_1a", "parborn_1b"),

    # --- Divorce law ---
    divlaw = safe_coalesce(., "divlaw_2", "divlaw_1a", "divlaw_1b"),

    # --- Sex education ---
    sexeduc = safe_coalesce(., "sexeduc_2", "sexeduc_1a", "sexeduc_1b"),
    teensex = safe_coalesce(., "teensex_2", "teensex_1a", "teensex_1b"),

    # --- Pill for teens ---
    pillok = safe_coalesce(., "pillok_2", "pillok_1a", "pillok_1b"),

    # --- Hits/violence ---
    hit = safe_coalesce(., "hit_2", "hit_1a", "hit_1b"),
    gun = safe_coalesce(., "gun_2", "gun_1a", "gun_1b"),

    # --- Job aspects ---
    jobhour = safe_coalesce(., "jobhour_2", "jobhour_1a", "jobhour_1b"),
    jobpromo = safe_coalesce(., "jobpromo_2", "jobpromo_1a", "jobpromo_1b"),

    # --- Government aid ---
    govaid = safe_coalesce(., "govaid_2", "govaid_1a", "govaid_1b"),
    getaid = safe_coalesce(., "getaid_2", "getaid_1a", "getaid_1b"),

    # --- Marijuana ---
    grass = safe_coalesce(., "grass_2", "grass_1a", "grass_1b"),

    # --- Closeness to groups ---
    closeblk = safe_coalesce(., "closeblk_2", "closeblk_1a", "closeblk_1b"),
    closewht = safe_coalesce(., "closewht_2", "closewht_1a", "closewht_1b"),

    # --- Prestige ---
    prestige = safe_coalesce(., "prestige_2", "prestige_1a", "prestige_1b"),
    prestg10 = safe_coalesce(., "prestg10_2", "prestg10_1a", "prestg10_1b"),

    # --- Alienation ---
    alienat1 = safe_coalesce(., "alienat1_2", "alienat1_1a", "alienat1_1b"),
    alienat2 = safe_coalesce(., "alienat2_2", "alienat2_1a", "alienat2_1b"),

    # --- Country attitudes ---
    amchrstn = safe_coalesce(., "amchrstn_2", "amchrstn_1a", "amchrstn_1b"),
    amcit = safe_coalesce(., "amcit_2", "amcit_1a", "amcit_1b"),
    amcult = safe_coalesce(., "amcult_2", "amcult_1a", "amcult_1b"),
    amgovt = safe_coalesce(., "amgovt_2", "amgovt_1a", "amgovt_1b"),

    # --- Extramarital sex ---
    xmarsex = safe_coalesce(., "xmarsex_2", "xmarsex_1a", "xmarsex_1b"),

    # --- Divorce ---
    divorce = safe_coalesce(., "divorce_2", "divorce_1a", "divorce_1b"),

    # --- Financial satisfaction ---
    satfin = safe_coalesce(., "satfin_2", "satfin_1a", "satfin_1b"),
    finrela = safe_coalesce(., "finrela_2", "finrela_1a", "finrela_1b"),

    # --- Job satisfaction ---
    satjob = safe_coalesce(., "satjob_2", "satjob_1a", "satjob_1b"),

    # --- Marital happiness ---
    hapmar = safe_coalesce(., "hapmar_2", "hapmar_1a", "hapmar_1b"),

    # --- Union ---
    union = safe_coalesce(., "union_2", "union_1a", "union_1b"),

    # --- Workhard ---
    workhard = safe_coalesce(., "workhard_2", "workhard_1a", "workhard_1b"),

    # --- More from speech items ---
    spkath = safe_coalesce(., "spkath_2", "spkath_1a", "spkath_1b"),
    spkrac = safe_coalesce(., "spkrac_2", "spkrac_1a", "spkrac_1b"),
    spkcom = safe_coalesce(., "spkcom_2", "spkcom_1a", "spkcom_1b"),
    spkmil = safe_coalesce(., "spkmil_2", "spkmil_1a", "spkmil_1b"),
    spkhomo = safe_coalesce(., "spkhomo_2", "spkhomo_1a", "spkhomo_1b"),

    # --- racdif2 (though rejected, keeping for documentation) ---
    racdif2 = safe_coalesce(., "racdif2_2", "racdif2_1a", "racdif2_1b"),

    # === Suicide items ===
    suicide1 = safe_coalesce(., "suicide1_2", "suicide1_1a", "suicide1_1b"),
    letdie1 = safe_coalesce(., "letdie1_2", "letdie1_1a", "letdie1_1b")
  ) %>%
  filter(!is.na(trump20))

message("Initial cases with trump20: ", nrow(fishing_data))

# =============================================================================
# Select variables for analysis
# =============================================================================

# Get all numeric columns except outcome
# IMPORTANT: Exclude ANES variables (v20XXXX, aprvXXX, rateXXX, etc.) - these are tautological
# (e.g., "approval of president" obviously predicts Trump vote)
all_vars <- fishing_data %>%
  select(-trump20) %>%
  select(where(is.numeric)) %>%
  names()

# Filter out ANES tautological variables
anes_patterns <- c("^v20", "^aprv", "^rate", "^poltrt", "^defund", "^strvbias",
                   "^econlast", "^helpblk", "^helpnot", "^helpsick", "^helppoor",
                   "^wrycovid", "^econstat", "^whovote", "^partyid", "^polviews",
                   "^pres16", "^pres20", "^vote16", "^vote20", "^anesid",
                   "^covopen", "^lkelyvot", "^letin1a")
all_vars <- all_vars[!grepl(paste(anes_patterns, collapse = "|"), all_vars)]

# CRITICAL: Remove wave-suffixed duplicates to avoid multicollinearity
# The script creates coalesced versions (e.g., "wrkwayup") from wave-specific
# versions (e.g., "wrkwayup_2", "wrkwayup_1a", "wrkwayup_1b") but the raw
# wave-specific columns also exist in the data. Including both causes:
# 1. Multicollinearity (near-identical variables)
# 2. Inflated importance for redundant measures of same construct
wave_suffix_pattern <- "_2$|_1a$|_1b$"
all_vars <- all_vars[!grepl(wave_suffix_pattern, all_vars)]

message("After removing wave-suffixed duplicates: ", length(all_vars), " variables")

# Also remove _r recoded versions that are perfectly correlated with originals
# These are reverse-coded versions created for scales but are redundant for RF
# (e.g., conpress_r = 4 - conpress, wrkwayup_r = 6 - wrkwayup)
# Keep the original raw versions for interpretability
recode_vars_to_remove <- c("conpress_r", "confed_r", "consci_r", "coneduc_r",
                           "wrkwayup_r", "racdif1_r", "racdif2_r", "racdif3_r",
                           "racdif4_r", "trust_r", "fair_r", "helpful_r")
all_vars <- all_vars[!all_vars %in% recode_vars_to_remove]

# Also remove "race" since "white" is derived from it (redundant)
all_vars <- all_vars[all_vars != "race"]

message("After removing recodes and redundant demographics: ", length(all_vars), " variables")

message("Total potential predictors (excluding ANES tautologies): ", length(all_vars))

# Check missingness
missing_pct <- fishing_data %>%
  select(all_of(all_vars)) %>%
  summarise(across(everything(), ~mean(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "pct_missing") %>%
  arrange(desc(pct_missing))

# Keep variables with <50% missing
vars_to_keep <- missing_pct %>%
  filter(pct_missing < 0.5) %>%
  pull(variable)

message("Variables with <50% missing: ", length(vars_to_keep))

# Prepare analysis data
rq1_data <- fishing_data %>%
  select(trump20, all_of(vars_to_keep))

# Median imputation for remaining missingness
rq1_data <- rq1_data %>%
  mutate(across(where(is.numeric), ~if_else(is.na(.), median(., na.rm = TRUE), .)))

message("Final analysis: N = ", nrow(rq1_data), ", predictors = ", ncol(rq1_data) - 1)
message("Obs per predictor: ", round(nrow(rq1_data) / (ncol(rq1_data) - 1), 1))

# =============================================================================
# Run Boruta
# =============================================================================
message("\nRunning Boruta feature selection...")
message("(This may take several minutes with ", ncol(rq1_data) - 1, " predictors)")

set.seed(42)
boruta_results <- Boruta(
  trump20 ~ .,
  data = rq1_data %>% mutate(trump20 = factor(trump20)),
  doTrace = 1,
  maxRuns = 100
)

# Get results
boruta_df <- attStats(boruta_results) %>%
  rownames_to_column("variable") %>%
  as_tibble() %>%
  arrange(desc(meanImp))

message("\n=== BORUTA RESULTS ===")
message("Confirmed: ", sum(boruta_df$decision == "Confirmed"))
message("Tentative: ", sum(boruta_df$decision == "Tentative"))
message("Rejected: ", sum(boruta_df$decision == "Rejected"))

# Save results
write_csv(boruta_df, file.path(output_tables, "rq1_extended_boruta.csv"))

# Print top 50
message("\nTop 50 predictors:")
print(head(boruta_df, 50))

# =============================================================================
# Quick validation
# =============================================================================
message("\nRunning validation RF...")

set.seed(42)
train_idx <- sample(nrow(rq1_data), 0.7 * nrow(rq1_data))
train_data <- rq1_data[train_idx, ]
test_data <- rq1_data[-train_idx, ]

rf_model <- ranger(
  trump20 ~ .,
  data = train_data %>% mutate(trump20 = factor(trump20)),
  importance = "permutation",
  num.trees = 1000,
  probability = TRUE,
  seed = 42
)

# Test AUC
test_preds <- predict(rf_model, test_data)$predictions[, "1"]
test_roc <- roc(test_data$trump20, test_preds, quiet = TRUE)
test_auc <- auc(test_roc)

message("\nTest set AUC: ", round(test_auc, 3))

# Save importance from RF
rf_importance <- tibble(
  variable = names(rf_model$variable.importance),
  importance = rf_model$variable.importance
) %>%
  arrange(desc(importance))

write_csv(rf_importance, file.path(output_tables, "rq1_extended_rf_importance.csv"))

message("\n06_extended_fishing.R complete!")
