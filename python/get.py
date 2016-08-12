#!/usr/bin/python3

import sys
from getopt import getopt
import xml.etree.ElementTree as ET
from basis import Basis
import algorithm
import xmlify
import links
import reinforcement
import logger

def do_search(tup, number, selector = None, **key):
    if number <= 0:
        return []
    if selector is None:
        selector = links.NoDupLinkSelector()
    base_script, match_func = tup
    spider = algorithm.Spider(selector = selector, **key)
    arr = []
    for i in range(0, number):
        base = base_script()
        curr = spider.crawl_times(base, match_func)
        if curr:
            arr.append(curr)
    spider.finished()
    return arr

def make_sel(keyword, rein):
    if rein:
        return reinforcement.ReinLinkSelector(keyword)
    else:
        return links.NoDupLinkSelector()

if __name__ == '__main__':
    args = dict(getopt(sys.argv[1:], "c:p:P:w:m:a:f:d:r")[0])
    celebs = int(args.get("-c", "0"))
    people = int(args.get("-p", "0"))
    places = int(args.get("-P", "0"))
    weapons = int(args.get("-w", "0"))
    monsters = int(args.get("-m", "0"))
    animals = int(args.get("-a", "0"))
    foods = int(args.get("-f", "0"))
    debug = int(args.get("-d", "0"))
    logger.set_global_debug_level(debug)
    rein = "-r" in args
    parts = {
        'celebs':    do_search(Basis.celebrity, celebs  , make_sel('people',   rein)),
        'people':    do_search(Basis.person   , people  , make_sel('people',   rein)),
        'places':    do_search(Basis.place    , places  , make_sel('places',   rein)),
        'weapons':   do_search(Basis.weapon   , weapons , make_sel('weapons',  rein)),
        'monsters':  do_search(Basis.monster  , monsters, make_sel('monsters', rein)),
        'animals':   do_search(Basis.animal   , animals , make_sel('animals',  rein)),
        'foods':     do_search(Basis.food     , foods   , make_sel('foods',    rein)),
    }
    print(ET.tostring(xmlify.xmlify(parts)).decode())
