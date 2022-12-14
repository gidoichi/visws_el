;;; visws.el --- Make whitespace visible
;;
;; Copyright (C) 2001 Free Software Foundation, Inc.
;;
;; Author: Miles Bader <miles@gnu.org>
;; Keywords: convenience

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;;
;; Defines the mode `visible-whitespace-mode'.
;;
;; When active, normally invisible whitespace characters are made visible.

;;; Code:

(defgroup visible-whitespace nil
  "Group for visible-whitespace.")

(defface visible-whitespace '((t :foreground "blue" :bold t))
  "Face for control-characters revealed by `visible-whitespace-mode'.")
(defvar visible-whitespace 'visible-whitespace
  "Symbol face used to make whitespace visible.")
(make-obsolete-variable 'visible-whitespace "use the face instead." "24.4")

(defcustom visible-whitespace-mappings
  '((?\n [?$ ?\n])
    ;; Note that TAB still tabs, but with a graphic indicator before the
    ;; tab; we only use single-character graphic indicator to reduce the
    ;; number of cases where the indicator causes the tabbing to be
    ;; screwed up.
    (?\t [?? ?\t] [?\\ ?\t])
    (?   [??] [?.]))
  "An alist of mappings for displaying whitespace in `visible-whitespace-mode'.

The car of each mapping is a whitespace character, and the cdr is a list of
display vectors (a vector of characters).  The first display vector the
list that can be displayed is used; if no display vector for a mapping can
be displayed, then that character is displayed unmodified.

The characters in are displayed using the `visible-whitespace' face."
  :type 'list)

(defun visws-legal-display-vector-p (vec)
  "Return true if every character in the display vector VEC can be displayed."
  (let ((i 0) (len (length vec)))
    (while (and (< i len) (char-displayable-p (aref vec i)))
      (setq i (1+ i)))
    (= i len)))

;; Buffer local variable used to remember whether a buffer initially had
;; a local display table or not.
(defvar visws-display-table-was-local nil)

(defvar visws-font-lock-keywords nil
  "Used to save keywords adds to `font-lock-keywords'.")

;;;###autoload
(define-minor-mode visible-whitespace-mode
  "Toggle Visible Whitespace mode.
When active, normally invisible whitespace characters are made visible.

With prefix argument ARG, turn on if positive, otherwise off.
Returns non-nil if the new state is enabled."
  :init-value nil
  :lighter " VisWS"
  :keymap nil
  (when visible-whitespace-mode
    (setq-local visws-font-lock-keywords nil)
    (set (make-local-variable 'visws-display-table-was-local)
         buffer-display-table)
    (unless buffer-display-table
      (setq buffer-display-table (make-display-table)))
    (let ((keywords '()))
      (dolist (entry visible-whitespace-mappings)
        (let ((vecs (cdr entry)))
          (while (and vecs (not (visws-legal-display-vector-p (car vecs))))
            (setq vecs (cdr vecs)))
          (when vecs
            (add-to-list 'keywords `(,(format "%c" (car entry)) (0 visible-whitespace t)))
            (aset buffer-display-table (car entry) (copy-sequence (car vecs))))))
      (setq visws-font-lock-keywords keywords)
      (font-lock-add-keywords nil keywords t)))
  (unless visible-whitespace-mode
    (print (format "%s" visws-font-lock-keywords))
    (if visws-display-table-was-local
        (dolist (entry visible-whitespace-mappings)
          (aset buffer-display-table (car entry) nil))
      (setq buffer-display-table nil))
    (font-lock-remove-keywords nil visws-font-lock-keywords)))

(provide 'visws)

;;; visws.el ends here
