#!/usr/bin/bash

docker run -it --entrypoint=/bin/bash -v $(pwd)/repo:/build:Z -v $(pwd)/features:/behave:Z pavelo/richdeps:1.0.4
