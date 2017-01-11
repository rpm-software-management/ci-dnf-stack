Generate documentation
----------------------

Following packages (or their python2 equivalents) should be installed:
  python3-behave python3-sphinx python3-whichcraft python3-pexpect

```
$ rm -vf doc/*.rst
$ behave-3 -q --dry-run -f sphinx.steps -o doc/
$ sphinx-build-3 -W -b html doc/ doc/_build/
```

respectively

```
$ rm -vf doc/*.rst
$ behave-2 -q --dry-run -f sphinx.steps -o doc/
$ sphinx-build-2 -W -b html doc/ doc/_build/
```
