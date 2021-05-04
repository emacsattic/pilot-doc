;;; pilot-doc.el --- Write the current buffer out to a PalmOS device as a doc formated file
;;
;; Copyright (C) 2000 Daryn Hanright
;; http://www.planetnz.com/palmheads/myhacks.php
;;
;; Authors: Daryn W Hanright <palmheads@planetnz.com>
;; with help from Patrick Campbell-Preston whom debugged my awful code!! : - )
;; Modification for problems with the prompt "Press the hotsync button..." appearing before it started 
;; doing the conversion: Liam M. Healy
;;
;; Created: Fri Oct 27 22:20:35 2000
;; Version: $Id: pilot-doc.el,v 0.3
;; Keywords: palm pilot doc
;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; History:
;;
;; 0.1 - Initial version
;; 0.2 - Fixed prompting with hotsynching. Thanks to Liam M. Healy for the better code!
;; 0.3 - Changed reliance on "makedoc" as the TXT to Palm DOC convertor to "txt2pdbdoc"
;;
;;; Notes:
;;
;; This code is basically "borrowed" from Andrew J Cosgriff pilot-memo.el. This can be found here
;; http://polydistortion.net/sw/emacs-lisp/ 
;;
;; My pilot-doc.el complements Andrew's work 
;;
;; Usage : M-x save-buffer-to-pilotdoc
;;
;; It converts then loads up the current buffer to the Palm in the 'doc' format.
;;
;; You will also need a copy of 'txt2pdbdoc' which can be found at
;; http://homepage.mac.com/pauljlucas/software.html
;;
;; You will also need the `pilot-link' software installed, as this code simply
;; runs the external `pilot-xfer' program to do all the hard work.
;;
;; `pilot-link' source can be found at http://pilot-link.org
;; or, if you're running one of the more popular Linux distributions, there may be an installable
;; package available as part of the distribution....
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst pilot-doc-version (substring "$Revision: 0.0.0.3 $" 11 -2)
  "Version of pilot-doc.")

;;
;;; User Customizable Variables:
;;

(defgroup pilot-doc nil
  "Upload emacs buffers to your Palm device as docs.")

(defcustom pilot-doc-convert-doc-program "txt2pdbdoc"
  "Program to run that will install the buffer onto your Palm device."
  :type 'string
  :group 'pilot-doc)

(defcustom pilot-doc-install-doc-program "pilot-xfer"
  "Program to run that will install the buffer onto your Palm device."
  :type 'string
  :group 'pilot-doc)

(defcustom pilot-doc-device (or (getenv "PILOTPORT") "/dev/pilot")
  "Device name for the serial port to which your Palm's hotsync cable is connected."
  :type 'string
  :group 'pilot-doc)


;;
;;; Other Variables:
;;
(defvar pilot-doc-title-history nil)


;;
;;; Code:
;;
;;
;; Yick.  Maybe there's a better way of doing this ?
;; (it's here for Emacs/XEmacs compatibility...)
;;
(defun pilot-get-temp-dir ()
  (cond ((boundp 'temp-directory)
         temp-directory)
        ((boundp 'temporary-file-directory)
         temporary-file-directory)
        (t ".")))

(defun save-buffer-to-pilotdoc (title)
  "Put description here."
  (interactive
   (list
    (read-from-minibuffer
     "Title: " (buffer-name) nil nil 'pilot-doc-title-history)))
  (let ((pilot-doc-buffer (get-buffer-create "*pilot-doc*"))
        (pilot-doc-filename (concat (pilot-get-temp-dir) "/pilot-doc.txt"))
        (pilot-doc-prc (concat (pilot-get-temp-dir) "/pilot-doc.prc"))
        (pilot-doc-docname title) 
        (pilot-doc-out-buffer (get-buffer-create "*Shell Command Output*")))
    (save-excursion
      (copy-region-as-kill (point-min) (point-max))
      (set-buffer pilot-doc-buffer)
      (erase-buffer)
      (yank)
      (delete-windows-on pilot-doc-buffer)
      (write-file pilot-doc-filename nil))
    (kill-buffer pilot-doc-buffer)
    (message "Converting document, wait...")
    (shell-command
     (concat pilot-doc-convert-doc-program 
             " \"" pilot-doc-docname "\" " pilot-doc-filename 
             " " pilot-doc-prc " "))
    (message "Press the hotsync button...")
    (shell-command
     (concat pilot-doc-install-doc-program     
             " -p " pilot-doc-device " -i " pilot-doc-prc))
    (delete-file pilot-doc-filename)
    (delete-file pilot-doc-prc)))


;;; pilot-doc.el ends here

