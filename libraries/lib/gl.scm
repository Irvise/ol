(define-library (lib gl)
   (version 1.0)
   (license MIT/LGPL3)
   (description "otus-lisp gl library")
(import
   (otus lisp)
   (otus case-apply)
   (lib gl config)
   (OpenGL platform))

(export
   gl:set-window-title gl:set-window-size
   gl:set-renderer ; OpenGL rendering function
   gl:set-calculator ; Math and Phys calculations

   ; event handlers
   gl:set-mouse-handler
   gl:set-keyboard-handler
   gl:set-resize-handler

   ; getters
   gl:window-dimensions ; variable
   gl:get-window-width gl:get-window-height ; functions

   ; additional functions
   gl:hide-cursor
   gl:redisplay ; (swap buffers)

   ; * internal use (with gl3 and gl4)
   native:enable-context native:disable-context
   hook:exit)

   ; todo:
   ;gl:finish ; if renderer exists - wait for window close, else just glFinish

(begin
   (define WIDTH  (get config 'width  854))
   (define HEIGHT (get config 'height 480))

   ; assume that window size can not be large than 16777215 for x32 build
   ;                                  and 72057594037927935 for x64 build.
   (define STATE [0 0 WIDTH HEIGHT]) ; x y width height

   ; public getters
   (define gl:window-dimensions STATE)

   (define (gl:get-window-width)
      (ref STATE 3))
   (define (gl:get-window-height)
      (ref STATE 4))

   (define GL_VR_HINT #x12001)
   (define GL_VIEWPORT #x0BA2)
)

(begin
   (setq glGetIntegerv (GL_LIBRARY fft-void "glGetIntegerv" fft-int (fft& fft-int)))
)
; -=( native functions )=-------------------------------------
(cond-expand
   (Android (include "lib/gl/Android.scm"))
   (Linux (include "lib/gl/Linux.scm"))
   (Emscripten (include "lib/gl/WebGL.scm"))
   (Windows (include "lib/gl/Windows.scm"))
   (else (runtime-error "Unsupported platform" *uname*)))

; -=( opengl coroutine )=-------------------------------------
(cond-expand
   ((or Emscripten) ; special case
      (begin
         (actor 'opengl (lambda ()
         (let loop ((dictionary {
               ; defaults:
               'resize-handler (lambda (w h) (glViewport 0 0 w h))
         }))
            (let*((envelope (wait-mail))
                  (sender msg envelope))
               (case msg
                  ; low level interface:
                  (['set key value]
                     (loop (put dictionary key value)))
                  (['get key]
                     (mail sender (dictionary key #false))
                     (loop dictionary))
                  (['debug]
                     (mail sender dictionary)
                     (loop dictionary))

                  (['atexit]
                     ;; (unless (get dictionary 'renderer #f)
                     ;;    ; рендерера нет, значит оновим буфер
                     ;;    (gl:SwapBuffers (get dictionary 'context #f)))
                     ;;    ; рендерер есть, но режим интерактивный? тогда вернем управление юзеру
                     ;;    ;(if *interactive* ;(or (zero? (length (command-line))) (string-eq? (car (command-line)) "-"))
                     ;;    ;   (mail sender 'ok)))
                     (loop (put dictionary 'customer sender)))

                  (else
                     (runtime-error "Unknown opengl server command " msg)
                     (loop dictionary))
               )))))))
   (else
      (begin
         (actor 'opengl (lambda ()
         (let loop ((this {
               ; defaults
               'resize-handler (lambda (w h) (glViewport 0 0 w h))
               'vr-mode #false
         }))
         (cond
            ((check-mail) => (lambda (envelope)
               (let*((sender msg envelope))
                  (case msg
                     ; low level interface:
                     (['set key value]
                        (loop (put this key value)))
                     (['get key]
                        (mail sender (this key #false))
                        (loop this))
                     (['debug]
                        (mail sender this)
                        (loop this))

                     (['atexit]  ; wait for OpenGL window closing (just no answer for interact)
                        ;; (unless (get this 'renderer #f)
                        ;;    ; если рендерера нет, просто оновим буфер
                        ;;    (gl:SwapBuffers (get this 'context #f)))
                        ;;    ; рендерер есть, но режим интерактивный? тогда вернем управление юзеру
                        ;;    ;(if *interactive* ;(or (zero? (length (command-line))) (string-eq? (car (command-line)) "-"))
                        ;;    ;   (mail sender 'ok)))
                        (loop (put this 'customer sender)))

                     ; setters
                     (['set-window-title title]
                        (gl:SetWindowTitle (this 'context #f) title)
                        (loop this))

                     (['set-window-size width height]
                        (gl:SetWindowSize (this 'context #f) width height)
                        (glViewport 0 0 width height)
                        (loop this))

                     (['set-resize-handler resize-handler]
                        (if resize-handler ; force fire resize function
                           (resize-handler (ref STATE 3) (ref STATE 4)))
                        (loop (put this 'resize-handler resize-handler)))

                     ; events
                     (['resize width height]
                        (set-ref! STATE 3 width)  ; cache current window dimensions
                        (set-ref! STATE 4 height)

                        (let ((resize-handler (this 'resize-handler #f)))
                           (if resize-handler (resize-handler width height)))
                        (loop this))

                     (else
                        (runtime-error "Unknown opengl server command " msg)
                        (loop this))))))

            ; блок непосредственно рабочего цикла окна
            ((this 'context #f) => (lambda (context)
               (let ((calculator (this 'calculator #f))
                     (renderer (this 'renderer #f)))
                  ; 1. обработаем сообщения (todo: не более чем N за раз)
                  (native:process-events context (lambda (event)
                     (case event
                        (['quit] (halt 0))
                        (['keyboard key]
                           ((this 'keyboard-handler (lambda (kk) #f)) key))
                        (['mouse button x y]
                           ((this 'mouse-handler (lambda (b x y) #f)) button x y))
                        (else
                           #false))))
                  ; 2. вычисляем мир
                  (if calculator
                     (calculator))
                  ; 3. и нарисуем его
                  (when renderer
                     (define mouse (gl:GetMousePos (this 'context #f)))
                     (define (draw)
                        (case-apply renderer
                           (list 0)
                           (list 1 mouse)
                           (list 2 mouse { ; TBD.
                              'option1 #true
                              'option2 #false
                           })))

                     (if (this 'vr-mode) ;; VR mode
                     then
                        (define viewport '(0 0 0 0))

                        (glHint GL_VR_HINT 1)
                        ((this 'vr-begin))
                        (for-each (lambda (eye)
                              ((this 'vr-update) eye)
                              (glGetIntegerv GL_VIEWPORT viewport)
                              ; todo: use vector (update ffi.c)
                              (set-ref! gl:window-dimensions 1 (list-ref viewport 0))
                              (set-ref! gl:window-dimensions 2 (list-ref viewport 1))
                              (set-ref! gl:window-dimensions 3 (list-ref viewport 2))
                              (set-ref! gl:window-dimensions 4 (list-ref viewport 3))

                              (draw) ((this 'vr-flush)))
                           '(0 1)) ; left eye, right eye
                        ((this 'vr-end))
                        (glHint GL_VR_HINT 0)
                     else
                        (draw) ;; regular mode
                        (native:swap-buffers (this 'context []))))

                  ; 4. done
                  (sleep 0)
                  (loop this))))
            (else
               (sleep 1)
               (loop this)))))))))

(begin

; -=( main )=--------------------------
; force window creation.
(let ((context (native:create-context "Ol: OpenGL Window")))
   (if context
      (mail 'opengl ['set 'context context])
      (runtime-error "Can't create OpenGL context" #null)))

(define (gl:redisplay)
   (native:swap-buffers
      (await (mail 'opengl ['get 'context]))))

; ----------------------------------------------------------
; just change a function
(define (gl:set-renderer renderer)
   (mail 'opengl ['set 'renderer renderer]))

(define (gl:set-calculator calculator)
   (mail 'opengl ['set 'calculator calculator]))

; do some thing on change
(define (gl:set-window-title title)
   (mail 'opengl ['set-window-title title]))

(define (gl:set-window-size width height)
   (mail 'opengl ['set-window-size width height]))

(define hook:exit (lambda args
   (await (mail 'opengl ['atexit]))))

; -----------------------------
;; (define gl:Color (case-lambda
;;    ((r g b)
;;       (glColor3f r g b))))

(define (gl:hide-cursor)
   (gl:HideCursor (await (mail 'opengl ['get 'context]))))

(define (gl:set-mouse-handler handler)
   (mail 'opengl ['set 'mouse-handler handler]))

(define (gl:set-keyboard-handler handler)
   (mail 'opengl ['set 'keyboard-handler handler]))

(define (gl:set-resize-handler handler)
   (mail 'opengl ['set-resize-handler handler]))

))
