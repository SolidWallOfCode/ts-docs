from docutils import nodes
from docutils.parsers import rst
from sphinx.domains import Domain
import os.path

def make_ts_github_link(name, rawtext, text, lineno, inliner, options={}, content=[]):
    """
    This docutils role lets us link to source code via the handy :swoc:git: markup.
    """
    url = 'https://github.com/apache/trafficserver/blob/{}/{}'
    ref = 'master'
    node = nodes.reference(rawtext, os.path.basename(text), refuri=url.format(ref, text), **options)
    return [node], []

def make_swoc_docs_github_link(name, rawtext, text, lineno, inliner, options={}, content=[]):
    """
    This docutils role lets us link to source code via the handy :swoc:git: markup.
    """
    url = 'https://github.com/soliwallofcode/ts-docs/blob/{}/{}'
    ref = 'master'
    node = nodes.reference(rawtext, os.path.basename(text), refuri=url.format(ref, text), **options)
    return [node], []

class swoc(Domain):
    name = 'swoc'
    label = 'Solid Wall Of Code'
    data_version = 1

class TSDomain(Domain):
    name = 'ts'
    label = 'Traffic Server'
    data_version = 1

def setup(app):
    rst.roles.register_generic_role('arg', nodes.emphasis)
    rst.roles.register_generic_role('const', nodes.literal)
    rst.roles.register_generic_role('pack', nodes.strong)

    app.add_domain(swoc)
    app.add_domain(TSDomain)

    app.add_role_to_domain('swoc', 'git', make_swoc_docs_github_link)
    app.add_role_to_domain('ts', 'git', make_ts_github_link)
