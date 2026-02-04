;; .emacs --- minimal bootstrap for config.org -*- lexical-binding: t; -*-

;; Always show package/native-comp actions (even if init is quiet)
(defun fp/force-message (fmt &rest args)
  (let ((inhibit-message nil) (message-log-max t))
    (apply #'message fmt args)))

(require 'package)

(advice-add 'package-refresh-contents
            :before (lambda (&rest _)
                      (fp/force-message "[pkg] Refreshing package archives...")))

(advice-add 'package-install
            :before (lambda (pkg &rest _)
                      (fp/force-message "[pkg] Installing: %s" pkg)))

(when (fboundp 'native-compile-async)
  (advice-add 'native-compile-async
              :before (lambda (files &rest _)
                        (fp/force-message "[eln] Native compiling %s file(s)..."
                                          (length files)))))

;; Quiet org-babel loading of ~/.emacs.d/config.org
(require 'org)
(setq org-babel-verbose nil
      org-babel-tangle-quiet t)

(let ((inhibit-message t)
      (load-verbose nil))
  (org-babel-load-file
   (expand-file-name "config.org" user-emacs-directory)))

;; .emacs ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-show-quick-access t nil nil "Customized with use-package company")
 '(package-selected-packages nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
