
library(tidyverse)
library(youtubecaption)
library(janitor)
library(lubridate)

#links to youtube urls from following website:
#http://www.williamsportwebdeveloper.com/FavBackUp.aspx
#pulled on 5/14/20

#reading in list of youtube urls and getting automatic transcripts
ep_links <- read_csv(here::here("Data/ymh_ep_links.csv")) %>%
  clean_names() %>%
  mutate(ep_num = str_replace_all(title, ".*Ep.*(\\d{3}).*", "\\1") %>%
           as.double(),
         ep_num = if_else(ep_num == 19, 532, ep_num),
         published_date = mdy_hm(published_date),
         vid = str_replace_all(video_url, ".*=(.*)$", "\\1"))

safe_cap <- safely(get_caption)

ymh_trans <- map(ep_links$video_url,
                 safe_cap)

res <- map(1:length(ymh_trans),
           ~pluck(ymh_trans, ., "result")) %>%
  compact() %>%
  bind_rows() %>%
  inner_join(x = ep_links,
            y = .,
            by = "vid")

#saving transcripts out to csv so I don't need to grab them again
write_csv(res, here::here("Data/ymh_transcripts_raw2.csv"))
