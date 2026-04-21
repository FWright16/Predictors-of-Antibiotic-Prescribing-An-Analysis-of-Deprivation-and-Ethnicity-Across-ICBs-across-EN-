library(tidyverse)
library(here)

imd_lsoa <- read_csv(here('data','raw','2019IMD.csv'))
lsoa_icb <- read_csv(here('data','raw','LSOA-ICB.csv'))

# names(imd_lsoa)
# names(lsoa_icb)

imd_clean <- imd_lsoa |> 
  select(lsoa11cd= 'LSOA code (2011)',
         imd_score = 'Index of Multiple Deprivation (IMD) Score',
         total_pop = 'Total population: mid 2015 (excluding prisoners)')

lookup <- lsoa_icb |> 
  select(lsoa11cd=LSOA11CD,
         icb22cd=ICB22CD,
         icb22nm=ICB22NM) |> 
  distinct(lsoa11cd,.keep_all = TRUE)

sum(!imd_clean$lsoa11cd %in% lookup$lsoa11cd)
# 0 unmatched LSOAs

imd_joined <- imd_clean |> 
  inner_join(lookup,by='lsoa11cd')

imd_icb <- imd_joined |> 
  group_by(icb22cd,icb22nm) |> 
  summarise(number_lsoas=n(),
            total_icb_pop=sum(total_pop,na.rm=TRUE),
            imd_score_weighted=sum(imd_score*total_pop,na.rm=T)/sum(total_pop,na.rm=TRUE),
            .groups='drop') |> 
  arrange(imd_score_weighted) |> 
  mutate(imd_rank=rank(imd_score_weighted,ties.method='average'),
         imd_quintile=ntile(imd_score_weighted,5))

# Validation
sum(imd_icb$total_icb_pop) 

nrow(imd_icb) #42 ICBs 

count(imd_icb,imd_quintile) # 8/9 ICBs per quintile

write_csv(imd_icb,here('data','processed','imd_icb_quintiles.csv'))

imd_icb$imd_score_weighted

