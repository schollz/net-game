#!/usr/bin/python3

# ///// Wouldn't it be nice if we could (from Lisp with godmode on) request pages using the expression syntax?

import sys
import xml.etree.ElementTree as ET
from arguments import Arguments, ArgSet
import xmlify
import links
import reinforcement
import logger
import search
import command
from tokenizer import TokenizeError

def make_sel(keyword, rein):
    """Constructs a simple selector or reinforcement learning selector, depending on arguments."""
    if rein:
        return reinforcement.ReinLinkSelector(keyword)
    else:
        return links.NoDupLinkSelector()

def produce_result(args, mod = (lambda x: x), selector = None, **key):
    """
    Runs all of the algorithms given in the Arguments object, using the basis modifier to augment each
    basis. The basis modifier should be a 1-argument callable which takes a basis and returns a new
    basis, and it should be side-effect free.
    """
    rein = args.rein()

    parts = {}
    for arg in args.standard_sequence():
        if arg.count <= 0:
            continue
        sel = selector or make_sel(arg.selector, rein and arg.rein)
        searcher = search.BasicSearch(basis = mod(arg.basis), number = arg.count, selector = sel, keys = key)
        parts[arg.key] = searcher.run()
    return xmlify.xmlify(parts)


def standard_run(args):
    print(ET.tostring(produce_result(args)).decode())

def unit_run(args):
    unit = args.unit().strip()

    def basis_transformer(b):
        return b.with_page(lambda: unit)

    print(ET.tostring(
        produce_result(
            args,
            mod = basis_transformer,
            selector = links.AbortLinkSelector(),
            max_tries = 1
        )
    ).decode())

def expr_run(args):
    try:
        exprs = command.read(args.expr())
        parts = {}
        for expr in exprs:
            search.CommandSearch(expr, parts).run()
        print(ET.tostring(xmlify.xmlify(parts)).decode())
    except TokenizeError as e:
        logger.echo(str(e))
        print("<data />")

if __name__ == '__main__':
    args = Arguments(sys.argv[1:], ArgSet.TOPLEVEL)
    logger.set_global_debug_level(args.debug())
    # TODO We should report an error if -u and -e are both supplied, probably.
    if args.unit():
        unit_run(args)
    elif args.expr():
        expr_run(args)
    else:
        standard_run(args)
