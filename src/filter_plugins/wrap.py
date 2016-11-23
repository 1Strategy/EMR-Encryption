# when using, use convert_data:False in lookup per https://github.com/ansible/ansible/issues/11885
def wrap(list):
    return [ '"' + x + '"' for x in list]

class FilterModule(object):
    def filters(self):
        return {
            'wrap': wrap
        }
