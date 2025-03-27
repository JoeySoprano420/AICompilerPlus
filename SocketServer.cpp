#include <iostream>
#include <fstream>
#include <queue>
#include <string>
#include <thread>
#include <chrono>
#include <iomanip>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <json/json.h>

using namespace std;

struct Task {
    string taskId;
    int priority;
    int executionTime;
    bool completed;
};

queue<Task> taskQueue;

void executeTask(const Task& task) {
    cout << "Executing Task: " << task.taskId << " with Priority: " << task.priority << endl;
    this_thread::sleep_for(chrono::milliseconds(task.executionTime));
    cout << "Task " << task.taskId << " completed." << endl;
}

void processIncomingData(int clientSocket) {
    char buffer[1024] = {0};
    read(clientSocket, buffer, sizeof(buffer));
    string jsonData(buffer);

    // Parse JSON data received from Python
    Json::CharReaderBuilder reader;
    Json::Value root;
    istringstream s(jsonData);
    string errs;

    if (!Json::parseFromStream(reader, s, &root, &errs)) {
        cerr << "Error parsing JSON: " << errs << endl;
        return;
    }

    // Create tasks from the received data
    for (const auto& key : root.getMemberNames()) {
        Task task;
        task.taskId = key;
        task.priority = root[key]["priority"].asInt();
        task.executionTime = root[key]["executionTime"].asInt();
        task.completed = false;
        taskQueue.push(task);
    }
    
    close(clientSocket);
}

int main() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(65432);

    if (bind(server_fd, (struct sockaddr*)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    while (true) {
        cout << "Waiting for connection..." << endl;
        if ((new_socket = accept(server_fd, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0) {
            perror("Accept failed");
            exit(EXIT_FAILURE);
        }

        processIncomingData(new_socket);

        // Execute tasks based on received priority
        while (!taskQueue.empty()) {
            Task task = taskQueue.front();
            taskQueue.pop();
            executeTask(task);
        }
    }

    return 0;
}
