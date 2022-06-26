;;; zettel2-graph.el --- Generate GraphViz graphs of the references between notes    -*- lexical-binding: t; -*-

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

;; `zettel2-graph' generates a GraphViz file representing how the
;; notes in the current directory are connected.
;;
;; `zettel2-graph-file' stores the path to the intermediate .dot
;; output file.  It can be either relative or absolute, but relative
;; probably makes more sense.
;;
;; `zettel2-graph-format' can be customized to generate a secondary
;; file from the .dot file.  Consider setting it to "pdf" or "png" if
;; the default standalone graph viewer is insuficient.
;;
;;
;; Internally the graph is generated by the script that should be
;; present in `zettel2-graph-script'.

;;; Code:

(require 'executable)


(defgroup zettel2-graph nil
  "The graphing capabilities within `zettel2-mode'."
  :group 'zettel2)

(defcustom zettel2-graph-file "./graph.dot"
  "The file to store the GraphViz graph of references."
  :type 'file)

(defconst zettel2-graph-script
  (expand-file-name "graph.pl"
                    (file-name-directory
                     (or load-file-name
                         buffer-file-name)))
  "Path to the script generating the graph.")

(defcustom zettel2-graph-format 'standalone
  "The output format of the GraphViz graph of references.

If set to a string, this value will be used like this:
$ dot -T{format} -o {name}.{format}

Can also be set to the symbol `standalone' to use -Tx11 with no
external files and their readers necessary."
  :type '(choice
          (const :tag "standalone" 'standalone)
          (string)))

(defun zettel2-graph-update (&rest args)
  "Recreate `zettel2-graph-file' and generate a PDF from it.

ARGS are passed to `zettel2-graph-file'.

Saves the current buffer before generating the graph."
  (interactive)
  (save-buffer)
  (let ((graph-file (expand-file-name zettel2-graph-file)))
    (apply #'call-process
           zettel2-graph-script nil `(:file ,graph-file) nil args)
    (let ((buffer-file-name graph-file))
      (executable-chmod))
    (unless (eq zettel2-graph-format 'standalone)
      (call-process "dot" nil 0 nil graph-file
                    (concat "-T" zettel2-graph-format)
                    "-o"
                    (file-name-with-extension graph-file
                                              zettel2-graph-format)))))

(defun zettel2-graph-display (&optional format)
  "Display the graph in a given FORMAT."
  (interactive)
  (let ((format (or format zettel2-graph-format)))
    (if (eq format 'standalone)
        (let ((graph-file (expand-file-name zettel2-graph-file)))
          (call-process graph-file nil 0 nil))
      (let ((graph-file (file-name-with-extension zettel2-graph-file
                                                  format)))
        (call-process "xdg-open" nil 0 nil graph-file)))))

;;;###autoload
(defun zettel2-graph (&optional arg)
  "Update and display the graph of references.

With `\\[universal-argument]' don't show the tags on the graph.
For some use cases it's more readable this way.

With `\\[universal-argument] \\[universal-argument]' only update
the graph, don't (re)display it."
  (interactive "P")
  (cond
   ((null arg)
    (zettel2-graph-update)
    (zettel2-graph-display))
   ((equal arg '(4))
    (zettel2-graph-update "--no-tags")
    (zettel2-graph-display))
   ((equal arg '(16))
    (zettel2-graph-update))))


(provide 'zettel2-graph)
;;; zettel2-graph.el ends here
