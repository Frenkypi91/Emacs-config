#Emacs config

This configuration is designed to be especially useful for *econometricians* and *data scientists*, precisely because I am an econometrician myself.  
The core idea is to have a lightweight but powerful ***IDE*** that supports multiple languages and allows exporting work in *markup* languages such as:

- LaTeX  
- HTML  
- Markdown  

Hopefully, this setup can also be useful for people working in different application domains.

You will need to place the file `*.emacs*` in your `/home/user` directory, and the files:

- `config.org`  
- `early-init.el`  
- `md-theme.css`  

inside the `~/.emacs.d/` directory for everything to work correctly.

This repository contains a **vanilla Emacs** configuration written in **Org Mode** (`config.org`) and automatically tangled into Emacs Lisp (`config.el`).  
The goal is to obtain a lightweight yet complete “IDE-like” environment for:

- **Python**, **Julia**, **R**, **C/C++**, **Fortran**, **Rust**
- **LaTeX** (AUCTeX + `latexmk` + SyncTeX with **Okular**)
- **Org Mode** (Babel + PDF export + Reveal.js)
- **Web development** (HTML/CSS/JS/TS) + formatter (**Prettier**) + snippets
- Project navigation (**project.el**, **Magit**, **Treemacs**)
- Modern completion (**Vertico/Orderless/Consult/Embark**) + **Company**
- Integrated terminal (**vterm** / **multi-vterm**)
- **LSP** (lsp-mode + lsp-ui) and **debugging** (dap-mode)

> Note: there are **two hardcoded paths** in the configuration for Reveal/MathJax (`/home/francesco/...`).  
> In the “Customizations” section you will find instructions on how to fix them.

You will also need to create a directory `~/.emacspkgs`, where you can place packages that are not available in the repositories listed in the file.

---

## File structure

- `config.org` → main configuration (literate)
- `config.el` → automatically generated from `config.org` (tangle)
- `Init` (or `init.txt`) → commands to install **system dependencies** (pacman/paru/npm/pip/…)

---

## Minimum requirements

### Emacs
- **Emacs 30+**. The official `emacs` package on Arch includes/enables native compilation and has replaced the old “nativecomp” packages.

### Font
The configuration uses the following font by default:

- `JetBrainsMonoNL Nerd Font Mono`

On Arch Linux you can install it with:
```bash
sudo pacman -S --needed ttf-jetbrains-mono-nerd
```

If you prefer another font, modify:
```elisp
(defconst fp/font-name "JetBrainsMonoNL Nerd Font Mono")
```
in `config.org`.

### External tools used by the configuration

The following binaries are **required** or strongly recommended:

- Search: `ripgrep`, `fd`, `fzf`
- Git: `git` (required for Magit)
- Emacs terminal: build toolchain + `libvterm`
- LSP servers (language-dependent): `texlab`, `pyright`, `rust-analyzer`, `clangd`, `fortls`, `typescript-language-server`, …
- LaTeX: TeX Live + `latexmk`, `biber`, `chktex`, `latexindent`, `minted` + **Pygments**
- PDF viewer: **Okular** (preconfigured)
- Markdown: `pandoc` (on Arch: **`pandoc-cli`**)

---

## Installation

The `Init` file is organized into modules. To make **exactly** what is configured in `config.org` work, the essential modules are:

### 1) Pacman

```bash
sudo pacman -S --needed   emacs git ripgrep fd fzf   hunspell hunspell-en_gb hunspell-it   clang clang-tools-extra   gdb lldb valgrind ctags bear   base-devel cmake ninja libtool pkgconf libvterm   ghostscript poppler poppler-glib   texlab okular pandoc-cli
```

> **Check against `Init`:**
> - `ripgrep`, `fd`, vterm toolchain, `texlab` are already included.
> - **Missing** in `Init` but required: **`okular`** and **`pandoc-cli`**.
> - `git` is not listed in `Init` (often already installed, but recommended).

### 2) AUR

Present in `Init`:
- `emacs-pdf-tools-git`
- `fortls`

Example with `paru`:
```bash
paru -S --needed emacs-pdf-tools-git fortls
```

### 3) NPM

```bash
npm install -g   typescript typescript-language-server   vscode-langservers-extracted   emmet-ls prettier markdownlint-cli   bash-language-server yaml-language-server   pyright decktape eslint
```

### 4) Python

```bash
sudo pacman -S --needed python python-pip
pip install --user   black isort ruff debugpy pygments ipython   jupyter jupyterlab   python-lsp-server[all]   flake8 mypy
```

### 5) Julia

```bash
julia -e 'using Pkg; Pkg.add(["LanguageServer","SymbolServer","JuliaFormatter","StaticLint","Revise","Debugger","OhMyREPL","IJulia"])'
```

### 6) R

```bash
R -q -e 'install.packages(c("languageserver","styler","lintr","formatR","devtools","roxygen2","IRkernel","httpgd")); IRkernel::installspec()'
```

### 7) Rust

```bash
rustup component add rust-analyzer rustfmt clippy
cargo install cargo-edit cargo-watch cargo-expand cargo-audit taplo-cli
```

### 8) TeX Live / LaTeX

**A) Pacman (recommended):**
```bash
sudo pacman -S --needed texlive texlive-binextra texlive-latexextra biber chktex
```

**B) tlmgr:**
```bash
tlmgr install minted latexindent latexmk chktex biber
```

---

## Installing the configuration

### 1) Clone the repository

```bash
git clone <REPO-URL> ~/.emacs.d
```

### 2) Minimal `init.el`

```elisp
(require 'org)

(let* ((dir (file-name-as-directory (expand-file-name "~/.emacs.d/")))
       (cfg-org (expand-file-name "config.org" dir))
       (cfg-el  (expand-file-name "config.el"  dir)))
  (when (file-exists-p cfg-org)
    (unless (file-exists-p cfg-el)
      (org-babel-tangle-file cfg-org cfg-el))
    (load cfg-el nil 'nomessage)))
```

### 3) First launch
On first launch, Emacs will download all ELPA/MELPA packages automatically.

### 4) Install `all-the-icons` fonts
- `M-x all-the-icons-install-fonts`
- Restart Emacs.

---

## Customizations

### Reveal.js / MathJax

Replace hardcoded paths with portable ones:
```elisp
(org-reveal-root (concat "file://" (expand-file-name "~/.local/share/revealjs/")))
(org-reveal-mathjax-url (concat "file://" (expand-file-name "~/.local/share/mathjax/es5/tex-mml-chtml.js")))
```

### Okular

```elisp
(TeX-view-program-selection '((output-pdf "Okular")))
(TeX-view-program-list '(("Okular" "okular --unique %o#src:%n%b")))
```

---

## Keybindings (cheatsheet)

### Search / minibuffer
- `C-s` → consult-line
- `C-c s r` → consult-ripgrep
- `C-x b` → consult-buffer

### Projects / Git
- `C-c f` → project-find-file
- `C-c g` → magit-status

### LSP
- `C-c C-r` → lsp-rename
- `C-c C-l` → lsp-format-buffer

### vterm
- `C-c t` → new vterm
- `C-c n / C-c p` → next/prev

### LaTeX
- `F6` → build
- `C-c C-c` → compile
- `C-c C-v` → view PDF

