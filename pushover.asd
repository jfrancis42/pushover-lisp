;;;; pushover.asd

(asdf:defsystem #:pushover
  :description "A library for using the Pushover API."
  :author "Jeff Francis <jeff@gritch.org>"
  :license "Specify license here"
  :depends-on (#:drakma
               #:cl-json)
  :serial t
  :components ((:file "package")
               (:file "pushover")))

