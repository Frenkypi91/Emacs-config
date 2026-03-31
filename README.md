# Emacs-config

A comprehensive, literate Emacs configuration written in Org-mode. This configuration is designed for academic work, computational economics research, and software development with a focus on performance, modularity, and extensibility.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Dependencies on Arch Linux](#dependencies-on-arch-linux)
  - [Configuration Setup](#configuration-setup)
- [Configuration Blocks](#configuration-blocks)
- [Features](#features)
- [Keybindings](#keybindings)
- [Troubleshooting](#troubleshooting)

## Overview

This configuration is written as a literate program using Org-mode (`.org` format). The `config.org` file contains both documentation and Emacs Lisp code blocks that are automatically tangled into `config.el` on save. The configuration emphasizes:

- **Minimal startup overhead**: Uses native compilation and aggressive lazy-loading
- **Comprehensive IDE capabilities**: LSP integration, debugging, and language-specific tools
- **Academic tooling**: LaTeX, R, Python, Julia, and Jupyter support
- **Modern workflow**: Git integration via Magit/Forge, project management, and terminal integration
- **Free AI tooling**: GPtel integration with local and remote AI models
- **Keyboard-centric design**: Extensive customizable keybindings for rapid editing

## Requirements

### System Requirements

- **OS**: Linux (tested on Arch Linux)
- **Emacs**: Version 29+ (for native compilation support)
- **Terminal**: Any terminal supporting 24-bit color and UTF-8
- **Keyboard**: Full keyboard with function keys (recommended)

### Arch Linux Dependencies

Install the following packages from the Arch repositories:

```bash
sudo pacman -S emacs  # Core Emacs (version 29+)
```

### Optional System Dependencies

Install these based on which features you plan to use:

```bash
# LaTeX environment
sudo pacman -S texlive-latex texlive-fonts texlive-xetex texlive-bibtex-extra

# Programming languages & tools
sudo pacman -S python julia gcc gdb rust rustup go npm

# Version control & utilities
sudo pacman -S git ripgrep fd sqlite3 pandoc

# Shell & terminal
sudo pacman -S zsh tmux

# Language servers (optional but recommended)
sudo pacman -S python-lsp-server python-pylsp-mypy

# Additional packages
sudo pacman -S aspell-en  # Spell checking
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/emacs-config ~/.emacs.d
cd ~/.emacs.d
```

### 2. Create Required Directories

The configuration automatically creates necessary directories, but you can pre-create them:

```bash
mkdir -p ~/.emacs.d/{elpa,eln-cache,tmp,lisp/gptel-autocomplete}
```

### 3. Install gptel-autocomplete

This configuration uses a custom autocomplete module that must be placed in your lisp directory:

```bash
# Clone or copy the gptel-autocomplete module
git clone https://github.com/yourusername/gptel-autocomplete \
  ~/.emacs.d/lisp/gptel-autocomplete
```

Alternatively, if you don't have the autocomplete module yet, you can disable it by commenting out the AI section in `config.org`.

### 4. Start Emacs

```bash
emacs
```

On first startup:
- Emacs will initialize the package system
- It will download and install `use-package`
- All other packages will be automatically installed via `use-package`
- The configuration will be tangled from `config.org` to `config.el`
- Package updates check will run (one per day)

### 5. Tangle the Configuration

If you edit `config.org`, save it to automatically tangle the file:

```lisp
C-x C-s  # In config.org — auto-tangle on save
```

Or manually tangle with:

```lisp
M-x org-babel-tangle-file RET
```

---

## Configuration Blocks

### **Core System Setup**

#### **Bootstrap Paths**
```lisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/gptel-autocomplete"))
```
- Adds the custom `gptel-autocomplete` module to Emacs' load path
- Allows Emacs to find custom Lisp files before package installation

```lisp
(setq user-emacs-directory "~/.emacs.d/"
      package-user-dir "~/.emacs.d/elpa/")
```
- Centralizes all Emacs configuration and packages in `~/.emacs.d/`
- Keeps the home directory clean by avoiding scattered `.emacs` files
- `elpa/` stores downloaded packages from MELPA and GNU ELPA

```lisp
(setq native-comp-eln-load-path (list "~/.emacs.d/eln-cache/"))
```
- **Native compilation**: Emacs 28+ can compile Lisp to native machine code for faster execution
- `eln-cache/` stores pre-compiled bytecode
- Dramatically improves startup time and runtime performance

#### **Safety & Defaults**
```lisp
(setq load-prefer-newer t
      byte-compile-warnings nil
      vc-follow-symlinks t)
```
- **load-prefer-newer**: Always load the newest `.el` file, avoiding stale bytecode
- **byte-compile-warnings**: Suppress unnecessary warnings during package loading
- **vc-follow-symlinks**: Follow symlinks when opening files (useful for version control)

```lisp
(prefer-coding-system 'utf-8-unix)
(require 'cl-lib)
(require 'seq)
```
- Enforce UTF-8 encoding (required for modern text processing)
- Load `cl-lib` (Common Lisp functions) and `seq` (sequence operations)

#### **Verbosity Control**
```lisp
(setq use-package-verbose nil
      package-verbose nil
      url-show-status nil)
```
- Suppresses verbose output during package initialization
- Makes startup feel faster by reducing console spam

#### **Package System Setup**
```lisp
(require 'package)
(setq package-archive-priorities '(("melpa-stable" . 2) 
                                    ("melpa" . 1) 
                                    ("gnu" . 0))
      package-archives '(("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
```
- Configures package repositories with priority ranking
- **melpa-stable** (priority 2): Stable, tested package versions
- **melpa** (priority 1): Latest development versions
- **gnu** (priority 0): Official GNU packages
- Higher priority repos are checked first when installing

```lisp
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer nil)
```
- Bootstraps `use-package` (if not already installed)
- `use-package-always-ensure`: Automatically installs packages if missing
- `use-package-always-defer`: Loads packages immediately (can be overridden per-package)

#### **Auto-Update Mechanism**
```lisp
(defvar funpkg-update-stamp-file "~/.emacs.d/.last-package-update")
(defvar funpkg-update-log-file "~/.emacs.d/tmp/package-update.log")
(defun funpkg-update-once-per-day () ...)
(add-hook 'emacs-startup-hook #'funpkg-update-once-per-day)
```
- Automatically updates all installed packages once per day
- Runs in a background process (non-blocking)
- Logs updates to `package-update.log` for debugging
- Uses a timestamp file to track the last update date
- On errors, displays a message pointing to the log file

#### **Server Mode**
```lisp
(require 'server)
(unless (server-running-p) (server-start))
```
- Starts Emacs in server mode
- Allows you to open files with `emacsclient` from the command line:
  ```bash
  emacsclient -nw myfile.txt  # Open in terminal
  emacsclient -c myfile.txt   # Open in new GUI frame
  ```
- Useful for setting Emacs as your `$EDITOR` for git commits, etc.

#### **Backup & Autosave Settings**
```lisp
(setq make-backup-files nil
      backup-inhibited t
      auto-save-default nil
      create-lockfiles nil
      temporary-file-directory "~/.emacs.d/tmp/")
```
- Disables all backup and autosave files (clean working directory)
- Temporary files are stored in `~/.emacs.d/tmp/` if needed
- Recommended for use with version control (git) where history is preserved

#### **Dired (File Manager)**
```lisp
(require 'dired-x)
```
- Loads extended Dired functionality
- Enables features like: omit mode, smart file opening, command guessing

---

### **Performance & Warnings**

```lisp
(setq ad-redefinition-action 'accept
      read-process-output-max (* 3 1024 1024)  ; 3MB
      warning-suppress-types nil
      warning-minimum-level :warning
      native-comp-async-report-warnings-errors nil)
```

- **ad-redefinition-action**: Accept function redefinitions silently (happens during package loading)
- **read-process-output-max**: Increase from default 4KB to 3MB for faster LSP/language server communication
- **warning-minimum-level**: Only show warnings and errors (suppress info messages)
- **native-comp-async-report-warnings-errors**: Don't spam console with native compilation warnings

---

### **Appearance & Frame Management**

#### **Frame Sizing**
```lisp
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

(defvar funframe-margin-left 15)
(defvar funframe-margin-right 30)
(defvar funframe-margin-top 10)
(defvar funframe-margin-bottom 50)

(defun funcenter-frame (frame) ...)
```

- Calculates monitor workarea (accounting for taskbars/panels)
- Centers Emacs window with specified margins
- Sets minimum size: 900×600 pixels
- Automatically runs on startup and when monitors change

**Margins**: Adjust these variables to control window placement on your monitor

#### **UI Customization**

```lisp
(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))
```

- Disables menu bar, tool bar, and scroll bar for minimal UI
- Maximizes screen real estate for editing

---

### **Theme & Color Customization**

The configuration includes theme support, font configuration, and line number styling. See the full config.org for detailed theme options.

---

### **IDE Features**

#### **LSP (Language Server Protocol)**

```lisp
(use-package lsp-mode
  :hook ((prog-mode . lsp-mode))
  :commands lsp
  :config
  (setq lsp-keymap-prefix "C-c l"
        lsp-enable-symbol-highlighting nil
        lsp-signature-auto-activate nil))

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config (setq lsp-ui-doc-enable nil))
```

- **lsp-mode**: Provides IDE features (goto definition, rename, format) for multiple languages
- **lsp-ui**: Enhanced UI for LSP (documentation, inline diagnostics)
- Keybindings:
  - `C-c l r`: Rename symbol
  - `C-c l f`: Format buffer
  - `M-.`: Go to definition
  - `M-,`: Back to previous location

**Supported Languages** (requires language servers):
- Python: `pip install python-lsp-server`
- C/C++: Install `clangd` (Arch: `pacman -S clang`)
- Go: Install `gopls` (Arch: `pacman -S gopls`)
- Rust: Install `rust-analyzer` (Arch: `pacman -S rust-analyzer`)

#### **Debugging**
```lisp
(use-package dap-mode
  :after lsp-mode
  :config
  (dap-register-debug-template "Python" ...)
  (dap-register-debug-template "C/C++" ...))
```

- **DAP** (Debug Adapter Protocol) for debugging
- Set breakpoints with `C-c d b`
- Step through code with `n` (next), `s` (step-into), `c` (continue)

#### **Autocompletion**
```lisp
(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-preselect-first nil))

(use-package cape
  :after corfu
  :config
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))
```

- **Corfu**: Fast in-buffer completion with candidate scrolling
- **Cape**: Additional completion-at-point backends (file paths, dictionary)
- Trigger manually with `M-/` or automatically after typing

---

### **Language Support**

#### **Python**
```lisp
(use-package python-mode
  :mode "\\.py\\'"
  :config
  (setq python-indent-offset 4))
```
- Syntax highlighting, indentation, and REPL support
- Works with LSP for advanced IDE features

**Requirements**: `python3` (Arch: `pacman -S python`)

#### **Julia**
```lisp
(use-package julia-mode
  :mode "\\.jl\\'"
  :hook ((julia-mode . lsp-mode)))
```
- Full support for Julia code editing
- LSP support with `LanguageServer.jl`

**Requirements**: Julia runtime (Arch: `pacman -S julia`)

#### **R**
```lisp
(use-package ess
  :mode (("\\.R\\'" . r-mode)
         ("\\.Rmd\\'" . rmd-mode))
  :config
  (setq ess-style 'RStudio))
```
- **ESS** (Emacs Speaks Statistics) for R/RStudio integration
- REPL support, debugging, and package management

**Requirements**: R (Arch: `pacman -S r`)

#### **C/C++**
```lisp
(add-hook 'c-mode-hook #'lsp-mode)
(add-hook 'c++-mode-hook #'lsp-mode)
```
- LSP integration via `clangd`
- Debugging with DAP

**Requirements**: `gcc`, `gdb`, `clangd` (Arch: `pacman -S gcc gdb clang`)

#### **Markdown**
```lisp
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-command "pandoc"))
```
- Syntax highlighting, preview, export
- Requires Pandoc for export features

**Requirements**: `pandoc` (Arch: `pacman -S pandoc`)

#### **LaTeX**
```lisp
(use-package auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config
  (setq TeX-engine 'xetex))

(use-package pdf-tools
  :config (pdf-tools-install))
```
- Full LaTeX authoring environment
- PDF viewer with annotations
- Keybindings:
  - `F6` or `C-c v b`: Build LaTeX
  - `C-c v p`: Compile and view PDF
  - `C-c v o`: Open PDF in right window

**Requirements**: TexLive (Arch: `pacman -S texlive-latex texlive-xetex`)

---

### **Git Integration**

#### **Magit**
```lisp
(use-package magit
  :bind ("C-c g" . magit-status)
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-same-window-except-diff-v1))
```

- Full-featured Git interface
- Keybindings:
  - `C-c g`: Open Magit status
  - `s`: Stage hunks
  - `c`: Commit
  - `P p`: Push
  - `F f`: Pull

#### **Forge**
```lisp
(use-package forge
  :after magit)
```

- GitHub/GitLab integration
- Create, browse, and manage issues/pull requests
- Keybinding: `C-c G` (forge-dispatch)

---

### **Terminal & Shell Integration**

#### **VTerm (Virtual Terminal)**
```lisp
(use-package vterm
  :config
  (setq vterm-shell "/usr/bin/zsh"))

(use-package multi-vterm
  :after vterm
  :config
  (setq multi-vterm-dedicated-window-height 20))
```

- Full terminal emulator inside Emacs
- Supports mouse, colors, and all shell features
- Keybindings:
  - `C-c v`: Toggle terminal
  - `C-c t t`: New terminal tab
  - `C-c t n/p`: Next/previous terminal
  - `C-c t r`: Send region to terminal
  - `C-c t l`: Send current line to terminal

**Requirements**: VTerm library (Arch: `pacman -S cmake libvterm`)

---

### **Navigation & Search**

#### **Consult**
```lisp
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g o" . consult-outline)
         ("C-c s r" . consult-ripgrep)))
```

- Modern, fast search and navigation
- `C-s`: Search in current buffer
- `C-c s r`: Search project with ripgrep
- `C-x b`: Switch buffers with preview
- `M-g i`: Jump to function definitions

**Requirements**: `ripgrep` (Arch: `pacman -S ripgrep`)

#### **Embark**
```lisp
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings)))
```

- Context-aware actions on search results
- `C-.`: Show actions for item at point
- Export search results, refactor across files

---

### **Editing Utilities**

#### **Multiple Cursors**
```lisp
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))
```

- Edit multiple locations simultaneously
- Select similar words and edit all at once

#### **Expand Region**
```lisp
(use-package expand-region
  :bind ("C-=" . er/expand-region))
```

- Progressively expand selection by semantic units
- Useful for selecting expressions, paragraphs, etc.

#### **iedit (Interactive Edit)**
```lisp
(use-package iedit
  :bind ("C-c i" . iedit-mode))
```

- Rename/edit all instances of a symbol
- Faster than find-and-replace for local edits

---

### **AI & Autocompletion**

#### **GPtel**
```lisp
(use-package gptel)
```

- Local or remote AI integration
- Chat directly in Emacs buffers
- No telemetry, free to use
- Works with: Claude, ChatGPT, Ollama (local models)

#### **GPtel-Autocomplete**
```lisp
(use-package gptel-autocomplete
  :ensure nil
  :load-path "~/.emacs.d/lisp/gptel-autocomplete"
  :after gptel
  :config
  (add-hook 'prog-mode-hook #'gptel-autocomplete-mode))
```

- AI-powered code completion
- Keybindings:
  - `M-/`: Trigger autocomplete
  - `M-<tab>`: Accept suggestion
  - `M-]`: Next suggestion
  - `M-[`: Previous suggestion
  - `M-\`: Clear suggestions

---

### **Project Management**

#### **Treemacs**
```lisp
(use-package treemacs
  :bind ("C-c m" . treemacs-prefix)
  :config
  (treemacs-follow-mode 1))
```

- File tree sidebar for project exploration
- `C-c m`: Open/toggle file tree
- `C-c M`: Focus tree window

---

### **Custom Functions**

#### **Developer Utilities**

**Run Current File** (`C-c e`):
```lisp
(defun funrun-file () ...)
```
- Compiles and executes the current buffer
- Supports: Python, Julia, C, R
- Automatically saves before running

**Toggle Comments** (`C-c /`):
```lisp
(defun funtoggle-comment () ...)
```
- Comment/uncomment line or region

**Duplicate Line/Region** (`C-c d`):
```lisp
(defun funduplicate-line-or-region () ...)
```
- Duplicate current line or selected region below

**Search TODOs** (`C-c T`):
```lisp
(defun funsearch-todo () ...)
```
- Find all TODO, FIXME, NOTE comments in project
- Uses ripgrep for performance

**Insert Timestamp** (`C-c I`):
```lisp
(defun funinsert-timestamp () ...)
```
- Insert current timestamp with language-specific comment syntax

**Open Current Directory** (`C-c o`):
```lisp
(defun funopen-current-dir () ...)
```
- Open file manager (dired) at current file's location

#### **Window Management**

```lisp
(global-set-key (kbd "C-x 2") #'funsplit-below)
(global-set-key (kbd "C-x 3") #'funsplit-right)
```

- Custom split functions (likely with better defaults)
- `C-x 2`: Split horizontally
- `C-x 3`: Split vertically

---

### **Auto-Tangle & Reload**

```lisp
(defun funtangle-and-reload ()
  (when (and buffer-file-name
             (string-equal (file-truename buffer-file-name)
                           (file-truename "~/.emacs.d/config.org")))
    (org-babel-tangle-file "~/.emacs.d/config.org" "~/.emacs.d/config.el")
    (load "~/.emacs.d/config.el" nil 'nomessage)))

(add-hook 'after-save-hook #'funtangle-and-reload)
```

- Whenever you save `config.org`, it's automatically:
  1. Tangled into `config.el`
  2. Reloaded into the running Emacs session
- **No restart needed** to test configuration changes

---

## Features Summary

| Feature | Status | Keybinding |
|---------|--------|------------|
| LSP IDE support | ✓ | `C-c l` |
| Git/GitHub integration | ✓ | `C-c g`, `C-c G` |
| Terminal emulator | ✓ | `C-c v`, `C-c t` |
| LaTeX authoring | ✓ | `F6`, `C-c v` |
| Python/Julia/R/C development | ✓ | `C-c e` |
| Debugging (DAP) | ✓ | `C-c d` |
| Code completion | ✓ | `M-/`, `M-<tab>` |
| Project navigation | ✓ | `C-c m` |
| Fast search/replace | ✓ | `C-s`, `C-c s r` |
| Buffer/line navigation | ✓ | `C-x b`, `M-g g` |
| AI-powered chat | ✓ | Via `gptel` |
| Multi-cursor editing | ✓ | `C-S-c C-S-c`, `C->` |

---

## Keybindings

### Global Custom Keys

| Key | Command | Purpose |
|-----|---------|---------|
| `C-x 2` | Split below | Horizontal window split |
| `C-x 3` | Split right | Vertical window split |
| `C-s` | `consult-line` | Search current buffer |
| `C-x b` | `consult-buffer` | Switch buffers with preview |
| `M-y` | `consult-yank-pop` | Browse kill ring |
| `M-g g` | `consult-goto-line` | Jump to line number |
| `M-g i` | `consult-imenu` | Jump to function/variable |
| `C-c s r` | `consult-ripgrep` | Full-project search |
| `C-.` | `embark-act` | Context actions |
| `C-;` | `embark-dwim` | Smart action at point |
| `C-c g` | `magit-status` | Git status |
| `C-c G` | `forge-dispatch` | GitHub/GitLab operations |
| `C-c f` | `project-find-file` | Find file in project |
| `C-c o` | Open dired | File manager at current location |
| `C-c e` | `funrun-file` | Execute current file |
| `C-c /` | Toggle comment | Comment/uncomment line or region |
| `C-c d` | Duplicate line | Duplicate line or selected region |
| `C-c T` | Search TODOs | Find TODO/FIXME/NOTE markers |
| `C-c I` | Insert timestamp | Add current date/time |
| `C-c h` | Toggle folding | Expand/collapse code blocks |
| `C-c y` | Insert snippet | Use YASnippet template |
| `C-c v` | vterm | Open terminal |
| `C-c t t` | New terminal | New vterm tab |
| `C-c t n/p` | Next/prev terminal | Navigate terminal tabs |
| `C-c t r` | Send region | Execute region in terminal |
| `C-c t l` | Send line | Execute current line in terminal |
| `C-c m` | Treemacs | Toggle file tree |
| `C-c M` | Treemacs focus | Focus tree window |
| `C-=` | Expand region | Expand selection |
| `C-c i` | iedit mode | Multi-cursor edit |
| `C-S-c C-S-c` | Multi-cursor | Edit all matching lines |
| `C->` | Mark next | Mark next similar occurrence |
| `C-<` | Mark prev | Mark previous similar occurrence |
| `M-/` | AI autocomplete | Trigger AI suggestions |
| `M-<tab>` | Accept AI | Accept AI suggestion |
| `C-h B` | Embark bindings | Show available keybindings |

### LSP Keybindings (Prefix: `C-c l`)

| Key | Command |
|-----|---------|
| `C-c l r` | Rename symbol |
| `C-c l f` | Format buffer |
| `M-.` | Go to definition |
| `M-,` | Back to previous location |

---

## Troubleshooting

### Package Installation Issues

**Problem**: Packages fail to install on first startup

**Solution**:
```bash
# Manually refresh and install
emacs --eval '(progn (package-initialize) (package-refresh-contents) (kill-emacs))'
```

### Native Compilation Errors

**Problem**: Native compilation warnings spam the console

**Solution**: This is harmless. Suppress with:
```lisp
(setq native-comp-async-report-warnings-errors nil)
```

### LSP Not Working

**Problem**: LSP features don't activate

**Solution**:
1. Verify language server is installed:
   ```bash
   # Python example
   pip install python-lsp-server
   ```
2. Check logs: `M-x lsp-describe-session`
3. Enable LSP explicitly: `M-x lsp-mode`

### Slow Startup

**Problem**: Emacs takes >5 seconds to start

**Solution**:
1. Check what's taking time: `M-x profile-startup`
2. Defer non-essential packages: Add `:defer t` to `use-package` blocks
3. Check native compilation: `M-x native-compile-prune-cache`

### Terminal (VTerm) Not Available

**Problem**: VTerm library not found

**Solution** (Arch Linux):
```bash
sudo pacman -S libvterm cmake
# Then rebuild Emacs
emacs --batch -l ~/.emacs.d/config.el
```

### GPtel Autocomplete Not Working

**Problem**: AI completions don't trigger

**Solution**:
1. Ensure the module exists: `ls ~/.emacs.d/lisp/gptel-autocomplete/`
2. Configure your AI provider:
   ```lisp
   (setq gptel-model "claude-opus"
         gptel-backend (make-instance 'gptel-openai
                         :name "Claude"
                         :host "api.anthropic.com"))
   ```
3. Set your API key: `M-x gptel-set-api-key`

### Magit / Git Integration Issues

**Problem**: Magit doesn't recognize git repository

**Solution**:
```bash
# Ensure current directory is inside a git repo
cd /path/to/repo
emacs myfile.txt
# Then use C-c g
```

---

## Performance Optimization Tips

1. **Increase read-process-output-max** for faster LSP:
   ```lisp
   (setq read-process-output-max (* 5 1024 1024))
   ```

2. **Lazy-load less-used packages**:
   ```lisp
   (use-package latex-mode
     :defer t  ; Don't load until .tex file is opened
     :mode "\\.tex\\'")
   ```

3. **Disable expensive modes** in large files:
   ```lisp
   (add-hook 'prog-mode-hook
     (lambda ()
       (when (> (buffer-size) 1000000)
         (turn-off-flycheck))))
   ```

4. **Use native compilation** (enabled by default):
   - Automatically compiles `.el` files to machine code
   - ~2–5x performance improvement

---

## Contributing

Feel free to fork, customize, and adapt this configuration to your needs. Key files:

- `config.org`: Main literate configuration
- `config.el`: Generated file (do not edit directly)
- `lisp/gptel-autocomplete/`: Custom AI module
- `.gitignore`: Prevents committing built files

---

## License

This configuration is provided as-is for personal and educational use. Adapt freely.

---

## Credits

- Built with [Emacs 29+](https://www.gnu.org/software/emacs/)
- Inspired by literate programming principles
- Uses modern packages: `use-package`, `consult`, `vertico`, `marginalia`, `magit`, `lsp-mode`

---

## Quick Reference

### First Time Setup
```bash
git clone <repo> ~/.emacs.d
cd ~/.emacs.d
mkdir -p lisp/gptel-autocomplete elpa eln-cache tmp
emacs
# Wait for packages to install (~2-3 minutes on first run)
```

### Daily Use
```bash
# Open Emacs with current project
emacs .

# Key commands:
# C-c g       → Git status
# C-c f       → Find file in project
# C-s         → Search current buffer
# C-c e       → Run current file
# C-c v       → Open terminal
# C-c m       → File tree
# M-x package-list-packages → Manage packages
```

### Troubleshoot
```bash
# Check for errors in startup
emacs --debug-init

# See startup profiling
emacs --eval '(profiler-start 'cpu)' && sleep 3 && emacs --batch -l ~/.emacs.d/config.el -eval '(profiler-report)'

# Update all packages
emacs --batch -Q --eval "(package-initialize)" --eval "(package-refresh-contents)" --eval "(package-upgrade-all)" --kill
```
