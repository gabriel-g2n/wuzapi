#!/bin/sh

# Verifica se o token de administração e usuário estão definidos
if [ -z "$WUZAPI_ADMIN_TOKEN" ] || [ -z "$WUZAPI_ADMIN_USER" ]; then
  echo "Erro: As variáveis de ambiente WUZAPI_ADMIN_TOKEN e WUZAPI_ADMIN_USER precisam estar definidas."
  exit 1
fi

# Inicia a aplicação em background
/app/server -logtype json &

# Espera a aplicação inicializar (ajuste o tempo se necessário)
sleep 5

# Verifica se o banco de dados contém o usuário com o token único
if ! sqlite3 /app/dbdata/users.db "SELECT 1 FROM users WHERE token = '$WUZAPI_ADMIN_TOKEN' LIMIT 1;" | grep -q 1; then
  # Usuário e token não encontrados, então insere
  echo "Usuário e token não encontrados. Inserindo novo usuário."
  sqlite3 /app/dbdata/users.db "INSERT INTO users ('name', 'token') VALUES ('$WUZAPI_ADMIN_USER', '$WUZAPI_ADMIN_TOKEN');"
else
  echo "Usuário já existente com o token fornecido."
fi

# Mantém o script rodando para a aplicação continuar em execução
wait
