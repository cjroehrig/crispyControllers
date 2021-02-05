=========================================
flufl.enum - A Python enumeration package
=========================================

This package is called ``flufl.enum``, a Python enumeration package.

The goals of ``flufl.enum`` are to produce simple, specific, concise semantics
in an easy to read and write syntax.  ``flufl.enum`` has just enough of the
features needed to make enumerations useful, but without a lot of extra
baggage to weigh them down.  This work grew out of the Mailman 3.0 project and
it is the enum package used there.  This package was previously called
``munepy``.

**Note: This package is deprecated!** Python 3.4 added an enum package to its
`standard library`_ which is also available as a `third party package`_ on
PyPI for older versions of Python.  If you are using `flufl.enum` you should
switch to the standard enum package.


Requirements
============

``flufl.enum`` requires Python 2.7 or newer, and is compatible with Python 3.


Documentation
=============

A `simple guide`_ to using the library is available within this package.


Project details
===============

 * Project home: https://gitlab.com/warsaw/flufl.enum
 * Report bugs at: https://gitlab.com/warsaw/flufl.enum/issues
 * Code hosting: git@gitlab.com:warsaw/flufl.enum.git
 * Documentation: http://fluflenum.readthedocs.org/

You can install it with `pip`::

    % pip install flufl.enum

You can grab the latest development copy of the code using git.  The master
repository is hosted on GitLab.  If you have git installed, you can grab
your own branch of the code like this::

    $ git clone git@gitlab.com:warsaw/flufl.enum.git

You may contact the author via barry@python.org.


Copyright
=========

Copyright (C) 2004-2017 Barry A. Warsaw

This file is part of flufl.enum.

flufl.enum is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

flufl.enum is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with flufl.enum.  If not, see <http://www.gnu.org/licenses/>.


Table of Contents
=================

.. toctree::

    docs/using.rst
    NEWS.rst

.. _`simple guide`: docs/using.html
.. `standard library`: https://docs.python.org/3/library/enum.html
.. `third party package`: https://pypi.python.org/pypi/enum34
