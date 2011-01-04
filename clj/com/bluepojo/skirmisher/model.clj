(use '[clojure.contrib.def :only [defnk]])

(defrecord Model [m ws bs s t w i a ld armor ward])

(defnk create
  [:m 0 :ws 0 :bs 0 :s 0 :t 0 :w 0 :i 0 :a 0 :ld 0 :armor 7 :ward 7]
  (Model. m ws bs s t w i a ld armor ward))
