#!/bin/bash

OPENGL_DOC_URL="http://www.opengl.org/sdk/docs/man/"
TEMPPATH="/tmp/gl21_temp.$RANDOM"
ABSPATH="www.opengl.org/sdk/docs/man/xhtml"
DOWNPATH="${TEMPPATH}/${ABSPATH}"
QHPFILE="${TEMPPATH}/gl21.qhp"
QHCPFILE="${TEMPPATH}/gl21.qhcp"

function grabfiles
{
    ### grab the necessary files
    if [ -d ${TEMPPATH} ]; then
        rm -Rf ${TEMPPATH}
    fi
    mkdir ${TEMPPATH}

    pushd ${TEMPPATH} 2>/dev/null 1>&2
    wget --recursive --level=100 --no-parent ${OPENGL_DOC_URL} 
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
    cat << EOF > ${QHPFILE}
<?xml version="1.0" encoding="UTF-8"?>
<QtHelpProject version="1.0">
    <namespace>opengl.org.sdk.21</namespace>
    <virtualFolder>doc</virtualFolder>
    <customFilter name="OpenGL SDK 2.1 Reference Manual">
    </customFilter>
    <filterSection>
        <filterAttribute>OpenGL SDK 2.1</filterAttribute>
        <toc>
            <section title="OpenGL 2.1 Reference manual" ref="#">
EOF

    echo "OK"
}

function writesection
{
    echo -n "Creating sections ... "
    ./gensection.sh ${DOWNPATH}/index.html ${ABSPATH} >> ${QHPFILE}

    echo "</section>" >> ${QHPFILE}
    echo "</toc>" >> ${QHPFILE}

    echo "OK"
}

function writekeywords
{
    echo -n "Creating keywords ... "
	echo "<keywords>" >> ${QHPFILE}
    ./genkey.sh ${DOWNPATH}/index.html ${ABSPATH} >> ${QHPFILE}
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
        fname=`echo $line | cut -c 3-`
        echo "<file>${fname}</file>" >> ${QHPFILE}
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
cat << EOF > ${QHCPFILE}
<?xml version="1.0" encoding="utf-8" ?>
<QHelpCollectionProject version="1.0">
    <docFiles>
        <generate>
            <file>
                <input>gl21.qhp</input>
                <output>gl21.qch</output>
            </file>
        </generate>
        <register>
            <file>gl21.qch</file>
        </register>
    </docFiles>
</QHelpCollectionProject>
EOF
}

function buildproject
{
	pushd ${TEMPPATH} 2>/dev/null 1>&2
	qcollectiongenerator ${QHCPFILE}
	popd 2>/dev/null 1>&2
}

grabfiles
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


