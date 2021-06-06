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
				  beginning-of-buffer
				  end-of-buffer
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
(defvar-local mymodal-marked nil)

(defun mymodal-hook ()
  "My modal hook for editing."
  (cond
   ((memq this-command mymodal-auto-markers) ;; Marker commands
    (if (and mymodal-marked
	     mymodal-last-command)
	(unless (eq mymodal-last-command this-command)
	  (push-mark)
	  (setq mymodal-last-command this-command)))
    (unless (region-active-p)
      (push-mark)
      (activate-mark)
      (setq mymodal-marked t
	    mymodal-last-command this-command)))

   ((memq this-command mymodal-actions)      ;; Action commands
    (unless (region-active-p)
      (setq mymodal-marked t
	    mymodal-last-command this-command)))

   ((and mymodal-marked                      ;; No marker commands.
	 mymodal-last-command
	 (not (eq mymodal-last-command this-command)))
    (setq mymodal-marked nil
	  mymodal-last-command nil)
    (deactivate-mark t))))

;;;###autoload
(define-minor-mode mymodal-mode
  "Simple auto-selection mymodal-mode mode."
  :global 1
  (if mymodal-mode
      (add-hook 'pre-command-hook #'mymodal-hook)
    (remove-hook 'pre-command-hook #'mymodal-hook)))

(provide 'mymodal)

;;; mymodal.el ends here
