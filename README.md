[한국어](README.ko.md)

# SF Server

Smart Factory monorepo for the automatic weld inspection and sorting system.  
Contains two servers that run together on the factory PC.

---

## Repository Structure

```
sf_server/
├── install.bat       # One-time setup for both servers
├── start.bat         # Launch all services
├── db_server/        # Database middleware, API, and React dashboard
└── cam_server/       # Camera server and TFLite weld classifier
```

---

## Requirements

| Dependency | Notes |
|---|---|
| Python 3.x | For `db_server` (any modern version) |
| Python 3.10 | For `cam_server` (TFLite compatibility) |
| Node.js | For `sf-dashboard` |
| MySQL 8.1 | Service name must be `MySQL81` |

---

## First-Time Setup

> Run once on a new machine. Requires Python and Node.js on PATH.

Right-click `install.bat` → **Run as administrator**

This will:
1. Recreate `db_server/dbvenv` and install Python dependencies
2. Start MySQL81 and run `db_setup.py` to create all databases and tables
3. Install Node packages for `sf-dashboard`
4. Create `cam_server/venv` (Python 3.10) and install dependencies

> **Note:** If `db_server` was previously installed at a different path, delete `db_server/dbvenv` manually before running — venvs hardcode their install path.

---

## Running

Right-click `start.bat` → **Run as administrator**

Launches four services in separate terminal windows:

| Window | Service | Address |
|---|---|---|
| SF API | FastAPI middleware | http://localhost:8000 |
| SF Dashboard | React/Vite dashboard | http://localhost:5173 |
| SF PLC Controller | PLC order sync | — |
| SF CAM | Camera + classifier | http://localhost:5000 |

The dashboard opens in the browser automatically after 5 seconds.

---

## Servers

### db_server
FastAPI middleware between MySQL and the dashboard/PLC. Manages orders, parts, ships, customers, sort results, and inspection snapshots.  
See [db_server/README.md](db_server/README.md) for API reference and schema details.

### cam_server
Flask server that streams the inspection camera feed and runs TFLite weld classification models. Accepts model switching at runtime via HTTP.  
Dependencies: OpenCV, TFLite (`ai_edge_litert`), pymcprotocol, mysql-connector.
