#!/bin/bash
export TTY

read -r -d '' shcode <<-HEREDOC
(ignore-errors (kill-buffer "*cider-repl tstprjclj*"))(find-file "$HOME/notes2018/ws/clojure/projects/tstprjclj/project.clj")(cider-jack-in)
HEREDOC

# sp -e "(ignore-errors (kill-buffer \"*cider-repl tstprjclj*\"))(find-file \"$HOME/notes2018/ws/clojure/projects/tstprjclj/project.clj\")(cider-jack-in)"

sp -e "$shcode"
