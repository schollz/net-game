
from getopt import getopt, GetoptError
from basis import Basis
from logger import echo

class Arguments:
    """
    The Arguments class manages the somewhat unwieldy collection of command line arguments that the
    Stage 1 program is expected to be able to handle.
    """

    def __init__(self, argv, arg_set):
        """
        Parses the argument list using getopt. The specific allowable arguments should be
        passed as the second argument, as a value of the form ArgSet.TOPLEVEL or
        ArgSet.LEGACY.
        """
        try:
            arglist = "c:p:P:w:m:a:f:r" if arg_set is ArgSet.LEGACY else "d:e:"
            self._args = dict(getopt(argv, arglist)[0])
        except GetoptError as e:
            self._args = {}
            echo("Error in arguments:", e)

    def celebs(self):
        return int(self._args.get("-c", "0"))

    def people(self):
        return int(self._args.get("-p", "0"))

    def places(self):
        return int(self._args.get("-P", "0"))

    def weapons(self):
        return int(self._args.get("-w", "0"))

    def monsters(self):
        return int(self._args.get("-m", "0"))

    def animals(self):
        return int(self._args.get("-a", "0"))

    def foods(self):
        return int(self._args.get("-f", "0"))

    def rein(self):
        return "-r" in self._args

    def debug(self):
        return int(self._args.get("-d", "0"))

    def expr(self):
        return self._args.get("-e", None)

    def standard_sequence(self):
        return [
            ArgEntry(key = 'celebs'  , basis = Basis.celebrity, count = self.celebs()   , selector = 'people'),
            ArgEntry(key = 'people'  , basis = Basis.person   , count = self.people()  ),
            ArgEntry(key = 'places'  , basis = Basis.place    , count = self.places()  ),
            ArgEntry(key = 'weapons' , basis = Basis.weapon   , count = self.weapons() ),
            ArgEntry(key = 'monsters', basis = Basis.monster  , count = self.monsters()),
            ArgEntry(key = 'animals' , basis = Basis.animal   , count = self.animals()  , rein = False),
            ArgEntry(key = 'foods'   , basis = Basis.food     , count = self.foods()    , rein = False),
        ]

class ArgEntry:

    def __init__(self, *, key, basis, count, selector = None, rein = True):
        self.key = key
        self.basis = basis
        self.count = count
        self.selector = selector or self.key
        self.rein = rein

class ArgSet:
    TOPLEVEL = object()
    LEGACY   = object()
