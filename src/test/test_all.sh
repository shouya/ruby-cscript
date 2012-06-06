#!/bin/sh

tests=`find -name "test_*_*.rb" | sort`
retval=0

for i in $tests; do
    echo -n -e "Testing $i   \t"
    ruby $i 2>&1 >/dev/null
    [ "$?" != "0" ] && {
        echo "[Failed]"
        retval=-1
        #ruby $i
    } || {
        echo "[Successful]"
    }

done # | column -t

echo All test works are finished.

exit $retval

