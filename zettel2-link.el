;;; zettel2-link.el --- Custom org-mode links for zettel2    -*- lexical-binding: t; -*-

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

;; Custom org-mode links for zettel2 that only reference the note ID.
;; This way the file can be freely renamed without breaking the link.
;;
;; The links are displayed with a distinct prefix
;; (`zettel2-link-text-prefix') to make the internal links immediately
;; obviously different from the external ones.
;;
;; To create a link use the "zettel:" prefix when creating a link with
;; `org-insert-link' (C-c C-l).

;;; Code:

(require 'zettel2)

(require 'org)


(defgroup zettel2-link nil
  "The custom links within `zettel2-mode'."
  :group 'zettel2)

(defcustom zettel2-link-text-prefix "§ "
  "A prefix for titles of links between notes."
  :type 'string)

(defun zettel2-link-follow (link &optional arg)
  (org-link-open-as-file (zettel2-id-to-file link) arg))

(defun zettel2-link-complete ()
  (concat
   "zettel:"
   (zettel2-file-id (completing-read "File: " (zettel2-get-files)))))

;;; XXX: Currently this displays a link prefix by replacing the hidden
;;; leading "[" character of the link with this prefix.  Apart from
;;; being a hack, it seems to persist during a mode change.  Right now
;;; it will suffice, but a better solution is needed.
(defun zettel2-link-make-overlay (start end path bracketp)
  (when bracketp
    (put-text-property start (1+ start)
                       'display zettel2-link-text-prefix)))

(org-link-set-parameters
 "zettel"
 :follow #'zettel2-link-follow
 :complete #'zettel2-link-complete
 :activate-func #'zettel2-link-make-overlay)


(provide 'zettel2-link)
;;; zettel2-link.el ends here
