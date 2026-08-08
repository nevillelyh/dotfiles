#!/bin/sh

set -eu

config="$HOME/.dotfiles/private/profile.d/ntfy.sh"
if [ ! -r "$config" ]; then
    echo "missing ntfy config: $config" >&2
    exit 1
fi
# shellcheck source=/dev/null
. "$config"

: "${NTFY_TOKEN:?missing NTFY_TOKEN}"
: "${NTFY_HOST:?missing NTFY_HOST}"
: "${NTFY_TOPIC_HERDR:?missing NTFY_TOPIC_HERDR}"

publish() {
    curl --fail --silent --show-error \
        -H "Authorization: Bearer $NTFY_TOKEN" \
        -H "Title: $1" \
        -H "Priority: $2" \
        -H "Tags: $3" \
        --data-binary "$4" \
        "${NTFY_HOST%/}/$NTFY_TOPIC_HERDR" >/dev/null
}

if [ "${1:-}" = test ]; then
    publish "Herdr test" default test "ntfy notifications are working."
    exit 0
fi

event=${HERDR_PLUGIN_EVENT_JSON:-}
status=$(printf '%s' "$event" | jq -er '.data.agent_status // empty | ascii_downcase') || exit 0
case "$status" in
done | blocked) ;;
*) exit 0 ;;
esac

pane_id=$(printf '%s' "$event" | jq -r '.data.pane_id // "unknown"')
herdr_bin=${HERDR_BIN_PATH:-herdr}
snapshot=$("$herdr_bin" api snapshot 2>/dev/null || true)

if [ "$status" = blocked ]; then
    rendered=$(printf '%s' "$snapshot" | jq -er --arg pane_id "$pane_id" '
        .result.snapshot as $snapshot
        | ($snapshot.panes[] | select(.pane_id == $pane_id)) as $pane
        | ($snapshot.layouts[]
            | select(
                .workspace_id == $snapshot.focused_workspace_id
                and .tab_id == $snapshot.focused_tab_id
            )) as $layout
        | if $pane.workspace_id != $snapshot.focused_workspace_id
            or $pane.tab_id != $snapshot.focused_tab_id
          then false
          elif $layout.zoomed
          then $layout.focused_pane_id == $pane_id
          else any($layout.panes[]; .pane_id == $pane_id)
          end
    ' 2>/dev/null || true)
    [ "$rendered" = true ] && exit 0
fi

metadata=$(printf '%s' "$snapshot" | jq -r --arg pane_id "$pane_id" '
    .result.snapshot as $snapshot
    | ($snapshot.panes[] | select(.pane_id == $pane_id)) as $pane
    | ($snapshot.workspaces[] | select(.workspace_id == $pane.workspace_id)) as $workspace
    | ($snapshot.tabs[] | select(.tab_id == $pane.tab_id)) as $tab
    | [
        ($pane.agent // "Agent"),
        ("workspace " + $workspace.label),
        ("tab " + $tab.label),
        ("pane " + $pane_id)
      ]
    | join(" · ")
' 2>/dev/null || true)
[ -n "$metadata" ] || metadata="Agent · pane $pane_id"

case "$status" in
done)
    publish "Herdr agent done" default white_check_mark "$metadata"
    ;;
blocked)
    publish "Herdr agent blocked" high warning "$metadata"
    ;;
esac
