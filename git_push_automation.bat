@echo off
SETLOCAL

REM =================================================================
REM || Script de Automação de Push para GitHub - Projeto AntiBet ||
REM =================================================================

REM --- 1. CONFIGURAÇÃO DE DIRETÓRIO ---

REM Define o diretório raiz do projeto (Caminho CORRIGIDO)
SET PROJECT_PATH=D:\projetos-inovexa\antibet
SET REMOTE_URL=https://github.com/Adonispaiva/antibet.git
SET BRANCH=master

echo.
echo Navegando para o diretorio do projeto: %PROJECT_PATH%
cd /d "%PROJECT_PATH%"

IF ERRORLEVEL 1 (
    echo ERRO CRITICO: Nao foi possivel acessar o caminho: %PROJECT_PATH%
    pause
    EXIT /B 1
)

REM --- 2. VERIFICACAO E INICIALIZACAO DE REPOSITORIO (Para a recriacao) ---
echo.
echo Verificando status do Git...
git status > NUL 2>&1

IF ERRORLEVEL 1 (
    echo [INFO] Repositorio Git nao inicializado. Inicializando...
    git init
    
    echo [INFO] Adicionando remoto para %REMOTE_URL%
    git remote add origin %REMOTE_URL%
    
    REM Garante que o branch padrao seja master para o push
    git checkout -b %BRANCH% > NUL 2>&1
)

REM --- 3. CONFIGURAÇÃO DO COMMIT ---

REM Cria um timestamp (formato: YYYY-MM-DD HH:MM:SS)
for /f "tokens=1-4 delims=/ " %%i in ('date /t') do set DATE_NOW=%%k-%%j-%%i
for /f "tokens=1-2 delims=:" %%a in ('time /t') do set TIME_NOW=%%a:%%b

SET TIMESTAMP=%DATE_NOW% %TIME_NOW%

SET COMMIT_MSG="[AUTO] Savepoint arquitetural: %TIMESTAMP%"

echo.
echo =========================================
echo Iniciando o Push Automatico para GitHub
echo Mensagem do Commit: %COMMIT_MSG%
echo =========================================
echo.

REM --- 4. EXECUÇÃO DOS COMANDOS GIT ---

echo [1/3] Adicionando todas as alteracoes (git add .)
git add .

echo.
echo [2/3] Commitando as alteracoes com timestamp
git commit -m %COMMIT_MSG%
IF ERRORLEVEL 1 (
    echo AVISO: Nenhum arquivo alterado para commit.
)

echo.
echo [3/3] Enviando para o repositorio remoto (git push)
REM O comando abaixo resolve o erro de 'no upstream branch' e o push inicial
git push --set-upstream origin %BRANCH%
IF ERRORLEVEL 1 (
    echo ERRO: Falha no push. Verifique a conexao ou as credenciais do GitHub.
    pause
    EXIT /B 1
)

echo.
echo SUCESSO! O projeto foi enviado para o GitHub.
echo =========================================

ENDLOCAL
pause