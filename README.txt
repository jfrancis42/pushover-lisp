pushover.lisp is a library for sending Pushover messages using the
Pushover API from Common Lisp. The documentation for the API is
available at https://pushover.net/api

There are three functions that can be called in this library:

* (send-pushover ...)
* (cancel-pushover ...)
* (check-receipt ...)

To the extent possible, the names used by Pushover in their API
documentation have been preserved in this code (or translated to their
logical equivalents). As of the time of this writing, all documented
API functions are supported in this library.

You must first register your application with Pushover and obtain a
Token. This token identifies you as the application author, as well as
the application itself to Pushover. This allows them to track your
usage, etc. Application registration is available (free) on their web
site.

You will also need a User Identifier. This is obtained by installing
the Pushover app on your Android or iOS device. You will need both a
Token and a User Identifier in order to send a message.

To send a message, you will call (send-pushover ...) with the
appropriate parameters. The first three parameters, token, user, and
message are mandatory.  Example:

(pushover:send-pushover "aqp4BUJysZ7jqK7r7D2P5S2qdznxkv" "uMrhoy99Nn8GnhnhQaQeAvEVQYedvf" "This is a test message.")

This is the minimum required. Additional parameters may be specified,
such as the the sound to be played upon receipt of the message, the
priority of the message, a callback URL, etc. The names and values of
these parameters have been kept as close to the API documentation as
possible. For example, to send a message that plays the siren upon
receipt, add the :sound :siren parameters:

(pushover:send-pushover "aqp4BUJysZ7jqK7r7D2P5S2qdznxkv" "uMrhoy99Nn8GnhnhQaQeAvEVQYedvf" "This is a test message." :sound :siren)

If sending the message succeeds, you will receive t, otherwise nil. If
you specify a priority of :priority :emergency, instead of t or nil,
you will receive a receipt ID or nil. The receipt ID should be kept in
order to check the status of the user's acknowlegement and/or to
cancel the emergency message. When sending an emergency message, you
can also specify :retry and :expire, per the API docs. In this
library, :retry defaults to 90 seconds and :expire defaults to 3600
seconds.

To cancel an emergency message, call (cancel-pushover ...) with your
token and the receipt ID. Example:

(pushover:cancel-pushover "aqp4BUJysZ7jqK7r7D2P5S2qdznxkv" "r3daccpy58atz545p4h9rffdxjqpnv")

This will result in a t or nil, representing success or failure of the
cancellation.

When an emergency message is sent, the user must acknowledge the
message (or it can time out or be canceled). In order to check the
status of the acknowledgement, use (check-receipt ...) with the token
and the receipt ID. This returns an association list with the various
values returned by Pushover. Example:

CL-USER> (pushover:check-receipt "aqp4BUJysZ7jqK7r7D2P5S2qdznxkv" "r3daccpy58atz545p4h9rffdxjqpnv")
((:STATUS . 1) (:ACKNOWLEDGED . 1) (:ACKNOWLEDGED--AT . 1472702768)
 (:ACKNOWLEDGED--BY . "uMrhoy99Nn8GnhnhQaQeAvEVQYedvf")
 (:ACKNOWLEDGED--BY--DEVICE . "itard") (:LAST--DELIVERED--AT . 1472702728)
 (:EXPIRED . 0) (:EXPIRES--AT . 1472789038) (:CALLED--BACK . 0)
 (:CALLED--BACK--AT . 0) (:REQUEST . "bab3dcf55d01b4b66181d1096074c38a"))
CL-USER> 

