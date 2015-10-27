#!/usr/bin/python -tt

import os
import subprocess

b = os.path.realpath(__file__)
c = os.getcwd()
a = subprocess.check_output(['pwd'])

A = os.path.join(os.path.dirname(__file__), '..')
B = os.path.dirname(os.path.realpath(__file__))
C = os.path.abspath(os.path.dirname(__file__))

print a
print b
print c
print A
print B
print C