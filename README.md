# ctags-status package

[![Build Status](https://travis-ci.org/mrkschan/ctags-status.svg?branch=master)](https://travis-ci.org/mrkschan/ctags-status)

Show the class/function/scope name of the current line on the status bar.

![A screenshot of ctags-status package](https://github.com/mrkschan/ctags-status/blob/master/docs/screenshot.gif?raw=true)

Inspired by VIM Tag List plugin. Using Ctags to locate the start of functions / classes, and heuristic (e.g. indentation / closing curly '}') to locate the end of them.


# Tested languages

* C / C++
* Coffeescript
* CSS / LESS / SCSS / SASS
* Go
* Java
* Javascript
* HTML / XML
* PHP
* Perl
* Python
* Ruby


# Dependency

If [symbols-view](https://atom.io/packages/symbols-view) is installed,
its vendored ctags binary will be used.
Otherwise, please install exuberant-ctags manually and
set the ctags binary path in your ctags-status settings.


# How it works

* Scope finding - http://mrkschan.blogspot.hk/2015/05/scope-finding-in-source-file.html


# Changelog

https://github.com/mrkschan/ctags-status/blob/master/CHANGELOG.md
