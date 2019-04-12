# -*- coding: utf-8 -*-

import contextlib
import multiprocessing
import os
import socket
import sys

PY3 = sys.version_info.major >= 3
if PY3:
    from http.server import SimpleHTTPRequestHandler
    from socketserver import TCPServer
else:
    from SimpleHTTPServer import SimpleHTTPRequestHandler
    from SocketServer import TCPServer


class NoLogHttpHandler(SimpleHTTPRequestHandler):
    def log_request(self, *args, **kwargs):
        pass

class HttpServerContext(object):
    """
    This object manages group of simple http servers. Each of them is run in 
    separate process and serves configured directory.

    Usage:
    ctx = HttpServerContext()
    ctx.start_new_server('/path/to/directory/supposed/to/be/served')
    ctx.start_new_server('/path/to/other_directory/supposed/to/be/served')
    do_stuff()
    ctx.shutdown()
    """

    @staticmethod
    def http_server(address, path):
        os.chdir(path)
        httpd = TCPServer(address, NoLogHttpHandler)
        httpd.serve_forever()

    @staticmethod
    def _get_free_socket(host='127.0.0.1'):
        with contextlib.closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((host, 0))
            return (host, s.getsockname()[1])

    def __init__(self):
        # mapping path -> (address, server process)
        self.servers = dict()

    def start_new_server(self, path):
        """
        Start a new http server for serving files from "path" directory.
        Returns (host, port) tupple of new running server.
        """
        if path in self.servers:
            return self.get_address(path)
        address = self._get_free_socket()
        process = multiprocessing.Process(target=self.http_server, args=(address, path))
        process.start()
        self.servers[path] = (address, process)
        return address

    def get_address(self, path):
        """
        Get address of http server bound to "path" directory
        """
        if path in self.servers:
            return self.servers[path][0]
        return None

    def shutdown(self):
        """
        Terminate all running servers
        """
        for _, process in self.servers.values():
            process.terminate()
