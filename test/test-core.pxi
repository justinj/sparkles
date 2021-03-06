(ns sparkles.test
  (:require [pixie.test :as t]
            [pixie.string :as s]
            [sparkles.core :as sparkles]))

; a little sketchy, but works
(defn string->number [s]
  (if (empty? s) nil
    (read-string s)))

(defn get-escape-codes [s]
  (let [chars (seq s)
        without-prefix (drop 2 chars)
        upto-m (apply str (take-while #(not (= \m %)) without-prefix))
        codes (set (map string->number (s/split upto-m ";")))]
    codes))

(def esc (char 27))

(t/deftest explicit
  (let [red-fg (sparkles/color {:fg :red})]
    (t/assert= (seq (red-fg "foo"))
              [esc \[ \3 \1 \m \f \o \o esc \[ \0 \m])))

(t/deftest single
  (let [red-fg (sparkles/color {:fg :red})]
    (t/assert= (get-escape-codes (red-fg "foo"))
               #{31}))
  (let [blue-fg (sparkles/color {:fg :blue})]
    (t/assert= (get-escape-codes (blue-fg "foo"))
               #{34}))
  (let [blue-bg (sparkles/color {:bg :blue})]
    (t/assert= (get-escape-codes (blue-bg "foo"))
               #{44})))

(t/deftest multiple-codes
  (let [fancy (sparkles/color {:fg :red
                          :bg :blue})]
    (t/assert= (get-escape-codes (fancy "foo")) #{31 44})))

(t/deftest styles
  (let [underline (sparkles/color {:styles [:underline]})]
    (t/assert= (get-escape-codes (underline "foo")) #{4}))
  (let [underline-inverse (sparkles/color {:styles [:underline :inverse]})]
    (t/assert= (get-escape-codes (underline-inverse "foo")) #{4 7})))

(defn parse-elem [elem]
  (let [without-prefix (rest elem)
        upto-m (apply str (take-while #(not (= \m %)) without-prefix))
        codes (set (map string->number (s/split upto-m ";")))
        after-m (apply str (rest (drop-while #(not (= \m %)) without-prefix)))]
    [codes after-m]))

; kind of a weird parsing format but it's easy and maps closely to the text.
; better format welcome though
(defn parse [text]
  (let [sections (s/split text (str (char 27)))]
    (map parse-elem (rest sections))))

(t/deftest concatenates-strs
  (let [red (sparkles/color {:fg :red})]
    (t/assert= (parse (red "foo" "bar"))
               [[#{31} "foo"] [#{0} ""] [#{31} "bar"] [#{0} ""]])))

(t/deftest composing-colors
  (let [red  (sparkles/color {:fg :red})
        blue (sparkles/color {:fg :blue})]
    (t/assert= (parse (red (blue "blue")))
               [[#{31} ""] [#{34} "blue"] [#{0} ""] [#{0} ""]]))
  (let [red  (sparkles/color {:fg :red})
        blue (sparkles/color {:fg :blue})]
    (t/assert= (parse (red (blue "blue") "red" (blue "blue")))
               [[#{31} ""]
                    [#{34} "blue"] [#{0} ""]
                  [#{0} ""]
                  [#{31} "red"] [#{0} ""]
                  [#{31} ""]
                    [#{34} "blue"] [#{0} ""]
                  [#{0} ""]])))

(t/deftest errors-on-non-existent-values
  (t/assert-throws? (sparkles/color {:fg :rainbow}))
  (t/assert-throws? (sparkles/color {:bg :rainbow}))
  (t/assert-throws? (sparkles/color {:styles [:wahoo]})))
