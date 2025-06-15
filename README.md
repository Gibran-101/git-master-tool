# 🚀 Git-Master: Modular Git Toolbox in Bash

**Git-Master** is a powerful, modular CLI-based Git assistant built with Bash scripting. It wraps common Git operations into a structured, interactive, and auditable workflow with minimal effort and maximum control.

---

## 📦 Features

- ✅ Branch Management (create, switch, delete)
- ✅ Push Strategies (standard, force, upstream, tag)
- ✅ Pull Strategies (merge, rebase, fast-forward)
- ✅ Stash Handling (create, apply, drop, clear)
- ✅ Reset & Revert Modes (soft, mixed, hard, revert commits)
- ✅ Clone Customization (shallow, branch-specific)
- ✅ Interactive Menus with Prompt Validation
- ✅ JSON-based Structured Logging (`logger.sh`)

---

## 🧱 Project Structure

```bash
git-master/
├── git-master.sh          # Main menu interface
├── common_utils.sh        # Input validation utilities
├── logger.sh              # Logging engine (JSON format)
├── lib/                   # Modular Git features
│   ├── branch.sh
│   ├── push.sh
│   ├── pull.sh
│   ├── stash.sh
│   ├── revert_reset.sh
│   ├── logs.sh
│   └── clone.sh
🛠️ Prerequisites
To run Git-Master, ensure the following are installed:

Git – installed and configured.

Bash – Recommended on Linux, macOS, or Windows WSL.

jq – used for logging in JSON format.

📥 Install jq on Ubuntu:
bash
Copy
Edit
sudo apt install jq
⚙️ Setup Instructions
1. Clone the Repository
bash
Copy
Edit
git clone https://github.com/your-username/git-master.git
cd git-master
2. Make Scripts Executable
bash
Copy
Edit
chmod +x git-master.sh common_utils.sh logger.sh lib/*.sh
3. Launch Git-Master
bash
Copy
Edit
./git-master.sh
📝 Logging Mechanism
All actions are logged to a structured JSON file:
git_activity_log.json

Each log entry contains:

⏱️ Timestamp (ISO 8601)

🧠 Script name (push.sh, stash.sh, etc.)

⚠️ Log level (INFO, SUCCESS, ERROR, WARNING)

💬 Message

🆔 Unique Serial Key (e.g., PSIN01, BRSU02)

📄 Example Log Entry
json
Copy
Edit
{
  "timestamp": "2025-06-09T19:45:21Z",
  "level": "SUCCESS",
  "script": "branch.sh",
  "message": "Switched to branch 'dev'",
  "serial_key": "BRSU03"
}
🧠 Use Cases
🚀 Speed up routine Git workflows

🪵 Keep a clear log of Git actions

🧪 Safely test revert/reset operations

🧰 Integrate into larger DevOps toolchains

🧪 Example Workflows
🏷️ Creating and Switching Branches
bash
Copy
Edit
./git-master.sh
# Choose "Branch Management" > "Create Branch"
⛴️ Pushing with Upstream
bash
Copy
Edit
# Inside the tool
# Navigate to "Push Strategies" > "Push with Upstream"
🧼 Clearing All Stashes
bash
Copy
Edit
# From the main menu
# Go to "Git Stash Operations" > "Clear All Stashes"
👨‍💻 Developer Notes
Each sub-script is built to be modular, with shared validation and logging handled by:

common_utils.sh – for input checks, confirmation prompts

logger.sh – centralized JSON logging system

Sub-features live in the lib/ folder and are executed from git-master.sh.

🪪 License
This project is licensed under the MIT License.
Use it, modify it, fork it — just don’t forget to give credit.

👤 Author
Gibran
Cloud Engineer in Training | DevOps Aficionado | Technical Blogger

🔗 Contributions, stars, forks, and PRs are always welcome.
