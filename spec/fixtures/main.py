class Klass:
    klass_attr = 1

    def func(self):
        pass


class Main(object):
    def __init__(self):
        self.inst_attr = 1

    def func(self):
        pass


def decorator(func):
    klass = Klass()

    def wrapped(*a, **k):
        main = Main()
        return func(klass, main, *a, **k)

    return wrapped

identity = lambda i: i


@decorator
def run(*a, **k):
    identity(1)
