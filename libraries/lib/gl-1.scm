(define-library (lib gl-1)
(import
   (scheme core)
   (lib gl) (OpenGL version-1-4))
(export
   (exports (lib gl))
   (exports (OpenGL version-1-4))))
