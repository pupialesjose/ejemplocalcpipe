from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer

PORT = 8080

with TCPServer(("", PORT), SimpleHTTPRequestHandler) as httpd:
    print("Servidor en http://localhost:8080")
    httpd.serve_forever()
