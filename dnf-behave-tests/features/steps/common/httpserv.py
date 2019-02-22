import os
import http.server
import socketserver
from multiprocessing import Manager, Process


socketserver.TCPServer.allow_reuse_address = True


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        """Process a GET request."""
        req = {'path': self.path, 'headers': self.headers}
        self.server._requests.append(req)
        super().do_GET()

    def log_request(self, *args, **kwargs):
        # Don't pollute the output with log messages
        pass


def worker(port, requests, path):
    os.chdir(path)
    with socketserver.TCPServer(('', port), Handler) as s:
        s._requests = requests
        s.serve_forever()


class HTTPServer(object):
    """A very simple HTTP server capturing incoming GET requests."""

    def __init__(self, path, port=8000):
        manager = Manager()
        self._requests = manager.list()
        self._path = path
        self._port = port

    def serve(self):
        """Start the server in a separate subprocess."""
        proc = Process(target=worker,
                       args=(self._port, self._requests, self._path))
        proc.start()
        self._proc = proc

    def shutdown(self):
        """Terminate the server."""
        self._proc.terminate()

    @property
    def requests(self):
        """Return a list of GET requests received by this server.

        A request here is a dictionary with the keys "path" and "headers".
        """
        return self._requests
