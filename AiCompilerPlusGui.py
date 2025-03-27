import os
import subprocess
import threading
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from tkinter.filedialog import askopenfilename

# --- VACU Theme Colors ---
BACKGROUND_COLOR = "#2C1E4D"  # Deep Violet
FOREGROUND_COLOR = "#FFD700"  # Brass Gold
BUTTON_COLOR = "#4B2F6A"      # Darker Violet
HIGHLIGHT_COLOR = "#B86FC6"   # Violet Aura Accent
TEXT_COLOR = "#FFFFFF"        # White

# Create main GUI window
class AICompilerGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("AI Compiler+ System - VACU Theme")
        self.geometry("800x600")
        self.configure(bg=BACKGROUND_COLOR)

        self.create_widgets()

    def create_widgets(self):
        # Title Label
        title_label = ttk.Label(
            self, text="AI Compiler+ Control Panel", font=("Helvetica", 18, "bold"),
            foreground=FOREGROUND_COLOR, background=BACKGROUND_COLOR
        )
        title_label.pack(pady=10)

        # Console Output Box
        self.console_output = scrolledtext.ScrolledText(self, height=20, width=100, bg="#1A0B29", fg=TEXT_COLOR)
        self.console_output.pack(pady=10)

        # Button Frame
        button_frame = ttk.Frame(self)
        button_frame.pack(pady=10)

        # Build All Button
        build_button = ttk.Button(button_frame, text="Build System", command=self.build_system)
        build_button.pack(side=tk.LEFT, padx=5)

        # Clean Button
        clean_button = ttk.Button(button_frame, text="Clean Build", command=self.clean_system)
        clean_button.pack(side=tk.LEFT, padx=5)

        # View Logs Button
        log_button = ttk.Button(button_frame, text="View Logs", command=self.view_logs)
        log_button.pack(side=tk.LEFT, padx=5)

        # Run AI Analysis Button
        ai_analysis_button = ttk.Button(button_frame, text="Run AI Analysis", command=self.run_ai_analysis)
        ai_analysis_button.pack(side=tk.LEFT, padx=5)

        # Task Scheduler Button
        task_scheduler_button = ttk.Button(button_frame, text="Launch Task Scheduler", command=self.launch_task_scheduler)
        task_scheduler_button.pack(side=tk.LEFT, padx=5)

        # Style the buttons (VACU Theme)
        style = ttk.Style()
        style.configure("TButton", font=("Helvetica", 12), background=BUTTON_COLOR, foreground=TEXT_COLOR)
        style.map("TButton", background=[("active", HIGHLIGHT_COLOR)])

    def build_system(self):
        self.log_to_console("Starting build process...")
        self.run_command("msbuild AI_Compiler_Plus.msbuild /t:BuildAll")

    def clean_system(self):
        self.log_to_console("Cleaning build artifacts...")
        self.run_command("msbuild AI_Compiler_Plus.msbuild /t:Clean")

    def view_logs(self):
        log_file_path = os.path.join(os.getcwd(), "logs", "build_log.log")
        if os.path.exists(log_file_path):
            with open(log_file_path, "r") as log_file:
                logs = log_file.read()
            self.display_text_in_window("Build Logs", logs)
        else:
            messagebox.showerror("Error", "No log file found.")

    def run_ai_analysis(self):
        self.log_to_console("Running AI-driven analysis on repository content...")
        self.run_command("python ai_analysis.py")

    def launch_task_scheduler(self):
        self.log_to_console("Launching C++ Task Scheduler...")
        self.run_command("AI_Compiler_Plus\\src\\build\\task_scheduler.exe")

    def run_command(self, command):
        def threaded_run():
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            for line in iter(process.stdout.readline, ""):
                self.log_to_console(line)
            process.stdout.close()
            process.wait()

        threading.Thread(target=threaded_run).start()

    def log_to_console(self, message):
        self.console_output.insert(tk.END, f"{message}\n")
        self.console_output.see(tk.END)

    def display_text_in_window(self, title, text_content):
        text_window = tk.Toplevel(self)
        text_window.title(title)
        text_window.geometry("600x400")
        text_window.configure(bg=BACKGROUND_COLOR)

        text_box = scrolledtext.ScrolledText(text_window, wrap=tk.WORD, bg="#1A0B29", fg=TEXT_COLOR)
        text_box.insert(tk.END, text_content)
        text_box.pack(expand=True, fill=tk.BOTH)

# --- Run the GUI ---
if __name__ == "__main__":
    app = AICompilerGUI()
    app.mainloop()
