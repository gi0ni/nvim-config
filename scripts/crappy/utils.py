import sys
import subprocess


Color = {
    "RED": "\033[31m",
    "GREEN": "\033[32m",
    "YELLOW": "\033[33m",
    "PURPLE": "\033[35m",
    "CLEAR": "\033[0m"
}


def wait_for_keypress():
    from crappy.config import Config
    wait_cmd = Config.platform_commands[Config.platform_name]["wait"]
    subprocess.run(wait_cmd)


def fail_gracefully(msg):
    print(msg)
    print("Press any key to continue...", end="", flush=True)
    wait_for_keypress()
    sys.exit(1)


def exception_hook(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    print(
        "\n\n{2}[CRAPPY][]{0} Looks like the {2}`Crappy Build Script (TM)`{0} ran into an {1}ERROR{0}!!"
        .format(Color["CLEAR"], Color["RED"], Color["YELLOW"])
    )
    input("Press ENTER to continue...")
    sys.exit(1)
