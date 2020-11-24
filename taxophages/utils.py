from .io import read_document, write_txt

def isolate_field(field_names, data, field):
    """Assumes the first row is the fieldnames"""
    column = []
    stripped_field_names = list(map(lambda i: i.strip(), field_names))
    idx = stripped_field_names.index(field)

    for datum in data:
        column.append(datum[idx])

    return column


