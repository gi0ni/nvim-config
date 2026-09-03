# =============================================================================
# *   CRAPPY BUILD SCRIPT                                                     *
# *      v0.0.17                                                              *
# *      @author gi0ni                                                        *
# =============================================================================

import platform
import os
import sys
import shlex
import subprocess
import time
from typing import List

# =============================================================================
# *                                                                           *
# *                                UTILITIES                                  *
# *                                                                           *
# =============================================================================
platform_name = platform.system()

python_runtime = "python3" if platform_name == "Linux" else "python"
self_script_path = os.path.realpath(__file__)

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


def wait_for_keypress():
    wait_cmd = platform_commands[platform_name]["wait"]
    subprocess.run(wait_cmd)


def fail_gracefully(msg):
    print(msg)
    print("Press any key to continue...", end="", flush=True)
    wait_for_keypress()
    sys.exit(1)


Color = {
    "RED":    "\033[31m",
    "GREEN":  "\033[32m",
    "YELLOW": "\033[33m",
    "PURPLE": "\033[35m",
    "CLEAR":  "\033[0m"
}


# TODO: Might be useful to be able to run more than one build&launch command in the same terminal window
class Task:
    def __init__(self, name=None, build_cmd=None, launch_cmd=None, predicate=None):
        self.name = name if name is not None else "build"
        self.predicate = predicate if callable(predicate) else None

        self.build_cmd = build_cmd if build_cmd else None
        self.launch_cmd = launch_cmd if launch_cmd else None

        self.tokenized_build_cmd = shlex.split(self.build_cmd) if self.build_cmd else None
        self.tokenized_launch_cmd = shlex.split(self.launch_cmd) if self.launch_cmd else None

    def execute_build(self) -> bool:
        if not self.has_build():
            return True

        return_code = 1
        try:
            return_code = subprocess.run(self.tokenized_build_cmd).returncode
        except FileNotFoundError:
            fail_gracefully("{1}[BUILD][✗]{0} failed to run unknown command {2}`{3}`{0}!"
                            .format(Color["CLEAR"], Color["RED"], Color["PURPLE"], self.build_cmd))

        build_passed = (return_code == 0)
        return build_passed

    def execute_launch(self) -> int:
        if not self.has_launch():
            return 0

        return_code = 1
        try:
            return_code = subprocess.run(self.tokenized_launch_cmd).returncode
        except FileNotFoundError:
            fail_gracefully("{1}[LUNCH][✗]{0} failed to find binary {2}`{3}`{0}!"
                            .format(Color["CLEAR"], Color["RED"], Color["PURPLE"], self.launch_cmd.strip()))

        return return_code

    def evaluate_predicate(self) -> bool:
        return True if self.predicate is None else self.predicate()

    def is_empty(self) -> bool:
        return not self.has_build() and not self.has_launch()

    def has_build(self):
        return self.build_cmd is not None

    def has_launch(self):
        return self.launch_cmd is not None


tasks: List[Task] = []
is_master_script = True
launch_disabled = False


def add_task(name=None, build_cmd=None, launch_cmd=None, predicate=None):
    if launch_disabled:
        launch_cmd = None
    task = Task(name, build_cmd, launch_cmd, predicate)
    tasks.append(task)


# =============================================================================
# *                                                                           *
# *                             ARGUMENT PARSING                              *
# *                                                                           *
# =============================================================================
def parse_args():
    global is_master_script
    global launch_disabled

    argc = len(sys.argv)

    # An element in one of these 2 lists is a string. It represents a command
    # joined together with its args in one single string. Each element will be
    # split into a list of tokens later
    build_commands = []
    launch_commands = []

    for i in range(1, argc):
        arg = sys.argv[i]

        match arg:
            case "--slave":
                is_master_script = False

            case "--build":
                pos = find_next_dash_arg(sys.argv, i)
                build_commands = sys.argv[i + 1:pos]
                i = pos - 1

            case "--launch":
                pos = find_next_dash_arg(sys.argv, i)
                launch_commands = sys.argv[i + 1:pos]
                i = pos - 1

            case "--launchDisabled":
                launch_disabled = True

    init_tasks_from_args(build_commands, launch_commands)


def find_next_dash_arg(argv: List[str], start_index):
    argc = len(argv)

    for i in range(start_index + 1, argc):
        arg = argv[i]
        if arg.find("--") == 0:
            return i

    return argc


def init_tasks_from_args(build_commands: List[str], launch_commands: List[str]):
    while build_commands or launch_commands:
        buildCmd = build_commands.pop(0) if build_commands else None
        launchCmd = launch_commands.pop(0) if launch_commands else None

        add_task(build_cmd=buildCmd, launch_cmd=launchCmd)


# =============================================================================
# *                                                                           *
# *                          MASTER SCRIPT INSTANCE                           *
# *                                                                           *
# =============================================================================
class Master:
    def __init__(self):
        self.slaves: List[subprocess.Popen] = []

        user_config()

        if not tasks:
            add_task(name="error")

        for task in tasks:
            if task.evaluate_predicate():
                self.dispatch_slaves(task)

        self.wait_for_slaves()

    def dispatch_slaves(self, task):
        spawn_cmd = [python_runtime, self_script_path, "--slave"]

        if platform_name == "Linux":
            spawn_cmd = ["-n", task.name] + spawn_cmd

        if task.has_build():
            spawn_cmd += ["--build", task.build_cmd]

        if task.has_launch():
            spawn_cmd += ["--launch", task.launch_cmd]

        spawn_cmd = platform_commands[platform_name]["term"] + spawn_cmd
        self.slaves += [subprocess.Popen(spawn_cmd)]

    def wait_for_slaves(self):
        for slave in self.slaves:
            slave.wait()


# =============================================================================
# *                                                                           *
# *                           SLAVE SCRIPT INSTANCE                           *
# *                                                                           *
# =============================================================================
class Slave:
    def __init__(self):
        task = self.get_task()
        if not task or task.is_empty():
            self.handle_no_work_given()

        runtime_nano = 0
        return_code = 1

        start = time.perf_counter_ns()
        build_passed = task.execute_build()
        end = time.perf_counter_ns()

        runtime_nano = end - start
        self.print_build_status(task, build_passed, runtime_nano)

        if build_passed and task.has_launch():
            if task.has_build():
                print("Open binary {1}`{2}`{0} with args {1}`{3}`{0}...\n"
                      .format(Color["CLEAR"], Color["PURPLE"],
                              task.tokenized_launch_cmd[0], task.tokenized_launch_cmd[1:]))

            start = time.perf_counter_ns()
            return_code = task.execute_launch()
            end = time.perf_counter_ns()

            runtime_nano = end - start
            self.print_launch_status(return_code, runtime_nano)

        print("Press any key to continue...", end="", flush=True)
        wait_for_keypress()

    def get_task(self) -> Task:
        if not tasks or tasks[0].is_empty():
            return None
        return tasks[0]

    def print_build_status(self, task, build_passed, runtime_nanos):
        if not task.has_build():
            return

        print("\n\n", end="")

        if build_passed:
            print("{2}[BUILD][✓]{0} completed in {1}{3}{0} with {2}no errors{0}!"
                  .format(Color["CLEAR"], Color["YELLOW"], Color["GREEN"], self.get_formatted_time(runtime_nanos)))
        else:
            print("{1}[BUILD][✗]{0} terminated at {2}{3}{0}, there are {1}some errors{0}..."
                  .format(Color["CLEAR"], Color["RED"], Color["YELLOW"], self.get_formatted_time(runtime_nanos)))

    def print_launch_status(self, returnCode, runtimeNano):
        formattedReturnCode = self.get_formatted_return_code(returnCode)
        formattedTime = self.get_formatted_time(runtimeNano)

        print("\n\n\n", end="")
        print("Process returned %s in %s." % (formattedReturnCode, formattedTime))

    def get_formatted_return_code(self, return_code):
        if return_code < 0:
            if platform_name == "Linux":
                return_code += 2 ** 8
            elif platform_name == "Windows":
                return_code += 2 ** 32

        result = "code %d (0x%08X)" % (return_code, return_code)

        color = Color["GREEN"] if return_code == 0 else Color["RED"]
        result = "%s%s%s" % (color, result, Color["CLEAR"])
        return result

    def get_formatted_time(self, nanos: int) -> str:
        micros = nanos // 1000
        millis = micros // 1000
        seconds = millis // 1000
        minutes = seconds // 60

        units = "ms"
        if minutes > 0:
            units = "min"
        elif seconds > 0:
            units = "sec"

        result = "%s%02d:%02d.%03d %s%s" % (
            Color["YELLOW"], minutes, seconds % 60, millis % 1000, units, Color["CLEAR"]
        )
        return result

    def handle_no_work_given(self):
        print("\n%sNo commands were given. There is nothing to do.%s" % (Color["YELLOW"], Color["CLEAR"]))
        print("Press any key to continue...", end="", flush=True)
        wait_for_keypress()
        sys.exit(0)


# =============================================================================
# *                                                                           *
# *                                 CONFIG                                    *
# *                                                                           *
# =============================================================================
def user_config():
    # e.g.
    # add_task(
    #     name="server",
    #     build_cmd="ninja -C build",
    #     launch_cmd="bin/server",
    #     predicate=lambda: subprocess.run(["bash", "-c", "ps aux | grep 'bin/server' | grep -v grep"]).returncode == 1
    # )
    #
    # add_task(
    #     name="client",
    #     launch_cmd="bin/client"
    # )



    pass


def exception_hook(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    print("\n\nLooks like the %sCrappy Build Script (TM)%s ran into an %sERROR%s!!" % (
        Color["YELLOW"], Color["CLEAR"], Color["RED"], Color["CLEAR"]
    ))
    input("Press ENTER to continue...")
    sys.exit(1)


if __name__ == "__main__":
    parse_args()

    if is_master_script:
        master = Master()
        sys.exit(0)

    sys.excepthook = exception_hook
    try:
        slave = Slave()
        sys.exit(0)
    except KeyboardInterrupt:
        print("%s\nProcess terminated forcefully...%s" % (Color["RED"], Color["CLEAR"]))
