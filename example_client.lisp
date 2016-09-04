(ql:quickload :pushover)
(ql:quickload :creds)

(creds:load-creds)

(defun send-message (message)
  (pushover:send-pushover (creds:get-cred "potoken") (creds:get-cred "pouser") message))
