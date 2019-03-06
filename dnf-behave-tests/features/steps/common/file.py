import codecs
import os
import shutil

def ensure_directory_exists(dirname):
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    assert os.path.exists(dirname), "ENSURE: dir exists {!r}".format(dirname)
    assert os.path.isdir(dirname), "ENSURE: is a dir {!r}".format(dirname)

def ensure_file_does_not_exist(filename):
    assert not os.path.exists(filename), "ENSURE: file does not exist {!r}".format(filename)

def delete_file(filename):
    if os.path.exists(filename):
        os.remove(filename)

def delete_directory(dirname):
    if os.path.exists(dirname):
        shutil.rmtree(dirname)

def create_file_with_contents(filename, contents, encoding="utf-8"):
    if os.path.exists(filename):
        os.remove(filename)
    with codecs.open(filename, "w", encoding) as outstream:
        outstream.write(contents)
        outstream.flush()
    assert os.path.exists(filename), "ENSURE: file exists {!r}".format(filename)

def read_file_contents(filename, encoding="utf-8"):
    assert os.path.exists(filename), "ENSURE: file exists {!r}".format(filename)
    with codecs.open(filename, "r", encoding) as outstream:
        output = outstream.read()
        return output
