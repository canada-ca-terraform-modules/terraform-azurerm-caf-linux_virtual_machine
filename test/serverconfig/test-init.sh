#!/bin/sh
echo "bootscript initiated" > /tmp/results.txt

echo "Doing stuff..."
touch /tmp/test.txt

echo "bootscript done" >> /tmp/results.txt

exit 0