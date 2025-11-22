@echo off
TITLE AntiBet - Importador de Design
SETLOCAL

echo ==================================================
echo      IMPORTAR LOGO DA PASTA DESIGN
echo ==================================================
echo.

REM Caminho de Destino (Onde o Flutter procura)
set "DEST_DIR=assets\images\logo"
REM Caminho de Origem (Onde voce guardou as artes)
set "SOURCE_DIR=..\design"

echo [1/3] Criando pasta de destino no Mobile...
if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

echo.
echo [2/3] Abrindo as pastas para voce...
echo.
echo ==========================================================
echo                 MISSAO FINAL (ATENCAO)
echo ==========================================================
echo 1. Vou abrir DUAS janelas agora.
echo 2. Janela 1: Pasta 'DESIGN' (Suas imagens).
echo 3. Janela 2: Pasta 'LOGO' (Destino).
echo.
echo ACAO: Arraste seu logo da janela DESIGN para a janela LOGO.
echo ACAO: Renomeie o arquivo na janela LOGO para: ic_launcher.png
echo ==========================================================
echo.

REM Abre a origem (Design)
if exist "%SOURCE_DIR%" (
    start "" "%SOURCE_DIR%"
) else (
    echo [AVISO] Nao achei a pasta 'design' na raiz. Verifique se o nome esta exato.
    echo Vou abrir apenas o destino.
)

REM Abre o destino (Mobile Assets)
start "" "%DEST_DIR%"

echo.
echo Pressione qualquer tecla DEPOIS de arrastar e renomear...
pause

echo.
echo [3/3] Aplicando os icones no Android...
call dart run flutter_launcher_icons

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCESSO TOTAL! Icones gerados.
    echo Agora voce pode rodar: flutter run
) else (
    echo.
    echo ❌ Ocorreu um erro. Verifique se voce renomeou para ic_launcher.png
)

echo.
pause
ENDLOCAL