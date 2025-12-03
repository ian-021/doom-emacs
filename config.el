;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Cursor configuration - block cursor that blinks in insert mode
(setq evil-insert-state-cursor '(box blink)
      evil-normal-state-cursor 'box
      evil-visual-state-cursor 'box
      evil-motion-state-cursor 'box
      evil-replace-state-cursor 'box
      evil-operator-state-cursor 'box)

;; Dired Config
(setq dired-listing-switches "-alh"
      dired-mouse-drag-files t)

;; whitespace mode
(global-whitespace-mode 1)

(add-to-list 'display-buffer-alist
             '("\\*terminal\\*"
               (display-buffer-at-bottom)
               (window-height . 0.3)))

(add-to-list 'display-buffer-alist
             '("\\*vterm\\*"
               (display-buffer-at-bottom)
               (window-height . 0.3)))



;; C-c t to toggle vterm
(defvar my-term-buffer-name "*vterm*"
  "Name of the terminal buffer to toggle.")

(defvar my-last-buffer nil
  "Store the last buffer before opening terminal.")

(defun my-toggle-term ()
  "Toggle terminal window at bottom."
  (interactive)
  (let* ((term-window (get-buffer-window my-term-buffer-name)))
    (if term-window
        ;; If terminal window is visible, close it and return to previous buffer
        (progn
          (delete-window term-window)
          (when my-last-buffer
            (switch-to-buffer my-last-buffer)))
      ;; If not visible, save current buffer and open terminal
      (progn
        (setq my-last-buffer (current-buffer))
        (if (get-buffer my-term-buffer-name)
            (progn
              (display-buffer my-term-buffer-name)
              (select-window (get-buffer-window my-term-buffer-name)))
          (progn
            (vterm)
            (select-window (get-buffer-window my-term-buffer-name))))))))

;; Bind C-c t to toggle terminal
(global-set-key (kbd "C-c t") #'my-toggle-term)

;; Disable evil mode in vterm completely
(add-hook 'vterm-mode-hook
          (lambda ()
            (when (bound-and-true-p evil-local-mode)
              (evil-local-mode -1))
            (when (bound-and-true-p evil-collection-mode)
              (evil-collection-mode -1))))

;; Disable evil-snipe and remap 's' to avy-goto-char-timer
;; Must be done in after! block to ensure it happens after evil-snipe loads
(after! evil-snipe
  (evil-snipe-mode -1))

;; Remap 's' to avy-goto-char-timer
;; Set the keybinding immediately; avy will autoload when the key is pressed
(map! :n "s" #'avy-goto-char-timer
      :m "s" #'avy-goto-char-timer)

;; Auto-run doom/reload at startup to ensure keybindings work
(add-hook 'emacs-startup-hook #'doom/reload)

;; Disable h/l navigation in dired/dirvish
;; Prefer using Enter to open files/directories and C-x C-j for jump-to-dired
;; To re-enable: comment out the code below
;;   Default: "h" -> #'dired-up-directory, "l" -> #'dired-find-file
(use-package! dirvish
  :config
  (map! :map dirvish-mode-map
        :n "h" nil
        :n "l" nil))
