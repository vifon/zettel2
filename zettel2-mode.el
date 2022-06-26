;;; zettel2-mode.el --- A major mode for easy access to zettel2 functionality    -*- lexical-binding: t; -*-

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

;; A major mode based on org-mode exposing the zettel2 functionality.

;;; Code:

(require 'zettel2)

(require 'org)


(defgroup zettel2-mode nil
  "A mode exposing the zettel2 functionality."
  :group 'zettel2)

(declare-function zettel2-graph "zettel2-graph")

(defvar zettel2-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-n") #'zettel2-create-note)
    (define-key map (kbd "C-c C-M-r") #'zettel2-graph)
    (define-key map (kbd "C-c C-r") #'zettel2-backrefs)
    (define-key map (kbd "M-n") #'org-next-link)
    (define-key map (kbd "M-p") #'org-previous-link)
    map))

;;;###autoload
(define-derived-mode zettel2-mode org-mode "Zettel"
  "A mode for Zettelkasten-style note-taking based on `org-mode'.")


(provide 'zettel2-mode)
;;; zettel2-mode.el ends here