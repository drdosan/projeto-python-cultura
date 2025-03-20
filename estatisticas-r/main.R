# Instalar e carregar os pacotes necessários
if (!require("httr")) install.packages("httr", dependencies=TRUE)
if (!require("jsonlite")) install.packages("jsonlite", dependencies=TRUE)
if (!require("utils")) install.packages("utils", dependencies=TRUE)  # utils para URLencode

library(httr)
library(jsonlite)
library(utils)

# Função para obter coordenadas da cidade usando a Location Search API da meteoblue
obter_coordenadas <- function(api_key, cidade) {
  url <- paste0("https://www.meteoblue.com/en/server/search/query3?query=", URLencode(cidade), "&apikey=", api_key)
  
  resposta <- GET(url)
  
  if (status_code(resposta) == 200) {
    dados <- content(resposta, "parsed", simplifyVector = FALSE)
    
    if (!is.null(dados$results) && length(dados$results) > 0) {
      lat <- dados$results[[1]]$lat
      lon <- dados$results[[1]]$lon
      return(list(lat = lat, lon = lon))
    } else {
      cat("\n❌ Cidade não encontrada na API da meteoblue.\n")
      return(NULL)
    }
  } else {
    cat("\n❌ Erro ao buscar coordenadas. Código HTTP:", status_code(resposta), "\n")
    print(content(resposta, as = "text", encoding = "UTF-8"))
    return(NULL)
  }
}

# Função para buscar dados meteorológicos usando a Forecast API da meteoblue
buscar_clima_meteoblue <- function(api_key, lat, lon) {
  url <- paste0("https://my.meteoblue.com/packages/basic-1h?lat=", lat, "&lon=", lon, "&apikey=", api_key)
  
  resposta <- GET(url)
  
  if (status_code(resposta) == 200) {
    clima <- content(resposta, "parsed", simplifyVector = FALSE)  # ❗ Mantemos como lista para evitar erro
    
    # Garantir que os dados sejam extraídos corretamente
    temperatura <- ifelse(!is.null(clima$data_1h$temperature), as.numeric(clima$data_1h$temperature[[1]]), "Não disponível")
    precipitacao <- ifelse(!is.null(clima$data_1h$precipitation), as.numeric(clima$data_1h$precipitation[[1]]), "Não disponível")
    umidade <- ifelse(!is.null(clima$data_1h$relativehumidity), as.numeric(clima$data_1h$relativehumidity[[1]]), "Não disponível")
    vento <- ifelse(!is.null(clima$data_1h$windspeed), as.numeric(clima$data_1h$windspeed[[1]]), "Não disponível")
    
    cat("\n🌦️ Dados Meteorológicos 🌦️\n")
    cat("Temperatura Atual: ", temperatura, "°C\n")
    cat("Precipitação: ", precipitacao, "mm\n")
    cat("Umidade: ", umidade, "%\n")
    cat("Velocidade do Vento: ", vento, "km/h\n")
  } else {
    cat("\n❌ Erro ao buscar dados meteorológicos. Código HTTP:", status_code(resposta), "\n")
  }
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

# Função para calcular estatísticas básicas
calcular_estatisticas <- function(dados) {
  areas <- as.numeric(dados$`Área (m²)`)
  insumos <- as.numeric(dados$`Insumo Total (L)`)
  
  media_area <- mean(areas, na.rm=TRUE)
  desvio_area <- ifelse(length(areas) > 1, sd(areas, na.rm=TRUE), 0)
  
  media_insumo <- mean(insumos, na.rm=TRUE)
  desvio_insumo <- ifelse(length(insumos) > 1, sd(insumos, na.rm=TRUE), 0)
  
  cat("\n📊 Estatísticas da Plantação 📊\n")
  cat("Média da Área: ", round(media_area, 2), "m²\n")
  cat("Desvio Padrão da Área: ", round(desvio_area, 2), "m²\n")
  cat("Média do Insumo: ", round(media_insumo, 2), "L\n")
  cat("Desvio Padrão do Insumo: ", round(desvio_insumo, 2), "L\n")
}

# Calcular estatísticas
calcular_estatisticas(dados)

# Perguntar ao usuário a cidade para buscar o clima
api_key <- "ETl9skMajh0gS4Zc"  # Substitua pela sua chave da meteoblue
cidade <- readline("\n🌍 Digite o nome da cidade para buscar dados meteorológicos: ")

coordenadas <- obter_coordenadas(api_key, cidade)
if (!is.null(coordenadas)) {
  buscar_clima_meteoblue(api_key, coordenadas$lat, coordenadas$lon)
}
