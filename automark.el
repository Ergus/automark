;;; mymodal.el --- Simle modal editing     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jimmy Aguilar Mena

;; Author: Jimmy Aguilar Mena
;; Homepage: 
;; Keywords: tools
;; Package-Requires: ((emacs "25.1"))
;; Version: 0

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

;; Personalized editing improvement.

;;; Code:

;;; package --- Sumary

(defgroup automark nil
  "Automark editing."
  :prefix "automark-"
  :group 'tools)

(defcustom automark-auto-markers '(forward-word
				  backward-word
				  forward-list
				  backward-list
				  ;;beginning-of-buffer
				  ;;end-of-buffer
				  back-to-indentation
				  move-beginning-of-line
				  move-end-of-line
				  my/smart-beginning-of-line)
  "List of automarker commands.

 The commands here are expected to be displacement commands."
  :type 'hook)

(defcustom automark-actions '(kill-ring-save
			     kill-region
			     delete-region
			     backward-delete-char-untabify
			     set-mark-command ;; this one is actually a trick
			     yank)
  "List of actions that don't deactivate our mark.

These are the commands that perform some actions."
  :type 'hook)

(defcustom automark-actions-regex "^composable-"
  "A regex of command names that may be considered as action commands.

This variable is checked after `automark-actions' and they work
together to provide more flexibility to the user."
  :type 'string)


(defvar-local automark-marker (make-marker))
(defvar-local automark-region-face-cookie nil)

(defun automark-exit ()
  "Deactivate automark mode."
  (set-marker automark-marker nil)
  (remove-hook 'post-command-hook #'automark-post-hook)
  (deactivate-mark t))

(defun automark-deactivate-mark-hook ()
  "Deactivate Mark hook for automark mode."
  (remove-hook 'deactivate-mark-hook #'automark-deactivate-mark-hook)
  (when (eq this-command 'keyboard-quit)
    (exchange-point-and-mark t))
  ;; restore default region background color
  (face-remap-remove-relative automark-region-face-cookie))

(defun automark-post-hook ()
  "Post command hook to get the point marker.

The marker info is useful only after a `automark-auto-markers'."
  (if (not (eq (marker-position automark-marker) (point)))
      (set-marker automark-marker (point))
    (automark-exit)))

(defun automark-hook ()
  "My modal hook for editing."
  (cond
   ((memq this-command automark-auto-markers)           ;; Marker commands
    (if (marker-position automark-marker)
	;; if automark is already active just update mark position
	(push-mark nil t)

      ;; Mode is not active, so, activate?
      (unless (region-active-p)
	(when (color-supported-p "brightblack" nil t)  ;; Change region's background
	  (setq automark-region-face-cookie
		(face-remap-add-relative 'region :background "brightblack"))
	  (add-hook 'deactivate-mark-hook #'automark-deactivate-mark-hook))
	;; Add the post command hook.
	(add-hook 'post-command-hook #'automark-post-hook)

	(push-mark nil t t))))

   ;; Condition to exit earlier and not disable the mode before the
   ;; action command.
   ((or (not (marker-position automark-marker))    ;; Mode is inactive
	(memq this-command automark-actions)
	(and (stringp automark-actions-regex)      ;; not a command in regex
	     (not (string= automark-actions-regex ""))
	     (string-match-p automark-actions-regex (symbol-name this-command))))      ;; Action commands,
    nil)

   (t ;; Otherwise exit the mode.
    (automark-exit))))

;;;###autoload
(define-minor-mode automark-mode
  "Simple auto-selection automark-mode mode."
  :global 1
  (if automark-mode
      (add-hook 'pre-command-hook #'automark-hook)
    (remove-hook 'pre-command-hook #'automark-hook)))

(provide 'automark)

;;; automark.el ends here
