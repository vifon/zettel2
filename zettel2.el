;;; zettel2.el --- Helpers for note organization     -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Wojciech Siewierski

;; Author: Wojciech Siewierski
;; Keywords: outlines, org-mode, convenience
;; Version: 0.9
;; Package-Requires: ((emacs "28.1") (org "9.5"))

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

;; Helpers for note organization.

;; Install with:

;; (use-package zettel2
;;   :straight (:host github :repo "vifon/zettel2"
;;              :files (:defaults "graph.pl"))
;;   :mode (("/\\.deft/[^/]+\\.org\\'" . zettel2-mode)
;;          ("/zettels?/[^/]+\\.org\\'" . zettel2-mode))
;;   :config (require 'zettel2-link))

;;; Code:


(defgroup zettel2 nil
  "Helpers for note organization."
  :group 'outlines)

(defconst zettel2-id-time-format "%Y%m%dT%H%M%S"
  "The prefix used for the filenames of created files.

Passed to `format-time-string'.")

(defconst zettel2-id-regexp
  (rx (= 8 digit) "T" (= 6 digit)))

(defcustom zettel2-frontmatter-template "\
:PROPERTIES:
:ID:          %i
:END:
#+TITLE:      %t

"
  "The frontmatter template passed to `format-spec'.

%i is replaced with the note ID.
%t is replaced with the note title.

Not all identifiers need to be used, but setting the title is
highly recommended."
  :type 'string)

(defun zettel2-all-notes (&optional directory)
  "List all the valid notes in DIRECTORY or the current directory."
  (directory-files
   (or directory default-directory)
   nil
   (rx bos
       (regexp zettel2-id-regexp)
       "--"
       (+ (not "/"))
       ".org"
       eos)))

(defun zettel2-all-tags (&optional directory)
  "List all the tags present in DIRECTORY in lexicographical order."
  (sort (seq-uniq
         (mapcan (lambda (file)
                   (split-string
                    (replace-regexp-in-string ".*__\\([^.]+\\)\\.org"
                                              "\\1"
                                              file)
                    "_"))
                 (zettel2-all-notes directory)))
        #'string<))

(defun zettel2-get-note-by-id (id)
  "Find a file by the note ID."
  (pcase (directory-files default-directory nil
                          (rx bos (literal id) "--" (* anything) ".org" eos))
    (`(,file)  file)
    ('()       (error "No file with ID: %S" id))
    (file-list (error "Conflicting file IDs: %S" file-list))))

(defun zettel2-file-id (file)
  "Extract the note ID from FILE."
  (string-match (rx (or bos "/")
                    (group (regexp zettel2-id-regexp))
                    "--")
                file)
  (match-string 1 file))

(defun zettel2-sanitize-name (name &optional tags)
  "Compute a valid filename for a new note named NAME."
  (format "%s--%s%s.org"
          (format-time-string zettel2-id-time-format)
          (replace-regexp-in-string "[^a-zA-Z0-9]+" "-" (downcase name))
          (if tags
              (concat "__" (string-join tags "_"))
            "")))

(defun zettel2-create-note (title &optional tags)
  "Create a new note with a given TITLE and TAGS."
  (interactive
   (list
    (read-from-minibuffer "Title: ")
    (completing-read-multiple "Tags: "
                              (zettel2-all-tags))))
  (let ((file-name (zettel2-sanitize-name title tags)))
    (find-file-other-window file-name)
    (with-current-buffer (get-file-buffer file-name)
      (insert (format-spec zettel2-frontmatter-template
                           `((?i . ,(zettel2-file-id file-name))
                             (?t . ,title))))
      (goto-char (point-max)))))

(defun zettel2-backrefs ()
  "Show the notes referencing this one using `grep'."
  (interactive)
  (unless (bound-and-true-p grep-template)
    (grep-compute-defaults))
  (lgrep (concat ":"
                 (regexp-quote (zettel2-file-id buffer-file-name))
                 "\\(--\\|]\\)")
         (mapconcat #'shell-quote-argument (zettel2-all-notes)
                    " ")))


(provide 'zettel2)
;;; zettel2.el ends here
