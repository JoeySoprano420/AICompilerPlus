#!/bin/bash

echo "Starting installation of dependencies for AI Compiler +..."

# Update and install basic packages
sudo apt-get update
sudo apt-get install -y build-essential cmake libboost-all-dev libsqlite3-dev wget

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install flask flask-socketio requests pandas numpy matplotlib scikit-learn torch joblib pyinstaller pytest black

# Install C++ libraries
echo "Installing C++ libraries: Boost, nlohmann-json, gRPC, and Taskflow..."

# Install nlohmann-json (via package manager)
sudo apt-get install -y nlohmann-json3-dev

# Install gRPC (from source)
git clone --recurse-submodules -b v1.56.0 https://github.com/grpc/grpc
cd grpc
mkdir -p cmake/build
cd cmake/build
cmake ../..
make -j$(nproc)
sudo make install
cd ../../../

# Install fmt (C++ formatting library)
sudo apt-get install -y libfmt-dev

# Install Taskflow (from source)
git clone https://github.com/taskflow/taskflow.git
cd taskflow
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
cd ../../

echo "Installing optional development tools..."
pip install clang-format

echo "All dependencies have been installed successfully!"
