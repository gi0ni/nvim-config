# =============================================================================
# *   CRAPPY BUILD SCRIPT                                                     *
# *      v0.0.14                                                              *
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
platformName = platform.system()

pythonRuntime = "python3" if platformName == "Linux" else "python"
selfScriptPath = os.path.realpath(__file__)

platformCommands = {
    "Linux": {
        "wait": ["bash", "-c", "read -n 1"],
        "term": ["tmux", "new-window"]
    },

    "Windows": {
        "wait": ["pwsh", "-NoLogo", "-Command", "$null = [System.Console]::ReadKey()"],
        "term": ["wt", "--"]
    }
}


def WaitForKeypress():
    waitCmd = platformCommands[platformName]["wait"]
    subprocess.run(waitCmd)


def FailGracefully(msg):
    print(msg)
    print("Press any key to continue...", end="", flush=True)
    WaitForKeypress()
    sys.exit(1)


Color = {
    "RED":    "\033[31m",
    "GREEN":  "\033[32m",
    "YELLOW": "\033[33m",
    "CLEAR":  "\033[0m"
}


# TODO: Might be useful to be able to run more than one build/launch command in the same terminal window
class Task:
    def __init__(self, name=None, buildCmd=None, launchCmd=None, predicate=None):
        self.name      = name      if name is not None    else "build"
        self.predicate = predicate if callable(predicate) else None

        self.buildCmd  = buildCmd  if buildCmd  else None
        self.launchCmd = launchCmd if launchCmd else None

        if not isMasterScript:
            self.tokenizedBuildCmd  = shlex.split(self.buildCmd)  if self.buildCmd  else None
            self.tokenizedLaunchCmd = shlex.split(self.launchCmd) if self.launchCmd else None


    def ExecuteBuild(self) -> bool:
        if not self.HasBuild():
            return True

        returnCode = 1
        try:
            returnCode = subprocess.run(self.tokenizedBuildCmd).returncode
        except FileNotFoundError:
            FailGracefully("{0}<BUILD FAILED>{1} Failed to run unknown command {0}`{2}`{1}!".format(Color["RED"], Color["CLEAR"], self.buildCmd))

        buildPassed = (returnCode == 0)
        if buildPassed and self.HasLaunch():
            print("\n\n", end="")
        
        return buildPassed


    def ExecuteLaunch(self) -> int:
        if not self.HasLaunch():
            return 0

        returnCode = 1
        try:
            returnCode = subprocess.run(self.tokenizedLaunchCmd).returncode
        except FileNotFoundError:
            FailGracefully("{0}<LAUNCH FAILED>{1} Executable {0}`{2}`{1} could not be found!".format(Color["RED"], Color["CLEAR"], self.launchCmd))

        return returnCode


    def EvaluatePredicate(self) -> bool:
        return True if self.predicate is None else self.predicate()

    
    def IsEmpty(self) -> bool:
        return not self.HasBuild() and not self.HasLaunch()


    def HasBuild(self):
        return self.buildCmd is not None


    def HasLaunch(self):
        return self.launchCmd is not None


tasks: List[Task] = []
isMasterScript = True

def AddTask(name=None, buildCmd=None, launchCmd=None, predicate=None):
    task = Task(name, buildCmd, launchCmd, predicate)
    tasks.append(task)


# =============================================================================
# *                                                                           *
# *                             ARGUMENT PARSING                              *
# *                                                                           *
# =============================================================================
def ParseArgs():
    global isMasterScript

    argc = len(sys.argv)

    # An element in one of these 2 lists is a string. It represents a command
    # joined together with its args in one single string. Each element will be
    # split into a list of tokens later
    buildCommands = []
    launchCommands = []

    for i in range(1, argc):
        arg = sys.argv[i]

        match arg:
            case "--slave":
                isMasterScript = False

            case "--build":
                pos = FindNextDashArg(sys.argv, i)
                buildCommands = sys.argv[i + 1:pos]
                i = pos - 1

            case "--launch":
                pos = FindNextDashArg(sys.argv, i)
                launchCommands = sys.argv[i + 1:pos]
                i = pos - 1

    InitTasksFromArgs(buildCommands, launchCommands)


def FindNextDashArg(argv: List[str], startIndex):
    argc = len(argv)

    for i in range(startIndex + 1, argc):
        arg = argv[i]
        if arg.find("--") == 0:
            return i

    return argc


def InitTasksFromArgs(buildCommands: List[str], launchCommands: List[str]):
    while buildCommands or launchCommands:
        buildCmd = buildCommands.pop(0) if buildCommands else None
        launchCmd = launchCommands.pop(0) if launchCommands else None

        AddTask(buildCmd=buildCmd, launchCmd=launchCmd)


# =============================================================================
# *                                                                           *
# *                          MASTER SCRIPT INSTANCE                           *
# *                                                                           *
# =============================================================================
class Master:
    def __init__(self):
        self.slaves: List[subprocess.Popen] = []

        UserConfig()

        if not tasks:
            AddTask(name="error")
        
        for task in tasks:
            if task.EvaluatePredicate():
                self.DispatchSlave(task)
        
        self.WaitForSlaves()


    def DispatchSlave(self, task):
        spawnCmd = [pythonRuntime, selfScriptPath, "--slave"]

        if platformName == "Linux":
            spawnCmd = ["-n", task.name] + spawnCmd

        if task.HasBuild():
            spawnCmd += ["--build", task.buildCmd]

        if task.HasLaunch():
            spawnCmd += ["--launch", task.launchCmd]

        spawnCmd = platformCommands[platformName]["term"] + spawnCmd
        self.slaves += [subprocess.Popen(spawnCmd)]

    
    def WaitForSlaves(self):
        for slave in self.slaves:
            slave.wait()


# =============================================================================
# *                                                                           *
# *                           SLAVE SCRIPT INSTANCE                           *
# *                                                                           *
# =============================================================================
class Slave:
    def __init__(self):
        task = self.GetTask()

        runtimeNano = 0
        returnCode = 1

        buildPassed = task.ExecuteBuild()

        if buildPassed and task.HasLaunch():
            start = time.perf_counter_ns()
            returnCode = task.ExecuteLaunch()
            end = time.perf_counter_ns()

            runtimeNano = end - start
            self.PrintLaunchStatus(returnCode, runtimeNano)
        else:
            self.PrintBuildStatus(buildPassed)

        print("Press any key to continue...", end="", flush=True)
        WaitForKeypress()


    def GetTask(self) -> Task:
        if not tasks or tasks[0].IsEmpty():
            print("\n%sNo commands were given. There is nothing to do.%s" % (Color["YELLOW"], Color["CLEAR"]))
            print("Press any key to continue...", end="", flush=True)
            WaitForKeypress()
            sys.exit(0)

        return tasks[0]


    def PrintBuildStatus(self, buildPassed):
        print("\n\n\n", end="")
        if buildPassed:
            print("{0}<BUILD PASSED>{1} Build task completed with {0}no errors{1}. Good work!".format(Color["GREEN"], Color["CLEAR"]))
        else:
            print("{0}<BUILD FAILED>{1} Build task terminated, {0}some errors{1} need fixing...".format(Color["RED"], Color["CLEAR"]))


    def PrintLaunchStatus(self, returnCode, runtimeNano):
        formattedReturnCode = self.GetFormattedReturnCode(returnCode)
        formattedTime = self.GetFormattedTime(runtimeNano)

        print("\n\n\n", end="")
        print("Process returned %s in %s." % (formattedReturnCode, formattedTime))


    def GetFormattedReturnCode(self, returnCode):
        if returnCode < 0:
            if platformName == "Linux":
                returnCode += 2 ** 8
            elif platformName == "Windows":
                returnCode += 2 ** 32

        result = "code %d (0x%08X)" % (returnCode, returnCode)

        color = Color["GREEN"] if returnCode == 0 else Color["RED"]
        result = "%s%s%s" % (color, result, Color["CLEAR"])
        return result


    def GetFormattedTime(self, nanos: int) -> str:
        micros = nanos // 1000
        millis = micros // 1000
        seconds = millis // 1000
        minutes = seconds // 60

        units = "ms"
        if minutes > 0:
            units = "min"
        elif seconds > 0:
            units = "sec"


        result = "%s%02d:%02d.%03d %s%s" % (Color["YELLOW"], minutes, seconds % 60, millis % 1000, units, Color["CLEAR"])
        return result


# =============================================================================
# *                                                                           *
# *                                 CONFIG                                    *
# *                                                                           *
# =============================================================================
def UserConfig():
    # e.g.
    # AddTask(
    #     name="server",
    #     buildCmd="ninja -C build",
    #     launchCmd="bin/server",
    #     predicate=lambda: subprocess.run(["bash", "-c", "ps aux | grep 'bin/server' | grep -v grep"]).returncode == 1
    # )
    #
    # AddTask(
    #     name="client",
    #     launchCmd="bin/client"
    # )



    pass


def ExceptionHook(exc_type, exc_value, tb):
    import traceback
    traceback.print_exception(exc_type, exc_value, tb)
    print("\n\nLooks like the %sCrappy Build Script (TM)%s ran into an %sERROR%s!!" % (Color["YELLOW"], Color["CLEAR"], Color["RED"], Color["CLEAR"]))
    input("Press ENTER to continue...")
    sys.exit(1)


if __name__ == "__main__":
    ParseArgs()

    if isMasterScript:
        master = Master()
        sys.exit(0)

    sys.excepthook = ExceptionHook
    try:
        slave = Slave()
        sys.exit(0)
    except KeyboardInterrupt:
        print("%s\nProcess terminated forcefully...%s" % (Color["RED"], Color["CLEAR"]))
