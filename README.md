

# microback 
<a href="https://gemini.google.com/">
    <img src="https://img.shields.io/badge/Built%20with-Gemini%20AI-8E75FF?style=for-the-badge&logo=googlegemini&logoColor=white" alt="Made with" />
</a>

Minimalist, zero-dependency local backup manager inspired by `microsocks` simplicity and `caddy`-style ergonomics.

Built with standard Python 3.8+ (`tomllib`/`tomli` or built-in zero-dependency TOML parser fallback, `argparse`, `shutil`, `rsync`). No pip packages required.

---

## Features

- **Broad Python Compatibility (3.8 - 3.13+)**: Zero external dependencies out-of-the-box. Uses `tomllib` on 3.11+, with seamless built-in fallback parser on older Pythons (Ubuntu 20.04/22.04 LTS).
- **Hardlink Snapshots (`format = "dir"`)**: Every backup looks like a full directory tree, but files unchanged from the previous backup are hardlinked (`--link-dest`), consuming zero extra disk space.
- **Archive Formats (`tar.zst`, `tar.gz`)**: Optional streaming compression for cold archives.
- **Deep Permission Checking**: Verifies read and traversal permissions recursively across all matched folders, subfolders, and files, plus write and traversal access to destination storage.
- **Rotation & Retention**: Automatically keeps `keep_count` newest snapshots and safely removes older ones.
- **Flexible Rules**: Glob patterns (`*`, `**`, `?`), tilde home expansion (`~`), and environment variables (`$HOME`).
- **Post/Pre-Hooks & Verification**: Run hooks (e.g. Docker pause/resume) and verify backup health (`null`, `size>10M`, or custom commands).
- **Simple Scheduling**: Supports daily times (`03:00`), intervals (`1d`, `12h`), or standard 5-field cron syntax via `microback cron`.

---

## Installation

Requires Linux with Python 3.8+ and `rsync`.

```bash
# Clone or copy microback
cd microback

# Install into /usr/local/bin (or PREFIX=/usr)
sudo ./install.sh
# or
sudo make install
```

To uninstall:
```bash
sudo make uninstall
```

Directory structure created:
- `/usr/local/bin/microback` — executable binary
- `/etc/microback/configs/` — repository of task configurations
- `/etc/microback/enabled.d/` — symlinks to enabled configs
- `/var/log/microback/` — log directory
- `/var/lib/microback/` — state directory (last execution timestamps)

---

## Configuration Syntax

Configurations are standard TOML files with `#` comments and optional top-level defaults.

Example (`/etc/microback/configs/pokemon.toml`):

```toml
# Top-level global defaults (applied to all tasks below unless overridden)
destination = "/big/backups"
keep_count = 7
format = "dir"
verify = "none"
schedule = "03:00"

[minecraft_pokemon]
destination = "/big/backups/pokemon"
keep_count = 14
schedule = "04:00"

# Format: "<source> -> <target_subdir>" or "<source> <target_subdir>"
rules = [
    "~/minecraft_pokemon/data/world/playerdata -> playerdata",
    "~/minecraft_pokemon/data/world/data/pokemon/pc/* -> pc",
    "~/minecraft_pokemon/server.properties -> config",
]

# Optional hooks:
# pre_hook = "docker exec mc rcon-cli save-off && docker exec mc rcon-cli save-all"
# post_hook = "docker exec mc rcon-cli save-on"
```

---

## CLI Usage

### 1. Create a Template
```bash
microback template /etc/microback/configs/mybackup.toml
```

### 2. Verify Configuration & Permissions
Validates config syntax, mandatory fields, rule mappings, and checks read/traversal permissions on all source files/subfolders and write permissions on destination:
```bash
microback verify /etc/microback/configs/mybackup.toml
```

### 3. Enable / Disable
Enabling automatically runs verification first:
```bash
microback enable /etc/microback/configs/mybackup.toml
microback disable mybackup
```

### 4. List Active Tasks
```bash
microback list
```

### 5. Manual Backup / Sync
Run all enabled tasks (or a specific config/task):
```bash
# Dry run to see what would be copied
microback sync --dry-run

# Run now
microback sync

# Run specific task from a file
microback sync -c /etc/microback/configs/mybackup.toml -t minecraft_pokemon
```

### 6. Automated Scheduling (Cron / Timer)
Add `microback cron` to root's crontab (`crontab -e`):
```cron
* * * * * /usr/local/bin/microback cron >> /var/log/microback/cron.log 2>&1
```
`microback cron` inspects each enabled task's schedule (`03:00`, `1d`, `12h`, etc.) and executes only tasks that are due.
