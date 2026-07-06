;;; Vi mode is enabled in auto-config.4.lisp — no need to duplicate it here.

;;; gopass is pass-compatible; point the password interface at the gopass store.
(define-configuration browser
  ((password-interface
    (make-instance 'password:password-store-interface
                   :password-store-path
                   (or (uiop:getenv "PASSWORD_STORE_DIR")
                       (uiop:xdg-data-home "gopass/stores/root"))))))

;;; Extra vi-normal bindings to match qutebrowser muscle memory.
;;; Nyxt 4 vi-normal defaults use [ / ] for tab switching; qutebrowser uses J/K.
(define-configuration nyxt/mode/vi:vi-normal-mode
  ((keyscheme-map
    (define-keyscheme-map "qutebrowser-extras" (list :import %slot-default%)
      keyscheme:vi-normal
      (list
        "J" 'switch-buffer-next
        "K" 'switch-buffer-previous
        ", p" 'copy-password
        ", P u" 'copy-username)))))
