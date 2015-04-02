(ns sparkles.core)

(def style-codes
  ^{:private true}
  {:reset     0
   :bold      1
   :faint     2
   :underline 4
   :blink     5
   :inverse   7
   :hidden    8})

(def fg-color-codes
  ^{:private true}
  {:black   30
   :red     31
   :green   32
   :yellow  33
   :blue    34
   :magenta 35
   :cyan    36
   :white   37})

(def bg-color-codes
  ^{:private true}
  {:black   40
   :red     41
   :green   42
   :yellow  43
   :blue    44
   :magenta 45
   :cyan    46
   :white   47})

(defn- get-codes [from codes key]
  (let [codes (if (satisfies? ISeqable codes) codes [codes])]
  (filter identity
          (map #(let [value (from %)]
                  (if (and (not (nil? %)) (nil? value))
                    (throw (str "Invalid " key " code " %))
                    value))
               codes))))

(defn color [formatting]
  (let [{:keys [fg bg styles]} formatting
        fg-codes    (get-codes fg-color-codes [fg] :fg)
        bg-codes    (get-codes bg-color-codes [bg] :bg)
        style-codes (get-codes style-codes styles :styles)
        codes (concat style-codes fg-codes bg-codes)
        code-str (apply str (interpose ";" codes))
        formatter #(str (char 27) "[" code-str "m" % (char 27) "[0m")]
    (fn [& text] (apply str (map formatter text)))))

(def red     (color {:fg :red}))
(def black   (color {:fg :black}))
(def red     (color {:fg :red}))
(def green   (color {:fg :green}))
(def yellow  (color {:fg :yellow}))
(def blue    (color {:fg :blue}))
(def magenta (color {:fg :magenta}))
(def cyan    (color {:fg :cyan}))
(def white   (color {:fg :white}))
