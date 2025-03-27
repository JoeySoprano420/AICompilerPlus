#include <iostream>
#include <cstdlib>

void run_python_executable() {
    std::string command = "./python_ai";  // Path to the bundled Python executable
    system(command.c_str());
}

int main() {
    std::cout << "Starting C++ task scheduler..." << std::endl;

    run_python_executable();

    return 0;
}
