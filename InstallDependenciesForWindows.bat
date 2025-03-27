@echo off

echo Installing dependencies for AI Compiler +...
choco install -y cmake boost-msvc sqlite3

:: Install Python dependencies
echo Installing Python packages...
python -m pip install --upgrade pip
pip install flask flask-socketio requests pandas numpy matplotlib scikit-learn torch joblib pyinstaller pytest black

:: Install gRPC and nlohmann-json (Windows users may need additional build tools)
echo Cloning and installing gRPC...
git clone --recurse-submodules -b v1.56.0 https://github.com/grpc/grpc
cd grpc
mkdir cmake\build
cd cmake\build
cmake ..\..
msbuild grpc.sln /p:Configuration=Release
cd ..\..\..

:: Install fmt
echo Installing fmt library...
choco install -y fmt

:: Install Taskflow (C++ Task Scheduling Library)
echo Cloning and installing Taskflow...
git clone https://github.com/taskflow/taskflow.git
cd taskflow
mkdir build
cd build
cmake ..
cmake --build . --config Release
cd ..\..

echo Installation complete! All dependencies have been installed.
pause
