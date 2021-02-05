============================
Using the flufl.enum library
============================

Author: `Barry Warsaw`_ <barry@python.org>

The ``flufl.enum`` package provides an enumeration data type for Python.  This
package was the inspiration for `PEP 435`_. ``flufl.enum`` provides similar
functionality compatible with versions of Python from Python 2.7, 3.2, 3.3,
and beyond.

An enumeration is a set of symbolic names bound to unique, constant values,
called *enumeration items*.  Within an enumeration, the items can be compared
by identity, and the enumeration itself can be iterated over.  The underlying
values can be retrieved from the enumeration items.  An integer based variant
is provided which allows items to be used as slices, to interoperate with
C-based APIs, and for logical operations.


Motivation
==========

[Lifted from `PEP 354`_ - the original rejected enumeration PEP]

The properties of an enumeration are useful for defining an immutable, related
set of constant values that have a defined sequence but no inherent semantic
meaning.  Classic examples are days of the week (Sunday through Saturday) and
school assessment grades ('A' through 'D', and 'F').  Other examples include
error status values and states within a defined process.

It is possible to simply define a sequence of values of some other basic type,
such as ``int`` or ``str``, to represent discrete arbitrary values.  However,
an enumeration ensures that such values are distinct from any others, and that
operations without meaning ("Wednesday times two") are not defined for these
values.


Creating an Enumeration
=======================

Class syntax
------------

Enumerations can be created using the class syntax, which makes them easy to
read and write.  Every enumeration item must have a unique value and the only
restriction on their names is that they must be valid Python identifiers.  To
define an enumeration, derive from the ``Enum`` class and add attributes with
assignment to their values.  Values may not be duplicated.
::

    >>> from flufl.enum import Enum
    >>> class Colors(Enum):
    ...     red = 1
    ...     green = 2
    ...     blue = 3

Enumeration items have nice, human readable string representations.

    >>> print(Colors.red)
    Colors.red

The ``reprs`` have additional detail.

    >>> print(repr(Colors.red))
    <EnumValue: Colors.red [value=1]>


Integer Enumerations
--------------------

A special subclass of ``Enum`` can be used when the enumeration items need to
act like integers.  In fact, the items in this ``IntEnum`` class *are*
integers and can be used any place an integer needs to be used, including when
interfacing with C APIs.
::

    >>> from flufl.enum import IntEnum
    >>> class Animals(IntEnum):
    ...     ant = 1
    ...     bee = 2
    ...     cat = 3

These enumeration items can be converted to integers.

    >>> int(Animals.bee)
    2

These enumeration items can also be used as slice indexes.

    >>> list(range(10)[Animals.ant:Animals.cat])
    [1, 2]


Convenience API
---------------

For convenience, you can create an enumeration by calling the ``Enum`` class.
The first argument is the name of the new enumeration, and the second is
provides the enumeration items.  There are several ways to specify the items
-- see the section `Functional API`_ for details -- but the easiest way is to
provide a string of space separated attribute names.  The values for these
items are auto-assigned integers starting from 1.

    >>> Rush = Enum('Rush', 'geddy alex neil')

The ``str`` and ``repr`` provide details.

    >>> print(Rush.geddy)
    Rush.geddy
    >>> print(repr(Rush.geddy))
    <EnumValue: Rush.geddy [value=1]>

See the section on the `Functional API`_ for more options and information.


Values
------

Enumeration items can have any value you choose, but typically they will be
integer or string values, and it is recommended that all the values be of the
same type, although this is not enforced.
::

    >>> class Rush(Enum):
    ...     geddy = 'bass'
    ...     alex = 'guitar'
    ...     neil = 'drums'

    >>> print(repr(Rush.alex))
    <EnumValue: Rush.alex [value=guitar]>


Inspecting Enumerations
=======================

``dir()`` returns the enumeration item names.

    >>> for member in sorted(dir(Colors)):
    ...     print(member)
    blue
    green
    red

The str and repr of the enumeration class also provides useful information.
The items are always sorted by attribute name.

    >>> print(Colors)
    <Colors {blue: 3, green: 2, red: 1}>
    >>> print(repr(Colors))
    <Colors {blue: 3, green: 2, red: 1}>

You can get the enumeration class object from an enumeration item.

    >>> cls = Colors.red.enum
    >>> print(cls.__name__)
    Colors

Enumerations also have a property that contains just their item name.

    >>> print(Colors.red.name)
    red
    >>> print(Colors.green.name)
    green
    >>> print(Colors.blue.name)
    blue

The underlying item value can also be retrieved via the ``.value`` attribute.

    >>> print(Rush.geddy.value)
    bass

Integer enumerations can also be explicitly convert to their integer value
using the ``int()`` built-in.

    >>> int(Animals.ant)
    1
    >>> int(Animals.bee)
    2
    >>> int(Animals.cat)
    3


Comparison
==========

Enumeration items are compared by identity.

    >>> Colors.red is Colors.red
    True
    >>> Colors.blue is Colors.blue
    True
    >>> Colors.red is not Colors.blue
    True
    >>> Colors.blue is Colors.red
    False


Standard Enumerations
---------------------

The standard ``Enum`` class does not allow comparisons against the integer
equivalent values, and if you define an enumeration with similar item
names and integer values, they will not be identical.

    >>> class OtherColors(Enum):
    ...     red = 1
    ...     blue = 2
    ...     yellow = 3
    >>> Colors.red is OtherColors.red
    False
    >>> Colors.blue is not OtherColors.blue
    True

These enumeration items are not equal, nor do they hash equally.

    >>> Colors.red == OtherColors.red
    False
    >>> len(set((Colors.red, OtherColors.red)))
    2

Ordered comparisons between enumeration items are *not* supported.  The base
enumeration values are not integers!

    >>> Colors.red < Colors.blue
    Traceback (most recent call last):
    ...
    TypeError: ...
    >>> Colors.red <= Colors.blue
    Traceback (most recent call last):
    ...
    TypeError: ...
    >>> Colors.blue > Colors.green
    Traceback (most recent call last):
    ...
    TypeError: ...
    >>> Colors.blue >= Colors.green
    Traceback (most recent call last):
    ...
    TypeError: ...
    >>> Colors.red < 3
    Traceback (most recent call last):
    ...
    TypeError: ...

Equality comparisons are defined though.

    >>> Colors.blue == Colors.blue
    True
    >>> Colors.green != Colors.blue
    True

While equality comparisons are allowed, comparisons against non-enumeration
items will always compare not equal.

    >>> Colors.green == 2
    False
    >>> Colors.blue == 3
    False
    >>> Colors.green != 3
    True
    >>> Colors.green == 'green'
    False


Integer enumerations
--------------------

With the ``IntEnum`` class though, enumeration items *are* integers, so all
the ordered comparisons work as expected.

    >>> Animals.ant < Animals.bee
    True
    >>> Animals.cat > Animals.ant
    True

Comparisons against other numbers also work as expected.

    >>> Animals.ant <= 1.0
    True
    >>> Animals.bee == 2
    True

You can even compare integer enumeration items against other unrelated integer
enumeration items, since the comparisons use the standard integer operators.
::

    >>> class Toppings(IntEnum):
    ...     anchovies = 1
    ...     black_olives = 2
    ...     cheese = 4
    ...     dried_tomatoes = 8
    ...     eggplant = 16

    >>> Toppings.black_olives == Animals.bee
    True


Conversions
===========

You can convert back to the enumeration item by using the ``Enum`` class's
``getitem`` syntax, passing in the value for the item you want.

    >>> Colors[2]
    <EnumValue: Colors.green [value=2]>
    >>> Rush['bass']
    <EnumValue: Rush.geddy [value=bass]>
    >>> Colors[1] is Colors.red
    True

If instead you have the enumeration name (i.e. the attribute name), just use
Python's normal ``getattr()`` function.

    >>> getattr(Colors, 'red')
    <EnumValue: Colors.red [value=1]>
    >>> getattr(Rush, Rush.alex.name)
    <EnumValue: Rush.alex [value=guitar]>
    >>> getattr(Colors, 'blue') is Colors.blue
    True


Iteration
=========

The ``Enum`` class support iteration.  Items are returned in order, sorted by
their attribute name.

    >>> from operator import attrgetter
    >>> by_value = attrgetter('value')
    >>> [v.name for v in sorted(Colors, key=by_value)]
    ['red', 'green', 'blue']
    >>> [v.value for v in sorted(Colors, key=by_value)]
    [1, 2, 3]
    >>> [v.name for v in sorted(Rush, key=by_value)]
    ['geddy', 'neil', 'alex']
    >>> for v in sorted(Rush, key=by_value):
    ...     print(v.value)
    bass
    drums
    guitar

Iteration over ``IntEnum`` is sorted in the order of the enumeration item
values.
::

    >>> class Toppings(IntEnum):
    ...     anchovies = 4
    ...     black_olives = 8
    ...     cheese = 2
    ...     dried_tomatoes = 16
    ...     eggplant = 1

    >>> for value in Toppings:
    ...     print(value.name, '=', value.value)
    eggplant = 1
    cheese = 2
    anchovies = 4
    black_olives = 8
    dried_tomatoes = 16

Enumeration items can be used in dictionaries and sets.

    >>> from operator import attrgetter
    >>> getvalue = attrgetter('value')
    >>> apples = {}
    >>> apples[Colors.red] = 'red delicious'
    >>> apples[Colors.green] = 'granny smith'
    >>> for color in sorted(apples, key=getvalue):
    ...     print(color.name, '->', apples[color])
    red -> red delicious
    green -> granny smith


Extending an enumeration through subclassing
============================================

You can extend previously defined enumerations by subclassing.  Just as
before, items cannot be duplicated in either the base class or subclass.

    >>> class MoreColors(Colors):
    ...     pink = 4
    ...     cyan = 5

When extended in this way, the base enumeration's items are identical to the
same named items in the derived class.

    >>> Colors.red is MoreColors.red
    True
    >>> Colors.blue is MoreColors.blue
    True


Pickling
========

Enumerations created with the class syntax can also be pickled and unpickled:

    >>> from flufl.enum.tests.fruit import Fruit
    >>> from pickle import dumps, loads
    >>> Fruit.tomato is loads(dumps(Fruit.tomato))
    True


Functional API
==============

As described above, you can create enumerations functionally by calling
``Enum`` or ``IntEnum``.

The first argument is always the name of the new enumeration.  The second
argument describes the enumeration item names and values.  As mentioned
previously, the easiest way to create new enumerations is to provide a single
string with space-separated attribute names.  In this case, the values are
auto-assigned integers starting from 1.

    >>> Enum('Animals', 'ant bee cat dog')
    <Animals {ant: 1, bee: 2, cat: 3, dog: 4}>

The second argument can also be a sequence of strings.  In this case too, the
values are auto-assigned integers starting from 1.

    >>> Enum('People', ('anne', 'bart', 'cate', 'dave'))
    <People {anne: 1, bart: 2, cate: 3, dave: 4}>

The items can also be specified by using a sequence of 2-tuples, where the
first item is the enumeration item name and the second is the value to use.
If 2-tuples are given, all items must be 2-tuples.

    >>> def enumiter():
    ...     start = 1
    ...     while True:
    ...         yield start
    ...         start <<= 1
    >>> Enum('Flags', zip(list('abcdefg'), enumiter()))
    <Flags {a: 1, b: 2, c: 4, d: 8, e: 16, f: 32, g: 64}>

You can also provide the enumeration items as a dictionary mapping names to
values.  Remember that the ``repr`` is sorted by attribute name.

    >>> bassists = dict(geddy='rush', chris='yes', flea='rhcp', jack='cream')
    >>> Enum('Bassists', bassists)
    <Bassists {chris: yes, flea: rhcp, geddy: rush, jack: cream}>

If you want to create an ``IntEnum`` where the values are integer subclasses,
call that class instead.  This has the same signature as calling ``Enum`` but
the items of the returned enumeration are int subclasses.

    >>> Numbers = IntEnum('Numbers', 'one two three four'.split())
    >>> Numbers.three == 3
    True


Customization protocol
======================

You can define your own enumeration value types by using the
``__value_factory__`` protocol.  This is how the ``IntEnum`` type is
defined.  As an example, let's say you want to define a new type of
enumeration where the values were subclasses of ``str``.  First, define your
enumeration value subclass.

    >>> from flufl.enum import EnumValue
    >>> class StrEnumValue(str, EnumValue):
    ...     def __new__(cls, enum, value, attr):
    ...         return super(StrEnumValue, cls).__new__(cls, value)

And then define your enumeration class.  You must set the class attribute
``__value_factory__`` to the class of the values you want to create.

    >>> class StrEnum(Enum):
    ...     __value_factory__ = StrEnumValue

Now, when you define your enumerations, the values will be ``str`` subclasses.
::

    >>> class Noises(StrEnum):
    ...     dog = 'bark'
    ...     cat = 'meow'
    ...     cow = 'moo'

    >>> isinstance(Noises.cow, str)
    True


Acknowledgments
===============

The ``flufl.enum`` implementation is based on an example by Jeremy Hylton.  It
has been modified and extended by Barry Warsaw for use in the `GNU Mailman`_
project.  Ben Finney is the author of the earlier enumeration PEP 354.  Eli
Bendersky is the co-author of PEP 435.  Numerous people on the `python-ideas`_
and `python-dev`_ mailing lists have provided valuable feedback.


.. _`PEP 435`: http://www.python.org/dev/peps/pep-0435/
.. _`Python 3.4`: http://www.python.org/dev/peps/pep-0429/
.. _`PEP 354`: http://www.python.org/dev/peps/pep-0354/
.. _enum: http://cheeseshop.python.org/pypi/enum/
.. _`GNU Mailman`: http://www.list.org
.. _`python-ideas`: http://mail.python.org/mailman/listinfo/python-ideas
.. _`python-dev`: http://mail.python.org/mailman/listinfo/python-dev
.. _`Barry Warsaw`: http://barry.warsaw.us
