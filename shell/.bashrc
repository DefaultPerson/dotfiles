alias cc="claude"
alias ccr="claude --resume"
alias ccp='CLAUDE_CONFIG_DIR=$HOME/.claude-personal claude'
alias ccdr='claude --dangerously-skip-permissions --resume'
alias ccd='claude --dangerously-skip-permissions'
export PATH="$HOME/.local/bin:$PATH"

# Tmux grid: tgrid -n 4
tg() {

    local n=4
    while getopts "n:" opt; do
        case $opt in
            n) n=$OPTARG ;;
        esac
    done

    if [ "$n" -lt 1 ]; then
        echo "Need at least 1 pane"
        return 1
    fi

    tmux new-session -d -s "grid-$$"
    for ((i=1; i<n; i++)); do
        tmux split-window -t "grid-$$"
        tmux select-layout -t "grid-$$" tiled
    done
    tmux attach -t "grid-$$"
}

# Add pane to current grid
ta() {
    tmux
    tmux split-window
    tmux select-layout tiled
}

# Quick tmux grids
alias tg3='tg -n 3'

# 2 panes side-by-side (horizontal split)
tg2() {
    tmux new-session -d -s "split-$$"
    tmux split-window -h -t "split-$$"
    tmux attach -t "split-$$"
}
