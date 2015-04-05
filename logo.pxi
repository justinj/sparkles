(ns sparkles.logo
  (require sparkles.core :as sparkles))

(def logo
  (str " ____                   _    _            "     \newline
       "/ ___| _ __   __ _ _ __| | _| | ___  ___  "     \newline
       "\\___ \\| '_ \\ / _` | '__| |/ / |/ _ \\/ __| " \newline
       " ___) | |_) | (_| | |  |   <| |  __/\\__ \\ "   \newline
       "|____/| .__/ \\__,_|_|  |_|\\_\\_|\\___||___/ " \newline
       "      |_|                                 "))

(def colors [:red :black :red :green :yellow :blue :magenta :cyan :white])

(defn sample [s] (nth s (int (rem (rand) (count s)))))

(defn color-it! [c] ((sparkles/color {:fg (sample colors)}) c))

(println (apply str (map color-it! logo)))
