#!/bin/bash

# --- CONFIGURATION VARIABLES ---
PROJECT_NAME="AI Compiler +"
LOG_FILE="logs/system_load.log"
PYTHON_VENV_DIR="env"
EXECUTABLE_PATH="dist/ai_compiler_plus"
CPLUSPLUS_BINARY="AI_Compiler_Plus/src/build/main_binary"
REQUIRED_PORT=5000

echo "=========================================" | tee -a $LOG_FILE
echo "Starting $PROJECT_NAME - Advanced Load Script" | tee -a $LOG_FILE
echo "Timestamp: $(date)" | tee -a $LOG_FILE
echo "=========================================" | tee -a $LOG_FILE

# --- SYSTEM CHECKS ---
echo "Performing system checks..." | tee -a $LOG_FILE

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo) to avoid permission issues." | tee -a $LOG_FILE
  exit 1
fi

# Check for essential dependencies
echo "Checking for essential dependencies..." | tee -a $LOG_FILE
command -v cmake >/dev/null 2>&1 || { echo "Error: CMake is not installed. Install it and try again." | tee -a $LOG_FILE; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: Python3 is not installed." | tee -a $LOG_FILE; exit 1; }
command -v g++ >/dev/null 2>&1 || { echo "Error: g++ compiler is not installed." | tee -a $LOG_FILE; exit 1; }

# Check if required ports are in use
echo "Checking if port $REQUIRED_PORT is already in use..." | tee -a $LOG_FILE
if lsof -i:$REQUIRED_PORT >/dev/null; then
  echo "Error: Port $REQUIRED_PORT is in use. Please free it and restart." | tee -a $LOG_FILE
  exit 1
fi

# --- ENVIRONMENT SETUP ---
echo "Setting up Python virtual environment..." | tee -a $LOG_FILE
if [ ! -d "$PYTHON_VENV_DIR" ]; then
  echo "Creating virtual environment..." | tee -a $LOG_FILE
  python3 -m venv $PYTHON_VENV_DIR
fi
source $PYTHON_VENV_DIR/bin/activate

echo "Installing Python dependencies..." | tee -a $LOG_FILE
pip install --upgrade pip
pip install -r requirements.txt

echo "Setting up C++ binaries..." | tee -a $LOG_FILE
if [ ! -f "$CPLUSPLUS_BINARY" ]; then
  echo "Compiling C++ project since binary not found..." | tee -a $LOG_FILE
  cd AI_Compiler_Plus/src/build
  cmake ..
  make -j$(nproc)
  cd ../../../..
else
  echo "C++ binary found. Skipping compilation." | tee -a $LOG_FILE
fi

# --- STARTING SYSTEM COMPONENTS ---
echo "Launching AI Compiler + system components..." | tee -a $LOG_FILE

echo "1. Starting Python server-based AI module..." | tee -a $LOG_FILE
if [ -f "$EXECUTABLE_PATH" ]; then
  nohup $EXECUTABLE_PATH --port $REQUIRED_PORT &>> $LOG_FILE &
else
  echo "Error: Python executable not found. Please ensure the project is built correctly." | tee -a $LOG_FILE
  exit 1
fi

echo "2. Launching C++ task scheduler..." | tee -a $LOG_FILE
nohup $CPLUSPLUS_BINARY &>> $LOG_FILE &

# --- SYSTEM STATUS MONITORING ---
echo "Monitoring system status..." | tee -a $LOG_FILE
sleep 5

if lsof -i:$REQUIRED_PORT >/dev/null; then
  echo "Python AI module is running on port $REQUIRED_PORT." | tee -a $LOG_FILE
else
  echo "Error: Python AI module failed to start." | tee -a $LOG_FILE
fi

echo "Checking for running C++ task scheduler..."
if pgrep -f $CPLUSPLUS_BINARY >/dev/null; then
  echo "C++ task scheduler is running successfully." | tee -a $LOG_FILE
else
  echo "Error: C++ task scheduler failed to start." | tee -a $LOG_FILE
fi

# --- LOGGING ---
echo "Logging process IDs..." | tee -a $LOG_FILE
echo "Python AI module PID: $(pgrep -f $EXECUTABLE_PATH)" | tee -a $LOG_FILE
echo "C++ Task Scheduler PID: $(pgrep -f $CPLUSPLUS_BINARY)" | tee -a $LOG_FILE

# --- FINAL MESSAGE ---
echo "=========================================" | tee -a $LOG_FILE
echo "$PROJECT_NAME has been successfully loaded!" | tee -a $LOG_FILE
echo "To stop the processes, use 'kill <PID>' for the respective components." | tee -a $LOG_FILE
echo "=========================================" | tee -a $LOG_FILE
