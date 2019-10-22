# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import contextlib
import multiprocessing
import os
import socket
import ssl
import sys

PY3 = sys.version_info.major >= 3
if PY3:
    from http.server import SimpleHTTPRequestHandler
    from socketserver import TCPServer
else:
    from SimpleHTTPServer import SimpleHTTPRequestHandler
    from SocketServer import TCPServer


class AccessRecord(object):
    """Represents an HTTP request processed by a server instance."""

    def __init__(self, handler):
        self.command = handler.command
        self.path = handler.path
        self.headers = handler.headers

    def __str__(self):
        headers = ['%s: %s' % (k, v) for k, v in self.headers.items()]
        return '\n%s %s\n%s' % (self.command, self.path, '\n'.join(headers))


class NoLogHttpHandler(SimpleHTTPRequestHandler):
    def log_request(self, *args, **kwargs):
        pass


class LoggingHttpHandler(SimpleHTTPRequestHandler):
    def log_request(self, *args, **kwargs):
        if not self.server._conf.get('logging', False):
            return
        self.server._log.append(AccessRecord(self))

    def do_GET(self):
        # Respond with the specific status code if configured, otherwise just
        # process the request as usual.
        if 'status' in self.server._conf:
            self.send_response(self.server._conf['status'])
            self.end_headers()
            return
        super(LoggingHttpHandler, self).do_GET()


class HttpServerContext(object):
    """
    This object manages group of simple http servers. Each of them is run in 
    separate process and serves configured directory.

    Usage:
    ctx = HttpServerContext()
    ctx.new_http_server('/path/to/directory/supposed/to/be/served')
    ctx.new_http_server('/path/to/other_directory/supposed/to/be/served')
    do_stuff()
    ctx.shutdown()
    """

    @staticmethod
    def http_server(address, path, log, conf):
        os.chdir(path)
        httpd = TCPServer(address, LoggingHttpHandler)
        httpd._log = log
        httpd._conf = conf
        httpd.serve_forever()

    @staticmethod
    def https_server(address, path, cacert, cert, key, client_verification=False):
        os.chdir(path)
        httpd = TCPServer(address, NoLogHttpHandler)
        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH, cafile=cacert)
        context.load_cert_chain(certfile=cert, keyfile=key)
        if client_verification:
            context.verify_mode = ssl.CERT_REQUIRED
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        httpd.serve_forever()

    @staticmethod
    def _get_free_socket(host='localhost'):
        with contextlib.closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((host, 0))
            return (host, s.getsockname()[1])

    def __init__(self):
        # mapping path -> (address, server process)
        self.servers = dict()
        # list of AccessRecord objects
        self._log = multiprocessing.Manager().list()
        self._conf = multiprocessing.Manager().dict()

    def _start_server(self, path, target, *args):
        """
        Start a new http server for serving files from "path" directory.
        Returns (host, port) tupple of new running server.
        """
        if path in self.servers:
            return self.get_address(path)
        address = self._get_free_socket()
        process = multiprocessing.Process(target=target, args=(address, path) + args)
        process.start()
        self.servers[path] = (address, process)
        return address

    def new_http_server(self, path):
        return self._start_server(path, self.http_server, self._log, self._conf)

    def new_https_server(self, path, cacert, cert, key, client_verification):
        return self._start_server(
            path, self.https_server, cacert, cert, key, client_verification)

    def get_address(self, path):
        """
        Get address of http server bound to "path" directory
        """
        if path in self.servers:
            return self.servers[path][0]
        return None

    @property
    def log(self):
        if self._log is None:
            raise Exception('No HTTP server was started yet')
        return self._log

    def clear_log(self):
        """
        Empty the log of the http server
        """
        del self.log[:]

    @property
    def conf(self):
        if self._conf is None:
            raise Exception('No HTTP server was started yet')
        return self._conf

    def shutdown(self):
        """
        Terminate all running servers
        """
        for _, process in self.servers.values():
            process.terminate()


if __name__ == '__main__':
    import os
    ctx = HttpServerContext()
    certpath = '../../../fixtures/certificates/testcerts'
    cacert = os.path.realpath(os.path.join(certpath, 'ca/cert.pem'))
    host, port = ctx.new_https_server(
        '../../../fixtures/repos/',
        cacert,
        os.path.realpath(os.path.join(certpath, 'server/cert.pem')),
        os.path.realpath(os.path.join(certpath, 'server/key.pem')),
        False)
    curl = 'curl --cacert {} https://{}:{}/'.format(cacert, host, port)
    #curl = 'wget --ca-certificate {} https://{}:{}/'.format(cacert, host, port)
    print(curl)
    print(os.system(curl))
    ctx.shutdown()
