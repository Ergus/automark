Readme
======

This is a simple package to enable mark on some movement commands.

This reduces enabling and disabling the mark manually constantly.

The config is pretty simple:

```Lisp
(use-package automark
  :diminish
  :load-path (lambda nil (my/load-path "~/gits/emacs_clones/automark-mode/"))
  :config
  (automark-mode 1))
```
