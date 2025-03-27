@echo off

echo Starting complete setup for AI Compiler +...

:: --- INSTALL SYSTEM DEPENDENCIES ---
echo Installing Chocolatey packages (CMake, Boost, SQLite, and fmt)...
choco install -y cmake boost-msvc sqlite3 fmt git

:: --- PYTHON SETUP ---
echo Setting up Python environment and installing packages...
python -m venv env
call env\Scripts\activate

pip install --upgrade pip
pip install flask flask-socketio requests pandas numpy matplotlib scikit-learn torch joblib pyinstaller pytest black

:: --- INSTALL C++ LIBRARIES ---
echo Cloning and installing Taskflow and gRPC...

:: Install Taskflow
git clone https://github.com/taskflow/taskflow.git
cd taskflow
mkdir build
cd build
cmake ..
cmake --build . --config Release
cd ..\..

:: Install gRPC
git clone --recurse-submodules -b v1.56.0 https://github.com/grpc/grpc
cd grpc
mkdir cmake\build
cd cmake\build
cmake ..\..
msbuild grpc.sln /p:Configuration=Release
cd ..\..

:: --- PROJECT-SPECIFIC SETUP ---
echo Setting up AI Compiler + project directories...
mkdir AI_Compiler_Plus\src
mkdir AI_Compiler_Plus\build
mkdir AI_Compiler_Plus\logs

move main.cpp AI_Compiler_Plus\src\
move app.py AI_Compiler_Plus\src\
move CMakeLists.txt AI_Compiler_Plus\src\

:: --- COMPILE C++ PROJECT ---
echo Compiling C++ project using CMake...
cd AI_Compiler_Plus\src
mkdir build
cd build
cmake ..
cmake --build . --config Release
cd ..\..

:: --- CREATE EXECUTABLE ---
echo Bundling Python and C++ components into a single executable...
pyinstaller --onefile AI_Compiler_Plus\src\app.py --name ai_compiler_plus.exe

:: --- FINAL CLEANUP ---
echo Cleaning up and finalizing installation...
rmdir /s /q taskflow grpc

:: --- SETUP COMPLETE ---
echo AI Compiler + setup complete!
echo Run the executable: .\dist\ai_compiler_plus.exe
pause
