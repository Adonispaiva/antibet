@echo off
REM
REM === ORION: SCRIPT DE GIT PUSH AUTOMATIZADO ===
REM Versão: 1.5 - Maxima Robustez de Console (Timeout + Pause)
REM
TITLE GIT PUSH - AntiBet - Inovexa Software

REM Pede a mensagem de commit
set /p commit_msg="Digite a mensagem de commit (Ex: FEAT: Nova feature de login): "

REM Verifica se a mensagem de commit foi fornecida
if "%commit_msg%"=="" (
    echo.
    echo 🚨 ERRO: A mensagem de commit nao pode ser vazia!
    goto FINAL_WAIT
)

echo.
echo ===========================================
echo [1/4] Adicionando todos os arquivos...
echo ===========================================
git add .
if %errorlevel% neq 0 (
    echo.
    echo ❌ Falha ao executar 'git add .'. Verifique se esta no diretorio Git.
    goto FINAL_WAIT
)

echo.
echo ===========================================
echo [2/4] Commit com a mensagem: "%commit_msg%"
echo ===========================================
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo.
    echo ⚠️ ATENCAO: Nenhum arquivo para commit OU falha ao commitar.
    REM Continua...
)

echo.
echo ===========================================
echo [3/4] Atualizando repositorio local (git pull --rebase)...
echo ===========================================
git pull --rebase
if %errorlevel% neq 0 (
    echo.
    echo ❌ Falha ao executar 'git pull --rebase'. Verifique sua conexao ou remote.
    goto FINAL_WAIT
)

echo.
echo ===========================================
echo [4/4] Enviando para o GitHub (git push)...
echo ===========================================
git push
if %errorlevel% neq 0 (
    echo.
    echo 🔴 ERRO CRITICO: O comando 'git push' falhou.
    echo ➡️ Solucao: Verifique se o seu "remote" esta configurado corretamente (git remote -v).
    echo ➡️ Solucao: Tente executar "git push --set-upstream origin master" (ou main).
    goto FINAL_WAIT
)

REM --- FLUXO DE SUCESSO (Cai aqui se tudo deu certo) ---
echo.
echo ✅ SUCESSO! O codigo foi enviado para o GitHub.
echo.
goto FINAL_WAIT

:FINAL_WAIT
REM Esta label garante que a janela sempre pausa, independente do resultado.
echo.
echo ==============================================================
echo | EXECUCAO CONCLUIDA. AGUARDE 5s OU PRESSIONE UMA TECLA. |
echo ==============================================================
timeout /t 5
echo.
echo Pressione qualquer tecla para fechar...
pause