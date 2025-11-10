@echo off
REM SCRIPT DE PUSH AUTOMATIZADO PARA O PROJETO ANTIBET
REM Persona: ORION (Inovexa Software)

echo ------------------------------------------
echo  AUTOMATIZADOR DE PUSH - PROJETO ANTIBET
echo ------------------------------------------
echo.

REM 1. Adiciona todos os arquivos modificados e novos
echo [PASSO 1/4] Adicionando todos os arquivos (git add .)...
git add .
echo.

REM 2. Solicita a mensagem de commit
echo [PASSO 2/4] Por favor, digite a mensagem do commit:
set /p commit_message="Mensagem: "

REM Verifica se a mensagem nao esta vazia (nao e robusto, mas ajuda)
if "%commit_message%"=="" (
    echo.
    echo ERRO: A mensagem de commit nao pode ser vazia.
    echo Abortando.
    pause
    exit /b
)

echo.

REM 3. Executa o commit
echo [PASSO 3/4] Executando o commit...
git commit -m "%commit_message%"
echo.

REM 4. Executa o push (para a branch upstream configurada)
echo [PASSO 4/4] Enviando para o GitHub (git push)...
git push

echo.
echo ------------------------------------------
echo  PROCESSO CONCLUIDO.
echo ------------------------------------------
echo.
pause