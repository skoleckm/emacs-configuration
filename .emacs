;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(defun ms-emacs26p () 
 "Checks if we are calling emacs version 26"
  (if (string-match "Emacs 26" (version)) t))

(defun ms-macosxp () 
 "Checks if we are running under mac os x"
 (if  (string-match "apple-darwin" (version)) t))

(defun ms-emacs26-and-macosx-p ()
 "Checks if we are running on mac os x and if version of emacs is 26"
  (and (ms-emacs26p) (ms-macosxp)))

(if (eq (ms-emacs26-and-macosx-p) t) 
(progn 
  (message "emacs26 on mac os x detected")
   ;; make command act as meta
   (setq mac-command-modifier 'meta)
   ;; unbind option key so that it can be used for other purposes - polish chars input for example
   (setq mac-option-modifier 'none)
   ;; make Emacs 26 work on mac. Dragging and dropping a file on a non running
   ;; emacs should cause only this file to open (no additional frames)
   ;; d&d a file on a running emacs should open this file instead of appending
   ;; its contents to an existing buffer. 
   (setq inhibit-startup-screen t)
   (define-key global-map [ns-drag-file] 'my-ns-open-files)
   (defun my-ns-open-files ()
  "Open files in the list `ns-input-file'."
  (interactive)
  (mapc 'find-file ns-input-file)
  (setq ns-input-file nil))
   ;; so that input file events do not cause new frame to be opened
  (setq ns-pop-up-frames nil) 
))

;; set initial frame(window) size
;;(set-frame-height (selected-frame) 100)
;;(set-frame-width (selected-frame) 160)

;; Cause the region to be highlighted and prevent region-based commands
;; from running when the mark isn't active.
(pending-delete-mode t)
 (setq transient-mark-mode t)

;; Cause emacs to ask every time it quits. 
(setq kill-emacs-query-functions
  (list (function (lambda ()
                    (ding)
                    (y-or-n-p "Really quit? ")))))

;;Fonts are automatically highlighted.  For more information
;;type M-x describe-mode font-lock-mode 
(global-font-lock-mode t)

;; standard one was Monaco 12
;; default one can be displayed by running M-x describe-font
(if (eq (ms-emacs26-and-macosx-p) t) 
(set-default-font "Monaco 10"))

;; to see matching parens
(show-paren-mode t)

;; Installs the color theme package
(add-to-list 'load-path "~/.site-lisp/color-theme-6.6.0")
(add-to-list 'load-path "~/.site-lisp/color-theme-6.6.0/themes")
(require 'color-theme)
   (color-theme-initialize)
   (color-theme-midnight)
;; set the color for highlighted region to some dark grey
;; otherwise it is set to ns_selection_color by default which does not work well with 
;; this color theme. 
(set-face-background 'region "#303030")
;; blink cursor because in Emacs 24 on mac os x text under the cursor does not show well
(blink-cursor-mode 1)
;; and set its color so that it's easily visible and the text shows through
(set-face-background 'cursor "#008800")

;; remove the menu and button bars to save screen space
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; set tab distance to something, so it doesn't change randomly and confuse people
(setq c-basic-offset 4)

;; tab 4
(setq default-tab-width 4)

;; tab for nxml mode
(setq nxml-child-indent 4)

;; (for display line number at mode-line)
(line-number-mode t)
;; (for display point in line at mode-line)
(column-number-mode t)

;; Linenum mode enabled by default
(global-linum-mode 1)

;; use cua mode only for rectangles
(setq cua-enable-cua-keys nil) 
(cua-mode t)

;; (for display date and time)
(setq display-time-day-and-date t
      display-time-24hr-format t)
(setq display-time-format "%m/%d(%a) %H:%M")
(display-time)

;; to show full file path - usefull when comparing 2 files of the same name
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; set the calendar to start weeks on monday
(setq calendar-week-start-day 1)

;; have smooth scrolling
(add-to-list 'load-path "~/.site-lisp/smooth-scrolling")
(require 'smooth-scrolling)
(setq smooth-scroll-margin 2)

;; be able to invoke M-x with other shortcut. C-c C-m if I miss C-x
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

;; set the spellchecking program to aspell
;;(setq ispell-program-name "aspell")

;; enable flyspell-mode by default for text mode
;;(add-hook 'text-mode-hook (lambda () (flyspell-mode 1)))

; return a backup file path of a give file path
; with full directory mirroring from a root dir
; non-existant dir will be created
(defun my-backup-file-name (fpath)
  "Return a new file path of a given file path.
   If the new path's directories does not exist, create them."
  (let (backup-root bpath)
    (setq backup-root "~/.emacs.d/emacs-backup")
    (setq bpath (concat backup-root fpath "~"))
    (make-directory (file-name-directory bpath) bpath)
    bpath
  )
)
;; for all those backup~ files
(setq make-backup-file-name-function 'my-backup-file-name)

;; Start emacs as a server so that it can be used by various clients as an editor
(server-start)


;; emacs yaml mode
(if (eq (ms-emacs26-and-macosx-p) t)
    (progn
      (add-to-list 'load-path "~/.site-lisp/yaml")
      (require 'yaml-mode)
      (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
      (add-hook 'yaml-mode-hook
		'(lambda ()
		   (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
      ;; add indent highlights to yaml
      (add-to-list 'load-path "~/.site-lisp/highlight-indent-guides")
      (require 'highlight-indent-guides)
      (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)))


;; tweak registers behaviour to have a way to quickly store point
;; position Allows to move quickly from some point in a file to some
;; other location and then go back I do not need multiple point
;; locations store because it's confusing and I would not remember
;; them anyway
(defun ms-store-point-location-in-register ()
  "store current point position in register P for quick reference"
  (interactive)
  (point-to-register ?P))

(defun ms-jump-point-to-location-in-register ()
  "jump to point position stored in register P"
  (interactive)
  (jump-to-register ?P))

(global-set-key (kbd "C-x r SPC") 'ms-store-point-location-in-register)
(global-set-key (kbd "C-x r j") 'ms-jump-point-to-location-in-register)

; Sets Ctrl-c Ctrl-c key combination for easy commenting
; out of selected lines.
(global-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)

(defun ms-my-python-mode-hook ()
  "My hook for `Python mode'."
  (local-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
  )

(add-hook 'python-mode-hook 'ms-my-python-mode-hook)

;; Settings for Octave Mode
(setq inferior-octave-program "/usr/local/bin/octave")


;; Configure packages for Emacs
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Setting of markdown command, installed separatey through Brew
(setq markdown-command "/usr/local/bin/markdown")

;; End of file.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (markdown-mode ## swift-mode terraform-mode hcl-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
