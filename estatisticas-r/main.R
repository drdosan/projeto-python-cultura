# Instalar pacotes necessários (caso ainda não estejam instalados)
if (!require("jsonlite")) install.packages("jsonlite", dependencies=TRUE)
if (!require("httr")) install.packages("httr", dependencies=TRUE)
if (!require("utils")) install.packages("utils", dependencies=TRUE)  # utils para URLencode

# Carregar bibliotecas
library(jsonlite)
library(httr)
library(utils)

# Função para calcular estatísticas básicas
calcular_estatisticas <- function(dados) {
  areas <- as.numeric(dados$`Área (m²)`)
  insumos <- as.numeric(dados$`Insumo Total (L)`)
  
  media_area <- mean(areas, na.rm=TRUE)
  desvio_area <- ifelse(length(areas) > 1, sd(areas, na.rm=TRUE), 0)  # Se tiver só um valor, retorna 0
  
  media_insumo <- mean(insumos, na.rm=TRUE)
  desvio_insumo <- ifelse(length(insumos) > 1, sd(insumos, na.rm=TRUE), 0)  # Se tiver só um valor, retorna 0
  
  cat("\n📊 Estatísticas da Plantação 📊\n")
  cat("Média da Área: ", round(media_area, 2), "m²\n")
  cat("Desvio Padrão da Área: ", round(desvio_area, 2), "m²\n")
  cat("Média do Insumo: ", round(media_insumo, 2), "L\n")
  cat("Desvio Padrão do Insumo: ", round(desvio_insumo, 2), "L\n")
}

# Capturar dados do usuário (copiados do Python)
cat("\n📋 Cole os dados da plantação no formato JSON e pressione ENTER duas vezes:\n")

# Lê todas as linhas da entrada como texto
dados_json <- scan(what = "", quiet = TRUE, sep = "\n")

# Junta todas as linhas para formar um JSON válido
dados_json <- paste(dados_json, collapse = "")

# Converter JSON para dataframe
dados <- fromJSON(dados_json)

# Exibir os dados carregados
cat("\n✅ Dados carregados com sucesso:\n")
print(dados)

# Calcular estatísticas
calcular_estatisticas(dados)

# Função para buscar dados meteorológicos do OpenWeather com URL encode
buscar_clima_openweather <- function(api_key, cidade) {
  cidade_url <- URLencode(cidade)  # Converte nome da cidade para formato URL válido
  
  url <- paste0("http://api.openweathermap.org/data/2.5/weather?q=", cidade_url, 
                "&appid=", api_key, "&units=metric&lang=pt")
  
  # Debug: verificar se a URL está correta
  print(paste("🔗 URL da requisição:", url))
  
  resposta <- GET(url)
  
  if (status_code(resposta) == 200) {
    clima <- content(resposta, "parsed", simplifyVector = FALSE)  # ❗ Alterado para FALSE para manter como lista
    
    cat("\n🌦️ Dados Meteorológicos 🌦️\n")
    cat("Cidade: ", clima$name, "\n")
    cat("Temperatura Atual: ", clima$main$temp, "°C\n")
    cat("Sensação Térmica: ", clima$main$feels_like, "°C\n")
    cat("Umidade: ", clima$main$humidity, "%\n")
    
    # Verifica se o campo "weather" existe e é uma lista
    if ("weather" %in% names(clima) && length(clima$weather) > 0) {
      descricao_tempo <- clima$weather[[1]]$description  # ❗ Agora garantimos que é uma lista
      cat("Condição do Tempo: ", descricao_tempo, "\n")
    } else {
      cat("Condição do Tempo: ❌ Não disponível\n")
    }
    
  } else {
    cat("\n❌ Erro ao buscar dados meteorológicos. Código HTTP:", status_code(resposta), "\n")
    print(content(resposta, as = "text", encoding = "UTF-8"))
  }
}

# Perguntar ao usuário a cidade para buscar o clima
api_key <- "cbb1938522a4b459f7f15c983cf3892e"  # Substitua pelo seu token do OpenWeather
cidade <- readline("\n🌍 Digite o nome da cidade para buscar dados meteorológicos: ")
buscar_clima_openweather(api_key, cidade)
