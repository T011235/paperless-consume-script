# 📄 paperless-consume-spooler

Ein Linux-Systemdienst zur automatisierten Übergabe gescannter oder hochgeladener PDF-Dokumente an [paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) über dessen REST-API.

Das Skript überwacht beliebige Eingangsordner, wartet auf stabile Dateien, benennt sie korrekt und überträgt sie direkt an paperless. Anschließend werden sie gelöscht – aber erst nach erfolgreichem Upload.

---

## ✅ Features

- Überwachung mehrerer Ordner (inotify)
- API-Upload direkt an paperless
- Wartet 10 Sekunden auf Dateistabilität
- Nutzt Dateiname als Dokumenttitel
- Löscht Datei **nur nach erfolgreichem Upload**
- `.env`-basierte Konfiguration
- Logging nach `/var/log/paperless-consume-spooler.log`
- Mit `flock` vor Mehrfachausführung geschützt

---

## 🛠️ Installation

### 📁 1. Repository-Struktur

```bash
git clone https://github.com/dein-benutzername/paperless-consume-spooler.git
cd paperless-consume-spooler
Kopiere die Dateien an ihre Zielorte:

sudo cp bin/paperless-consume-spooler.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/paperless-consume-spooler.sh

sudo cp systemd/paperless-consume-spooler.service /etc/systemd/system/
```
### ⚙️ 2. Konfiguriere Umgebungsvariablen
Lege eine .env Datei an:
```bash
sudo nano /etc/paperless-uploader.env
```

Inhalt:
```env
API_TOKEN=dein-paperless-api-token
PAPERLESS_URL=http://localhost:8000
```

### 🔐 3. Log-Datei & Lock-Datei vorbereiten
```bash
sudo touch /var/log/paperless-consume-spooler.log
sudo chmod 644 /var/log/paperless-consume-spooler.log

sudo mkdir -p /var/lock
sudo touch /var/lock/paperless-consume-spooler.lock
```

### 🚀 4. Service starten

```bash
sudo systemctl daemon-reload
sudo systemctl enable paperless-consume-spooler.service
sudo systemctl start paperless-consume-spooler.service
```

🔍 Wartung & Fehlerbehebung

Aktive Logs prüfen:
```bash
tail -f /var/log/paperless-consume-spooler.log
```

Service neu starten:
```bash
sudo systemctl restart paperless-consume-spooler.service
```

Alte Prozesse stoppen (z. B. bei Hängern):
```bash
sudo pkill -f paperless-consume-spooler.sh
```

Lock-Datei aufräumen (optional):
```bash
sudo rm -f /var/lock/paperless-consume-spooler.lock
```

### 💡 Hinweise
Erfordert inotify-tools und curl:

```bash
sudo apt install inotify-tools curl
```
Das Skript löscht nur Dateien, die erfolgreich übertragen wurden.
Der Dienst verarbeitet ausschließlich .pdf-Dateien.

📜 Lizenz
MIT License
