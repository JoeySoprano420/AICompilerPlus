import json
import socket

# AI-related functions (from previous Python code)
def analyze_repository():
    # Sample task prioritization for demonstration
    priorities = {"task_1": {"priority": 1, "executionTime": 500},
                  "task_2": {"priority": 2, "executionTime": 300}}
    return priorities

def send_task_priority(priorities):
    host = '127.0.0.1'
    port = 65432

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        data = json.dumps(priorities)
        s.sendall(data.encode())

def analyze_and_send():
    priorities = analyze_repository()
    send_task_priority(priorities)

if __name__ == "__main__":
    analyze_and_send()
