import shlex
import subprocess

from crappy.utils import fail_gracefully, Color


# TODO: Might be useful to run multiple launch commmands from a slave
class Task:
    def __init__(self, name=None, build_cmd=None, launch_cmd=None, predicate=None, blocking_on=None):
        self.name = name if name is not None else "build"
        self.predicate = predicate if callable(predicate) else None

        self.build_cmd = build_cmd if build_cmd else None
        self.launch_cmd = launch_cmd if launch_cmd else None

        self.tokenized_build_cmd = shlex.split(self.build_cmd) if self.build_cmd else None
        self.tokenized_launch_cmd = shlex.split(self.launch_cmd) if self.launch_cmd else None

        self.blocking_on = blocking_on

    def execute_build(self) -> bool:
        if not self.has_build():
            return True

        return_code = 1
        try:
            return_code = subprocess.run(self.tokenized_build_cmd).returncode
        except FileNotFoundError:
            fail_gracefully(
                "{1}[BUILD][✗]{0} failed to run unknown command {2}`{3}`{0}!"
                .format(Color["CLEAR"], Color["RED"], Color["PURPLE"], self.build_cmd)
            )

        build_passed = (return_code == 0)
        return build_passed

    def execute_launch(self) -> int:
        if not self.has_launch():
            return 0

        return_code = 1
        try:
            return_code = subprocess.run(self.tokenized_launch_cmd).returncode
        except FileNotFoundError:
            fail_gracefully(
                "{1}[BUILD][✗]{0} failed to find binary {2}`{3}`{0}!"
                .format(Color["CLEAR"], Color["RED"], Color["PURPLE"], self.launch_cmd.strip())
            )

        return return_code

    def evaluate_predicate(self) -> bool:
        return True if self.predicate is None else self.predicate()

    def is_empty(self) -> bool:
        return not (self.has_build() or self.has_launch())

    def has_build(self) -> bool:
        return self.build_cmd is not None

    def has_launch(self) -> bool:
        return self.launch_cmd is not None

    def is_blocking(self) -> bool:
        return self.blocking_on is not None
