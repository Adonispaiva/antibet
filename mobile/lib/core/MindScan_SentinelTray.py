import os
import io
import time
import json
import threading
import webbrowser
import requests
import subprocess
from datetime import datetime
from PIL import Image, ImageDraw
import pystray
from plyer import notification
from pathlib import Path

# ============================================
# 🧠 MindScan Sentinel Tray — v5.6
# ============================================
# Autor: Leo Vinci (GPT Inovexa)
# Data: 12/11/2025
# Função: Interface residente de bandeja com controle direto
# ============================================

REMOTE_CONSOLE = "http://127.0.0.1:8093"
DASHBOARD_URL = "http://127.0.0.1:8095"
LOG_API = "http://127.0.0.1:8091/logs"
AUTH_TOKEN = os.getenv("INOVEXA_CONSOLE_KEY", "DEV-LOCAL-KEY")
ICON_COLOR = "#3B82F6"  # Azul Inovexa

def now():
    return datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S")

def log(msg, level="INFO"):
    print(f"[{now()}] [SentinelTray] [{level}] {msg}")
    try:
        requests.post(LOG_API, json={"origin": "SentinelTray", "message": msg, "level": level}, timeout=1)
    except Exception:
        pass

def notify(title, message):
    try:
        notification.notify(title=title, message=message, timeout=4, app_name="MindScan Sentinel")
    except Exception:
        pass

# ---------------------- AÇÕES ----------------------
def open_dashboard(icon, item=None):
    webbrowser.open(DASHBOARD_URL)
    log("Painel Sentinel aberto pelo menu de bandeja.")
    notify("MindScan Sentinel", "Painel aberto no navegador.")

def restart_services(icon, item=None):
    log("Reinício de serviços solicitado via Tray.")
    try:
        r = requests.post(f"{REMOTE_CONSOLE}/restart", headers={"Authorization": f"Bearer {AUTH_TOKEN}"}, timeout=5)
        if r.status_code == 200:
            notify("MindScan Sentinel", "Serviços reiniciados com sucesso.")
        else:
            notify("MindScan Sentinel", "Falha ao reiniciar serviços.")
    except Exception as e:
        log(f"Erro ao reiniciar: {e}", "ERROR")
        notify("MindScan Sentinel", "Erro de comunicação com o console.")

def force_sync(icon, item=None):
    log("Sincronização forçada via Tray.")
    try:
        r = requests.post(f"{REMOTE_CONSOLE}/sync", headers={"Authorization": f"Bearer {AUTH_TOKEN}"}, timeout=5)
        if r.status_code == 200:
            notify("MindScan Sentinel", "Sincronização concluída.")
        else:
            notify("MindScan Sentinel", "Falha na sincronização.")
    except Exception as e:
        log(f"Erro no sync: {e}", "ERROR")

def trigger_rollback(icon, item=None):
    log("Rollback remoto acionado via Tray.")
    try:
        r = requests.post(f"{REMOTE_CONSOLE}/rollback", headers={"Authorization": f"Bearer {AUTH_TOKEN}"}, timeout=5)
        if r.status_code == 200:
            notify("MindScan Sentinel", "Rollback executado com sucesso.")
        else:
            notify("MindScan Sentinel", "Falha ao executar rollback.")
    except Exception as e:
        log(f"Erro no rollback: {e}", "ERROR")

def show_status(icon, item=None):
    try:
        r = requests.get(f"{REMOTE_CONSOLE}/status", headers={"Authorization": f"Bearer {AUTH_TOKEN}"}, timeout=5)
        if r.status_code == 200:
            data = r.json()
            msg = f"CPU: {data['cpu']}% | Mem: {data['memory']}% | Proc: {data['processes']}"
            notify("Status MindScan", msg)
            log(f"Status exibido: {msg}")
        else:
            notify("MindScan Sentinel", "Falha ao obter status.")
    except Exception:
        notify("MindScan Sentinel", "Console remoto inacessível.")

def exit_app(icon, item=None):
    log("Sentinel Tray encerrado pelo usuário.", "WARN")
    notify("MindScan Sentinel", "Agente encerrado.")
    icon.stop()

# ---------------------- ÍCONE ----------------------
def create_icon():
    img = Image.new("RGB", (64, 64), color=ICON_COLOR)
    draw = ImageDraw.Draw(img)
    draw.ellipse((12, 12, 52, 52), fill="#60A5FA")
    draw.text((23, 20), "M", fill="white")
    return img

# ---------------------- MAIN ----------------------
def main():
    log("Sentinel Tray iniciado.")
    notify("MindScan Sentinel", "Painel residente ativo na bandeja.")
    icon = pystray.Icon(
        "MindScan Sentinel",
        create_icon(),
        menu=pystray.Menu(
            pystray.MenuItem("Abrir Painel", open_dashboard),
            pystray.MenuItem("Exibir Status", show_status),
            pystray.MenuItem("Forçar Sync", force_sync),
            pystray.MenuItem("Executar Rollback", trigger_rollback),
            pystray.MenuItem("Reiniciar Serviços", restart_services),
            pystray.MenuItem("Sair", exit_app)
        )
    )
    icon.run()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("Sentinel Tray encerrado manualmente.", "WARN")
        notify("MindScan Sentinel", "Tray encerrado manualmente.")
