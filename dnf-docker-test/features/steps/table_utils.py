from __future__ import absolute_import
from __future__ import unicode_literals

import collections
import enum

from behave.model import Table
from behave.model import Row

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

def convert_table_kv_to_skv(table, new_headings, new_column):
    """
    Convert kv based table to skv based table by adding one extra column.

    :param behave.model.Table table: Original kv based table
    :param list new_headings: Headings for the skv based table (3 elements, where 2 of them are also in the original table)
    :param list new_column: Strings to be added as the new column (empty string is used when there is not enough items)
    :return: New skv based table
    :rtype: behave.model.Table
    """
    headings = table.headings
    new_column_index = new_headings.index(list(set(new_headings) - set(headings))[0])
    i = 0
    new_rows = []
    for row in table.rows:
        value = new_column[i] if i < len(new_column) else ""
        i += 1
        new_values = row.cells[:]
        new_values.insert(new_column_index, value)
        new_row = Row(new_headings, new_values)
        new_rows.append(new_row)
    new_table = Table(new_headings, rows=new_rows)
    return new_table
