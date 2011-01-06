(ns com.bluepojo.skirmisher.probability
  (:require  [clojure.test :as test])
  (:require [com.bluepojo.skirmisher.model :as model])
  (:require [clojure.contrib.trace :as trace]))

(test/with-test
  (defn to_wound
    ([s t]
       (let [x (+ 4 (- t s))]
         (max 2 (min 6 x)))))
  (test/is (= (to_wound 3 3) 4))
  (test/is (= (to_wound 3 4) 5))
  (test/is (= (to_wound 3 2) 3))
  (test/is (= (to_wound 3 1) 2))
  (test/is (= (to_wound 4 1) 2))
  (test/is (= (to_wound 5 1) 2))
  (test/is (= (to_wound 6 1) 2))
  (test/is (= (to_wound 7 1) 2))
  (test/is (= (to_wound 4 6) 6))
  (test/is (= (to_wound 4 7) 6)))

(test/with-test
  (defn to_hit
    ([attacker_ws defender_ws]
       (let [difference (- defender_ws attacker_ws)]
         (cond (> difference attacker_ws) 5
               (< difference 0)  3
               :else 4))))
  (test/is (= (to_hit 3 3) 4))
  (test/is (= (to_hit 3 4) 4))
  (test/is (= (to_hit 3 5) 4))
  (test/is (= (to_hit 3 6) 4))
  (test/is (= (to_hit 3 7) 5))
  (test/is (= (to_hit 3 8) 5))
  (test/is (= (to_hit 3 2) 3))
  (test/is (= (to_hit 3 1) 3)))

(test/with-test
  (defn to_save_armor
    ([s armor]
       (let [modifier (max 0 (- s 3))]
         (max 2 (+ armor  modifier)))))
  (test/is (= (to_save_armor 5 2) 4))
  (test/is (= (to_save_armor 5 3) 5))
  (test/is (= (to_save_armor 5 5) 7))
  (test/is (= (to_save_armor 1 3) 3))
  (test/is (= (to_save_armor 2 3) 3))
  (test/is (= (to_save_armor 3 3) 3))
  (test/is (= (to_save_armor 3 1) 2))
  (test/is (= (to_save_armor 3 -1) 2)))

(test/with-test
  (defn to_save_ward
    ([ward]
       (max 2 ward)))
  (test/is (= (to_save_ward 0) 2))
  (test/is (= (to_save_ward 7) 7))
  (test/is (= (to_save_ward -5) 2))
  (test/is (= (to_save_ward 3) 3)))

(test/with-test
  (defn probability_of
    ([target_roll]
       (/ (- 7 (min 7 (max 1 target_roll)))
          6)))
  (test/is (= (probability_of 6) (/ 1 6)))
  (test/is (= (probability_of 7) 0))
  (test/is (= (probability_of 4) (/ 3 6)))
  (test/is (= (probability_of 0) 1))
  (test/is (= (probability_of -1) 1))
  )

(test/with-test
  (defn inverted
    [probability]
    (- 1 probability))
  (test/is (= (inverted 1/3) 2/3))
  (test/is (= (inverted 3/5) 2/5))
  (test/is (= (inverted 1) 0))
  (test/is (= (inverted 0) 1)))

(test/with-test
  (defn to_wound_on_single_attack
    ([attacker defender]
       (reduce * [(probability_of (to_hit (:ws attacker) (:ws defender)))
                  (probability_of (to_wound (:s attacker) (:t defender)))
                  (inverted (probability_of (to_save_armor (:s attacker) (:armor defender))))
                  (inverted (probability_of (to_save_ward  (:ward defender))))])))
  ;; 3 to hit, 4 to wound, no saves: 2/3 hit, 1/2 wound, 0/6 saves
  (test/is (= (to_wound_on_single_attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5)) (/ 1 3)))
  (test/is (= (to_wound_on_single_attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :armor 1)) (/ 1 9)))
  (test/is (= (to_wound_on_single_attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :armor 1 :ward 4)) (/ 1 18)))
  (test/is (= (to_wound_on_single_attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :ward 4)) (/ 1 6))))


