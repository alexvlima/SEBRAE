# if(!require(twitteR,quietly = TRUE))
# install.packages('twitteR',dependencies=TRUE)
library(twitteR)

# coloque suas chaves. Eu gerei a API do meu usuário do twitter.
api_key <- "XXXXXXXXXXXXX"
api_secret <- "XXXXXXXXXXXXX"
access_token <- "XXXXXXXXXXXXX"
access_token_secret <- "XXXXXXXXXXXXX"

setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
# 1

# availableTrendLocations()

# woeid -> where on earth id
# availableTrendLocations()

# 455819 - codigo de Brasilia
# trendsBrasilia <- getTrends(woeid = 455819)
# 10 primeiros apenas
# trendsBrasilia$name[1:10]

# 10 primeiros trend topics de Goiania
# trendsGoiania <- getTrends(woeid = 455831)
# trendsGoiania$name[1:10]

# Twitter com o #sebrae
sebrae <- searchTwitter('#sebrae', n = 9999)
sebrae <- twListToDF(sebrae)

nrow(sebrae)
head(sebrae, 15, order(sebrae$retweetCount, decreasing = FALSE))

# install.packages("tm")
# install.packages("stringr")

library(tm)
library(stringr)

# Funcao para remover acento
rm_accent <- function(str,pattern="all") {
  # Rotinas e funções úteis V 1.0
  # rm.accent - REMOVE ACENTOS DE PALAVRAS
  # Função que tira todos os acentos e pontuações de um vetor de strings.
  # Parâmetros:
  # str - vetor de strings que terão seus acentos retirados.
  # patterns - vetor de strings com um ou mais elementos indicando quais acentos deverão ser retirados.
  # Para indicar quais acentos deverão ser retirados, um vetor com os símbolos deverão ser passados.
  # Exemplo: pattern = c("´", "^") retirará os acentos agudos e circunflexos apenas.
  # Outras palavras aceitas: "all" (retira todos os acentos, que são "´", "`", "^", "~", "¨", "ç")
  if(!is.character(str))
    str <- as.character(str)
  
  pattern <- unique(pattern)
  
  if(any(pattern=="Ç"))
    pattern[pattern=="Ç"] <- "ç"
  
  symbols <- c(
    acute = "áéíóúÁÉÍÓÚýÝ",
    grave = "àèìòùÀÈÌÒÙ",
    circunflex = "âêîôûÂÊÎÔÛ",
    tilde = "ãõÃÕñÑ",
    umlaut = "äëïöüÄËÏÖÜÿ",
    cedil = "çÇ"
  )
  
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  
  accentTypes <- c("´","`","^","~","¨","ç")
  
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str)
  
  return(str)
}

#Tratamento dos Dados
x <- sebrae$text 
x <- strsplit(x, " ")
x <- unlist(x)
x <- removePunctuation(x)
x <- tolower(x)
x <- rm_accent(x)
x <- iconv(x, to = "latin1")
x <- gsub('\n', '', x)
x <- gsub('\\"','',x)
x <- gsub('\\S+Â\\S+','',x)
x <- gsub('\\S+æ\\S+','',x)
x <- gsub("http\\S+", '', x)
x <- gsub("sebrae\\S+", '', x)
x <- removeWords(x, words = c(stopwords("en"), stopwords("pt"),"sebrae","sebrae\\*","rt", "http\\*", "sob","absb"))
x <- removeNumbers(x)
x <- gsub("empreendedores", "empreendedorismo",x)
x <- x[x != ""]

tabela <- table(x)
tabela <- sort(tabela, decreasing = T)
nrow(tabela)
tabela

# install.packages("wordcloud")
library(wordcloud)
wordcloud(names(tabela[1:nrow(tabela)]), tabela [1:nrow(tabela)], min.freq = 3, scale = c(3,.5))
