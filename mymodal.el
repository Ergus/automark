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

(defgroup mymodal nil
  "Mymodal editing."
  :prefix "mymodal-"
  :group 'tools)

(defcustom mymodal-auto-markers '(forward-word
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

(defcustom mymodal-actions '(kill-ring-save
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


(defvar-local mymodal-last-command nil)
(defvar-local mymodal-marker (make-marker))
(defvar-local mymodal-region-backgrownd-saved nil)

(defun mymodal-exit ()
  "Deactivate mymodal mode."
  (set-marker mymodal-marker nil)
  (setq mymodal-last-command nil)
  (deactivate-mark t))

(defun mymodal-deactivate-mark-hook ()
  "Deactivate Mark hook for mymodal mode."
  (remove-hook 'deactivate-mark-hook #'mymodal-deactivate-mark-hook)
  ;; restore default region background color
  (set-face-attribute 'region nil :background mymodal-region-backgrownd-saved))

(defun mymodal-post-hook ()
  "Post command hook to get the point marker.

The marker info is useful only after a `mymodal-auto-markers'."
  (if (not (eq (marker-position mymodal-marker) (point)))
      (set-marker mymodal-marker (point))
    (remove-hook 'post-command-hook #'mymodal-post-hook)
    (mymodal-exit)))

(defun mymodal-hook ()
  "My modal hook for editing."
  (cond
   ((memq this-command mymodal-auto-markers)           ;; Marker commands
    (if (and (marker-position mymodal-marker)
	     mymodal-last-command)      ;; Already active?
	(unless (eq mymodal-last-command this-command) ;; But change command
	  (push-mark)
	  (setq mymodal-last-command this-command))

      ;; Mode is not active, so, activate?
      (unless (region-active-p)
	(when (color-supported-p "brightblack" nil t)  ;; Change region's background
	  (setq mymodal-region-backgrownd-saved (face-attribute 'region :background))
	  (set-face-attribute 'region nil :background "brightblack")
	  (add-hook 'deactivate-mark-hook #'mymodal-deactivate-mark-hook))
	(add-hook 'post-command-hook #'mymodal-post-hook)

	(push-mark)
	(activate-mark)
	(setq mymodal-last-command this-command))))

   ((memq this-command mymodal-actions)      ;; Action commands,
    ;; add something here to assert we don't go to the latest condition.
    ;; that disables the mode before executing the command.
    nil
    ;; (unless (region-active-p)
    ;;   (setq mymodal-marker t
    ;; 	    mymodal-last-command this-command))
    )

   ((and (marker-position mymodal-marker)       ;; No marker commands.
	 mymodal-last-command
	 (not (eq mymodal-last-command this-command)))
    (mymodal-exit))))

;;;###autoload
(define-minor-mode mymodal-mode
  "Simple auto-selection mymodal-mode mode."
  :global 1
  (if mymodal-mode
      (add-hook 'pre-command-hook #'mymodal-hook)
    (remove-hook 'pre-command-hook #'mymodal-hook)))

(provide 'mymodal)

;;; mymodal.el ends here
