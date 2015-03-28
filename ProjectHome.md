# OpenGL Help for Qt Creator #

Here you will find a few scripts to create a Qt help file based on the reference manual found at opengl.org. As of April 2011 the most up-to-date version of the OpenGL Reference manual is 4.1. You can find the original documentation here:

http://www.opengl.org/sdk/docs/man4/

The toolchain is based on Bash-Scripts and is supposed to run on a Linux based system.

## Features ##
  * Automatic download of the OpenGL Reference Manual from opengl.org
    * Supports 2.1, 3.3 and 4.1 documentation
  * Automatic creation of the necessary project files
  * Automatic compilation of the project to build the QCH file ("Qt Compressed Help")

## Installation (Binary) ##
  * Download the desired release and unpack
  * In Qt Creator open the settings and add the file as a help source

## Installation (Source) ##
  * Download the toolchain and unpack
  * Open a terminal, change to the containing directory and run "gendoc.sh" and follow the instructions given
  * After the build has been finished, copy the resulting qch file and proceed with the binary installation

## Screenshot ##
![http://qtcreator-openglhelp.googlecode.com/svn/wiki/qtcreator_screenshot.png](http://qtcreator-openglhelp.googlecode.com/svn/wiki/qtcreator_screenshot.png)