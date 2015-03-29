(ns sparkles.core)

(def style-codes
  {:reset 0
   :bold 1
   :faint 2
   :underline 4
   :blink 5
   :inverse 7
   :hidden 8})

(def fg-color-codes
  {:black   30
   :red     31
   :green   32
   :yellow  33
   :blue    34
   :magenta 35
   :cyan    36
   :white   37})

(def bg-color-codes
  {:black   40
   :red     41
   :green   42
   :yellow  43
   :blue    44
   :magenta 45
   :cyan    46
   :white   47})

(defn formatter
  [{:keys [fg bg styles]}]
  (let [fg-code (fg-color-codes fg)
        bg-code (bg-color-codes bg)
        style-codes (seq (map style-codes styles))
        all-codes (seq (conj style-codes fg-code bg-code))
        provided-codes (filter identity all-codes)
        code-str (apply str (interpose ";" provided-codes))]
    (fn [s]
      (str (char 27) "[" code-str "m" s (char 27) "[0m"))))
