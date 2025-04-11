#simple tcp client
import socket

clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clientsocket.connect(('localhost', 2000))
#clientsocket.send('hello')
clientsocket.sendall(b"Hello, world")
data = clientsocket.recv(1024)

print(f"Received {data!r}")