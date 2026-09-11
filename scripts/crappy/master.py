import os
import sys
import socket
import subprocess
from typing import List

from crappy.config import Config
from crappy.task import Task
from crappy.event import MasterSlaveEvent


class Master:
    def __init__(self, config: Config):
        self.listen_socket: socket.socket = None
        self.port: int = None

        self.slave_pids: List[subprocess.Popen] = []
        self.slave_sockets: List[socket.socket] = []
        self.slave_statuses: List[int] = []

        self.config: Config = config

    def driver(self):
        self.start_server()

        if not self.config.task_queue:
            self.config.task_queue.append(Task(name="error"))

        for task in self.config.task_queue:
            if task.evaluate_predicate():
                self.dispatch_slave(task)

                if task.is_blocking():
                    self.wait_for_event(task.blocking_on)

        self.run_user_commands()
        self.stop_server()
        self.wait_for_slaves()

    def run_user_commands(self):
        for command in self.config.command_queue:
            os.system(command)

    def start_server(self):
        self.listen_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.listen_socket.bind(("localhost", 0))
        self.port = self.listen_socket.getsockname()[1]
        self.listen_socket.listen(8)
        self.listen_socket.settimeout(5)

    def connect_to_slave(self):
        sock = None
        try:
            sock, addr = self.listen_socket.accept()
        except TimeoutError:
            pass
        self.slave_sockets += [sock]
        self.slave_statuses += [0]

    def wait_for_event(self, event: MasterSlaveEvent):
        if self.slave_sockets is None:
            return

        while self.slave_statuses[-1] != event.value:
            data = bytearray(0)
            while len(data) < 4:
                try:
                    result = self.slave_sockets[-1].recv(4 - len(data))
                    if not result:
                        sys.exit(1)
                    data += result
                except OSError:
                    sys.exit(1)
            self.slave_statuses[-1] = int.from_bytes(data)

    def stop_server(self):
        for sock in self.slave_sockets:
            if sock:
                sock.close()
        self.listen_socket.close()

    def dispatch_slave(self, task):
        spawn_cmd = [Config.python_runtime, self.config.self_script_path, "--slave"]

        if Config.platform_name == "Linux":
            spawn_cmd = ["-n", task.name] + spawn_cmd

        if task.has_build():
            spawn_cmd += ["--build", task.build_cmd]

        if task.has_launch() and not self.config.launch_disabled:
            spawn_cmd += ["--launch", task.launch_cmd]

        spawn_cmd += ["--master-port", str(self.port)]

        spawn_cmd = Config.platform_commands[Config.platform_name]["term"] + spawn_cmd
        print(spawn_cmd)
        self.slave_pids += [subprocess.Popen(spawn_cmd)]
        self.connect_to_slave()

    def wait_for_slaves(self):
        for slave in self.slave_pids:
            slave.wait()
