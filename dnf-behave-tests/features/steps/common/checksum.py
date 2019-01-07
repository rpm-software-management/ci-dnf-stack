import hashlib


def sha256_checksum(data):
    h = hashlib.new("sha256")
    h.update(data)
    return h.hexdigest()
