zettel2 [name desperately in need of a change]
==============================================

A set of lightweight Emacs functionalities augmenting the `org-mode`
note-taking and note management experience in a non-invasive manner.

A successor to [zettel-mode](https://github.com/vifon/zettel-mode) but
different enough to warrant being a separate project.

`zettel2` focuses on providing a consistent naming scheme, links
resistant to file renaming and a graph showing the relationship
between the notes.  All this while avoiding putting artificial
restrains such as limiting its use to a single directory.

FEATURES
--------

`zettel2` strives to be modular and not impose unnecessary
functionality upon the user.  It contains the following modules:

* `zettel2` contains the base commands and the functions to work with the note IDs.
* `zettel2-mode` is a major mode based on `org-mode` that can be added
  to `auto-mode-alist` as wanted.  This mode modifies `org-mode`
  keymap the expose the `zettel2` functionality in an easy to
  use manner.
* `zettel2-link` provides a custom `org-mode` link type (its format
  being `zettel:ID`) that behaves roughly like the `file:` links but
  contain only the note ID allowing to freely rename the file without
  breaking the link.  The link is additionally decorated to make it
  clear it's an internal link between two notes and not to an
  external resource.
* `zettel2-graph` visualizes the relationship between notes using
  GraphViz.  Tracks both the special `zettel:` links and the standard
  `file:` links.

GOALS
-----

### COMPATIBILITY & FLEXIBILITY

**This system needs to work with any vanilla `org-mode` file, no
special metadata needed.  `zettel2` shouldn't be bound to any specific
directory, its functionality shouldn't assume anything about where the
files are being kept or how many distinct sets of notes we own.**

The only hard requirements concern the filename, not the file
contents.  Namely I've borrowed the excellent naming scheme from
[Denote][1] by Protesilaos Stavrou et al.  Please refer to its
documentation for the details.

[1]: https://protesilaos.com/emacs/denote

Due to how non-invasive it is, `zettel2` composes very well with
various other packages, for example:

- `denote-dired-mode` can be used to decorate the `dired` note listings
- `deft` can be used to search and browse the notes

Some functionalities assume a flat directory structure, i.e. all the
notes in a given set exist in the same directory.
Subdirectories won't break anything per se, though the `zettel:` links
cannot be used between directories (they always look for a given note
ID in the same directory) and the reference graph may be incomplete
(only the current directory is searched for links between the notes).

### RESILIENCE TO MODIFICATION

**The note integrity must be preserved through almost any possible
operation.  As it stands, the only harmful operation is
changing/removal of the note ID (file creation timestamp) from the
filename as it's used for all the linking.**

This is achieved first and foremost by not duplicating any information
that doesn't absolutely need to be duplicated.

The filename contains:

- the note ID
- the machine-readable note title
- tags

The file contents contain:

- the human-readable note title
- the IDs of the linked notes (inside the links)
- optionally: the note ID; this one is actually duplicated from the
  filename but they are immutable anyway and it could be handy in case
  of data recovery or for compatibility with the vanilla `org-mode`

The file contents specifically don't contain:

- the full file names of the linked notes (would break in case of
  a rename or retag)
- the note tags (would be duplicated with the filename and could
  become inconsistent with it)

KEYMAP
------

`zettel2-mode` exposes the following keymap (on top of the regular
`org-mode` one):

- <kbd>C-c C-n</kbd> (`zettel2-create-note`) prompts for a title and
  tags for a new note and creates it according to the
  naming convention.
- <kbd>C-c C-M-r</kbd> (`zettel2-graph`) calculate and display the
  graph of relationships between notes.
- <kbd>C-c C-r</kbd> (`zettel2-backrefs`) show the notes linking to
  the current note using `grep`.
- <kbd>M-n</kbd> (`org-next-link`)
- <kbd>M-p</kbd> (`org-previous-link`)

INSTALLATION
------------

To install `zettel2` mode using `straight.el`, use the following code:

```elisp
(use-package zettel2
  :straight (:host github :repo "vifon/zettel2"
             :files (:defaults "graph.pl"))
  :mode (("/\\.deft/[^/]+\\.org\\'" . zettel2-mode)
         ("/zettels?/[^/]+\\.org\\'" . zettel2-mode))
  :config (progn
            (require 'zettel2-link)
            (setq zettel2-graph-format "png")))
```

This specific configuration associates `zettel2-mode` with all the
`*.org` files inside any directory named `.deft`, `zettel` or
`zettels`.  It also activates the custom link type and sets the
dependency graph format to "png".  This is just an example (that the
author happens to use) and it's perfectly fine to customize it.

Installation with `package.el` wasn't tested.
