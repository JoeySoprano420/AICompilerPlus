import networkx as nx
import matplotlib.pyplot as plt

class ExtendedAI(AdvancedAI):
    def analyze_repository(self, repo_path):
        """
        Analyzes the code in the repository to build a function call graph and other code metrics.
        """
        function_graph = nx.DiGraph()

        # Walk through the repository files and parse code
        for root, _, files in os.walk(repo_path):
            for file in files:
                if file.endswith(('.py', '.js', '.cpp', '.java')):  # Add more extensions as needed
                    file_path = os.path.join(root, file)
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        self.parse_code_for_functions(file, content, function_graph)
        
        # Visualize the function call graph
        self.visualize_function_graph(function_graph)

    def parse_code_for_functions(self, file_name, content, function_graph):
        """
        A simple parser to detect function definitions in the code and build a call graph.
        """
        function_pattern = re.compile(r"def (\w+)\(")  # Python-style function definition
        function_matches = function_pattern.findall(content)

        # Create graph edges based on function calls
        for function in function_matches:
            function_graph.add_node(function)
            # This part can be expanded to capture more complex relationships

    def visualize_function_graph(self, function_graph):
        """
        Visualizes the function call graph using NetworkX and Matplotlib.
        """
        plt.figure(figsize=(10, 8))
        pos = nx.spring_layout(function_graph)
        nx.draw(function_graph, pos, with_labels=True, node_color='skyblue', node_size=3000, font_size=10, font_weight='bold')
        plt.title("Function Call Graph")
        plt.show()

    def analyze_and_visualize(self, repo_url):
        """
        Clone repository and analyze it for function relationships and code complexity.
        """
        base_dir = "./cloned_repos"
        if not os.path.exists(base_dir):
            os.makedirs(base_dir)

        try:
            repo_name = repo_url.split("/")[-1].replace(".git", "")
            repo_path = os.path.join(base_dir, repo_name)

            if not os.path.exists(repo_path):
                print(f"Cloning {repo_url}...")
                git.Repo.clone_from(repo_url, repo_path)
            else:
                print(f"Repository {repo_name} already cloned. Pulling latest changes...")
                repo = git.Repo(repo_path)
                repo.remotes.origin.pull()

            self.analyze_repository(repo_path)  # Perform repository analysis

        except Exception as e:
            print(f"Failed to clone or process {repo_url}: {e}")
