import socket

try:
    # Example socket connection
    with socket.create_connection(('localhost', 5000)) as s:
        s.sendall(b'Hello, Server!')
except ConnectionRefusedError as e:
    print(f"Connection failed: {e}")
