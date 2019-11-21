def start_server_based_on_type(context, server_dir, rtype, certs=None):
    if rtype == "http":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'
        host, port = context.httpd.new_http_server(server_dir)
    elif rtype == "ftp":
        assert (hasattr(context, 'ftpd')), 'Ftpd fixture not set. Use @fixture.ftpd tag.'
        host, port = context.ftpd.new_ftp_server(server_dir)
    elif rtype == "https":
        assert (hasattr(context, 'httpd')), 'Httpd fixture not set. Use @fixture.httpd tag.'

        host, port = context.httpd.new_https_server(
            server_dir, certs["cacert"], certs["cert"], certs["key"],
            client_verification=bool(context.dnf._get("client_ssl")))
    else:
        raise AssertionError("Unknown server type: %s" % rtype)

    return host, port
