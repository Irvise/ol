(define-library (owl port)
   (export 
      make-port

      socket? 
      tcp?

      fd->port
      fd->socket
      fd->tcp

      port->fd)  ;; port | socket | tcp → fd

   (import
      (owl defmac))

   (begin
      (define (make-port)     (raw type-port '(0)))

      (define (socket? x)     (eq? (type x) type-socket))
      (define (tcp? x)        (eq? (type x) type-tcp-client))

      (define (fd->port fd)   (raw type-port (list fd)))
      (define (fd->socket fd) (cast fd type-socket))
      (define (fd->tcp fd)    (cast fd type-tcp-client))

      (define (port->fd port) (cast port type-fix+))


))
