# dodanie do menedżera poświadczeń hasła
# keyring::key_set("wiki", username = "ksieklucki")

# pobranie danych dla użytkownika i hasła
rvest::html_session(
  "https://wiki.neuca.pl/display/ALPRO/User+Login",
  # "https://wiki.neuca.pl/rest/api/content/42563957?expand=body.storage",
  httr::authenticate(
    "ksieklucki",
    # rstudioapi::askForPassword()
    keyring::key_get("wiki", "ksieklucki")
  )
) %>%
  rvest::html_table(fill = TRUE) %>%
  .[[1]] %>%
  as_tibble() %>%
  mutate(rola = tolower(rola)) %>%
  select(-grupa, -wiki) %>%
  arrange(login)