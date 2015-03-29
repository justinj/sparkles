(ns sparkles.core)

(def style-codes
  {:reset     0
   :bold      1
   :faint     2
   :underline 4
   :blink     5
   :inverse   7
   :hidden    8})

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

(deftype FormattedText [formatter contents]
  ISeqable
  (-seq [this] (seq (str this)))

  INamed
  (-name [this] (str this))

  IObject
  (-repr [this] (str this))
  (-str [this] (apply str (map formatter contents))))

(defn get-codes [from codes key]
  (let [codes (if (satisfies? ISeqable codes) codes [codes])]
  (filter identity
          (map #(let [value (from %)]
                  (if (and (not (nil? %)) (nil? value))
                    (throw (str "Invalid " key " code " %))
                    value))
               codes))))

(defn formatter [formatting]
  (let [{:keys [fg bg styles]} formatting
        fg-codes    (get-codes fg-color-codes [fg] :fg)
        bg-codes    (get-codes bg-color-codes [bg] :bg)
        style-codes (get-codes style-codes styles :styles)
        codes (concat style-codes fg-codes bg-codes)
        code-str (apply str (interpose ";" codes))
        formatter #(str (char 27) "[" code-str "m" % (char 27) "[0m")]
    (fn [& text] (->FormattedText formatter text))))
