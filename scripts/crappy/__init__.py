from crappy.config import Config
from crappy.task import Task
from crappy.event import MasterSlaveEvent
from crappy.master import Master
from crappy.slave import Slave


def driver(config: Config):
    import sys
    from crappy.utils import Color, exception_hook
    from crappy.args import parse_args

    parse_args(config)

    if config.is_master_script:
        for task in config.task_queue:
            if config.launch_disabled:
                task.launch_cmd = None
                task.tokenized_launch_cmd = None

            if task.is_blocking():
                config.sockets_enabled = True  # Enables sockets on Master

        master = Master(config)
        master.driver()
        sys.exit(0)

    sys.excepthook = exception_hook

    try:
        slave = Slave(config)
        slave.driver()
        sys.exit(0)
    except KeyboardInterrupt:
        print(
            "\n{1}[BUILD][✗] process terminated forcefully...{0}"
            .format(Color["CLEAR"], Color["RED"])
        )
