
# study end date for survival analysis ----
db_end_date <- cdm$observation_period %>%
  summarise(last_obs_end = as.Date(max(observation_period_end_date,
                                       na.rm = TRUE))) %>%
  pull(last_obs_end)
survival_end_date <- db_end_date - years(1)

# generate MM cohorts ----
mm_cohorts <- CDMConnector::readCohortSet(here("cohorts"))
cdm <- generateCohortSet(cdm = cdm, name = "mm_cohort",
                   cohortSet = mm_cohorts,
                   overwrite = TRUE)

cdm$mm_cohort <- cdm$mm_cohort %>%
  filter(cohort_start_date >= as.Date("2012-01-01")) %>%
  compute_query()
# %>%
#   record_cohort_attrition("Before 2012-01-01")

cdm$mm_cohort <- cdm$mm_cohort %>%
  filter(cohort_start_date <=  survival_end_date) %>%
  compute_query()
# %>%
#   record_cohort_attrition(paste0("Before ", survival_end_date))

cdm$mm_cohort <- cdm$mm_cohort %>%
  addDemographics(cdm = cdm, ageGroup = list(c(0,17),
                                             c(18,44),
                                             c(45,59),
                                             c(60,69),
                                             c(70,150)))


# generate death cohort
cdm <- generateDeathCohortSet(cdm = cdm)

class(cdm$mm_cohort) <- c(class(cdm$mm_cohort), "GeneratedCohortSet")
attr(cdm$mm_cohort, "cohort_set") <- cdm$mm_cohort %>%
  group_by(.data$cohort_definition_id) %>%
  tally() %>%
  mutate(cohort_name = "MM") %>%
  select(!n)

surv <- estimateSurvival(cdm = cdm,
                 targetCohortTable = "mm_cohort",
                 outcomeCohortTable = "death_cohort",
                 strata = list(c("sex"),
                               c("age_group"),
                               c("sex","age_group")))

plot_surv <- plotSurvival(surv,
             colour = "strata_level",
             facet= "strata_name")

ggsave(here("Results", "mm_survival.png"), plot_surv,
       width = 12, height = 9)
