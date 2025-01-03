# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'gupje'
copyright = '2024, Eljakim'
author = 'Eljakim'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [  'myst_parser',
                'sphinx_wagtail_theme',
                'sphinx.ext.todo',
                'sphinxcontrib.confluencebuilder',
                "sphinxcontrib.drawio",
]

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_wagtail_theme'
html_static_path = ['_static']


project = "Gupje"

# These are options specifically for the Wagtail Theme.
html_theme_options = dict(
    project_name = "Gupje",
    # logo = "img/wagtail-logo-circle.svg",
    logo_alt = "Gupje",
    logo_height = 59,
    logo_url = "/",
    logo_width = 45,
)
