import codecs
import os

def ensure_directory_exists(dirname):
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    assert os.path.exists(dirname), "ENSURE: dir exists {!r}".format(dirname)
    assert os.path.isdir(dirname), "ENSURE: is a dir {!r}".format(dirname)

def create_file_with_contents(filename, contents, encoding="utf-8"):
    if os.path.exists(filename):
        os.remove(filename)
    with codecs.open(filename, "w", encoding) as outstream:
        outstream.write(contents)
        outstream.flush()
    assert os.path.exists(filename), "ENSURE: file exists {!r}".format(filename)
