;;; zettel2-frontmatter.el --- Frontmatter templates for zettel2   -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Wojciech Siewierski

;; Author: Wojciech Siewierski
;; Keywords: outlines, org-mode, convenience
;; Version: 0.9

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Frontmatter templates for zettel2.

;;; Code:

(require 'org)


(defgroup zettel2-frontmatter nil
  "Frontmatter templates for zettel2."
  :group 'zettel2)


(defconst zettel2-frontmatter-simple "#+TITLE: %t\n\n")
(defconst zettel2-frontmatter-with-id "\
:PROPERTIES:
:ID:          %i
:END:
#+TITLE:      %t

"
  "Compatible with `org-mode' IDs, but might break the `deft' title detection.")
(defconst zettel2-frontmatter-with-date "\
#+TITLE: %t
#+DATE: %d

"
  "A human readable date.

Duplicated from the ID in the filename for the user convenience.")


(defcustom zettel2-frontmatter-template zettel2-frontmatter-simple
  "The frontmatter template passed to `format-spec'.

%i is replaced with the note ID.
%t is replaced with the note title.
%d is replaced with the note creation date.

Not all identifiers need to be used, but setting the title is
highly recommended."
  :type `(choice
          (const :tag "Simple" ,zettel2-frontmatter-simple)
          (const :tag "With ID" ,zettel2-frontmatter-with-id)
          (const :tag "With date" ,zettel2-frontmatter-with-date)
          (string :tag "Custom")))

(defun zettel2-frontmatter-format-spec (id title &optional time)
  "Generate the alist for `format-spec'.

ID, TITLE and TIME are the corresponding metadata of the file."
  `((?i . ,id)
    (?t . ,title)
    (?d . ,(format-time-string (org-time-stamp-format) time))))


(provide 'zettel2-frontmatter)
;;; zettel2-frontmatter.el ends here
