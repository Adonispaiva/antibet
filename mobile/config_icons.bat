@echo off
TITLE AntiBet - Gerador de Icones
SETLOCAL

echo ==================================================
echo      ANTIBET MOBILE - GERADOR DE ICONES
echo ==================================================
echo.

REM Define o caminho da imagem fonte conforme configurado no pubspec.yaml
set "IMG_SOURCE=assets\images\logo\ic_launcher.png"

echo [1/3] Verificando imagem fonte...
if exist "%IMG_SOURCE%" (
    echo [OK] Imagem encontrada em: %IMG_SOURCE%
) else (
    echo.
    echo [X] ERRO: Imagem fonte nao encontrada!
    echo --------------------------------------------------
    echo Por favor, coloque sua logomarca (PNG) no caminho:
    echo D:\projetos-inovexa\antibet\mobile\%IMG_SOURCE%
    echo.
    echo Dica: O arquivo deve se chamar 'ic_launcher.png'.
    echo --------------------------------------------------
    echo.
    pause
    goto end
)

echo.
echo [2/3] Baixando dependencias do projeto...
call flutter pub get
if %errorlevel% neq 0 (
    echo [X] Falha no 'flutter pub get'. Verifique o console.
    pause
    goto end
)

echo.
echo [3/3] Gerando icones para Android e iOS...
call dart run flutter_launcher_icons
if %errorlevel% neq 0 (
    echo [X] Falha na geracao dos icones.
) else (
    echo.
    echo ==================================================
    echo [SUCESSO] Novos icones aplicados com sucesso!
    echo ==================================================
    echo Lembre-se de reinstalar o app no emulador para ver a mudanca.
)

:end
echo.
pause
ENDLOCAL