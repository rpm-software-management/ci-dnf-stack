# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import contextlib
import multiprocessing
import socket


class ServerContext(object):
    """
    This object manages a group of simple servers. Each of them is run in a
    separate process. This is the shared base for http and ftp servers and it
    has a 'path' argument on the interface, which is passed to the server and
    from which the server will serve files.

    It also provides a dict with keys being the path and value being the
    (address, process) pair for the server serving from the path.
    """

    @staticmethod
    def _get_free_socket(host='localhost'):
        with contextlib.closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((host, 0))
            return (host, s.getsockname()[1])

    def __init__(self):
        # mapping path -> (address, server process)
        self.servers = dict()

    def _start_server(self, path, target, *args):
        """
        Start a new server. Returns (host, port) tupple of the new running server.
        """
        if path in self.servers:
            return self.get_address(path)
        address = self._get_free_socket()
        process = multiprocessing.Process(target=target, args=(address, path) + args)
        process.start()
        self.servers[path] = (address, process)
        return address

    def get_address(self, path):
        """
        Get address of the server bound to the "path" directory.
        """
        if path in self.servers:
            return self.servers[path][0]
        return None

    def shutdown(self):
        """
        Terminate all running servers.
        """
        for _, process in self.servers.values():
            process.terminate()
