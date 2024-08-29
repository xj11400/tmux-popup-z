#!/usr/bin/env bash

get-tmux-env() {
    tmux showenv -g "$1" | cut -d '=' -f 2
}

get-tmux-option() {
    # options=$1, default=$2
    local value="$(tmux show-option -gqv "$1")"
    echo "${value:-$2}"
}

popup_env() {
    current_session=$(tmux display-message -p '#{session_name}')
    current_path=$(tmux display-message -p '#{pane_current_path}')
    last_session=$(get-tmux-option '@last_session_name' '')

    # 'path', 'no'
    Z_POPUP_TITLE_TYPE=$(get-tmux-option '@z-popup-title-type' "off")
    if [ "$Z_POPUP_TITLE_TYPE" = "path" ]; then
        Z_POPUP_TITLE="| $current_path |"
    elif [ "$Z_POPUP_TITLE_TYPE" = "no" ]; then
        Z_POPUP_TITLE=""
    else
        Z_POPUP_TITLE=$(get-tmux-option '@z-popup-title' "| : ) |")
    fi

    Z_POPUP_SESSION_NAME=$(get-tmux-option '@z-popup-session-name' "Z-Popup")
    Z_POPUP_TEXT_COLOR=$(get-tmux-option '@z-popup-text-color' 'blue')
    Z_POPUP_BORDER_COLOR=$(get-tmux-option '@z-popup-border-color' 'black')
    Z_POPUP_BORDER_LINE=$(get-tmux-option '@z-popup-border-line' 'rounded')
    Z_POPUP_WIDTH=$(get-tmux-option '@z-popup-width' '75%')
    Z_POPUP_HEIGHT=$(get-tmux-option '@z-popup-height' '75%')
    Z_POPUP_STATUS=$(get-tmux-option '@z-popup-status' "on")
    Z_POPUP_STATUS_POSITION=$(get-tmux-option '@z-popup-status-position' "bottom")
}

popup() {
    if [ "$current_session" = "${Z_POPUP_SESSION_NAME}" ]; then
        # If the current session is '${Z_POPUP_SESSION_NAME}', detach the client
        tmux detach-client
    else
        # Set the last session name as a global tmux variable
        tmux set-option -g '@last_session_name' "$current_session"

        # status bar
        tmux set-option -t "${Z_POPUP_SESSION_NAME}" status $Z_POPUP_STATUS
        tmux set-option -t "${Z_POPUP_SESSION_NAME}" status-position $Z_POPUP_STATUS_POSITION

        # popup
        tmux popup \
            -d "$current_path" \
            -xC -yC \
            -w "${Z_POPUP_WIDTH}" \
            -h "${Z_POPUP_HEIGHT}" \
            -b "${Z_POPUP_BORDER_LINE}" \
            -S fg="${Z_POPUP_BORDER_COLOR}" \
            -s fg="${Z_POPUP_TEXT_COLOR}" \
            -T "${Z_POPUP_TITLE}" \
            -E "tmux new -A -s ${Z_POPUP_SESSION_NAME}"
    fi
}

z_popup() {
    popup_env

    if [[ "$current_session" == *"${Z_POPUP_SESSION_NAME}"* ]]; then
        Z_POPUP_SESSION_NAME="${current_session}"
    fi

    popup
}

z_popup_isolate() {
    popup_env
    Z_POPUP_TITLE="${Z_POPUP_TITLE} ${current_session} |"

    if [[ "$current_session" == *"${Z_POPUP_SESSION_NAME}"* ]]; then
        Z_POPUP_SESSION_NAME=${current_session}
    else
        Z_POPUP_SESSION_NAME="${Z_POPUP_SESSION_NAME}-${current_session}"
    fi

    popup
}

z_popup_break() {
    popup_env

    if [[ "$current_session" != *"${Z_POPUP_SESSION_NAME}"* ]]; then
        tmux break-pane
    else
        tmux break-pane -s ${Z_POPUP_SESSION_NAME} -t "$last_session:" -n $current_session
    fi
}

z_popup_break_detached() {
    popup_env

    if [[ "$current_session" == *"${Z_POPUP_SESSION_NAME}"* ]]; then
        tmux break-pane -d -s ${Z_POPUP_SESSION_NAME} -t "$last_session:" -n $current_session
    fi
}

$@
