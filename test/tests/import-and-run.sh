#!/bin/bash

if [ -z "$1" ]; then
    lein repl :headless
elif [ "$1" == "test" ]; then
    lein test
else
    true
fi