@echo off
setlocal enabledelayedexpansion

:: ============================================================
::      INVENTÁRIO AVANÇADO DO PROJETO ANTIBET (INOVEXA)
:: ============================================================

title INVENTÁRIO AVANÇADO DO PROJETO ANTIBET
color 0B
cls

echo ===============================================
echo      INVENTÁRIO AVANÇADO DO PROJETO ANTIBET
echo ===============================================
echo.
echo Gerando arvore completa do projeto...
echo (isso pode levar alguns segundos)
echo.

:: ----------- DEFINIR DIRETÓRIO BASE -------------------------
:: (ASSUMINDO QUE A RAIZ DO PROJETO ESTÁ AQUI)
set "BASE_DIR=D:\projetos-inovexa\antibet"
if not exist "%BASE_DIR%" (
    echo ERRO: Diretorio base nao encontrado: %BASE_DIR%
    echo Verifique se o caminho acima e a raiz do seu projeto AntiBet.
    pause
    exit /b
)

:: ----------- CRIAR DIRETÓRIO DE SAÍDA ------------------------
set "OUT_DIR=%BASE_DIR%\arvore_antibet"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

:: ----------- DATA/HORA FORMATADA -----------------------------
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    set DD=%%a
    set MM=%%b
    set AA=%%c
)
for /f "tokens=1-2 delims=:." %%h in ("%time%") do (
    set HH=%%h
    set MN=%%i
)
set "TS=%AA%-%MM%-%DD%_%HH%%MN%"

:: ----------- DEFINIR ARQUIVOS DE SAÍDA ------------------------
set "ARVORE_FILE=%OUT_DIR%\arvore_%TS%.txt"
set "INVENTARIO_FILE=%OUT_DIR%\inventario_completo_%TS%.txt"
set "GRANDES_FILE=%OUT_DIR%\grandes_arquivos_%TS%.txt"
set "SUMARIO_FILE=%OUT_DIR%\sumario_%TS%.txt"

:: ============================================================
::                      GERAR RELATÓRIOS
:: ============================================================

:: 1. Gerar Arvore de Pastas e Arquivos
echo Gerando arvore...
tree "%BASE_DIR%" /F /A > "%ARVORE_FILE%"

:: 2. Gerar Inventario Completo (Lista de todos os arquivos)
echo Gerando inventario de arquivos...
dir "%BASE_DIR%" /S /B /A-D > "%INVENTARIO_FILE%"

:: 3. Gerar Lista de Arquivos Maiores que 50MB
echo Verificando arquivos grandes (> 50MB)...
(
    echo.
    echo ======== ARQUIVOS MAIORES QUE 50MB ========
    echo.
) > "%GRANDES_FILE%"
for /r "%BASE_DIR%" %%F in (*) do (
    if %%~zF GTR 52428800 (
        echo "%%~fF" (%%~zF bytes) >> "%GRANDES_FILE%"
    )
)

:: ============================================================
::                      GERAR SUMÁRIO
:: ============================================================
echo Gerando sumario...

set /a COUNT=0
for /f "delims=" %%A in ('dir "%BASE_DIR%" /S /B') do (
    set /a COUNT+=1
)

(
    echo ===============================================
    echo SUMARIO DO PROJETO ANTIBET - %TS%
    echo ===============================================
    echo.
    echo Diretorio raiz: %BASE_DIR%
    echo.
    echo Quantidade de arquivos e pastas:
    echo -----------------------------------------------
    echo Total de entradas: !COUNT!
    echo.
    echo Principais diretorios encontrados:
    echo -----------------------------------------------
) >> "%SUMARIO_FILE%"

:: (Diretórios específicos do AntiBet)
for %%D in (backend mobile) do (
    if exist "%BASE_DIR%\%%D" echo - %%D >> "%SUMARIO_FILE%"
)

(
    echo.
    echo ===============================================
    echo ARQUIVOS MAIORES QUE 50MB
    echo ===============================================
    type "%GRANDES_FILE%"
    echo.
    echo ======== FIM DO SUMARIO ========
) >> "%SUMARIO_FILE%"

:: ============================================================
::                      FINALIZAÇÃO
:: ============================================================
echo Concluido!
echo.
echo Arquivos salvos em:
echo - "%ARVORE_FILE%"
echo - "%INVENTARIO_FILE%"
echo - "%GRANDES_FILE%"
echo - "%SUMARIO_FILE%"
echo.
echo Por favor, me envie o arquivo: %SUMARIO_FILE%
echo e, se necessario, o %ARVORE_FILE%.
pause