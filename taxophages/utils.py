from .io import read_document, write_txt

def isolate_field(field_names, data, field_of_interest):
    """
    """

    column = [] # a list of the data in the field that we want to pull out of the data
    stripped_field_names = list(map(lambda i: i.strip(), field_names))
    idx = stripped_field_names.index(field_of_interest)

    for datum in data:
        column.append(datum[idx])

    return column


def make_str_list(lst):
    pre = lst[0:-2]
    comma_joined = ', '.join(pre)

    return comma_joined + ' & ' + lst[-1]
