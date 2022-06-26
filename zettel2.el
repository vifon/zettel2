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

(defun zettel2-get-files ()
  ""
  (directory-files default-directory nil (rx bos
                                             (regexp zettel2-id-regexp)
                                             "--"
                                             (+ (not "/"))
                                             ".org"
                                             eos)))

(defun zettel2-id-to-file (id)
  "Find a file by the zettel ID."
  (pcase (directory-files default-directory nil
                          (rx bos (literal id) "--" (* anything) ".org" eos))
    (`(,file)  file)
    ('()       (error "No file with ID: %S" id))
    (file-list (error "Conflicting file IDs: %S" file-list))))

(defun zettel2-file-id (file)
  "Extract the zettel ID from FILE."
  (string-match (rx (or bos "/")
                    (group (regexp zettel2-id-regexp))
                    "--")
                file)
  (match-string 1 file))

(defun zettel2-new-filename (name)
  "Compute a valid filename for a new note named NAME."
  (format "%s--%s.org"
          (format-time-string zettel2-id-time-format)
          (replace-regexp-in-string "[^a-zA-Z0-9]+" "-" (downcase name))))

(defun zettel2-create-note (title)
  "Create a new note."
  (interactive
   (list (read-from-minibuffer "Title: ")))
  (let ((file-name (zettel2-new-filename title)))
    (find-file-other-window file-name)
    (with-current-buffer (get-file-buffer file-name)
      (insert "#+TITLE: " title "\n\n")
      (goto-char (point-max)))))

(defun zettel2-backrefs ()
  (interactive)
  (unless (bound-and-true-p grep-template)
    (grep-compute-defaults))
  (lgrep (concat ":"
                 (regexp-quote (zettel2-file-id buffer-file-name))
                 "\\(--\\|]\\)")
         (mapconcat #'shell-quote-argument (zettel2-get-files)
                    " ")))


(provide 'zettel2)
;;; zettel2.el ends here
