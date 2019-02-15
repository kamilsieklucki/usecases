library("sendmailR")

from <- "me"
to <- "someone"
subject <- "Hello from R"

body <- list(
  # optional template
  # mime_part("path_to_html", type="text/html", disposition="inline"),
  mime_part(iris)
)

sendmail(
  from,
  to,
  subject,
  body,
  control=list(smtpServer="server")
)