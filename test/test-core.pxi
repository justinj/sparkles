(ns sparkles.test
  (use 'sparkles.core)
  (require pixie.test :as t)
  (require pixie.string :as s))

; a little sketchy, but works
(defn string->number [s]
  (if (empty? s) nil
    (read-string s)))

(defn get-escape-codes [s]
  (let [chars (seq s)
        without-prefix (drop 2 chars)
        upto-m (apply str (take-while #(not (= \m %)) without-prefix))
        codes (set (map string->number (s/split upto-m ";")))]
    codes
    ))

; gotta have at least one super low-level test, I guess.
(t/deftest explicit
  (let [red-fg (formatter {:fg :red})]
    (t/assert= (seq (red-fg "foo"))
              [(char 27) \[ \3 \1 \m \f \o \o (char 27) \[ \0 \m] )))

(t/deftest single
  (let [red-fg (formatter {:fg :red})]
    (t/assert= (get-escape-codes (red-fg "foo"))
               #{31}))
  (let [blue-fg (formatter {:fg :blue})]
    (t/assert= (get-escape-codes (blue-fg "foo"))
               #{34}))
  (let [blue-bg (formatter {:bg :blue})]
    (t/assert= (get-escape-codes (blue-bg "foo"))
               #{44})))

(t/deftest multiple-codes
  (let [fancy (formatter {:fg :red
                          :bg :blue})]
    (t/assert= (get-escape-codes (fancy "foo")) #{31 44})))

(t/deftest styles
  (let [underline (formatter {:styles [:underline]})]
    (t/assert= (get-escape-codes (underline "foo")) #{4}))
  (let [underline-inverse (formatter {:styles [:underline :inverse]})]
    (t/assert= (get-escape-codes (underline-inverse "foo")) #{4 7})))
