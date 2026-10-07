# Start an ad-hoc bar timer: `qtile-timer laundry 45m`, or with no arguments
# ask for one through rofi. Same syntax as the widget: a name plus durations
# like 45m / 1h30m / 90s, bare numbers being minutes.

state="${XDG_STATE_HOME:-$HOME/.local/state}/qtile/timers.json"

# Running ad-hoc timers, one per line, for rofi's message area
running() {
  [[ -r $state ]] || return 0
  jq -r '
    def pad: tostring | if length < 2 then "0" + . else . end;
    def fmt: floor | if . < 0 then 0 else . end
      | if . >= 3600 then "\(. / 3600 | floor):\(. % 3600 / 60 | floor | pad):\(. % 60 | pad)"
        else "\(. / 60 | floor):\(. % 60 | pad)" end;
    (.adhoc // [])[]
    | (.name | @html) as $n
    | if .done then "\($n)  <b>done!</b>"
      elif .end then "\($n)  \(.end - now | fmt)"
      elif .left then "\($n)  \(.left | fmt) (paused)"
      else empty end
  ' "$state" 2>/dev/null || true
}

if (( $# )); then
  spec="$*"
else
  mesg="e.g. <i>laundry 45m</i>, <i>1h game</i>, <i>pizza 12</i> (minutes)"
  timers=$(running)
  [[ -n $timers ]] && mesg+=$'\n\n'"$timers"
  # No list to pick from, just the input line
  spec=$(rofi -dmenu -p timer -mesg "$mesg" \
    -theme-str 'listview { enabled: false; }' < /dev/null) || exit 0
fi

[[ -n ${spec//[[:space:]]/} ]] || exit 0
qtile cmd-obj -o widget adhoc_timers -f add -a "$spec" > /dev/null
