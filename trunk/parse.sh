#!/bin/bash

INFILE=$1

cat ${INFILE} | fromdos | tr '\n' ',' | grep fsfunc | while read line
do
    MORE=1
    CURNUM=2
    while [ ${MORE} -eq 1 ]; do
        TEMPFILE=/tmp/glparse.awk.$RANDOM
        echo '{print $__NUM__}' | sed s/__NUM__/${CURNUM}/g > ${TEMPFILE}
        FUNC=`echo ${line} | awk -F '<b class' -f ${TEMPFILE} | awk -F '</b>' '{print $1}'  | grep fsfunc | awk -F '>' '{print $2}'`

        if [ "${FUNC}" == "" ]; then
            let MORE=0
        else
            echo ${FUNC}
        fi

        let CURNUM=${CURNUM}+1
        rm ${TEMPFILE}
    done
done
