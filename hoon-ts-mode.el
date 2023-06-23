;;; hoon-ts-mode.el --- Hoon ts mode -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'treesit)

(defvar hoon--treesit-font-lock-setting
  (treesit-font-lock-rules
   :feature 'comment
   :language 'hoon
   '((Gap) @font-lock-comment-face)

   :feature 'string
   :language 'hoon
   '((string) @font-lock-string-face)

   :feature 'aura
   :language 'hoon
   '((aura) @font-lock-type-face)

   :feature 'shadow
   :language 'hoon
   '((wrapFace (name) @font-lock-variable-name-face));;TODO: labels

   :feature 'rune
   :language 'hoon
   '((rune) @font-lock-constant-face)

   :feature 'lusNames
   :language 'hoon
   '((luslusTall (name) @font-lock-function-name-face)
    (lusbucTall (name) @font-lock-function-name-face))
   
   :feature 'constants
   :language 'hoon
   '((mold) @font-lock-constant-face
    (lark) @font-lock-constant-face
    (date) @font-lock-constant-face
    (term) @font-lock-constant-face
    (number) @font-lock-constant-face))

  "Tree-sitter font-lock settings.")

;;;###autoload
(define-derived-mode hoon-ts-mode fundamental-mode "Hoon ts mode"
  "Treesitter mode for hoon files"

  (when (treesit-ready-p 'hoon)
    (treesit-parser-create 'hoon)
    ;; set up treesit
    (setq-local treesit-font-lock-feature-list
                '((comment string aura)
                  (rune)
                  (constants lusNames shadow)
                  ))
    (setq-local treesit-font-lock-settings hoon--treesit-font-lock-setting)
    ;; - treesit-simple-indent-rules
    ;; - treesit-defun-type-regexp
    ;; - treesit-defun-name-function
    ;; - treesit-simple-imenu-settings
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.hoon\\'" . hoon-ts-mode))

(defvar hoon-ts-mode-default-grammar-sources
  '((hoon . ("https://github.com/urbit-pilled/tree-sitter-hoon.git"))))

(defun hoon-ts-install-grammar ()
  "Experimental function to install the tree-sitter-hoon grammar."
  (interactive)
  (if (and (treesit-available-p) (boundp 'treesit-language-source-alist))
      (let ((treesit-language-source-alist
             (append
              treesit-language-source-alist
              hoon-ts-mode-default-grammar-sources)))
        (if (y-or-n-p
             (format
              (concat "The following language grammar repository which will be "
                      "downloaded and installed "
                      "%s, proceed?")
              (cadr (assoc 'hoon treesit-language-source-alist))))
            (treesit-install-language-grammar 'hoon)))
    (display-warning
     'treesit
     (concat "Cannot install grammar because"
             " "
             "tree-sitter library is not compiled with Emacs"))))

(provide 'hoon-ts-mode)

;;; hoon-ts-mode.el ends here

