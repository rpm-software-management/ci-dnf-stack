from __future__ import absolute_import
from __future__ import unicode_literals

import collections
import enum

__all__ = [
    "parse_kv_table",
    "parse_skv_table",
]

def is_allowed(ctx, key, allowed_keys):
    if not allowed_keys:
        return key
    msg = "Key {!r} is not allowed".format(key)
    if isinstance(allowed_keys, enum.EnumMeta):
        ctx.assertion.assertTrue(hasattr(allowed_keys, key), msg)
        return allowed_keys[key]
    ctx.assertion.assertIn(key, allowed_keys, msg)
    return key

def parse_kv_table(ctx, headings, allowed_keys=None):
    """
    Parse key/value table.

    :param behave.runner.Context ctx: Context
    :param list headings: Table headings
    :return: Parsed table
    :rtype: dict(str: str)
    """
    ctx.assertion.assertEqual(len(headings), 2,
                              "Headings must contain 2 elements")
    ctx.assertion.assertIsNotNone(ctx.table, "Table is not provided")
    ctx.assertion.assertEqual(ctx.table.headings, headings)

    table = {}
    for key, value in ctx.table:
        key = is_allowed(ctx, key, allowed_keys)
        ctx.assertion.assertNotIn(key, table,
                                  "Duplicate key: {!r}".format(key))
        table[key] = value
    return table

def parse_skv_table(ctx, headings, allowed_keys=None, repeating_keys=None):
    """
    Parse section/key/value table.

    :param list headings: Table headings (3 elements)
    :param list allowed_keys: Keys which can be used
    :param list repeating_keys: Keys which can be repeated
    :return: Parsed table
    :rtype: collections.OrderedDict(str: str)
    """
    ctx.assertion.assertEqual(len(headings), 3,
                              "Headings must contain 3 elements")
    ctx.assertion.assertIsNotNone(ctx.table, "Table is not provided")
    ctx.assertion.assertEqual(ctx.table.headings, headings)

    sections = collections.OrderedDict()
    last_section = None
    for section, key, value in ctx.table:
        if not section:
            section = last_section
        else:
            last_section = section
        ctx.assertion.assertIsNotNone(last_section,
                                      "Empty section in first line")
        if section not in sections:
            sections[section] = {}
            sect = sections[section]
        if not key:
            ctx.assertion.assertIsNotNone(value, "Value with empty key")
            continue
        key = is_allowed(ctx, key, allowed_keys)
        if repeating_keys and key in repeating_keys:
            if key not in sect:
                sect[key] = [value]
            else:
                sect[key].append(value)
        else:
            ctx.assertion.assertNotIn(key, sect,
                                      "Duplicate key: {!r}".format(key))
            sect[key] = value

    return sections
