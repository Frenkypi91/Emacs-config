;; Early init

;; Disable package startup
(setq package-enable-at-startup nil)

;; Boost gc startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Speed file handlers
(defvar fp/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Restore gc values
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)
            ;; Restore file handlers
            (setq file-name-handler-alist fp/file-name-handler-alist)))

;; Avoid frame resize
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Disable ui bars
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Silence native comp
(setq native-comp-async-report-warnings-errors nil)

