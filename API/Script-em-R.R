install.packages(c("httr", "jsonlite"))

result <- httr::POST(
  url    = "https://apiplataforma.sebrae.com.br/graphql",
  body   = "{\"query\":\"{getEmpresasAleatorias(qtdElementos: 10)}\"}", 
  config = httr::config(ssl_verifypeer = FALSE)
)

parsed <- jsonlite::fromJSON(content(result, "text"), simplifyVector = TRUE)
