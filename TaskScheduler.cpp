#include <iostream>
#include <queue>
#include <vector>
#include <thread>
#include <chrono>
#include <iomanip>

using namespace std;

// Define Task structure and constants
struct Task {
    int taskId;          // Task ID in hexadecimal (0x00 to 0xFF)
    int priority;        // Task priority as hexadecimal value
    int executionTime;   // Execution time in milliseconds (based on hexadecimal values)
    int statusFlag;      // Task status (0x0: Pending, 0x1: Completed)
};

const int FLAG_COMPLETED = 0x1;

// Task queue comparator for priority scheduling
auto compareTasks = [](Task a, Task b) { return a.priority < b.priority; };
priority_queue<Task, vector<Task>, decltype(compareTasks)> taskQueue(compareTasks);

// Function to add a task to the queue interactively
void addTask() {
    int taskId, priority, execTime;
    cout << "Enter Task ID (Hex): ";
    cin >> hex >> taskId;
    cout << "Enter Task Priority (Hex): ";
    cin >> hex >> priority;
    cout << "Enter Task Execution Time (ms): ";
    cin >> execTime;

    taskQueue.push({taskId, priority, execTime, 0x0});
    cout << "Task 0x" << hex << taskId << " added to the queue.\n";
}

// Monitor and display task queue in real-time
void monitorQueue() {
    cout << "\nTask Queue Status:\n";
    cout << "Task ID | Priority | Execution Time | Status Flag\n";

    auto tempQueue = taskQueue;
    while (!tempQueue.empty()) {
        Task task = tempQueue.top();
        tempQueue.pop();
        cout << "0x" << hex << task.taskId << "     | 0x" << task.priority
             << "       | 0x" << task.executionTime << " ms      | 0x"
             << task.statusFlag << endl;
    }
}

// Execute tasks from the queue with monitoring
void executeTasks() {
    while (!taskQueue.empty()) {
        Task task = taskQueue.top();
        taskQueue.pop();

        cout << "\nExecuting Task 0x" << hex << task.taskId
             << " with Priority 0x" << task.priority << "...\n";
        this_thread::sleep_for(chrono::milliseconds(task.executionTime));  // Simulate task execution

        task.statusFlag = FLAG_COMPLETED;
        cout << "Task 0x" << hex << task.taskId << " completed.\n";
    }
}

// Main interactive CLI for task management
int main() {
    int choice;

    while (true) {
        cout << "\nTask Scheduler Menu:\n";
        cout << "1. Add a Task\n";
        cout << "2. Monitor Task Queue\n";
        cout << "3. Execute Tasks\n";
        cout << "4. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch (choice) {
            case 1:
                addTask();
                break;
            case 2:
                monitorQueue();
                break;
            case 3:
                executeTasks();
                break;
            case 4:
                cout << "Exiting...\n";
                return 0;
            default:
                cout << "Invalid choice. Please try again.\n";
        }
    }
}
