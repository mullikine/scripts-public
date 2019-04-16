#!/bin/sh
":"; exec emacs --quick -l "$0"

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(kill-buffer "*scratch*")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
    (package-refresh-contents)
      (package-install 'use-package))

(use-package magit
  :ensure t 
  :config
  (let ((pop-up-windows nil))
    (call-interactively 'magit-status)))