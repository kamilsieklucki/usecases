df <- data.frame(id = letters[1:10], a = 1:10, b = 1:10, c = 1:10, d = 1:10, stringsAsFactors = FALSE)

test <- df %>% 
  group_by(id) %>% 
  nest() %>% 
  mutate(data = map(data, sum)) %>% 
  unnest() %>% 
  print()
