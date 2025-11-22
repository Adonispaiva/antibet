@echo off
TITLE AntiBet - Corretor de Pacote Kotlin
SETLOCAL

echo ==================================================
echo      AJUSTE ESTRUTURAL DO PACOTE KOTLIN
echo ==================================================
echo.

REM Vai para o diretório onde o erro está (src\main\kotlin)
cd android\app\src\main\kotlin

REM Verifica se a estrutura esperada ja existe
if exist com\inovexa\antibet (
    echo [AVISO] Estrutura ja parece correta. Continuando...
    goto final_instruction
)

REM 1. Cria a pasta 'inovexa'
if not exist com\inovexa (
    mkdir com\inovexa
    echo [OK] Pasta 'inovexa' criada.
)

REM 2. Move a pasta 'antibet' para dentro de 'inovexa'
if exist com\antibet (
    move com\antibet com\inovexa\
    echo [SUCESSO] Estrutura do pacote corrigida para com.inovexa.antibet.
) else (
    echo [ALERTA] A pasta 'com\antibet' nao foi encontrada.
    echo Por favor, crie manualmente a estrutura: com\inovexa\antibet
)

:final_instruction
echo.
echo ==================================================
echo ACAO MANDATORIA:
echo 1. Certifique-se de que o arquivo AntiBetApplication.kt esta salvo na nova pasta:
echo    com\inovexa\antibet
echo 2. Rode o comando final de build.
echo ==================================================
echo.

REM Volta para a raiz do modulo mobile
cd ..\..\..\..\..\
pause

ENDLOCAL