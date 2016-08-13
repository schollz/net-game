
class Keywords:
    _key = None
    @staticmethod
    def _load_file():
        Keywords._key = dict()
        state = ""
        with open("./data/keywords.txt") as f:
            data = f.read()
        for curr in data.split("\n"):
            if curr == "":
                continue
            if curr[:3] == ":: ":
                state = curr[3:]
            else:
                Keywords._key[state] = Keywords._key.get(state, []) + [curr]
    @staticmethod
    def check_match(key, c):
        """
        Attempt to match the category c against the match words associated with the keyword key
        provided. Returns whether any matches were found
        """
        if not Keywords._key:
            Keywords._load_file()
        for x in Keywords._key[key]:
            if x in c.lower(): # TODO Whole words only? Consider the consequences if we switched to that
                return True
        return False
