(ns com.bluepojo.skirmisher.probability
  (:require  [clojure.test :as test])
  (:require [com.bluepojo.skirmisher.model :as model])
  (:require [clojure.contrib.trace :as trace]))

(test/with-test
  (defn to-wound
    ([s t]
       (let [x (+ 4 (- t s))]
         (max 2 (min 6 x)))))
  (test/is (= (to-wound 3 3) 4))
  (test/is (= (to-wound 3 4) 5))
  (test/is (= (to-wound 3 2) 3))
  (test/is (= (to-wound 3 1) 2))
  (test/is (= (to-wound 4 1) 2))
  (test/is (= (to-wound 5 1) 2))
  (test/is (= (to-wound 6 1) 2))
  (test/is (= (to-wound 7 1) 2))
  (test/is (= (to-wound 4 6) 6))
  (test/is (= (to-wound 4 7) 6)))

(test/with-test
  (defn to-hit
    ([attacker-ws defender-ws]
       (let [difference (- defender-ws attacker-ws)]
         (cond (> difference attacker-ws) 5
               (< difference 0)  3
               :else 4))))
  (test/is (= (to-hit 3 3) 4))
  (test/is (= (to-hit 3 4) 4))
  (test/is (= (to-hit 3 5) 4))
  (test/is (= (to-hit 3 6) 4))
  (test/is (= (to-hit 3 7) 5))
  (test/is (= (to-hit 3 8) 5))
  (test/is (= (to-hit 3 2) 3))
  (test/is (= (to-hit 3 1) 3)))

(test/with-test
  (defn to-save-armor
    ([s armor]
       (let [modifier (max 0 (- s 3))]
         (max 2 (+ armor  modifier)))))
  (test/is (= (to-save-armor 5 2) 4))
  (test/is (= (to-save-armor 5 3) 5))
  (test/is (= (to-save-armor 5 5) 7))
  (test/is (= (to-save-armor 1 3) 3))
  (test/is (= (to-save-armor 2 3) 3))
  (test/is (= (to-save-armor 3 3) 3))
  (test/is (= (to-save-armor 3 1) 2))
  (test/is (= (to-save-armor 3 -1) 2)))

(test/with-test
  (defn to-save-ward
    ([ward]
       (max 2 ward)))
  (test/is (= (to-save-ward 0) 2))
  (test/is (= (to-save-ward 7) 7))
  (test/is (= (to-save-ward -5) 2))
  (test/is (= (to-save-ward 3) 3)))

(test/with-test
  (defn probability-of
    ([target-roll]
       (/ (- 7 (min 7 (max 1 target-roll)))
          6)))
  (test/is (= (probability-of 6) (/ 1 6)))
  (test/is (= (probability-of 7) 0))
  (test/is (= (probability-of 4) (/ 3 6)))
  (test/is (= (probability-of 0) 1))
  (test/is (= (probability-of -1) 1))
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
  (defn to-wound-on-single-attack
    ([attacker defender]
       (reduce * [(probability-of (to-hit (:ws attacker) (:ws defender)))
                  (probability-of (to-wound (:s attacker) (:t defender)))
                  (inverted (probability-of (to-save-armor (:s attacker) (:armor defender))))
                  (inverted (probability-of (to-save-ward  (:ward defender))))])))
  ;; 3 to hit, 4 to wound, no saves: 2/3 hit, 1/2 wound, 0/6 saves
  (test/is (= (to-wound-on-single-attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5)) (/ 1 3)))
  (test/is (= (to-wound-on-single-attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :armor 1)) (/ 1 9)))
  (test/is (= (to-wound-on-single-attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :armor 1 :ward 4)) (/ 1 18)))
  (test/is (= (to-wound-on-single-attack (model/create :ws 5 :s 5) (model/create :ws 3 :t 5 :ward 4)) (/ 1 6))))



(test/with-test
  (defn kill-impossible?
    ([attacks wounds remaining_chance]
       (or (< attacks wounds)
           (< attacks 0)
           (= remaining_chance 0))))
  (test/is (= (kill-impossible? 3 3 1)   false))
  (test/is (= (kill-impossible? 3 3 0)   true))
  (test/is (= (kill-impossible? -1 -1 1) true))
  (test/is (= (kill-impossible? 2 3 1)   true)))

(test/with-test
  (defn kill-completed?
    ([attacks wounds exact]
       (cond (and (= wounds 0) (= attacks 0) (= exact)) true
             (and (= wounds 0) (not exact)) true
             :else false)))
  (test/is (= (kill-completed? 0 1 true)  false))
  (test/is (= (kill-completed? 1 1 false) false))
  (test/is (= (kill-completed? 0 0 true)  true))
  (test/is (= (kill-completed? 1 0 false) true))
  (test/is (= (kill-completed? 0 0 false) true)))

(defn- perform-kill
  ([attacks wounds chance_to_wound remaining_chance exact]
     (if (kill-impossible? attacks wounds remaining_chance) 0
         (if (kill-completed? attacks wounds exact) remaining_chance
             (let [remaining_chance_for_wound_branch (* chance_to_wound remaining_chance)
                   remaining_chance_for_fail_branch (- remaining_chance remaining_chance_for_wound_branch)
                   wound_branch (perform-kill (- attacks 1) (- wounds 1) chance_to_wound, remaining_chance_for_wound_branch exact)
                   fail_branch (perform-kill (- attacks 1) wounds chance_to_wound remaining_chance_for_fail_branch exact)]
               (+ wound_branch fail_branch))))))

(test/with-test
  (defn to-kill
    ([attacker defender]
       (let [chance_to_wound (to-wound-on-single-attack attacker defender)]
         (perform-kill (:a attacker) (:w defender) chance_to_wound 1 false))))
  (let [defender (model/create :ws 3 :t 3 :w 1)]
    (test/is (= (to-kill (model/create :ws 3 :s 3 :a 1) defender) 1/4))
    (test/is (= (to-kill (model/create :ws 4 :s 3 :a 1) defender) 1/3))
    (test/is (= (to-kill (model/create :ws 1 :s 3 :a 1) defender) 1/6))
    (test/is (= (to-kill (model/create :ws 3 :s 4 :a 1) defender) 1/3))
    (test/is (= (to-kill (model/create :ws 3 :s 5 :a 1) defender) 5/12)))
  (let [defender (model/create :ws 3 :t 3 :w 2)]
    (test/is (= (to-kill (model/create :ws 3 :s 3 :a 1) defender) 0))
    (test/is (= (to-kill (model/create :ws 4 :s 3 :a 2) defender) 1/9))
    (test/is (= (to-kill (model/create :ws 1 :s 3 :a 2) defender) 1/36))
    (test/is (= (to-kill (model/create :ws 3 :s 4 :a 2) defender) 1/9))
    (test/is (= (to-kill (model/create :ws 3 :s 5 :a 2) defender) 25/144)))
  (let [defender (model/create :ws 3 :t 3 :w 1)]
    (test/is (= (to-kill (model/create :ws 3 :s 3 :a 2) defender) 7/16))
    (test/is (= (to-kill (model/create :ws 4 :s 3 :a 2) defender) 5/9))
    (test/is (= (to-kill (model/create :ws 1 :s 3 :a 2) defender) 11/36))
    (test/is (= (to-kill (model/create :ws 3 :s 4 :a 2) defender) 5/9))
    (test/is (= (to-kill (model/create :ws 3 :s 5 :a 2) defender) 95/144))))

(test/with-test
  (defn to-score-exact-wounds
    ([attacker defender wounds]
       ())))


