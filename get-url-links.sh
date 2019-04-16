#!/bin/bash
export TTY
# shopt -s nullglob # use for 'for' loops but not for 'ls', 'grep'

url="$1"

read -r -d '' code <<- HEREDOC
	(def a (->>
	        (slurp "$url")
	        (re-seq #"(?:http://)?www(?:[./#\+-]\w*)+")))
	(doseq [i a]
	   (println i))
HEREDOC

printf -- "%s" "$code" | clojure -