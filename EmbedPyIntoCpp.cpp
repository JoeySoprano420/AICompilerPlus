#include <Python.h>
#include <iostream>
#include <queue>
#include <string>
#include <unistd.h>

// Function to execute Python code from C++
void run_python_script(const std::string &script_name) {
    FILE* fp = fopen(script_name.c_str(), "r");
    if (fp == nullptr) {
        std::cerr << "Error opening Python script: " << script_name << std::endl;
        return;
    }
    PyRun_SimpleFile(fp, script_name.c_str());
    fclose(fp);
}

void start_python_interpreter() {
    // Initialize the Python interpreter
    Py_Initialize();

    // Execute the Python script that contains AI analysis logic
    run_python_script("python_ai.py");

    // Finalize the Python interpreter
    Py_Finalize();
}

int main() {
    std::cout << "Starting C++ task scheduler and Python integration..." << std::endl;

    start_python_interpreter();

    return 0;
}
