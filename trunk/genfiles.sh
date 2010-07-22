#!/bin/bash
find doc -name \*.xml | while read line
do
    echo "<file>${line}</file>"
done
