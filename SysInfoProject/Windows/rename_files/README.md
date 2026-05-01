# Rename Spaces to Underscores (PowerShell)

A PowerShell script to **recursively rename files and folders**, replacing spaces (" ") with underscores ("_"), with **dry-run**, **logging**, and **undo** capabilities.

---

## ✨ Features

- ✅ Renames **files and directories**
- ✅ Recursive operation
- ✅ **Dry-run mode** (preview changes safely)
- ✅ **Timestamped CSV log files**
- ✅ **Undo (redo)** support using the latest log
- ✅ Safe for deeply nested folder structures
- ✅ Built-in PowerShell help (`Get-Help` supported)

---

## 🚀 Usage

### Preview changes (Dry-Run)
```powershell
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -DryRun
```

### Perform renaming
```powershell
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data"
```

### Undo last rename (Preview)
```powershell
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -Undo -DryRun
```

### Undo last rename (Execute)
```powershell
.\Rename-SpacesToUnderscore.ps1 -Path "C:\Data" -Undo
```

---

## 🧾 Logging

Each run creates a timestamped log file:
```
rename_log_YYYYMMDD_HHMMSS.csv
```

The log is required for undo operations.

---

## 📖 Built‑in Help

```powershell
Get-Help .\Rename-SpacesToUnderscore.ps1 -Examples
```

---

## ⚠️ Best Practices

- Always run with `-DryRun` first
- Keep log files until changes are verified
- Do not run multiple instances in parallel

---

## 📄 License

MIT License
