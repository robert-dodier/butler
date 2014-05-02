(in-package #:butler)


(defun kernel-heartbeat (heartbeat-socket)
  (loop
     (let ((query (make-instance 'zmq:msg)))
       (zmq:recv heartbeat-socket query))
     (zmq:send heartbeat-socket (make-instance 'zmq:msg :data query))))


(defun kernel-start (config)
  (zmq:with-context (ctx 1)
    (zmq:with-socket (heartbeat-socket ctx zmq:rep)
      (flet ((cfg (key) (config-value key config)))
        (zmq:bind heartbeat-socket (socket-bind-address (cfg :transport)
                                                        (cfg :ip)
                                                        (cfg :hb--port)))
        (bordeaux-threads:make-thread
         #'(lambda () (kernel-heartbeat heartbeat-socket)))))))
