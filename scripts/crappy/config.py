import platform
from typing import List

from crappy.task import Task


class Config:
    platform_name = platform.system()
    python_runtime = "python3" if platform_name == "Linux" else "python"
    platform_commands = {
        "Linux": {
            "wait": ["bash", "-c", "read -n 1"],
            "term": ["tmux", "new-window"]
        },
        "Windows": {
            "wait": ["pwsh", "-NoLogo", "-Command", "$null = [System.Console]::ReadKey()"],
            "term": ["wt", "--"]
        }
    }

    def __init__(self):
        self.is_master_script: bool = True
        self.launch_disabled: bool = False
        self.sockets_enabled: bool = False
        self.master_port_number: int = None

        self.task_queue: List[Task] = []
        self.command_queue: List[str] = []

        self.self_script_path = None
        self.argv = []
