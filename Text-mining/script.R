#################
### LIBRARIES ###
#################

library(tidyverse)
library(stringr)
library(tm)
library(tokenizers)
library(lexiconPT)
library(wordcloud)

###############
### DATASET ###
###############

df <- readxl::read_excel("/Users/alexandre.lima/Desktop/Base de dados Ouvidoria_01-10-2018 a 31-12-2018.xls")
glimpse(df)

############
### TEXT ###
############

text <- df$Relato
head(text)

### Funcao para remover acento ###
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

text <- rm_accent(text) 
text <- tolower(text)
text <- removePunctuation(text)
text <- removeNumbers(text)
text <- removeWords(text, words = c(stopwords("en"), stopwords("pt")))
text <- removeWords(text, rm_accent(stopwords("pt")))
text <- gsub('\n', '', text)
text <- strsplit(text, " ")
text <- unlist(text)

text <- text[text != ""]
tabela <- table(text)
tabela <- sort(tabela, decreasing = T)
nrow(tabela)

head(tabela, 50)

wordcloud(names(tabela[1:nrow(tabela)]), tabela [1:nrow(tabela)], min.freq = 5, scale = c(3,.5))
