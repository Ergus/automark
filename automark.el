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
			     composable-kill-region
			     composable-kill-ring-save
			     composable-indent-region
			     composable-comment-dwim
			     composable-upcase-region
			     composable-downcase-region
			     composable-delete-region)
  "List of actions that don't deactivate our mark.

These are the commands that perform some actions."
  :type 'hook)


(defvar-local automark-last-command nil)
(defvar-local automark-marker (make-marker))
(defvar-local automark-region-backgrownd-saved nil)

(defun automark-exit ()
  "Deactivate automark mode."
  (set-marker automark-marker nil)
  (setq automark-last-command nil)
  (deactivate-mark t))

(defun automark-deactivate-mark-hook ()
  "Deactivate Mark hook for automark mode."
  (remove-hook 'deactivate-mark-hook #'automark-deactivate-mark-hook)
  ;; restore default region background color
  (set-face-attribute 'region nil :background automark-region-backgrownd-saved))

(defun automark-post-hook ()
  "Post command hook to get the point marker.

The marker info is useful only after a `automark-auto-markers'."
  (if (not (eq (marker-position automark-marker) (point)))
      (set-marker automark-marker (point))
    (remove-hook 'post-command-hook #'automark-post-hook)
    (automark-exit)))

(defun automark-hook ()
  "My modal hook for editing."
  (cond
   ((memq this-command automark-auto-markers)           ;; Marker commands
    (if (and (marker-position automark-marker)
	     automark-last-command)      ;; Already active?
	(unless (eq automark-last-command this-command) ;; But change command
	  (push-mark)
	  (setq automark-last-command this-command))

      ;; Mode is not active, so, activate?
      (unless (region-active-p)
	(when (color-supported-p "brightblack" nil t)  ;; Change region's background
	  (setq automark-region-backgrownd-saved (face-attribute 'region :background))
	  (set-face-attribute 'region nil :background "brightblack")
	  (add-hook 'deactivate-mark-hook #'automark-deactivate-mark-hook))
	(add-hook 'post-command-hook #'automark-post-hook)

	(push-mark)
	(activate-mark)
	(setq automark-last-command this-command))))

   ((memq this-command automark-actions)      ;; Action commands,
    ;; add something here to assert we don't go to the latest condition.
    ;; that disables the mode before executing the command.
    nil
    ;; (unless (region-active-p)
    ;;   (setq automark-marker t
    ;; 	    automark-last-command this-command))
    )

   ((and (marker-position automark-marker)       ;; No marker commands.
	 automark-last-command
	 (not (eq automark-last-command this-command)))
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
