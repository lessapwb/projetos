# Nova forma de mesclagem dos dados

# Instalando o pacote
#install.packages("synthesisr") # Instalar, caso não possua
#install.packages("openxlsx") # Instalar, caso não possua

#Carregando o pacote instalado
library(synthesisr)
library(openxlsx)

# Definindo o diretório do trabalho
setwd("C://Users//patri//OneDrive//Documentos//Artigos - 2024//6. Revisão Inteligência de Mercado - Artigo da Aula Teorias em Marketing//Base") # Coloque o caminho da pasta que você pretende usar

# Carregando os dados da Scopus e Web of Science
scopus <- read_ref(
  "scopus.bib",
  tag_naming = "best_guess",
  return_df = TRUE,
  verbose = FALSE
)
wos <- read_ref(
  "wos.bib",
  tag_naming = "best_guess",
  return_df = TRUE,
  verbose = FALSE
)

# Realizando a junção das bases
base_temp <- merge_columns(scopus,wos)

# Removendo as duplicadas da base_temp
base <- deduplicate(base_temp, "title", # Você pode usar outra coluna (rode colnames(base_temp))
            method = "string_osa",
            rm_punctuation = TRUE,
            to_lower = TRUE)

# Exportando em bib
write_refs(base, format = "bib", tag_naming = "synthesisr", file = TRUE)

# Exportando em ris
write_refs(base, format = "ris", tag_naming = "synthesisr", file = TRUE)

# Exportando em xlxs
write.xlsx(base_temp, file = "base_temp.xlsx") # Base temporária
write.xlsx(base, file = "base.xlsx") # Base oficial, sem duplicadas
