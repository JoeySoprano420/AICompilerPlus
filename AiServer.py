import socket
import json
import networkx as nx
import matplotlib.pyplot as plt
import os
import re
import git
from queue import Queue

# Socket settings
HOST = '127.0.0.1'
PORT = 65432

class ExtendedAI:
    def __init__(self):
        self.task_priority_queue = Queue()

    def analyze_repository(self, repo_path):
        # Analyze the repository and extract function call graphs
        function_graph = nx.DiGraph()

        for root, _, files in os.walk(repo_path):
            for file in files:
                if file.endswith('.py'):
                    file_path = os.path.join(root, file)
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        self.parse_code_for_functions(file, content, function_graph)

        return function_graph

    def parse_code_for_functions(self, file_name, content, function_graph):
        function_pattern = re.compile(r"def (\w+)\(")
        function_matches = function_pattern.findall(content)

        for function in function_matches:
            function_graph.add_node(function)

    def prioritize_tasks_based_on_analysis(self, function_graph):
        # Here we can use function call data to assign task priorities
        # For simplicity, prioritize tasks based on number of function calls
        priorities = {}
        for function in function_graph.nodes:
            priorities[function] = len(function_graph.neighbors(function))

        # Send tasks to the task scheduler (C++) over socket
        return priorities

    def send_task_priority(self, priorities):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((HOST, PORT))
            data = json.dumps(priorities)
            s.sendall(data.encode())
            s.close()

    def analyze_and_send(self, repo_url):
        base_dir = "./cloned_repos"
        if not os.path.exists(base_dir):
            os.makedirs(base_dir)

        repo_name = repo_url.split("/")[-1].replace(".git", "")
        repo_path = os.path.join(base_dir, repo_name)

        if not os.path.exists(repo_path):
            print(f"Cloning {repo_url}...")
            git.Repo.clone_from(repo_url, repo_path)
        else:
            print(f"Repository {repo_name} already cloned. Pulling latest changes...")
            repo = git.Repo(repo_path)
            repo.remotes.origin.pull()

        function_graph = self.analyze_repository(repo_path)
        task_priorities = self.prioritize_tasks_based_on_analysis(function_graph)
        self.send_task_priority(task_priorities)

# Main method
if __name__ == "__main__":
    ai_system = ExtendedAI()
    ai_system.analyze_and_send("https://github.com/your/repository.git")
