
library(tidyverse)
library(youtubecaption)

ep_links <- readxl::read_excel("~/Data/YMH/Data/ymh_full.xlsx")

cleaned_links <- ep_links %>%
  janitor::clean_names() %>%
  mutate(ep_num = str_replace_all(title, ".*Ep.*(\\d{3}).*", "\\1") %>%
           as.double(),
         ep_num = if_else(ep_num == 19, 532, ep_num),
         published_date = ymd_hms(published_date),
         vid = str_replace_all(video_url, ".*=(.*)$", "\\1"))

safe_cap <- safely(get_caption)

ymh_trans <- map(cleaned_links$video_url,
                 safe_cap)

res <- map(1:length(ymh_trans),
           ~pluck(ymh_trans, ., "result")) %>%
  compact() %>%
  bind_rows() %>%
  inner_join(cleaned_links,
             y = .,
             by = "vid")

write_csv(res, "~/Data/YMH/Data/ymh_trans.csv")