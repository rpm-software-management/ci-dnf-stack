Generate documentation
----------------------
```
$ rm -vf doc/*.rst
$ behave-3 -q --dry-run -f sphinx.steps -o doc/
$ sphinx-build-3 -W -b html doc/ doc/_build/
```
