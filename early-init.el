;; early-init.el

;; Prevent package.el from initializing twice
(setq package-enable-at-startup nil)

;; Aggressive GC during startup, then restore normal values
(setq gc-cons-threshold (* 128 1024 1024))
(setq gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))
            (setq gc-cons-percentage 0.1)))

;; Disable implicit resizing of the initial frame
(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)

;; Disable UI bars before the first frame (reduce flicker)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Reduce native-comp noise at startup (optional)
(setq native-comp-async-report-warnings-errors nil)
