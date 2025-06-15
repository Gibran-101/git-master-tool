# Git-Master: A Modular Command-Line Git Toolbox

`git-master` is a modular and menu-driven command-line interface designed to simplify common Git operations such as branching, pushing, pulling, stashing, logging, and more. It provides a centralized way to interact with Git while maintaining structured logging for auditing and tracking.

---

## Features

- **Branch Management** – Create, switch, list, or delete branches
- **Push Strategies** – Support for normal, upstream, force, and tag pushes
- **Pull Mechanisms** – Pull using merge, rebase, or fast-forward modes
- **Stash Handling** – Create, list, apply, drop, or clear stashes
- **Reset/Revert** – Perform soft, mixed, hard resets, or commit reverts
- **Clone Options** – Clone repositories with custom depth or branch targeting
- **Structured Logging** – Generate detailed JSON logs for every action
- **Interactive Menus** – Clean user prompts with validation support

---

## Directory Structure

git-master/
├── git-master.sh # Main entry script (interactive menu)
├── common_utils.sh # Shared input, prompt, and validation utilities
├── logger.sh # Structured JSON logging logic
├── lib/
│ ├── branch.sh # Branch management script
│ ├── push.sh # Push handling logic
│ ├── pull.sh # Pull mechanisms
│ ├── stash.sh # Stash operations
│ ├── revert_reset.sh # Reset/revert options
│ ├── logs.sh # Git log viewer
│ └── clone.sh # Clone customization

yaml
Copy
Edit

---

## Prerequisites

- Git must be installed (`git --version`)
- Bash shell (Linux, macOS, or WSL on Windows)
- `jq` for JSON log handling (`sudo apt install jq`)

---

## Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/git-master.git
   cd git-master
Make scripts executable:

bash
Copy
Edit
chmod +x git-master.sh logger.sh common_utils.sh lib/*.sh
Run the tool:

bash
Copy
Edit
./git-master.sh
Follow the interactive prompts to perform Git operations.

Logging System
All operations are recorded in a JSON-formatted log file (git_activity_log.json) with:

Timestamp

Script name

Log level (INFO, SUCCESS, ERROR, WARNING)

Custom message

Auto-generated serial key (e.g., PSIN01)

This enables traceability and supports audit requirements.

Example entry:

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
Use Cases
Rapid Git operations without remembering syntax

Structured tracking for every action performed

Safer branching, pushing, and resetting with guided prompts

Automation base for larger DevOps workflows

License
This project is licensed under the MIT License.
You are free to use, modify, and distribute the code with attribution.

Author
Gibran
Graduate Assistant · DevOps Enthusiast · Cloud Engineer in Training

For feedback, suggestions, or contributions, feel free to open an issue or submit a pull requ
