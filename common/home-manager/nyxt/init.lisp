;;; Vi keybindings for all web buffers
(define-configuration web-buffer
  ((default-modes (pushnew 'vi-normal-mode %slot-value%))))

;;; Password manager — gopass is pass-compatible
(define-configuration browser
  ((password-interface
    (make-instance 'password:password-store-interface
                   :password-store-path
                   (or (uiop:getenv "PASSWORD_STORE_DIR")
                       (uiop:xdg-data-home "gopass/stores/root"))))))

;;; Custom vi-normal bindings to match qutebrowser defaults
(define-configuration nyxt/mode/vi:vi-normal-mode
  ((keyscheme-map
    (nkeymaps:define-keyscheme-map "qutebrowser" (list :import %slot-default%)
      nkeymaps:keyscheme:vi-normal
      (list
        ;; Tab navigation — qutebrowser J/K
        "J" 'switch-buffer-next
        "K" 'switch-buffer-previous

        ;; Tab reordering — qutebrowser C-S-j / C-S-k
        "C-S-j" 'nyxt/mode/buffer-listing:move-buffer-after-other
        "C-S-k" 'nyxt/mode/buffer-listing:move-buffer-before-other

        ;; Toggle tab bar — qutebrowser ,,
        ", ," 'toggle-status-buffer

        ;; Password manager — qutebrowser ,p / ,Pu / ,Pp / ,Po
        ", p" 'fill-password
        ", P u" 'copy-username
        ", P p" 'copy-password
        ", P o" 'copy-otp)))))
