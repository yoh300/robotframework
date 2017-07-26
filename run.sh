#!/bin/bash
set -e
echo "Start Robot"
# Set the defaults
DEFAULT_LOG_LEVEL="INFO" # Available levels: TRACE, DEBUG, INFO (default), WARN, NONE (no logging)
DEFAULT_RES="1280x1024x24"
DEFAULT_DISPLAY=":99"
DEFAULT_ROBOT_TESTS="/test/"
DEFAULT_ROBOT_PARAM=""
DEFAULT_GDRIVE="false"

# Use default if none specified as env var
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
RES=${RES:-$DEFAULT_RES}
DISPLAY=${DISPLAY:-$DEFAULT_DISPLAY}
ROBOT_TESTS=${ROBOT_TESTS:-$DEFAULT_ROBOT_TESTS}
ROBOT_PARAM=${ROBOT_TESTS:-$DEFAULT_ROBOT_PARAM}
GDRIVE=${GDRIVE:-$DEFAULT_GDRIVE}

if [[ "${ROBOT_TESTS}" == "false" ]]; then
  echo "Error: Please specify the robot test or directory as env var ROBOT_TESTS"
  exit 1
fi

# Start Xvfb
echo -e "Starting Xvfb on display ${DISPLAY} with res ${RES}"
Xvfb ${DISPLAY} -ac -screen 0 ${RES} +extension RANDR &
export DISPLAY=${DISPLAY}
sleep 10

# Execute tests
echo -e "Executing robot tests at log level ${LOG_LEVEL}"
pybot --loglevel ${LOG_LEVEL} --outputdir ${ROBOT_TESTS} ${ROBOT_TESTS}
#pybot --loglevel ${LOG_LEVEL} ${ROBOT_TESTS}
echo -e "End Robot"

if [[ "${GDRIVE}" == "false" ]]; then
  echo -e "Warning: Do not specific google drive id, do not upload."
  exit 0
fi
echo -e "Start convert result to excel and upload"
python /robot2docs/robot2excel.py ${ROBOT_TESTS} ${GDRIVE}

echo -e "Stop Xvfb"
kill -9 $(pgrep Xvfb)
