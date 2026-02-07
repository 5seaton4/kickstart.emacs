;; -*- lexical-binding: t; -*-

(defun start/org-babel-tangle-config ()
  "Automatically tangle our init.org config file and refresh package-quickstart when we save it. Credit to Emacs From Scratch for this one!"
  (interactive)
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle)
      (package-quickstart-refresh)
      )))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

(defun start/display-startup-time ()
  (interactive)
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'start/display-startup-time)

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t) ;; Always ensures that a package is installed

(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

(setq package-quickstart t) ;; For blazingly fast startup times, this line makes startup miles faster

(use-package async
  :defer
  :custom
  (dired-async-mode t)
  (async-bytecomp-package-mode t)
  (async-bytecomp-allowed-packages '(all))
  (async-package-do-action t))

(use-package emacs
  :custom
  ;; Still needed for terminals
  (menu-bar-mode nil)         ;; Disable the menu bar
  (scroll-bar-mode nil)       ;; Disable the scroll bar
  (tool-bar-mode nil)         ;; Disable the tool bar

  ;;(inhibit-startup-screen t)  ;; Disable welcome screen

  (delete-selection-mode t)   ;; Select text and delete it by typing.
  (electric-indent-mode nil)  ;; Turn off the weird indenting that Emacs does by default.
  (electric-pair-mode t)      ;; Turns on automatic parens pairing

  (blink-cursor-mode nil)     ;; Don't blink cursor
  (global-auto-revert-mode t) ;; Automatically reload file and show changes if the file has changed
  ;; (use-short-answers t)   ;; Since Emacs 29, `yes-or-no-p' will use `y-or-n-p'

  ;;(dired-kill-when-opening-new-dired-buffer t) ;; Dired don't create new buffer
  ;;(recentf-mode t) ;; Enable recent file mode

  ;;(global-visual-line-mode t)           ;; Enable line wrapping (NOTE: breaks vundo)
  ;;(global-display-line-numbers-mode t)  ;; Display line numbers
  ;;(display-line-numbers-type 'relative) ;; Relative line numbers
  (global-hl-line-mode t)               ;; Highlight current line

  (native-comp-async-report-warnings-errors 'silent) ;; Don't show native comp errors
  (warning-minimum-level :error) ;; Only show errors in warnings buffer

  (mouse-wheel-progressive-speed nil) ;; Disable progressive speed when scrolling
  (scroll-conservatively 10) ;; Smooth scrolling
  (scroll-margin 8)

  ;; (pixel-scroll-precision-mode t) ;; Precise pixel scrolling. i.e. smooth scrolling (GUI only)
  ;; (pixel-scroll-precision-use-momentum nil)

  (indent-tabs-mode nil) ;; Only use spaces for indentation
  (tab-width 4)
  (sgml-basic-offset 4) ;; Set Html mode indentation to 4
  (c-ts-mode-indent-offset 4) ;; Fix weird indentation in c-ts (C, C++)
  (go-ts-mode-indent-offset 4) ;; Fix weird indentation in go-ts

  ;; (display-fill-column-indicator-column 80) ;; Set line length indicator to 80 characters
  (whitespace-style '(face tabs tab-mark trailing))

  (make-backup-files nil) ;; Stop creating ~ backup files
  (auto-save-default nil) ;; Stop creating # auto save files
  (delete-by-moving-to-trash t)
  :hook
  (prog-mode . hs-minor-mode) ;; Enable folding hide/show globally
  ;; (prog-mode . display-fill-column-indicator-mode) ;; Display line length indicator
  (prog-mode . whitespace-mode)
  :config
  ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  :bind (
         ([escape] . keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
         ;; Zooming In/Out
         ("C-+" . text-scale-increase)
         ("C--" . text-scale-decrease)
         ("<C-wheel-up>" . text-scale-increase)
         ("<C-wheel-down>" . text-scale-decrease)
         ))

(use-package evil
  :hook (after-init . evil-mode)
  :init
  (evil-mode)
  :config
  (evil-set-initial-state 'eat-mode 'insert) ;; Set initial state in eat terminal to insert mode
  ;; (global-set-key [C-backspace] 'evil-delete-backward-word) ;; Make C-backspace less agressive
  :custom
  (evil-want-keybinding nil)    ;; Disable evil bindings in other modes (It's not consistent and not good)
  (evil-want-C-u-scroll t)      ;; Set C-u to scroll up
  (evil-want-C-i-jump nil)      ;; Disables C-i jump

  (evil-undo-system 'undo-fu) ;; C-r to redo
  (evil-want-fine-undo t)
  ;; (evil-respect-visual-line-mode t) ;; Move in wrap lines
  ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil)))
(use-package evil-collection
  :after evil
  :config
  ;; Setting where to use evil-collection)
  (setq evil-collection-mode-list '(dired ibuffer magit corfu consult info (package-menu package) bookmark))
  (evil-collection-init))

(defun start/open-init-file ()
  "Open init.org configuration file"
  (interactive)
  (find-file "~/.config/emacs/init.org"))

(defun start/reload-config()
  "Reload Emacs config"
  (interactive)
  (load-file "~/.config/emacs/init.el"))

(use-package general
  :after (evil) ;; <- evil
  :config
  (general-evil-setup) ;; <- evil
  ;; Set up 'SPC' as the leader key
  (general-create-definer start/leader-keys
    :states '(normal visual motion emacs) ;; <- evil
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "SPC") ;; Set global leader key so we can access our keybindings from any state

  (general-define-key
    :states '(normal visual motion)
    ";" #'evil-ex
    ":" #'evil-repeat-find-char)

  (general-define-key
    :states '(normal visual motion)
    ";" #'evil-ex
    ":" #'evil-repeat-find-char)

   (general-define-key
     "M-m" #'my-compile-project-build)

    (general-define-key
    "M-M" #'my-problems-show)

    ;; Global error navigation
    (global-set-key (kbd "M-n") #'next-error)
    (global-set-key (kbd "M-p") #'previous-error)

  (start/leader-keys
    "." '(find-file :wk "Find file")
    "," '(embark-act :wk "Embark act")
    "TAB" '(comment-line :wk "Comment lines")
    "q" '(flymake-show-buffer-diagnostics :wk "Flymake buffer diagnostic")
    "c" '(eat :wk "Eat terminal")

    ;; Projectile
    "p" '(projectile-command-map :wk "Projectile")
    "s p" '(projectile-discover-projects-in-search-path :wk "Search for projects")
    "s p" '(projectile-discover-projects-in-search-path :wk "Search for projects")
    "SPC" '(consult-fd :wk "Search files with fd")
    "*"   '(consult-ripgrep :wk "Search with ripgrep")
    )

  (start/leader-keys
    "m" '(:ignore t :wk "Bookmarks & Registers")
    ;; Registers
    "m s" '(consult-register :wk "Consult register")
    "m k" '(jump-to-register :wk "Jump to register")
    "m e" '(point-to-register :wk "Point to register")
    ;; Bookmarks
    "m a" '(bookmark-set :wk "Bookmark Set")
    "m d" '(bookmark-jump :wk "Bookmark Jump")
    "m r" '(bookmark-delete :wk "Bookmark Delete")
    "m R" '(bookmark-delete-all :wk "Bookmark Delete All")
    "m l" '(bookmark-bmenu-list :wk "Bookmark bmenu list")
    "m c" '(consult-bookmark :wk "Consult Bookmark"))

  (start/leader-keys
    "s" '(:ignore t :wk "Search")
    "s c" '(start/open-init-file :wk "Open init file")
    "s r" '(consult-recent-file :wk "Search recent files")
    "s f" '(consult-fd :wk "Search files with fd")
    "s g" '(consult-ripgrep :wk "Search with ripgrep")
    "s l" '(consult-line :wk "Search line")
    "s i" '(consult-imenu :wk "Search Imenu buffer locations")) ;; This one is really cool

  (start/leader-keys
    "d" '(:ignore t :wk "Buffers & Dired")
    "d s" '(consult-buffer :wk "Switch buffer")
    "d k" '(kill-current-buffer :wk "Kill current buffer")
    "d i" '(ibuffer :wk "Ibuffer")
    "d n" '(next-buffer :wk "Next buffer")
    "d p" '(previous-buffer :wk "Previous buffer")
    "d r" '(revert-buffer :wk "Reload buffer")
    "d v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))

  (start/leader-keys
    "e" '(:ignore t :wk "Languages")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e d" '(eldoc-doc-buffer :wk "Eldoc Buffer")
    "e f" '(eglot-format :wk "Eglot Format")

    "e l" '(consult-flymake :wk "Consult Flymake")
    "e n" '(flymake-goto-next-error :wk "Flymake next error")
    "e p" '(flymake-goto-prev-error :wk "Flymake previous error")

    "e a" '(eglot-code-actions :wk "Eglot code actions")
    "e r" '(eglot-rename :wk "Eglot Rename")
    "e i" '(xref-find-definitions :wk "Find definition")
    "e s" '(xref-find-references :wk "Find references")

    "e v" '(:ignore t :wk "Elisp")
    "e v b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e v r" '(eval-region :wk "Evaluate elisp in region"))

  (start/leader-keys
    "g" '(:ignore t :wk "Git")
    "g s" '(magit-status :wk "Magit status"))

  (start/leader-keys
    "r" '(:ignore t :wk "Reload & Packages") ;; To get more help use C-h commands (describe variable, function, etc.)
    ;; Mason.el
    "r m" '(mason-manager :wk "Mason manager")
    "r i" '(mason-install :wk "Mason install")
    ;; Package-menu-mode
    "r p" '(list-packages :wk "List packages")
    "r c" '(package-menu-clear-filter :wk "Package clear filters")
    "r n" '(package-menu-filter-by-name :wk "Package filter by name")
    "r N" '(package-menu-filter-by-name-or-description :wk "Package filter by name or descriptions")
    "r s" '(package-menu-filter-by-status :wk "Package filter by status")
    "r u" '(package-menu-filter-upgradable :wk "Package filter by upgradable")

    "r q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
    "r b" '(org-babel-tangle :wk "Recreate init.el")
    "r r" '(start/reload-config :wk "Reload Emacs config"))

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t v" '(vundo :wk "Toggle Vundo - Visual undo tree")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers"))

  (start/leader-keys
    "w" '(:ignore t :wk "Window")
    "w v" '(split-window-right :wk "Split window vertically")
    "w s" '(split-window-below :wk "Split window horizontally")
    "w h" '(evil-window-left :wk "Move to left window")
    "w l" '(evil-window-right :wk "Move to right window")
    "w j" '(evil-window-down :wk "Move to window below")
    "w k" '(evil-window-up :wk "Move to window above"))
  )


;; Fix general.el leader key not working instantly in messages buffer with evil mode
(use-package emacs
  :after (evil general)
  :ghook ('after-init-hook
          (lambda (&rest _)
            (when-let ((messages-buffer (get-buffer "*Messages*")))
              (with-current-buffer messages-buffer
                (evil-normalize-keymaps))))
          nil nil t))

(use-package undo-fu
  :defer
  :config
  ;; Increase undo history limits to reduce likelihood of data loss
  (setq undo-limit (* 1024 1024 64)          ;; 64mb  (default is 160kb)
        undo-strong-limit (* 1024 1024 96)   ;; 96mb  (default is 240kb)
        undo-outer-limit (* 1024 1024 960))) ;; 960mb (default is 24mb)

(use-package undo-fu-session
  :hook (after-init . undo-fu-session-global-mode)
  :custom (undo-fu-session-incompatible-files '("\\.gpg$" "/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
  :config
  (when (executable-find "zstd")
    ;; There are other algorithms available, but zstd is the fastest, and speed
    ;; is our priority within Emacs
    (setq undo-fu-session-compression 'zst)))

(use-package vundo
  :defer
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  (vundo-compact-display t))

(use-package gruvbox-theme
  :config
  (setq gruvbox-bold-constructs t)
  (load-theme 'gruvbox-dark-medium t)) ;; We need to add t to trust this package

(add-to-list 'default-frame-alist '(alpha-background . 90)) ;; For all new frames henceforth

;; Transparency in terminal
(defun start/tui-enable-transparency ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))))

(add-hook 'window-setup-hook 'start/tui-enable-transparency)

(use-package doom-modeline
  :custom
  (doom-modeline-height 25) ;; Set modeline height
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons :defer)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package projectile
  :hook (after-init . projectile-mode)
  :config
  (projectile-mode)
  :custom
  ;; (projectile-auto-discover nil) ;; Disable auto search for better startup times ;; Search with a keybind
  (projectile-run-use-comint-mode t) ;; Interactive run dialog when running projects inside emacs (like giving input)
  (projectile-switch-project-action #'projectile-dired) ;; Open dired when switching to a project
  (projectile-project-search-path '("~/projects/" "~/work/" ("~/github" . 1)))) ;; . 1 means only search the first subdirectory level for projects

(use-package eglot
  :ensure nil ;; Don't install eglot because it's now built-in
  :hook ((c-mode c++-mode ;; Autostart lsp servers for a given mode
                 lua-mode) ;; Lua-mode needs to be installed
         . eglot-ensure)
  :custom
  ;; Good default
  (eglot-events-buffer-size 0) ;; No event buffers (LSP server logs)
  (eglot-autoshutdown t);; Shutdown unused servers.
  (eglot-report-progress nil) ;; Disable LSP server logs (Don't show lsp messages at the bottom, java)
  ;; Manual lsp servers
  ;;:config
  ;;(add-to-list 'eglot-server-programs
  ;;             `(lua-mode . ("PATH_TO_THE_LSP_FOLDER/bin/lua-language-server" "-lsp"))) ;; Adds our lua lsp server to eglot's server list
  )

(use-package mason
  :hook (after-init . mason-ensure))

(use-package sideline-flymake
  :hook (flymake-mode . sideline-mode)
  :custom
  (sideline-flymake-display-mode 'line) ;; Show errors on the current line
  (sideline-backends-right '(sideline-flymake)))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package yasnippet-snippets :defer)

(defun start/corfu-yas-tab-handler ()
  "Prioritize corfu over yasnippet when yasnippet is active"
  (interactive)
  ;; There is no direct way to get if corfu is currently displayed so we watch the completion index
  (if (> corfu--index -1)
      (corfu-complete)
    (yas-next-field-or-maybe-expand)
    ))
(use-package emacs
  :after (yasnippet corfu)
  :bind
  (:map yas-keymap
        ("TAB" . start/corfu-yas-tab-handler)))

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (gdscript "https://github.com/PrestonKnopp/tree-sitter-gdscript")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (hyprlang "https://github.com/tree-sitter-grammars/tree-sitter-hyprlang")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (vue "https://github.com/ikatyang/tree-sitter-vue")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(defun start/install-treesit-grammars ()
  "Install missing treesitter grammars"
  (interactive)
  (dolist (grammar treesit-language-source-alist)
    (let ((lang (car grammar)))
      (unless (treesit-language-available-p lang)
        (treesit-install-language-grammar lang)))))

;; Call this function to install missing grammars
(add-hook 'after-init-hook #'start/install-treesit-grammars)

;; Optionally, add any additional mode remappings not covered by defaults
(setq major-mode-remap-alist
      '((yaml-mode . yaml-ts-mode)
        (sh-mode . bash-ts-mode)
        (c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
        (css-mode . css-ts-mode)
        (python-mode . python-ts-mode)
        (mhtml-mode . html-ts-mode)
        (javascript-mode . js-ts-mode)
        (js-json-mode . json-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (conf-toml-mode . toml-ts-mode)
        (gdscript-mode . gdscript-ts-mode)
        ))
(setq treesit-font-lock-level 3)

;; Or if there is no built in mode
(use-package cmake-ts-mode :ensure nil :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))
(use-package go-mod-ts-mode :ensure nil :mode "\\.mod\\'")
(use-package lua-ts-mode :ensure nil :mode "\\.lua\\'")
(use-package rust-ts-mode :ensure nil :mode "\\.rs\\'")
(use-package typescript-ts-mode :ensure nil :mode "\\.ts\\'")
(use-package tsx-ts-mode :ensure nil :mode "\\.tsx\\'")
(use-package yaml-ts-mode :ensure nil :mode ("\\.yaml\\'" "\\.yml\\'"))

(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
  :hook
  (org-mode . org-indent-mode) ;; Indent text
  )

(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(use-package eat
  :defer
  :hook ('eshell-load-hook #'eat-eshell-mode))

(use-package exec-path-from-shell
  :hook (after-init . exec-path-from-shell-initialize))

;; (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; (require 'start-multiFileExample)

;; (start/hello)

(use-package transient
  :defer
  :config
  (define-key transient-map (kbd "<escape>") 'transient-quit-one)) ;; Make escape quit magit prompts

(use-package magit
  :defer
  :custom (magit-diff-refine-hunk (quote all)) ;; Shows inline diff
  :config
  (setopt magit-format-file-function #'magit-format-file-nerd-icons) ;; Magit nerd icons
  )

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (after-init . global-diff-hl-mode)))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popup info delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package yasnippet-capf :defer)

(defun start/setup-capfs ()
  "Configure completion backends"
  ;; Take care when adding Capfs to the list since each of the Capfs adds a small runtime cost.
  (let ((merge-backends (list
                         #'cape-keyword      ;; Keyword completion
                         ;; #'cape-abbrev       ;; Complete abbreviation
                         #'cape-dabbrev      ;; Complete word from current buffers
                         ;; #'cape-line         ;; Complete entire line from current buffer
                         ;; #'cape-history      ;; Complete from Eshell, Comint or minibuffer history
                         ;; #'cape-dict         ;; Dictionary completion (Needs Dictionary file installed)
                         ;; #'cape-tex          ;; Complete Unicode char from TeX command, e.g. \hbar
                         ;; #'cape-sgml         ;; Complete Unicode char from SGML entity, e.g., &alpha
                         ;; #'cape-rfc1345      ;; Complete Unicode char using RFC 1345 mnemonics
                         ;; #'snippy-capf       ;; Vscode Snippets (Snippy needs to be installed)
                         #'yasnippet-capf    ;; Yasnippet snippets
                         ))
        (seperate-backends (list
                            #'cape-file ;; Path completion
                            #'cape-elisp-block ;; Complete elisp in Org or Markdown mode
                            )))
    ;; Remove keyword completion in git commits
    (when (derived-mode-p 'git-commit-mode)
      (setq merge-backends (remq #'cape-keyword merge-backends)))

    ;; Add Elisp symbols only in Elisp modes
    (when (derived-mode-p 'emacs-lisp-mode 'ielm-mode)
      (setq merge-backends (cons #'cape-elisp-symbol merge-backends))) ;; Emacs Lisp code (functions, variables)

    ;; Add Eglot to the front of the list if it's active
    (when (bound-and-true-p eglot--managed-mode)
      (setq merge-backends (cons #'eglot-completion-at-point merge-backends)))

    ;; Create the super-capf and set it buffer-locally
    (setq-local completion-at-point-functions
                (append
                 seperate-backends
                 (list (apply #'cape-capf-super merge-backends)))
                )))

(use-package cape
  :after (corfu)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.

  ;; Seperate function needed, because we use setq-local (everything is replaced)
  (add-hook 'eglot-managed-mode-hook #'start/setup-capfs)
  (add-hook 'prog-mode-hook #'start/setup-capfs)
  (add-hook 'text-mode-hook #'start/setup-capfs))

(use-package orderless
  :defer
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :hook (after-init . vertico-mode)
  ;; Vim keybinds
  ;; :bind (:map vertico-map
  ;;            ("C-j" . vertico-next)
  ;;            ("C-k" . vertico-previous)
  ;;            ("C-u" . vertico-scroll-down)
  ;;            ("C-d" . vertico-scroll-up))
  :custom
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  )

(savehist-mode) ;; Enables save history mode

(use-package marginalia
  :after vertico
  :config
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup))

(use-package embark :defer)
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package helpful
  :bind
  ;; Note that the built-in `describe-function' includes both functions
  ;; and macros. `helpful-function' is functions only, so we provide
  ;; `helpful-callable' as a drop-in replacement.
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command)
  )

(use-package diminish :defer)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo
  :hook
  ((prog-mode yaml-ts-mode) . hl-todo-mode)
  :config
  ;; From doom emacs
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        '(;; For reminders to change or add something at a later date.
          ("TODO" warning bold)
          ;; For code (or code paths) that are broken, unimplemented, or slow,
          ;; and may become bigger problems later.
          ("FIXME" error bold)
          ;; For code that needs to be revisited later, either to upstream it,
          ;; improve it, or address non-critical issues.
          ("REVIEW" font-lock-keyword-face bold)
          ;; For code smells where questionable practices are used
          ;; intentionally, and/or is likely to break in a future update.
          ("HACK" font-lock-constant-face bold)
          ;; For sections of code that just gotta go, and will be gone soon.
          ;; Specifically, this means the code is deprecated, not necessarily
          ;; the feature it enables.
          ("DEPRECATED" font-lock-doc-face bold)
          ;; Extra keywords commonly found in the wild, whose meaning may vary
          ;; from project to project.
          ("NOTE" success bold)
          ("BUG" error bold)
          ("XXX" font-lock-constant-face bold)))
  )

(use-package indent-guide
  :hook
  (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│")) ;; Set the character used for the indent guide.

(use-package which-key
  :ensure nil ;; Don't install which-key because it's now built-in
  :hook (after-init . which-key-mode)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display because the default is only 1
  (which-key-idle-delay 0.3)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)) ;; Fixes which-key window slipping out in Emacs Daemon

(use-package ws-butler
  :hook (after-init . ws-butler-global-mode))

(use-package dashboard
:ensure t
:config
(dashboard-setup-startup-hook))

(use-package rainbow-mode
:ensure t
)

(use-package eldoc-box
:ensure t
:config
    (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t)
)

(use-package javelin
:ensure t
:config
  (global-javelin-minor-mode 1)
)

(require 'compile)
    (require 'projectile)

    (defgroup my-compile nil
        "Project compilation helpers."
        :group 'tools)

    (defcustom my-compile-build-script "build.sh"
        "Build script to look for in projectile root."
        :type 'string)

    (defun my-compile--project-root ()
        "Return projectile project root, or error."
        (or (projectile-project-root)
        (user-error "Not in a projectile project")))

    (defun my-compile--build-script-path ()
        "Return absolute path to build script in project root, or error."
        (let* ((root (my-compile--project-root))
                (path (expand-file-name my-compile-build-script root)))
            (unless (file-exists-p path)
            (user-error "No %s found in projectile-root: %s" my-compile-build-script root))
            path))

    (defun my-compile-project-build ()
        "Compile ./build.sh from the projectile project root."
        (interactive)
        (let* ((root (my-compile--project-root))
                (script (my-compile--build-script-path))
                (default-directory root)
                (cmd (concat "./" (file-name-nondirectory script))))
            (compile cmd)))

    ;; Show *compilation* in a right-side vertical split
    (add-to-list
        'display-buffer-alist
        '("\\*compilation\\*"
        (display-buffer-in-side-window)
        (side . right)
        (slot . 0)
        (window-width . 0.40)
        (reusable-frames . visible)))

    ;; Core compilation behaviour
    (setq compilation-scroll-output 'first-error)              ; auto-scroll
    (setq compilation-auto-jump-to-first-error t)   ; jump on first error
    (setq compilation-max-output-line-length nil)   ; don't truncate lines
    (setq compilation-always-kill t)                ; kill previous compile

    (require 'ansi-color)

    (defun my-compile--ansi-colorize ()
    "Apply ANSI colors to compilation buffer."
    (ansi-color-apply-on-region compilation-filter-start (point)))

    (add-hook 'compilation-filter-hook #'my-compile--ansi-colorize)

    (setq compilation-highlight-overlay t)

;; TODO: Untested
(defun my-compile-hide-on-success (buf msg)
"Hide the compilation window if compilation succeeded.
    BUF is the compilation buffer. MSG is the status message."
(when (and (buffer-live-p buf)
            (string-match-p "\\`finished" msg))
    ;; Small delay so you can see the 'finished' line flash in the buffer.
    (run-at-time
    0.25 nil
    (lambda (b)
        (when (buffer-live-p b)
        (let ((win (get-buffer-window b)))
            (when (window-live-p win)
            ;; Close the window, but keep the buffer around for later review.
            (delete-window win)))))
    buf)))

(add-to-list 'compilation-finish-functions #'my-compile-hide-on-success)

(require 'compile)
(require 'projectile)

;; Clang-style errors: /path/file.cpp:123:45: error: ...
(setq compilation-error-regexp-alist
    (cons 'clang compilation-error-regexp-alist))

(with-eval-after-load 'compile
(defun my-ue-compilation-font-lock ()
"Extra highlighting for UE build output."
(font-lock-add-keywords
nil
`(
;; Core severity
("\\<fatal error:\\>" . font-lock-constant-face)
("\\<error:\\>"       . font-lock-warning-face)
("\\<warning:\\>"     . font-lock-keyword-face)

;; UE sections / headers
("\\<UHT\\>\\|\\<UBT\\>\\|UnrealBuildTool\\|UnrealHeaderTool" . font-lock-function-name-face)

;; Result line
("^Result: Failed.*$"   . font-lock-warning-face)
("^Result: Succeeded.*$" . font-lock-string-face)

;; Action counters like: [1/8] Compile ...
("^\\[\\([0-9]+\\)/\\([0-9]+\\)\\] \\(Compile\\|Link\\|Generate\\).*"
(0 font-lock-type-face))

;; “Building …” / “Starting …” style banners
("^[-=]+.*[-=]+$" . font-lock-comment-face)
))
(font-lock-flush)))

(add-hook 'compilation-mode-hook #'my-ue-compilation-font-lock)

(require 'tabulated-list)
                        (require 'cl-lib)
                        (require 'subr-x)

                        (defvar my-problems-source-buffer "*compilation*")
                        (defvar my-problems-filter-kind 'all)   ;; 'all | 'errors | 'warnings
                        (defvar my-problems-filter-file nil)    ;; nil or absolute/relative file string

                        (defvar my-problems--items nil)         ;; internal cache of parsed issues

                        (add-to-list
                            'display-buffer-alist
                                '("\\*Problems\\*"
                                    (display-buffer-in-side-window)
                                    (side . right)
                                    (slot . 1)                 ;; below compilation (slot 0)
                                    (window-height . 0.30)
                                    (reusable-frames . visible)))


        (defface my-problems-error-face
          '((t :inherit error))
          "Face for errors in *Problems*.")

        (defface my-problems-warning-face
          '((t :inherit warning))
          "Face for warnings in *Problems*.")

        (defface my-problems-file-face
          '((t :inherit font-lock-string-face))
          "Face for file names in *Problems*.")

        (defface my-problems-location-face
          '((t :inherit font-lock-constant-face))
          "Face for line/column in *Problems*.")

    (defun my-problems--sev-face (sev)
      (pcase sev
        ('warning 'my-problems-warning-face)
        (_        'my-problems-error-face)))

                        (defun my-problems--project-root ()
                            (when (fboundp 'projectile-project-root)
                            (ignore-errors (projectile-project-root))))

                        (defun my-problems--relpath (path)
                            (let ((root (my-problems--project-root)))
                            (if (and root (string-prefix-p (file-truename root) (file-truename path)))
                                (file-relative-name path root)
                                path)))

                        (defun my-problems--parse-compilation ()
                            "Parse *compilation* buffer and return list of plist issues."
                            (let ((buf (get-buffer my-problems-source-buffer)))
                            (unless (buffer-live-p buf)
                                (user-error "No buffer named %s" my-problems-source-buffer))
                            (with-current-buffer buf
                                (save-excursion
                                (goto-char (point-min))
                                (let (out)
                                    ;; clang-like:
                                    ;; /path/file.cpp:264:55: error: message...
                                    (while (re-search-forward
                                            "^\\(/[^:\n]+\\):\\([0-9]+\\):\\([0-9]+\\): \\(fatal error\\|error\\|warning\\): \\(.*\\)$"
                                            nil t)
                                    (let* ((file (match-string 1))
                                            (line (string-to-number (match-string 2)))
                                            (col  (string-to-number (match-string 3)))
                                            (kind (match-string 4))
                                            (msg  (match-string 5))
                                            (sev  (if (string-match-p "warning" kind) 'warning 'error)))
                                        (push (list :file file :line line :col col :sev sev :kind kind :msg msg) out)))
                                    (nreverse out))))))

                        (defun my-problems--apply-filters (items)
                            (let ((filef my-problems-filter-file)
                                (kindf my-problems-filter-kind))
                            (cl-remove-if
                                (lambda (it)
                                (let ((sev (plist-get it :sev))
                                        (file (plist-get it :file)))
                                    (or (and (eq kindf 'errors)   (eq sev 'warning))
                                        (and (eq kindf 'warnings) (eq sev 'error))
                                        (and filef (not (string= filef file))
                                            ;; also allow matching relative paths if user picked those
                                            (not (string= filef (my-problems--relpath file)))))))
                                items)))

                        (defun my-problems--unique-files (items)
                            (let ((ht (make-hash-table :test 'equal)))
                            (dolist (it items)
                                (puthash (plist-get it :file) t ht))
                            (hash-table-keys ht)))

                        (defun my-problems--header (items)
                            (let* ((errs  (cl-count-if (lambda (it) (eq (plist-get it :sev) 'error)) items))
                                    (warns (cl-count-if (lambda (it) (eq (plist-get it :sev) 'warning)) items))
                                    (files (length (my-problems--unique-files items)))
                                    (kf my-problems-filter-kind)
                                    (ff my-problems-filter-file))
                            (format "Problems: %d errors, %d warnings, %d files  |  Filter: %s%s"
                                    errs warns files
                                    (pcase kf ('all "all") ('errors "errors-only") ('warnings "warnings-only"))
                                    (if ff (format "  file=%s" (my-problems--relpath ff)) ""))))

    (defun my-problems--dedupe (items)
      "Remove exact duplicate problem entries from ITEMS.

    ITEMS is a list of plists with keys:
    :file :line :col :sev :msg

    Returns a new list preserving original order."
      (let ((seen (make-hash-table :test 'equal))
            out)
        (dolist (it items (nreverse out))
          (let ((key (list (plist-get it :file)
                           (plist-get it :line)
                           (plist-get it :col)
                           (plist-get it :sev)
                           (plist-get it :msg))))
            (unless (gethash key seen)
              (puthash key t seen)
              (push it out))))))

            (defvar my-problems-dedupe-enabled t)
            (defun my-problems-toggle-dedupe ()
              (interactive)
              (setq my-problems-dedupe-enabled (not my-problems-dedupe-enabled))
              (my-problems-refresh)
              (message "Problems dedupe: %s" (if my-problems-dedupe-enabled "ON" "OFF")))


                        (defun my-problems-refresh ()
                            "Refresh the Problems buffer."
                            (interactive)
        ;;                    (setq my-problems--items (my-problems--parse-compilation))
                            (setq my-problems--items
                                (let ((items (my-problems--parse-compilation)))
                                    (if my-problems-dedupe-enabled
                                        (my-problems--dedupe items)
                                    items)))

                            (let* ((filtered (my-problems--apply-filters my-problems--items)))
                            (setq tabulated-list-entries
                                    (mapcar
                                    (lambda (it)
                                        (let* ((file (plist-get it :file))
                                            (line (plist-get it :line))
                                            (col  (plist-get it :col))
                                            (sev  (plist-get it :sev))
                                            (msg  (plist-get it :msg))
                                            (face (my-problems--sev-face sev))
                                            (kind (if (eq sev 'warning) "Warning" "Error")))
                                        (list it
                                                (vector
                                                (propertize kind 'face face)
                                                (propertize (my-problems--relpath file) 'face 'my-problems-file-face)
                                                (propertize (format "%d:%d" line col) 'face 'my-problems-location-face)
                                                (propertize msg 'face face)))))
                                    filtered))
                            (setq header-line-format (my-problems--header filtered))
                            (tabulated-list-print t)))

                        (defun my-build--main-window ()
                            "Pick a sane window for visiting source: non-side, not compilation/problems."
                            (or
                            (get-window-with-predicate
                            (lambda (w)
                                (and (window-live-p w)
                                    (not (my-build--side-window-p w))
                                    (let ((bn (buffer-name (window-buffer w))))
                                        (not (member bn '("*compilation*" "*Problems*")))))))
                            ;; fallback: if everything is side windows, just use current
                            (selected-window)))

                        ;; Make Problems RET jump in the main window (replace your my-problems-jump with this)
                        (defun my-problems-jump ()
                            "Jump to the problem at point, using a main editing window."
                            (interactive)
                            (let ((it (tabulated-list-get-id)))
                            (unless it (user-error "No problem on this line"))
                            (let* ((file (plist-get it :file))
                                    (line (plist-get it :line))
                                    (col  (plist-get it :col))
                                    (win  (my-build--main-window)))
                                (select-window win)
                                (find-file file)
                                (goto-char (point-min))
                                (forward-line (1- line))
                                (forward-char (max 0 (1- col))))))


                    ;; Make compilation/next-error jumps open in the main window too
                    (defun my-build--compilation-goto-locus-main-window (orig msg loc end-loc)
                        (let ((win (my-build--main-window)))
                        (with-selected-window win
                            (funcall orig msg loc end-loc))))

                (with-eval-after-load 'compile
                  (advice-add 'compilation-goto-locus :around #'my-build--compilation-goto-locus-main-window))

                (defun my-problems-set-filter-file ()
                    "Pick a file to filter problems by."
                    (interactive)
                    (unless my-problems--items
                    (setq my-problems--items (my-problems--parse-compilation)))
                    (let* ((files (sort (my-problems--unique-files my-problems--items) #'string<))
                            (choices (mapcar #'my-problems--relpath files))
                            (picked (completing-read "Filter file: " choices nil t)))
                    ;; store absolute match if possible
                    (setq my-problems-filter-file
                            (or (cl-find-if (lambda (f) (string= (my-problems--relpath f) picked)) files)
                                picked))
                    (my-problems-refresh)))

                (defun my-problems-clear-filter-file ()
                    (interactive)
                    (setq my-problems-filter-file nil)
                    (my-problems-refresh))

                (defun my-problems-filter-all () (interactive) (setq my-problems-filter-kind 'all) (my-problems-refresh))
                (defun my-problems-filter-errors () (interactive) (setq my-problems-filter-kind 'errors) (my-problems-refresh))
                (defun my-problems-filter-warnings () (interactive) (setq my-problems-filter-kind 'warnings) (my-problems-refresh))

                (define-derived-mode my-problems-mode tabulated-list-mode "Problems"
                    "IDE-like problems list for compilation output."
                    (setq tabulated-list-format [("Type" 8 t)
                                                ("File" 45 t)
                                                ("Line:Col" 10 t)
                                                ("Message" 0 t)])
                    (setq tabulated-list-padding 2)
                    (tabulated-list-init-header)
                    (setq truncate-lines t))

                (let ((map my-problems-mode-map))
                    (define-key map (kbd "g") #'my-problems-refresh)
                    (define-key map (kbd "RET") #'my-problems-jump)
                    (define-key map (kbd "e") #'my-problems-filter-errors)
                    (define-key map (kbd "w") #'my-problems-filter-warnings)
                    (define-key map (kbd "a") #'my-problems-filter-all)
                    (define-key map (kbd "f") #'my-problems-set-filter-file)
                    (define-key map (kbd "F") #'my-problems-clear-filter-file)
                    (define-key map (kbd "q") #'quit-window)

                    ;; nice: n/p move lines
                    (define-key map (kbd "n") #'next-line)
                    (define-key map (kbd "p") #'previous-line))

           (with-eval-after-load 'evil
            ;; Make sure Problems opens in normal state
            (evil-set-initial-state 'my-problems-mode 'normal)

            ;; Bind keys in Evil normal state for this mode
            (evil-define-key 'normal my-problems-mode-map
                (kbd "q") #'quit-window
                (kbd "g") #'my-problems-refresh
                (kbd "RET") #'my-problems-jump
                (kbd "e") #'my-problems-filter-errors
                (kbd "w") #'my-problems-filter-warnings
                (kbd "a") #'my-problems-filter-all
                (kbd "f") #'my-problems-set-filter-file
                (kbd "F") #'my-problems-clear-filter-file
                (kbd "d") #'my-problems-toggle-dedupe))

            (defun my-build--side-window-p (win)
                (window-parameter win 'window-side))

            (defun my-build--compilation-window ()
                (get-buffer-window "*compilation*" 0))

                (defun my-problems-show (&optional focus)
                    "Show (or refresh) the Problems panel from the latest compilation.
                    If FOCUS is non-nil, select the Problems window."
                    (interactive (list t))
                    (let ((buf (get-buffer-create "*Problems*")))
                    (with-current-buffer buf
                        (my-problems-mode)
                        (my-problems-refresh))
                    (let ((win (display-buffer buf)))
                        (when focus
                        (select-window win))
                        win)))

                (defun my-problems-auto-show-on-failure (buf msg)
                    "On failed compilation, show Problems below compilation and focus it."
                    (when (and (buffer-live-p buf)
                                (stringp msg)
                                (not (string-prefix-p "finished" msg)))
                    (my-problems-show t)))

                (add-to-list 'compilation-finish-functions #'my-problems-auto-show-on-failure)

(add-hook 'my-problems-mode-hook #'hl-line-mode)
