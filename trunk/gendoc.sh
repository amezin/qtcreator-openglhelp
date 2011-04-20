#!/bin/bash

function grabfiles
{
    ### grab the necessary files
    echo "Grabbing files (can take a long time) ... "
    if [ -d ${TEMPPATH} ]; then
        rm -Rf ${TEMPPATH}
    fi
    mkdir ${TEMPPATH}

    pushd ${TEMPPATH} 2>/dev/null 1>&2
    wget --recursive --level=100 --no-parent ${OPENGL_DOC_URL} 
    popd 2>/dev/null 1>&2
}

function checkredirects
{
    pushd ${DOWNPATH} 2>/dev/null 1>&2

    echo "Checking redirects ... "
    pwd
    ls *.xml | while read line
    do
        cat ${line} | grep "meta http-equiv=\"Refresh\"" 2>/dev/null 1>&2
        if [ $? -eq 0 ]; then
            ## we need to fetch a redirect
            redir=`cat ${line} | grep "meta http-equiv=\"Refresh\"" | awk -F "URL=" '{print $2}' | awk -F '"' '{print $1}'`
            wget -O ${line} ${ABSPATH}/${redir}
        fi
    done

    popd 2>/dev/null 1>&2
}

function checkmultidoc
{
    # checks if a file contains the documentation for more than one function and copy it to a new
    # name to reflect this

    pushd ${DOWNPATH} 2>/dev/null 1>&2

    if [ -f ${ALIASES} ]; then
        rm ${ALIASES}
    fi

    echo "Checking for multifunction documentation ..."
    ls *.xml | while read line
    do
        echo "File:  ${line}"
        ${MYDIR}/parse.sh ${line} | while read fname
        do
            echo "   ----> ${fname}"
            if [ ! -f ${fname}.xml ]; then
                echo ${fname} ${line} >> ${ALIASES}
            fi
        done
    done

    popd 2>/dev/null 1>&2
}

function renamefiles
{
    echo -n "Renaming files ... "
    pushd ${DOWNPATH} 2>/dev/null 1>&2
    find . -name \*.xml | while read fname
    do
       cat $fname | sed s/\.xml\"\>/\.html\"\"\>/g > `echo $fname | sed s/\.xml/\.html/g`
    done
    popd 2>/dev/null 1>&2
    echo "OK"
}

function writeheader
{
    echo -n "Creating header ... "

    ### write qhp file header
    cat header.txt | sed s/__SDKSHORT__/${SDKSHORT}/g | sed s/__SDKLONG__/${SDKLONG}/g > ${QHPFILE}

    echo "OK"
}

function writesection
{
    echo -n "Creating sections ... "
    ./gensection.sh ${DOWNPATH}/index.html ${ABSPATH} ${ALIASES}>> ${QHPFILE}

    echo "</section>" >> ${QHPFILE}
    echo "</toc>" >> ${QHPFILE}

    echo "OK"
}

function writekeywords
{
    echo -n "Creating keywords ... "
	echo "<keywords>" >> ${QHPFILE}
    ./genkey.sh ${DOWNPATH}/index.html ${ABSPATH} ${ALIASES} >> ${QHPFILE}
    echo "</keywords>" >> ${QHPFILE}
    echo "OK"
}

function writefiles
{
    echo -n "Creating file list ... "
    echo "<files>" >> ${QHPFILE}
    pushd ${TEMPPATH} 2>/dev/null 1>&2
    find . -name gl\*.html | while read line
    do
        fname=`echo $line | awk -F '/' '{print $NF}'`
        echo "<file>${ABSPATH}/${fname}</file>" >> ${QHPFILE}
    done
    popd 2>/dev/null 1>&2
    echo "</files>" >> ${QHPFILE}
    echo "OK"
}

function writefooter
{
    echo "</filterSection>" >> ${QHPFILE}
    echo "</QtHelpProject>" >> ${QHPFILE}
}

function generateprojectfile
{
    cat project.txt | sed s/__SDKSHORT__/${SDKSHORT}/g > ${QHCPFILE}
}

function buildproject
{
	pushd ${TEMPPATH} 2>/dev/null 1>&2
	qcollectiongenerator ${QHCPFILE}
	popd 2>/dev/null 1>&2
}

### -----------------------------------------------------------------
### entry
### -----------------------------------------------------------------

if [ $# -eq 0 ]; then 
    echo usage: `basename $0` \<glversion\>
    echo 
    echo "  <glversion>:"
    echo "    21 - Generate help file for OpenGL 2.1"
    echo "    33 - Generate help file for OpenGL 3.3"
    echo "    41 - Generate help file for OpenGL 4.1"
    echo
    exit
else
    case $1 in
        "21")
            export SDKSHORT=21;
            export SDKLONG="2.1";
            export OPENGL_DOC_URL="http://www.opengl.org/sdk/docs/man/"
            export ABSPATH="www.opengl.org/sdk/docs/man/xhtml"
            ;;
        "33")
            export SDKSHORT=33;
            export SDKLONG="3.3";
            export OPENGL_DOC_URL="http://www.opengl.org/sdk/docs/man3/"
            export ABSPATH="www.opengl.org/sdk/docs/man3/xhtml"
            ;;
        "41")
            export SDKSHORT=41;
            export SDKLONG="4.1";
            export OPENGL_DOC_URL="http://www.opengl.org/sdk/docs/man4/"
            export ABSPATH="www.opengl.org/sdk/docs/man4/xhtml"
            ;;
        *)
            echo Unknown SDK version!;
            exit;
            ;;
    esac
fi

### setting variables
MYDIR=`pwd`
TEMPPATH="/tmp/gl${SDKSHORT}_temp.$RANDOM"
DOWNPATH="${TEMPPATH}/${ABSPATH}"
QHPFILE="${TEMPPATH}/gl${SDKSHORT}.qhp"
QHCPFILE="${TEMPPATH}/gl${SDKSHORT}.qhcp"
ALIASES="${TEMPPATH}/aliases.txt"


echo "Generating documentation for OpenGL ${SDKLONG}"

grabfiles
checkredirects
checkmultidoc
renamefiles

writeheader
writesection
writekeywords
writefiles
writefooter

generateprojectfile

buildproject

echo -------------------------------------------------
echo
echo documentation file located at: ${TEMPPATH}
echo
echo -------------------------------------------------


