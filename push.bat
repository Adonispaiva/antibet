@echo off
ECHO ===========================================
ECHO  INNOVEXA SOFTWARE - SCRIPT DE PUSH
ECHO ===========================================

REM Sincronizar a branch local 'main' com a remota 'origin/main'
git push origin main

IF %ERRORLEVEL% NEQ 0 (
    ECHO.
    ECHO ❌ ERRO: O push falhou!
    ECHO.
    ECHO * Verifique se o seu Personal Access Token (PAT) ainda e valido.
    ECHO * Verifique se o seu Git Credential Manager esta funcionando.
    PAUSE
    EXIT /B 1
) ELSE (
    ECHO.
    ECHO ✅ SUCESSO! Repositorio remoto atualizado.
    ECHO.
    ECHO A janela sera fechada automaticamente em 5 segundos...
    TIMEOUT /T 5 /NOBREAK
    EXIT /B 0
)