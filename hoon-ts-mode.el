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
   '((aura) @font-lock-builtin-face)

   :feature 'shadow
   :language 'hoon
   '((wrapFace (name) @font-lock-variable-name-face));;TODO: labels

   :feature 'rune
   :language 'hoon
   '((rune) @font-lock-variable-name-face)

   :feature 'typeCast
   :language 'hoon
   '((typeCast (_)) @font-lock-type-face)

   :feature 'zapzap
   :language 'hoon
   '((zapzap (_)) @font-lock-warning-face)

   :feature 'name
   :language 'hoon
   '((name) @font-lock-variable-name-face)

   :feature 'lusNames
   :language 'hoon
   '((luslusTall (name) @font-lock-function-name-face)
     (lusbucTall (name) @font-lock-function-name-face))

   :feature 'gateCall
   :language 'hoon
   '((gateCall) @font-lock-constant-call-face)

   :feature 'constants
   :language 'hoon
   '((mold) @font-lock-keyword-face
     (lark) @font-lock-doc-markup-face
     (date) @font-lock-keyword-face
     (number) @font-lock-keyword-face
     (boolean) @font-lock-keyword-face
     (term) @font-lock-keyword-face))

  "Tree-sitter font-lock settings.")


;;;###autoload
(define-derived-mode hoon-ts-mode hoon-mode "Hoon ts mode"
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
    (setq treesit-simple-imenu-settings
          `(("Arms" "\\`luslusTall\\'" nil hoon--treesit-defun-name)
            ("Molds" "\\`lusbucTall\\'" nil hoon--treesit-defun-name)))   ;; - treesit-simple-imenu-settings
    (treesit-major-mode-setup)))

(defun hoon--treesit-defun-name (node)
  (pcase (treesit-node-type node)
    ((or "luslusTall" "lusbucTall" "wrapFace")
        (treesit-node-text (treesit-search-forward node "name")))))
(add-to-list 'auto-mode-alist '("\\.hoon$" . hoon-ts-mode))

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
