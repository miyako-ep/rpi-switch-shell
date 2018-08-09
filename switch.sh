#!/bin/bash

print_usage_and_exit () {
    cat \
<<-USAGE 1>&2
This is an easy test tool for gpio by shell. Execute as a root user.

Usage   : ${0##*/} [options] [keyword ...]
Options :
    -r <BCM gpio num>   |--read                 Read the gpio.
    -w <BCM gpio num>   |--write                Write the gpio (todo).
    -i <sec>            |--interval             Reading Interval (todo).
    -v                  |--verbose              Print verbose log (todo).
    -h                  |--help                 Print this.
USAGE
    exit 1
}

[ "_$1" != "_-r" ] && print_usage_and_exit
[ -z "$2" ] && print_usage_and_exit

GPIO_NUMBER=$2
GPIO_EXPORT="/sys/class/gpio/export"
GPIO_UNEXPORT="/sys/class/gpio/unexport"
GPIO_DIRECTION="/sys/class/gpio/gpio$GPIO_NUMBER/direction"
GPIO_VALUE="/sys/class/gpio/gpio$GPIO_NUMBER/value"
INTERVAL=1

# destract
destract () {
    echo "$GPIO_NUMBER" > "$GPIO_UNEXPORT"
    exit 0
}
trap destract 1 2 3 15

# already expoted
[ -e "/sys/class/gpio/gpio$GPIO_NUMBER" ] && echo "$GPIO_NUMBER" > "$GPIO_UNEXPORT"

# main loop
echo "$GPIO_NUMBER" > "$GPIO_EXPORT"
while [ ! -e "$GPIO_DIRECTION" ]; do : ; done
echo "in" > "$GPIO_DIRECTION"

while :
do
    logger -ip local0.info -t [gpio] -s $(cat "$GPIO_VALUE")
    sleep "$INTERVAL"
done

echo "$GPIO_NUMBER" > "$GPIO_UNEXPORT"

