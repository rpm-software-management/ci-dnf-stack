import re


SPLITTER_RE = re.compile(r", *")


def splitter(text):
    """
    Split text by ", "
    """
    return SPLITTER_RE.split(text)
