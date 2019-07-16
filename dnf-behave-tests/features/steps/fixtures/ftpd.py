# -*- coding: utf-8 -*-

import contextlib
import multiprocessing
import os
import socket

from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer


class NoLogFtpHandler(FTPHandler):
    def log_request(self, *args, **kwargs):
        pass

class FtpServerContext(object):
    """
    This object manages group of simple ftp servers. Each of them is run in
    separate process and serves configured directory.

    Usage:
    ctx = FtpServerContext()
    ctx.new_ftp_server('/path/to/directory/supposed/to/be/served')
    ctx.new_ftp_server('/path/to/other_directory/supposed/to/be/served')
    do_stuff()
    ctx.shutdown()
    """

    @staticmethod
    def ftp_server(address, path):
        os.chdir(path)
        authorizer = DummyAuthorizer()
        # Read only anonymous user
        authorizer.add_anonymous(path)

        handler = NoLogFtpHandler
        handler.authorizer = authorizer

        ftpd = FTPServer(address, handler)
        ftpd.serve_forever()

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
        Start a new ftp server for serving files from "path" directory.
        Returns (host, port) tupple of new running server.
        """
        if path in self.servers:
            return self.get_address(path)
        address = self._get_free_socket()
        process = multiprocessing.Process(target=target, args=(address, path) + args)
        process.start()
        self.servers[path] = (address, process)
        return address

    def new_ftp_server(self, path):
        return self._start_server(path, self.ftp_server)

    def get_address(self, path):
        """
        Get address of ftp server bound to "path" directory
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
