from enum import Enum


class MasterSlaveEvent(Enum):
    SLAVE_BUILD_SUCCESS = 1
    SLAVE_BUILD_FAILURE = 2
