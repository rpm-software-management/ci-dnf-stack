def check_context_table(context, headings):
    if not context.table:
        raise ValueError("Table not specified.")

    if context.table.headings != headings:
        raise ValueError("Invalid table headings. Expected: %s" % ", ".join(headings))
