;;;; pushover.lisp

(in-package #:pushover)

(defmacro cdr-assoc (name alist)
  "Replaces '(cdr (assoc name alist))' because it's used a bajillion
times when doing API stuff."
  `(cdr (assoc ,name ,alist :test #'equal)))

(defun join (stuff separator)
  "Join a list of strings with a separator (like ruby string.join())."
  (with-output-to-string (out)
    (loop (princ (pop stuff) out)
       (unless stuff (return))
       (princ separator out))))

(defun alist-encoder (alist)
  "Turn an alist of values to be passed to the Pushover API into a big
'percent encoded' string."
  (join
   (mapcar
    (lambda (n)
      (concatenate 'string
		   (drakma:url-encode
		    (car n) :utf-8) "="
		   (drakma:url-encode
		    (cdr n) :utf-8)))
    alist)
   "&"))

(defun send-pushover (token user message
		      &key device title url url-title
			(priority :normal)
			timestamp sound (retry 90)
			(expire 3600) callback)
  "expire defaults to one hour and retry defaults to 90 seconds."
  (let
      ((payload
	(acons "token" token
	       (acons "user" user
		      (acons "message" message nil)))))
    (assert (typep retry 'integer))
    (assert (typep expire 'integer))
    (if timestamp (assert (typep timestamp 'integer)))
    (if retry (if (< retry 30) (setf retry 30)))
    (if expire (if (> 86400 expire) (setf expire 86400)))
    (if device (setf payload (acons "device" device payload)))
    (if title (setf payload (acons "title" title payload)))
    (if url (setf payload (acons "url" url payload)))
    (if url-title (setf payload (acons "url_title" url-title payload)))
    (if callback (setf payload (acons "callback" callback payload)))
    (if timestamp (setf payload (acons "timestamp" timestamp payload)))
    (if sound
	(cond
	  ((equal sound :pushover)
	   (setf payload (acons "sound" "pushover" payload)))
	  ((equal sound :bike)
	   (setf payload (acons "sound" "bike" payload)))
	  ((equal sound :bugle)
	   (setf payload (acons "sound" "bugle" payload)))
	  ((equal sound :cashregister)
	   (setf payload (acons "sound" "cashregister" payload)))
	  ((equal sound :classical)
	   (setf payload (acons "sound" "classical" payload)))
	  ((equal sound :cosmic)
	   (setf payload (acons "sound" "cosmic" payload)))
	  ((equal sound :falling)
	   (setf payload (acons "sound" "falling" payload)))
	  ((equal sound :gamelan)
	   (setf payload (acons "sound" "gamelan" payload)))
	  ((equal sound :incoming)
	   (setf payload (acons "sound" "incoming" payload)))
	  ((equal sound :intermission)
	   (setf payload (acons "sound" "intermission" payload)))
	  ((equal sound :magic)
	   (setf payload (acons "sound" "magic" payload)))
	  ((equal sound :mechanical)
	   (setf payload (acons "sound" "mechanical" payload)))
	  ((equal sound :pianobar)
	   (setf payload (acons "sound" "pianobar" payload)))
	  ((equal sound :siren)
	   (setf payload (acons "sound" "siren" payload)))
	  ((equal sound :spacealarm)
	   (setf payload (acons "sound" "spacealarm" payload)))
	  ((equal sound :tugboat)
	   (setf payload (acons "sound" "tugboat" payload)))
	  ((equal sound :alien)
	   (setf payload (acons "sound" "alien" payload)))
	  ((equal sound :climb)
	   (setf payload (acons "sound" "climb" payload)))
	  ((equal sound :persistent)
	   (setf payload (acons "sound" "persistent" payload)))
	  ((equal sound :echo)
	   (setf payload (acons "sound" "echo" payload)))
	  ((equal sound :updown)
	   (setf payload (acons "sound" "updown" payload)))
	  ((equal sound :none)
	   (setf payload (acons "sound" "none" payload)))
	  (t
	   (setf payload (acons "sound" "pushover" payload)))))
    (if priority
	(cond
	  ((equal priority :lowest)
	   (setf payload (acons "priority" "-2" payload)))
	  ((equal priority :low)
	   (setf payload (acons "priority" "-1" payload)))
	  ((equal priority :normal)
	   (setf payload (acons "priority" "0" payload)))
	  ((equal priority :high)
	   (setf payload (acons "priority" "1" payload)))
	  ((equal priority :emergency)
	   (setf payload
		 (acons "priority" "2"
			(acons "retry"
			       (format nil "~A" retry)
			       (acons "expire"
				      (format nil "~A" expire)
				      payload)))))
	  (t
	   (setf payload (acons "priority" "0" payload)))))    
    (let
	((val (multiple-value-list
	       (drakma:http-request
		"https://api.pushover.net:443/1/messages.json"
		:method :post
		:content-type "application/x-www-form-urlencoded"
		:content (alist-encoder payload)))))
      (let ((pushover-reply
	     (json:decode-json-from-string
	      (babel:octets-to-string (first val)))))
	(if (= (cdr-assoc :status pushover-reply) 1)
	    (if (equal priority :emergency)
		(cdr-assoc :receipt pushover-reply)
		t)
	    nil)))))

(defun cancel-pushover (token receipt)
  "Cancel a previous emergency request."
  (let ((payload (acons "token" token nil)))
    (let ((val
	   (multiple-value-list
	    (drakma:http-request
	     (concatenate 'string
			  "https://api.pushover.net:443/1/receipts/"
			  receipt "/cancel.json")
	     :method :post
	     :content-type "application/x-www-form-urlencoded"
	     :content (alist-encoder payload)))))
      (let ((pushover-reply
	     (json:decode-json-from-string
	      (babel:octets-to-string (first val)))))
	(if (= (cdr-assoc :status pushover-reply) 1)
	    t
	    nil)))))

(defun check-receipt (token receipt)
  "Check to see if an emergency message has been acknowledged. Returns
an alist of values for you to check status (see Pushover docs for
details)."
  (let ((payload (acons "token" token nil)))
    (let ((val
	   (multiple-value-list
	    (drakma:http-request
	     (concatenate 'string
			  "https://api.pushover.net:443/1/receipts/"
			  receipt ".json")
	     :method :get
	     :content-type "application/x-www-form-urlencoded"
	     :content (alist-encoder payload)))))
      (let ((pushover-reply
	     (json:decode-json-from-string
	      (babel:octets-to-string (first val)))))
	pushover-reply))))
