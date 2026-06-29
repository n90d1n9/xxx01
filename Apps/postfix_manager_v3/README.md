# PostfixMgr v2 — Enhanced Mail Server Management

Full-stack Postfix management system with Flutter frontend and Quarkus backend.

## ✨ What's New in v2

| Feature | Description |
|---------|-------------|
| 🔐 Auth | Login screen + JWT token management |
| 🗺️ Transport Maps | Visual editor for postfix transport rules |
| 🛡️ Access Control | Blacklist/whitelist manager (IP, domain, email, network) |
| 🔒 TLS Manager | Certificate viewer, upload, expiry tracking |
| 🌐 DNS Inspector | SPF / DKIM / DMARC / MX / rDNS health checker |
| 🔔 Alerts | Critical/warning/info notification center with badge count |
| 💾 Backup & Restore | Granular config backup with selective restore |
| ⚙️ Settings | API URL, auto-refresh, alert thresholds |
| 📊 Enhanced Dashboard | Alert banner, delivery rate, more metrics |
| 🔍 Queue Search | Full-text search + sort + detail modal |
| 📡 Enhanced Logs | Syntax highlighting (queue IDs, emails, IPs), auto-scroll |

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Web/Desktop                   │
│  Login → Dashboard → Queue → Logs → Config              │
│          Transport → Access → TLS → DNS                 │
│          Domains → Mailboxes → Aliases                  │
│          Alerts → Backup → Settings                     │
└────────────────────┬────────────────────────────────────┘
                     │ REST + WebSocket
┌────────────────────▼────────────────────────────────────┐
│              Quarkus 3.9 REST API                        │
│  /api/auth   /api/postfix  /api/mail                    │
│  /api/alerts /api/postfix/transport                     │
│  /api/postfix/access  /api/postfix/tls                  │
│  /api/postfix/dns     /api/postfix/backups              │
│  ws://host/api/logs/stream   (WebSocket log tail)       │
└────────────────────┬────────────────────────────────────┘
          ┌──────────┴──────────┐
          │                     │
┌─────────▼──────┐    ┌────────▼────────┐
│   PostgreSQL   │    │     Postfix      │
│ virtual_domains│    │ /etc/postfix/   │
│ virtual_mailbox│    │ /var/log/mail.log│
│ virtual_aliases│    │ /var/spool/postfix│
│ access_rules   │    └─────────────────┘
│ mail_logs      │
└────────────────┘
```

## Quick Start

### Prerequisites
- Docker + Docker Compose
- Flutter SDK 3.x (for building frontend)

### 1. Build Flutter Web App
```bash
cd flutter_app
flutter pub get
flutter build web --release
```

### 2. Start All Services
```bash
docker-compose up -d
```

### 3. Access
| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8080/api |
| Swagger UI | http://localhost:8080/swagger |
| Health | http://localhost:8080/q/health |

**Default login:** `admin` / `admin`

### Dev Mode (backend only)
```bash
cd quarkus_backend
./mvnw quarkus:dev
```

## Project Structure

```
postfix_manager/
├── flutter_app/
│   └── lib/
│       ├── main.dart              # App entry, theme, shell, router
│       ├── models/models.dart     # All data models
│       ├── providers/providers.dart # Riverpod state
│       ├── services/api_service.dart # Dio HTTP client
│       └── screens/
│           ├── auth/login_screen.dart
│           ├── postfix/
│           │   ├── dashboard_screen.dart
│           │   ├── queue_screen.dart
│           │   ├── logs_screen.dart
│           │   ├── config_screen.dart
│           │   ├── transport_screen.dart  ← NEW
│           │   ├── access_screen.dart     ← NEW
│           │   ├── tls_screen.dart        ← NEW
│           │   ├── dns_screen.dart        ← NEW
│           │   └── backup_screen.dart     ← NEW
│           ├── mail/
│           │   ├── domains_screen.dart
│           │   ├── mailboxes_screen.dart
│           │   └── aliases_screen.dart
│           ├── alerts_screen.dart         ← NEW
│           └── settings_screen.dart       ← NEW
└── quarkus_backend/
    ├── Dockerfile
    ├── pom.xml
    └── src/main/java/com/postfix/
        ├── dto/Dtos.java           # All DTO records
        ├── model/Entities.java     # JPA entities
        ├── resource/
        │   ├── Resources.java      # All REST endpoints
        │   └── LogStreamWebSocket.java
        └── service/
            ├── AuthService.java
            ├── PostfixService.java
            ├── MailService.java
            ├── TransportService.java  ← NEW
            ├── AccessService.java     ← NEW
            ├── TlsService.java        ← NEW
            ├── DnsService.java        ← NEW
            ├── AlertService.java      ← NEW
            └── BackupService.java     ← NEW
```

## API Reference

### Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | /api/auth/login | Login → TokenResponse |
| POST | /api/auth/logout | Logout |

### Postfix Engine
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/postfix/status | Server status + metrics |
| POST | /api/postfix/start\|stop\|reload | Control daemon |
| GET | /api/postfix/stats?period= | Delivery statistics |
| GET | /api/postfix/queue?status=&search= | Mail queue |
| POST | /api/postfix/queue/flush | Flush all deferred |
| DELETE | /api/postfix/queue/{id} | Delete message |
| POST | /api/postfix/queue/{id}/requeue\|hold\|release | Queue actions |
| GET | /api/postfix/logs?level=&search= | Log entries |
| GET/PUT | /api/postfix/config | Read/write config |
| GET/PUT | /api/postfix/transport | Transport maps |
| GET/POST/DELETE | /api/postfix/access | Access rules |
| GET/POST/DELETE | /api/postfix/tls/certificates | TLS certs |
| GET/POST | /api/postfix/dns/{domain} | DNS health check |
| GET/POST/DELETE | /api/postfix/backups | Config backups |

### Mail Management
| Method | Path | Description |
|--------|------|-------------|
| GET/POST | /api/mail/domains | Virtual domains |
| PATCH/DELETE | /api/mail/domains/{domain} | Manage domain |
| GET/POST | /api/mail/mailboxes?domain= | Virtual mailboxes |
| PATCH/DELETE | /api/mail/mailboxes/{email} | Manage mailbox |
| GET/POST | /api/mail/aliases?domain= | Email aliases |
| PATCH/DELETE | /api/mail/aliases/{source} | Manage alias |

### Alerts
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/alerts?unreadOnly= | Get alerts |
| PATCH | /api/alerts/{id}/read | Mark read |
| POST | /api/alerts/read-all | Mark all read |
| DELETE | /api/alerts/{id} | Delete alert |

## Design System
- **Theme:** GitHub Dark (bg #0D1117, card #1C2128, accent #00D9FF)
- **Typography:** IBM Plex Mono throughout
- **Colors:** Cyan (accent), Green (success), Red (error), Orange (warning), Purple (info)

## Production Notes
1. Change default admin password in `AuthService.java`
2. Set `%prod.quarkus.hibernate-orm.database.generation=update`
3. Mount real postfix directories in docker-compose volumes
4. Add TLS to nginx for HTTPS
5. Consider Redis for session/token storage at scale
