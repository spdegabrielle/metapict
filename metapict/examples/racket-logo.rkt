#lang racket
(require metapict)

;;;
;;; Racket Logo
;;;

; The following measurements were done with WebPlotDigitizer.
; The image used was racket-logo.svg.
; The logo consists of three blobs:
;   a blue to the right
;   a red to the left
;   a red in the middle

; The points below are points on the outlines
; in the anti-clockwise direction.

; Notes: The curves blue1, red-left-1 and red-middle-1
;        follow a circle, so we could use arc instead.

(def blue1 '(
455.38072669826227  412.5118483412322
508.7646129541864  277.434439178515
497.4407582938389  177.94628751974724
449.71879936808847  91.39968404423381
385.0110584518167  37.20695102685624
307.3617693522907  7.279620853080568
239.41864139020538  3.235387045813586
168.24012638230647  18.60347551342812
))

(def blue2 '(
169.85781990521326  18.60347551342812
230.521327014218  61.472353870458136
283.90521327014216  112.42969984202212
336.48025276461294  177.13744075829385
379.349131121643  241.84518167456557
415.7472353870458  308.1706161137441
439.2037914691943  359.93680884676144
455.38072669826227  413.32069510268565
))

(def red-left-1 '(
89.78199052132702  65.51658767772511
51.76619273301738  107.57661927330174
21.03001579778831  161.7693522906793
6.470774091627172  215.1532385466035
4.8530805687203795  280.6698262243286
19.412322274881518  344.5687203791469
38.015797788309634  385.0110584518167
67.13428120063192  422.21800947867297
))

(def red-left-2 '(
66.32543443917851  422.21800947867297
87.35545023696683  367.216429699842
109.19431279620854  321.1121642969984
143.16587677725119  262.8751974723539
178.75513428120064  211.91785150078988
220.00631911532386  164.1958925750395
))

(def red-left-3 '(
220.00631911532386  164.1958925750395
175.51974723538706  119.70932069510269
128.60663507109004  85.73775671406003
90.59083728278041  65.51658767772511
))

(def red-middle-1 '(
137.50394944707742  478.83728278041076
199.78515007898895  503.1026856240126
266.11058451816746  508.7646129541864
330.0094786729858  499.0584518167457
379.349131121643  477.21958925750397
))

(def red-middle-2 '(
379.349131121643  478.02843601895734
355.08372827804106  393.9083728278041
322.7298578199052  313.83254344391787
266.9194312796209  222.43285939968405
))

(def red-middle-3 '(
267.72827804107425  222.43285939968405
224.05055292259084  277.434439178515
191.69668246445497  334.86255924170615
169.04897314375987  379.349131121643
152.87203791469193  421.4091627172196
137.50394944707742  478.83728278041076
))


; convert the above points into MetaPict points (pt).
(define (measurements->pts ms)
  (match ms
    ['()  '()]
    [(list* x y ms) (cons (pt x y) (measurements->pts ms))]))


; In the measurements above the logo is centered in (256,256)
; and has a radius of 2*253. Also the y-cordinates are the wrong way.
; We fix this and transform the curves, so the logo is centered in (0,0)
; and has radius 1.
(define fix (scaled 1/253 (flipy (shifted -256 -256))))

; Connect the points with a nice curve (using .. between the points).
; Note: Using -- would connect the points with straight lines.
(define (conv ms)
  (curve* (add-between (map fix (measurements->pts ms)) ..)))


; outlines
(def blue-curve       (curve-append (conv blue1)
                                    (conv blue2)))
(def red-left-curve   (curve-append (conv red-left-1)
                                    (conv red-left-2)
                                    (conv red-left-3)))
(def red-middle-curve (curve-append (conv red-middle-1)
                                    (conv red-middle-2)
                                    (conv red-middle-3)))
; all curves
(def logo (list blue-curve red-left-curve red-middle-curve))


; colors - rgb values from original logo
(def red  (make-color* 157 31 36))
(def blue (make-color* 63 93 167))


; let's be fancy and give the blue area a gradient
(define blue-gradient
  (let ()
    (def stops  (map (λ(x) (/ x 50.)) (list 0 9 18 25 50)))
    (def colors (list (color-med 0.15 "white" blue)
                      (color-med 0.75 "white" blue)
                      blue
                      (color-med 0.80 "black" blue)
                      red))
    (gradient colors stops)))


; Here is a flat logo
(set-curve-pict-size 260 260)
(def light (pt 0.7 0.7))
#;(save-pict "racket-logo.png"
(beside
 (draw (color blue (fill blue-curve))
       (color red  (fill red-left-curve))
       (color red  (fill red-middle-curve)))
 
 ; A version with a spotlight at (0.7, 0.7).
 
 (freeze (draw ; (brushcolor "white" (fill (rectangle (pt -1 -1) (pt 1 1))))
               (brushgradient (radial-gradient light 0 light 2 blue-gradient)
                              (draw (fill blue-curve)))
               (color red (fill red-left-curve))
               (color red (fill red-middle-curve))))
         
         ; A Simple outline version
 (pencolor "white"
 (draw blue-curve red-left-curve red-middle-curve))
 
 ; A simple black and white filled version
 (brushcolor "white"
           (fill blue-curve red-left-curve red-middle-curve))))


;; (save-pict "racket-logo.png"
           
;;            (draw (color "white" (fill blue-curve))
;;                  (color "white" (fill red-left-curve))
;;                  (color "white" (fill red-middle-curve))
;;                  ))

;; Sticker Edition
;; (set-curve-pict-size 128 128)
;; (save-pict "racket-sticker.svg" 
;;            (with-font (make-similar-font (new-font)
;;                                          #:face "Cooper Hewitt"
;;                                          #:size 100)
;;              (beside  (draw (color blue (fill blue-curve))
;;                             (color red  (fill red-left-curve))
;;                             (color red  (fill red-middle-curve)))
;;                       (blank 15 1)
;;                       (above (blank 1 30)
;;                              (text "Racket"))))
;;            'svg)



(set-curve-pict-size 128 128)
(define white "white")
(define gray  (make-color* 196 196 196))

(require (prefix-in pict: pict)
         metapict/crop)

(define (create-racket-stories-logo file col)  
  (save-pict file
   (crop/inked
    (with-font
      (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 100)
      (beside  (draw (color col  (fill blue-curve))
                     (color col  (fill red-left-curve))
                     (color col  (fill red-middle-curve)))
               (blank 15 1)
               (above (blank 1 30)
                      (pict:text "Racket Stories"
                                 (cons (make-color* col)
                                       (current-font)))))))
   'svg))

(create-racket-stories-logo "white-logo-racket-stories.svg" white)
(create-racket-stories-logo  "gray-logo-racket-stories.svg" gray)

;;; For Racket Stories favicons
(set-curve-pict-size 260 260)
(save-pict "gray-racket-stories.png"
  (draw (color gray (fill blue-curve))
        (color gray (fill red-left-curve))
        (color gray (fill red-middle-curve))))

(save-pict "white-racket-stories.png"
  (draw (color white (fill blue-curve))
        (color white (fill red-left-curve))
        (color white (fill red-middle-curve))))

(save-pict "white-racket-stories.svg"
  (draw (color white (fill blue-curve))
        (color white (fill red-left-curve))
        (color white (fill red-middle-curve))))


(define (logo2020 level [transform identity])
  (set-curve-pict-size 260 260)
  (define t transform)
  (case level
    [(0)   (draw (color blue (fill (t blue-curve)))
                 (color red  (fill (t red-left-curve)))
                 (color red  (fill (t red-middle-curve))))]
    [else  (draw (color blue (fill (t blue-curve)))
                 (color red  (fill (t red-left-curve)))
                 (logo2020 (- level 1) (shifted 0.05 -0.4 (scaled 0.4 t))))]))

; (logo2020 10)


(define (create-racket-discourse-white-logo file)  
  (set-curve-pict-size 260 260)
  (define transparent
    (crop/inked
     (with-font
         (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 200)
       (beside  (draw (color blue  (fill blue-curve))
                      (color red   (fill red-left-curve))
                      (color red   (fill red-middle-curve)))
                (blank 15 1)
                (above (blank 1 30)
                       (pict:text "" #;"Racket"
                                  (cons (make-color* "black")
                                        (current-font))))))))
  (define w (pict-width  transparent))
  (define h (pict-height transparent))
  (define background      (filled-rectangle w h #:color "white" #:draw-border? #f))
  (define with-background (cc-superimpose background transparent))
  (save-pict file (scale (/ 120 h) with-background) 'png)
  with-background)

(create-racket-discourse-white-logo "racket-discourse-white-no-text.png")

(define (create-racket-discourse-black-logo file)  
  (define blackish (make-color* 17 17 17))
  (set-curve-pict-size 260 260)
  (define transparent
    (crop/inked
     (with-font
         (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 200)
       (beside  (draw (color blue  (fill blue-curve))
                      (color red   (fill red-left-curve))
                      (color red   (fill red-middle-curve)))
                (blank 15 1)
                (above (blank 1 30)
                       (pict:text "Racket"
                                  (cons (make-color* "white")
                                        (current-font))))))))
  (define w (pict-width  transparent))
  (define h (pict-height transparent))
  (define background      (filled-rectangle (* 1.02 w) (* 1 h) #:color blackish #:draw-border? #f))
  (define with-background (cc-superimpose background transparent))
  (save-pict file (scale (/ 120 h) with-background) 'png)
  with-background)
 
(create-racket-discourse-black-logo "racket-discourse-black-with-text.png")

(define (create-racket-discourse-black-logo-outside-transparent file)
  (define blackish (make-color* 221 221 221))
  (set-curve-pict-size 260 260)
  (define transparent
    (crop/inked
     (with-font
         (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 200)
       (beside  (draw (color blue  (fill blue-curve))
                      (color red   (fill red-left-curve))
                      (color red   (fill red-middle-curve)))
                (blank 15 1)
                (above (blank 1 30)
                       (pict:text "" #;"Racket"
                                  (cons (make-color* "white")
                                        (current-font))))))))
  (define w (pict-width  transparent))
  (define h (pict-height transparent))
  (displayln (list w h))
  (define background      (filled-ellipse (* 0.992 w) (* 0.992 h) #:color blackish #:draw-border? #f))
  (define with-background (cc-superimpose background transparent))
  (save-pict file (scale (/ 120 h) with-background) 'png)
  with-background)

(create-racket-discourse-black-logo-outside-transparent "racket-discourse-black-no-text-outside-transparent.png")

(define (create-racket-discourse-white-logo-outside-transparent file)  
  (set-curve-pict-size 260 260)
  (define transparent
    (crop/inked
     (with-font
         (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 200)
       (beside  (draw (color blue  (fill blue-curve))
                      (color red   (fill red-left-curve))
                      (color red   (fill red-middle-curve)))
                (blank 15 1)
                (above (blank 1 30)
                       (pict:text "" #;"Racket"
                                  (cons (make-color* "black")
                                        (current-font))))))))
  (define w (pict-width  transparent))
  (define h (pict-height transparent))
  (define background      (filled-ellipse (* 0.991 w) (* 0.991 h) #:color "white" #:draw-border? #f))
  (define with-background (cc-superimpose background transparent))
  (save-pict file (scale (/ 120 h) with-background) 'png)
  with-background)

(create-racket-discourse-white-logo-outside-transparent "racket-discourse-white-no-text-outside-transparent.png")

; The speech bubble was drawn in Inkscape and saved as a plain svg.
; The svg used commands m, c and C only, so these commands are implemented below.
; The end result is a metapict path.
(define speech-bubble
  (let ()
    (define-values (cx cy) (values 0 0))

    (define (move-relative dx dy)
      (set! cx (+ cx dx))
      (set! cy (+ cy dy)))
    
    (define (move-absolute x y)
      (set! cx x)
      (set! cy y))

    (define (cubic-absolute x1 y1  x2 y2  x y)  
      (define b (bez (pt cx cy)  (pt x1 y1)  (pt x2 y2)  (pt x y)))
      (move-absolute x y)
      b)

    (define (cubic-relative dx1 dy1  dx2 dy2  dx dy)  
      (cubic-absolute  (+ cx dx1) (+ cy dy1)  (+ cx dx2) (+ cy dy2)  (+ cx dx) (+ cy dy)))


    (define (c . as)
      (match as
        [(list)
         '()]
        [(list* dx1 dy1  dx2 dy2  dx dy as)
         (cons (cubic-relative dx1 dy1  dx2 dy2  dx dy)
               (apply c as))]
        [else
         (error 'raise-arguments-error 'c "expected 6*n floats" "arguments" as)]))
    
    (define (C . as)
      (match as
        [(list)
         '()]
        [(list* x1 y1  x2 y2  x y as)
         (cons (cubic-absolute x1 y1  x2 y2  x y)
               (apply C as))]
        [else
         (error 'raise-arguments-error 'C "expected 6*n floats" "arguments" as)]))
    

    (define m move-relative)
    (define M move-absolute)
    

    ; move to (dx,dy)
    (M 0 0)
    (m 108.41151  34.146771) 
    
    (define speech-bubble
      (let ()
        (define bezs
          (append
           ;   control:  dx1,dy1    control dx2,dy2          end dx      end dy
           (c  50.88374   0         89.32874   28.750338   90.26334   73.007109 
               1.16767  55.29342  -72.56155   70.49635   -89.82087   70.79478 
               -19.021879  0.3289   -23.84302   -1.92868   -37.609717  -6.19455 
               -6.80322   8.90992  -47.786473  21.68091   -51.326212  17.25623 
               -3.539738 -4.42467   16.371286 -21.6809     17.256223 -38.93712)
           ;   control:  x1,y1     control   x2, y2       end x      end y
           (C 18.590649 127.94985  19.475585 120.87037  19.033117 108.03882 
              17.599682 66.469241  58.412705 34.589239 108.41151 34.146771)))
        (curve: #t bezs)))

    speech-bubble))
    


(define (create-racket-discourse-favicon file)  
  (set-curve-pict-size 260 260)
  (define a 0.6)
  (define t (trans 1 0 0 1 0.2 -0.15))
  (define transparent
    (crop/inked
     (with-font
       (make-similar-font (new-font) #:face "Cooper Hewitt" #:size 200)
       (draw (penscale 16
                       (color "white"
                              (pencolor "black" (filldraw ((trans 1 0 0 1 -0.9 0.9) 
                                                           (flipy (scaled 1/100 speech-bubble)))))))
             (color blue  (fill (t (scaled a blue-curve))))
             (color red   (fill (t (scaled a red-left-curve))))
             (color red   (fill (t (scaled a red-middle-curve))))                      
             ))))
  (define w (pict-width  transparent))
  (define h (pict-height transparent))
  ; (define background      (filled-ellipse (* 0.991 w) (* 0.991 h) #:color "white" #:draw-border? #f))
  ; (define with-background (cc-superimpose background transparent))
  (save-pict file (scale (/ 120 h) transparent) 'svg)
  transparent)

(create-racket-discourse-favicon "racket-discourse-favicon8.svg")


