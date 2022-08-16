#entry point https://stackoverflow.com/questions/20223601/r-how-to-run-some-code-on-load-of-package processing function
#functions that invoke when load of the package

# install knitr hooks when package is attached to search path
.onAttach <- function(libname, pkgname) {
  initialize_vlab()
  install_mark_knitr_hooks()
}
