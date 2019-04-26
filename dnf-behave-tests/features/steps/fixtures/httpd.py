# -*- coding: utf-8 -*-

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


class NoLogHttpHandler(SimpleHTTPRequestHandler):
    def log_request(self, *args, **kwargs):
        pass

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
    def http_server(address, path):
        os.chdir(path)
        httpd = TCPServer(address, NoLogHttpHandler)
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
        return self._start_server(path, self.http_server)

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
