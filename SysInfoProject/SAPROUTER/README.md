# SAProuter Management Script

This repository provides a **Bash script** to manage SAProuter with full lifecycle commands (`start`, `stop`, `status`, `restart`) and extended configuration options.

---

## Features
- **Start/Stop/Status/Restart** SAProuter easily.
- Supports **trace level control**:
  - `--no-trace` disables trace.
  - `--trace-level <n>` sets custom trace level.
- Includes **extended SAProuter options**:
  - `-r` : Run as router.
  - `-Y 0` : Disable timeout for inactive connections.
  - `-C 1000` : Maximum number of clients.
  - `-D` : Run as daemon.
  - `-J 20000000` : Jump buffer size.
  - `-W 10000` : Maximum waiting connections.
  - `-K "<cert>"` : Use specified certificate.
- **Logging**: Output stored in `saprouter.log`.
- **PID management**: PID stored in `saprouter.pid`.

---

## Usage

```bash
saprouter_manager.sh {start|stop|status|restart} [OPTIONS]
