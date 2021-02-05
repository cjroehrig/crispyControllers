# Copyright (C) 2011-2017 Barry Warsaw
#
# This file is part of flufl.enum.
#
# flufl.enum is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# flufl.enum is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with flufl.enum.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Barry Warsaw <barry@python.org>

"""Additional package tests."""

from __future__ import absolute_import, print_function, unicode_literals

__metaclass__ = type
__all__ = [
    'TestBasic',
    'TestIntEnum',
    ]


import warnings
import unittest

from flufl.enum import Enum, IntEnum, make
from itertools import combinations
from operator import attrgetter, index

SPACE = ' '


class TestBasic(unittest.TestCase):
    """Basic functionality tests"""

    class Colors(Enum):
        red = 1
        green = 2
        blue = 3

    all_colors = ['red', 'green', 'blue']

    def test_basic_reprs(self):
        self.assertEqual(str(self.Colors.red), 'Colors.red')
        self.assertEqual(str(self.Colors.green), 'Colors.green')
        self.assertEqual(str(self.Colors.blue), 'Colors.blue')
        self.assertEqual(str(self.Colors['red']), 'Colors.red')
        self.assertEqual(
            repr(self.Colors.red),
            '<EnumValue: Colors.red [value=1]>')

    def test_string_value(self):
        class Rush(Enum):
            geddy = 'bass'
            alex = 'guitar'
            neil = 'drums'
        self.assertEqual(
            repr(Rush.alex),
            '<EnumValue: Rush.alex [value=guitar]>')

    def test_factory_single_string(self):
        Color = Enum('Color', SPACE.join(self.all_colors))
        for c in self.all_colors:
            self.assertEqual(str(Color[c]), 'Color.' + c)

    def test_enum_dir(self):
        # dir() returns the list of enumeration item names.
        self.assertEqual(sorted(dir(self.Colors)), sorted(self.all_colors))

    def test_enumclass_getitem(self):
        self.assertEqual(self.Colors[2], self.Colors.green)
        self.assertEqual(self.Colors['red'], self.Colors.red)
        self.assertEqual(self.Colors[self.Colors.red], self.Colors.red)

    def test_iteration(self):
        # Iteration over basic Enums is by attribute name.
        A = Enum('A', 'a b c')
        self.assertEqual(list(v.name for v in A), ['a', 'b', 'c'])
        B = Enum('B', 'c b a')
        self.assertEqual(list(v.name for v in B), ['a', 'b', 'c'])
        # If iteration sorted over values, this would give a TypeError.
        C = Enum('C', dict(a='7', b=7))
        self.assertEqual(list(v.name for v in C), ['a', 'b'])

    def test_hashing(self):
        getvalue = attrgetter('value')
        apples = {}
        apples[self.Colors.red] = 'red delicious'
        apples[self.Colors.green] = 'granny smith'
        self.assertEqual(
            [(c.name, apples[c]) for c in sorted(apples, key=getvalue)],
            [('red', 'red delicious'), ('green', 'granny smith')])

    def test_value_enum_attributes(self):
        for i, c in enumerate(self.all_colors, 1):
            # enum attribute
            self.assertEqual(self.Colors[c].enum, self.Colors)
            # name attribute
            self.assertEqual(self.Colors[c].name, c)
            # value attribute
            self.assertEqual(self.Colors[c].value, i)

    def test_enum_class_name(self):
        self.assertEqual(self.Colors.__name__, 'Colors')

    def test_comparisons(self):
        r, g, b = self.Colors.red, self.Colors.green, self.Colors.blue
        for c in r, g, b:
            self.assertIs(c, c)
            self.assertEqual(c, c)
        for first, second in combinations([r, g, b], 2):
            self.assertIsNot(first, second)
            self.assertNotEqual(first, second)

        with self.assertRaises(TypeError):
            self.Colors.red < self.Colors.blue
        with self.assertRaises(TypeError):
            self.Colors.red <= self.Colors.blue
        with self.assertRaises(TypeError):
            self.Colors.red > self.Colors.green
        with self.assertRaises(TypeError):
            self.Colors.green >= self.Colors.blue

    def test_comparison_with_int(self):
        with self.assertRaises(TypeError):
            self.Colors.red < 3
        with self.assertRaises(TypeError):
            self.Colors.red <= 3
        with self.assertRaises(TypeError):
            self.Colors.blue > 2
        with self.assertRaises(TypeError):
            self.Colors.green >= 1

        self.assertNotEqual(self.Colors.green, 2)
        self.assertNotEqual(self.Colors.blue, 3)
        self.assertNotEqual(self.Colors.green, 3)

    def test_comparison_with_other_enum(self):
        class OtherColors(Enum):
            red = 1
            blue = 2
            yellow = 3

        self.assertIsNot(OtherColors.red, self.Colors.red)
        self.assertNotEqual(OtherColors.red, self.Colors.red)
        self.assertNotEqual(hash(OtherColors.red), hash(self.Colors.red))

    def test_subclass(self):
        class MoreColors(self.Colors):
            pink = 4
            cyan = 5
        self.assertIs(self.Colors.red, MoreColors.red)
        self.assertIs(self.Colors.blue, MoreColors.blue)

    def test_pickle(self):
        from flufl.enum.tests.fruit import Fruit
        from pickle import dumps, loads
        self.assertIs(Fruit.tomato, loads(dumps(Fruit.tomato)))

    def test_functional_api_single_string(self):
        animals = Enum('Animals', 'ant bee cat dog')
        self.assertEqual(
            repr(animals),
            '<Animals {ant: 1, bee: 2, cat: 3, dog: 4}>')

    def test_functional_api_sequence(self):
        people = Enum('People', ('anne', 'bart', 'cate', 'dave'))
        self.assertEqual(
            repr(people),
            '<People {anne: 1, bart: 2, cate: 3, dave: 4}>')

    def test_functional_api_2_tuples(self):
        def enumiter():
            start = 1
            while True:
                yield start
                start <<= 1
        flags = Enum('Flags', zip(list('abcdefg'), enumiter()))
        self.assertEqual(
            repr(flags),
            '<Flags {a: 1, b: 2, c: 4, d: 8, e: 16, f: 32, g: 64}>')

    def test_functional_api_dict(self):
        # Note: repr is sorted by attribute name
        bassists = dict(geddy='rush', chris='yes', flea='rhcp', jack='cream')
        self.assertEqual(
            repr(Enum('Bassists', bassists)),
            '<Bassists {chris: yes, flea: rhcp, geddy: rush, jack: cream}>')

    def test_invalid_getitem_arguments(self):
        # getitem on an Enum with invalid value raises an exception.
        class Colors(Enum):
            red = 1
            green = 2
            blue = 3
        with self.assertRaises(ValueError) as cm:
            Colors['magenta']
        self.assertEqual(cm.exception.args, ('magenta',))

    def test_no_duplicates(self):
        with self.assertRaises(ValueError) as cm:
            class Bad(Enum):
                cartman = 1
                stan = 2
                kyle = 3
                kenny = 3 # Oops!
                butters = 4
        self.assertEqual(
            str(cm.exception),
            "Conflicting enum value '3' for names: 'kenny' and 'kyle'")

    def test_no_duplicates_in_subclass(self):
        class Colors(Enum):
            red = 1
            green = 2
            blue = 3
        with self.assertRaises(ValueError) as cm:
            class MoreColors(Colors):
                yellow = 4
                magenta = 2 # Oops!
        self.assertEqual(
            str(cm.exception),
            "Conflicting enum value '2' for names: 'green' and 'magenta'")

    def test_no_duplicates_in_dict(self):
        with self.assertRaises(ValueError) as cm:
            Enum('Things', dict(a='yes', b='no', c='maybe', d='yes'))
        self.assertEqual(
            cm.exception.args[0],
            "Conflicting enum value 'yes' for names: 'a' and 'd'")

    def test_functional_api_not_all_2_tuples(self):
        # If 2-tuples are used, all items must be 2-tuples.
        self.assertRaises(ValueError, Enum, 'Animals', (
            ('ant', 1),
            ('bee', 2),
            'cat',
            ('dog', 4),
            ))
        self.assertRaises(ValueError, Enum, 'Animals', (
            ('ant', 1),
            ('bee', 2),
            ('cat',),
            ('dog', 4),
            ))
        self.assertRaises(ValueError, Enum, 'Animals', (
            ('ant', 1),
            ('bee', 2),
            ('cat', 3, 'oops'),
            ('dog', 4),
            ))

    def test_functional_api_identifiers(self):
        # Ensure that the functional API enforces identifiers.
        with self.assertRaises(ValueError) as cm:
            Enum('Foo', ('1', '2', '3'))
        self.assertEqual(cm.exception.args[0], 'non-identifiers: 1 2 3')
        with self.assertRaises(ValueError) as cm:
            Enum('Foo', (('ant', 1), ('bee', 2), ('3', 'cat')))
        self.assertEqual(cm.exception.args[0], 'non-identifiers: 3')

    def test_functional_api_identifiers_lp1167052(self):
        # LP: #1167052
        self.assertRaises(ValueError, Enum, 'X', 'a-1')

    def test_functional_api_identifiers_numbers(self):
        # There was a typo in IDENTIFIER_RE where the range 0-0 was used.
        MyEnum = Enum('X', 'a9')
        self.assertEqual(MyEnum.a9.name, 'a9')

    def test_deprecate_make(self):
        # LP: #1162375 -- use Enum() calling syntax instead.
        with warnings.catch_warnings(record=True) as seen:
            # In Python 3.3+ we can use self.assertWarns()
            warnings.simplefilter('always')
            Animals = make('Animals', 'ant bee cat'.split())
        self.assertEqual(len(seen), 1)
        self.assertEqual(seen[0].category, DeprecationWarning)
        # We don't need to assert the deprecation message.
        self.assertEqual(Animals.ant.value, 1)

    def test_deprecate_getitem_by_name(self):
        # LP: #1167091
        # Enum[item_name] should be deprecated.
        Fruit = Enum('Fruit', dict(
            apple='red', banana='yellow', tangerine='orange',
            orange='reddish yellow'))
        with warnings.catch_warnings(record=True) as seen:
            # In Python 3.3+ we can use self.assertWarns()
            warnings.simplefilter('always')
            item = Fruit['banana']
        self.assertEqual(len(seen), 1)
        self.assertEqual(seen[0].category, DeprecationWarning)
        # But for now it still works.
        self.assertIs(item, Fruit.banana)
        # getitem() should still access by value, without deprecation warning.
        with warnings.catch_warnings(record=True) as seen:
            # In Python 3.3+ we can use self.assertWarns()
            warnings.simplefilter('always')
            item = Fruit['yellow']
        self.assertEqual(len(seen), 0)
        self.assertIs(item, Fruit.banana)

    def test_explicit_getattr(self):
        Fruit = Enum('Fruit', 'apple banana tangerine orange')
        self.assertIs(getattr(Fruit, 'banana'), Fruit.banana)
        self.assertIs(getattr(Fruit, Fruit.banana.name), Fruit.banana)


class TestIntEnum(unittest.TestCase):
    """Tests of the IntEnums."""

    class Animals(IntEnum):
        ant = 1
        bee = 2
        cat = 3

    def test_issue_17576(self):
        # http://bugs.python.org/issue17576
        #
        # The problem is that despite the documentation, operator.index() is
        # *not* equivalent to calling obj.__index__() when the object in
        # question is an int subclass.
        # Test that while the actual type returned by operator.index() and
        # obj.__index__() are not the same (because the former returns the
        # subclass instance, but the latter returns the .value attribute) they
        # are equal.
        self.assertEqual(index(self.Animals.bee), self.Animals.bee.__index__())

    def test_basic_intenum(self):
        animal_list = [self.Animals.ant, self.Animals.bee, self.Animals.cat]
        self.assertEqual(animal_list, [1, 2, 3])
        self.assertEqual([int(a) for a in animal_list], [1, 2, 3])
        self.assertEqual(
            list(range(10)[self.Animals.ant:self.Animals.cat]),
            [1, 2])

    def test_int_enums_type(self):
        # IntEnum() enum values are ints.
        Toppings = IntEnum(
            'Toppings',
            dict(olives=1, onions=2, mushrooms=4, cheese=8, garlic=16).items())
        self.assertEqual(Toppings.garlic, 16)
        self.assertIsInstance(Toppings.mushrooms, int)

    def test_comparisons(self):
        self.assertTrue(self.Animals.ant < self.Animals.bee)
        self.assertTrue(self.Animals.cat > self.Animals.ant)

        self.assertTrue(self.Animals.ant <= 1.0)
        self.assertEqual(self.Animals.bee, 2)

        class Toppings(IntEnum):
            anchovies = 1
            black_olives = 2
        self.assertEqual(self.Animals.bee, Toppings.black_olives)

    def test_iteration(self):
        # Iteration over IntEnums is by value.
        A = IntEnum('A', 'a b c')
        self.assertEqual(list(v.name for v in A), ['a', 'b', 'c'])
        B = IntEnum('B', 'c b a')
        # Iteration over this enum is different than if it were an Enum.
        self.assertEqual(list(v.name for v in B), ['c', 'b', 'a'])
