FROM golang:1.21-alpine AS build

# Instala dependências para a compilação
RUN apk add --no-cache git gcc musl-dev

# Clona o repositório do GitHub
WORKDIR /app
RUN git clone https://github.com/gabriel-g2n/wuzapi.git . 

# Gerencia dependências do Go
RUN go mod tidy

# Compila o binário
ENV CGO_ENABLED=1
RUN go build -o server .

# Imagem final baseada em Alpine
FROM alpine:latest

# Instala o SQLite
RUN apk add --no-cache sqlite

# Cria diretório da aplicação
RUN mkdir /app

# Copia arquivos estáticos e binário do build
COPY --from=build /app/static /app/static
COPY --from=build /app/server /app/

# Copia o script entrypoint do estágio de build
COPY --from=build /app/entrypoint.sh /app/entrypoint.sh

# Torna o script executável
RUN chmod +x /app/entrypoint.sh

# Define volumes para persistência de dados
VOLUME [ "/app/dbdata", "/app/files" ]

# Define o diretório de trabalho
WORKDIR /app

# Configuração de ambiente
ENV WUZAPI_ADMIN_TOKEN=${WUZAPI_ADMIN_TOKEN}\
	 WUZAPI_ADMIN_USER=${WUZAPI_ADMIN_USER}

# Comando de execução da aplicação, usando o entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
