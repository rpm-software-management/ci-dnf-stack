Generate documentation
----------------------
```
$ rm -vf doc/*.rst
$ behave-3 -q --dry-run -f sphinx.steps -o doc/
$ sphinx-build-3 -b html doc/ doc/_build/
```
