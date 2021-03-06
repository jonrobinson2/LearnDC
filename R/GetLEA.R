options(stringsAsFactors=FALSE)

if(!require(jsonlite)){
  install.packages("jsonlite")
  library(jsonlite)
}

leadgr <- function(x, y){
  if(!is.na(x)){
    while(nchar(x)<y){
      x <- paste("0",x,sep="")
    }
  }
  return(x)
}

`%notin%` <- function(x,y) !(x %in% y)

GetLEA <- function(exhibit){
  exhibit <- tolower(exhibit)
  if(exhibit %notin% c("graduation","dccas","hqt_classes","staff_degree","mgp_scores","special_ed","enrollment")){
    stop("The requested exhibit does not exist.\r
Please check the spelling of your exhibit using GetLEAExhibits() to get the correct names of LearnDC's LEA Exhibits.")
  }
  else {
 lea <- read.csv(paste0("https://learndc-api.herokuapp.com//api/exhibit/",exhibit,".csv?s[][org_type]=lea&sha=promoted"))
 lea$org_code <- sapply(lea$org_code,leadgr,4)
 lea <- subset(lea,org_code %notin% c('0000','0001','6000'))
  
 lea_overview <- subset(jsonlite::fromJSON("https://learndc-api.herokuapp.com//api/leas?sha=promoted")[2:3],org_code %in% lea$org_code)
 lea <- merge(lea,lea_overview,by=c('org_code'),all.x=TRUE)
 lea <- lea[c(1:2,ncol(lea),3:(ncol(lea)-1))]

if(exhibit %in% c('graduation','dccas','special_ed','enrollment')){
        lea$subgroup <- tolower(lea$subgroup)
        subgroup_map <- c("bl7"="african american",
                            "wh7"="white",
                            "hi7"="hispanic",
                            "as7"="asian",
                            "mu7"="multiracial",
                            "pi7"="pacific islander",
                            "am7"="american indian",
                            "direct cert"="tanf/snap eligible",
                            "economy"="economically disadvantaged",
                            "lep"="english learner",
                            "sped"="special education",
                            "sped level 1"="special education level 1",
                            "sped level 2"="special education level 2",
                            "sped level 3"="special education level 3",
                            "sped level 4"="special education level 4",
                            "all sped students"="special education",
                            "alt test takers"="alternative testing",
                            "with accommodations"="testing accommodations",
                            "all"="all",
                            "female"="female",
                            "male"="male",
                            "asian"="asian",
                            "economically disadvantaged"="economically disadvantaged",
                            "african american"="african american",
                            "english learner"="english learner",
                            "hispanic"="hispanic",
                            "multiracial"="multiracial",
                            "pacific islander"="pacific islander",
                            "special education"="special education",
                            "white"="white")

        lea$subgroup <- subgroup_map[lea$subgroup]
        }

    if(exhibit %in% c('enrollment')){
        lea$year <- paste0(lea$year,"-",lea$year+1)
    } else {
        lea$year <- paste0(lea$year-1,"-",lea$year)
    }
  }
  lea$population <- NULL
  return(lea)
}  