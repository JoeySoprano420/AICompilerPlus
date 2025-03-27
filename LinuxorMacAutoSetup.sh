#!/bin/bash

echo "Starting complete setup for AI Compiler +..."

# --- SYSTEM UPDATE ---
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# --- INSTALL DEPENDENCIES ---
echo "Installing required system dependencies..."

# Installing development tools and essential libraries
sudo apt-get install -y build-essential cmake libboost-all-dev libsqlite3-dev libfmt-dev nlohmann-json3-dev wget git

# --- INSTALL PYTHON DEPENDENCIES ---
echo "Setting up Python environment and dependencies..."
python3 -m venv env  # Creating a virtual environment
source env/bin/activate

# Upgrading pip and installing Python packages
pip install --upgrade pip
pip install flask flask-socketio requests pandas numpy matplotlib scikit-learn torch joblib pyinstaller pytest black

# --- INSTALL C++ LIBRARIES ---
echo "Cloning and installing additional C++ libraries (Taskflow, gRPC)..."

# Install Taskflow (Task Scheduling Library)
git clone https://github.com/taskflow/taskflow.git
cd taskflow
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
cd ../..

# Install gRPC (gRPC & protobuf setup)
git clone --recurse-submodules -b v1.56.0 https://github.com/grpc/grpc
cd grpc
mkdir -p cmake/build
cd cmake/build
cmake ../..
make -j$(nproc)
sudo make install
cd ../../../

# --- PROJECT-SPECIFIC SETUP ---
echo "Setting up AI Compiler + project structure..."

# Create directories for the project
mkdir -p AI_Compiler_Plus/{src,build,logs}

# Move project files to the right places (dummy example)
mv main.cpp AI_Compiler_Plus/src/
mv app.py AI_Compiler_Plus/src/
mv CMakeLists.txt AI_Compiler_Plus/src/

# --- COMPILE C++ COMPONENT ---
echo "Compiling the C++ project with CMake..."
cd AI_Compiler_Plus/src
mkdir build
cd build
cmake ..
make -j$(nproc)

# --- CREATE EXECUTABLE ---
echo "Bundling Python and C++ components into a single executable..."
cd ../../..
pyinstaller --onefile AI_Compiler_Plus/src/app.py --name ai_compiler_plus

# --- FINAL CLEANUP AND INTEGRATION ---
echo "Cleaning up temporary files and finalizing installation..."
rm -rf build grpc taskflow

# --- PROJECT COMPLETE ---
echo "AI Compiler + setup is complete!"
echo "Run the executable: ./dist/ai_compiler_plus"
