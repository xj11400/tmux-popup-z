#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main() {
    source "$CURRENT_DIR/scripts/popup.sh"
    tmux bind-key $(get-tmux-option "@z-popup-bind" '`') run-shell "$CURRENT_DIR/scripts/popup.sh z_popup"
    tmux bind-key $(get-tmux-option "@z-popup-bind-isolate" "@") run-shell "$CURRENT_DIR/scripts/popup.sh z_popup_isolate"
    tmux bind-key $(get-tmux-option "@z-popup-bind-break" "!") run-shell "$CURRENT_DIR/scripts/popup.sh z_popup_break"

    if [ ! -z "$(tmux show-option -gqv  "@z-popup-bind-detached")" ]; then
        tmux bind-key $(tmux show-option -gqv  "@z-popup-bind-detached") run-shell "$CURRENT_DIR/scripts/popup.sh z_popup_break_detached"
    fi
}

main
