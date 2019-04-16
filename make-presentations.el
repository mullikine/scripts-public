#!/usr/bin/emacs --script

;; This is OK but racket is better for presentations

(require 'ox-latex)

;; Define an interactive function for easy testing
(defun org-beamer-export-to-pdf-directory (files)
  "Export all files to latex"
  (interactive "Export org files to tex")
  (save-excursion
    (let ((org-files-lst ))
      (dolist (org-file files)
        (message "*** Exporting file %s ***" org-file)
        (find-file org-file)
        (org-beamer-export-to-pdf)
        (kill-buffer)))))

;; Use utf8x for LaTeX export to access more unicode characters
(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))

;; Export all org files given on the command line
(org-beamer-export-to-pdf-directory argv)
