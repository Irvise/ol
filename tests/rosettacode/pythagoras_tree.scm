; http://rosettacode.org/wiki/Pythagoras_tree#Ol

(import (lib gl))
(import (OpenGL version-1-0))
(gl:set-window-size 700 600)
(gl:set-window-title "http://rosettacode.org/wiki/Pythagoras_tree")

(glLineWidth 2)
(gl:set-renderer (lambda (mouse)
   (glClear GL_COLOR_BUFFER_BIT)
   (glLoadIdentity)
   (glOrtho -3 4 -1 5 0 1)

   (let loop ((a '(0 . 0)) (b '(1 . 0)) (n 7))
      (unless (zero? n)
         (define dx (- (car b) (car a)))
         (define dy (- (cdr b) (cdr a)))
         (define c (cons
            (- (car b) dy)
            (+ (cdr b) dx)))
         (define d (cons
            (- (car a) dy)
            (+ (cdr a) dx)))
         (define e (cons
            (- (/ (+ (car c) (car d)) 2) (/ dy 2))
            (+ (/ (+ (cdr c) (cdr d)) 2) (/ dx 2))))

         (glColor3f 0 (+ 1/3 (/ 2/3 n)) 0)
         (glBegin GL_QUADS)
            (glVertex2f (car a) (cdr a))
            (glVertex2f (car b) (cdr b))
            (glVertex2f (car c) (cdr c))
            (glVertex2f (car d) (cdr d))
         (glEnd)
         (glColor3f 1 0 0)
         (glBegin GL_TRIANGLES)
            (glVertex2f (car c) (cdr c))
            (glVertex2f (car e) (cdr e))
            (glVertex2f (car d) (cdr d))
         (glEnd)
         (loop d e (- n 1))
         (loop e c (- n 1))
      ))
))
