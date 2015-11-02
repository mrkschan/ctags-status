# ctags-status package

[![Build Status](https://travis-ci.org/mrkschan/ctags-status.svg?branch=master)](https://travis-ci.org/mrkschan/ctags-status)

Show the class/function/scope name of the current line on the status bar.

![A screenshot of ctags-status package](https://github.com/mrkschan/ctags-status/blob/master/docs/screenshot.gif?raw=true)

Inspired by VIM Tag List plugin. Using Ctags to locate the start of functions / classes and heuristic (e.g. indentation / closing curly '}') to locate the end of them.

If you like this plugin, leave it a **star** :) If you find any problem, create an **issue** at https://github.com/mrkschan/ctags-status/issues. If you find it works for any programming languages that are not in the **Tested languages** list, you may add it to the list by making a **pull request** at https://github.com/mrkschan/ctags-status/pulls.


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

## Ubuntu / Debian

```
sudo apt-get install exuberant-ctags
```

## Red Hat / Fedora / CentOS

```
sudo yum install ctags
```

## OS X

```
brew install ctags
```

And, put `/usr/local/bin/ctags` to your ctags-status settings.

## Windows

1. Download CTags binary from http://prdownloads.sourceforge.net/ctags/ctags58.zip.
2. Unzip the binary to anywhere that can be located by your PATH.


# How it works

* Scope finding - http://mrkschan.blogspot.hk/2015/05/scope-finding-in-source-file.html


# Changelog

https://github.com/mrkschan/ctags-status/blob/master/CHANGELOG.md
