from typing import List
from typing import defaultdict

from crappy.task import Task
from crappy.config import Config


def parse_args(config: Config):
    dash_args = defaultdict(list)
    last_key = None

    for arg in config.argv:
        if arg.find("--") == 0:
            dash_args[arg] = list()
            last_key = arg
        else:
            if last_key:
                dash_args[last_key].append(arg)
        pass

    if "--slave" in dash_args:
        config.is_master_script = False
        config.task_queue = []  # Slaves shouldn't see the predefined tasks

    if "--disable-launch" in dash_args:
        config.launch_disabled = True

    temp = dash_args["--master-port"]
    if temp:
        config.master_port_number = int(temp[0])

    # Lists of shell commands (not tokenized)
    build_commands = dash_args["--build"]
    launch_commands = dash_args["--launch"]
    init_tasks_from_args(config, build_commands, launch_commands)


def init_tasks_from_args(config: Config, build_commands: List[str], launch_commands: List[str]):
    while build_commands or launch_commands:
        build_cmd = build_commands.pop(0) if build_commands else None
        launch_cmd = launch_commands.pop(0) if launch_commands else None

        if config.launch_disabled:
            launch_cmd = None

        config.task_queue.append(Task(build_cmd=build_cmd, launch_cmd=launch_cmd))
