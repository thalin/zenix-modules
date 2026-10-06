"""Countdown timers for the bar.

Two kinds of widget:

- PresetTimer: one per preset in host_vars "timers.presets", e.g. tea.
  Left click starts/pauses/acknowledges, right click resets to the preset,
  scroll nudges the duration (or the time left, while running).
- AdhocTimers: one widget holding any number of named one-off timers,
  added through the bar prompt as e.g. "laundry 45m" or "1h30m game".
  Left click adds one (or dismisses finished ones), right click cancels one
  by name.

Finished timers send an urgent notification and stay highlighted until
acknowledged. Running timers are kept in $XDG_STATE_HOME/qtile/timers.json
so they survive a qtile restart.
"""

import json
import os
import re
import time

from libqtile.command.base import expose_command
from libqtile.utils import send_notification
from libqtile.widget.prompt import Prompt
from qtile_extras import widget

from .logging import logger
from .themes.gruvbox import theme


STATE_FILE = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "qtile",
    "timers.json",
)

# background per timer status
COLOURS = {
    "idle": theme["dark2"],
    "running": theme["faded_green"],
    "paused": theme["faded_yellow"],
    "done": theme["neutral_red"],
}

_UNITS = {"h": 3600, "m": 60, "s": 1, "": 60}  # bare numbers are minutes
_DURATION_RE = re.compile(r"(?:\d+(?:\.\d+)?[hms]?)+")
_DURATION_PART_RE = re.compile(r"(\d+(?:\.\d+)?)([hms]?)")


def parse_duration(text):
    """Seconds for "4m", "1h30m", "90s", "1.5h" or "45" (minutes); None if
    ``text`` isn't a duration. Numbers pass straight through as seconds."""
    if isinstance(text, (int, float)):
        return float(text)
    text = str(text).strip().lower()
    if not _DURATION_RE.fullmatch(text):
        return None
    return float(
        sum(float(n) * _UNITS[unit] for n, unit in _DURATION_PART_RE.findall(text))
    )


def parse_timer_spec(spec):
    """Split "laundry 45m" / "1h 30m check oven" into (name, seconds).

    Every word that parses as a duration is summed; the rest is the name."""
    seconds, name = 0.0, []
    for word in spec.split():
        d = parse_duration(word)
        if d is None:
            name.append(word)
        else:
            seconds += d
    return " ".join(name) or "timer", seconds


def format_seconds(seconds):
    seconds = max(0, int(round(seconds)))
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    return f"{h}:{m:02}:{s:02}" if h else f"{m}:{s:02}"


class Timer:
    """One countdown. Wall-clock based so it can be persisted."""

    def __init__(self, name, duration):
        self.name = name
        self.duration = duration  # what it was (or will be) set for
        self.end = None  # wall-clock end time while running
        self.left = None  # seconds left while paused
        self.done = False

    @property
    def status(self):
        if self.done:
            return "done"
        if self.end is not None:
            return "running"
        if self.left is not None:
            return "paused"
        return "idle"

    def remaining(self):
        if self.done:
            return 0.0
        if self.end is not None:
            return max(0.0, self.end - time.time())
        if self.left is not None:
            return self.left
        return self.duration

    def start(self):
        self.end = time.time() + (self.left if self.left is not None else self.duration)
        self.left = None
        self.done = False

    def pause(self):
        self.left = self.remaining()
        self.end = None

    def reset(self):
        self.end = self.left = None
        self.done = False

    def check_finished(self):
        """Flip a running timer to done once it hits zero; True if it just did."""
        if self.end is not None and time.time() >= self.end:
            self.end = None
            self.done = True
            return True
        return False

    def to_dict(self):
        return {
            "name": self.name,
            "duration": self.duration,
            "end": self.end,
            "left": self.left,
            "done": self.done,
        }

    @classmethod
    def from_dict(cls, d):
        t = cls(d["name"], d["duration"])
        t.end, t.left, t.done = d.get("end"), d.get("left"), d.get("done", False)
        return t


def _load_state():
    try:
        with open(STATE_FILE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


# Shared by every timer widget; each owns its own key.
_state = _load_state()


def _save_state(key, value):
    _state[key] = value
    try:
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        tmp = STATE_FILE + ".tmp"
        with open(tmp, "w") as f:
            json.dump(_state, f)
        os.replace(tmp, STATE_FILE)
    except OSError as e:
        logger.info(f"timers: unable to save state: {e}")


def _notify_finished(timer):
    send_notification(
        f"⏲ {timer.name}",
        f"{format_seconds(timer.duration)} timer finished",
        urgent=True,
    )


class _TimerWidget(widget.TextBox):
    """Ticks once a second and recolours itself (and so its powerline
    neighbours) to match the timer status."""

    def __init__(self, **config):
        super().__init__(text="", **config)

    def _configure(self, qtile, bar):
        super()._configure(qtile, bar)
        self._tick()

    def _tick(self):
        self.refresh()
        self.timeout_add(1, self._tick)

    def render(self):
        """Returns (text, status) for the current state."""
        raise NotImplementedError

    def refresh(self):
        text, status = self.render()
        background = COLOURS[status]
        if not self.can_draw():
            # Not laid out yet; the first bar draw picks these up.
            self.text, self.background = text, background
            return
        if background == self.background:
            if text != self.text:
                self.update(text)
            return
        # The powerline arrows either side take their colours from this
        # background, so the whole bar has to redraw, not just this widget.
        self.background = background
        self.text = text
        self.bar.draw()


class PresetTimer(_TimerWidget):
    """A fixed timer, e.g. tea; ``duration`` and ``step`` take "4m"-style
    strings or seconds."""

    defaults = [
        ("timer_name", "timer", "Timer name"),
        ("duration", "5m", "Preset duration"),
        ("icon", "⏲", "Icon shown before the name"),
        ("step", "1m", "How much one scroll tick changes the timer by"),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(PresetTimer.defaults)
        self.preset = parse_duration(self.duration) or 300.0
        self.step_seconds = parse_duration(self.step) or 60.0
        self.timer = Timer(self.timer_name, self.preset)
        saved = _state.get(self._key)
        # Only restore in-flight timers; an idle one picks up the (possibly
        # changed) preset from the host config instead.
        if saved and (saved.get("end") or saved.get("left") or saved.get("done")):
            self.timer = Timer.from_dict(saved)
        self.add_callbacks(
            {
                "Button1": self.toggle,
                "Button3": self.reset,
                "Button4": lambda: self.adjust(self.step_seconds),
                "Button5": lambda: self.adjust(-self.step_seconds),
            }
        )

    @property
    def _key(self):
        return f"preset:{self.timer_name}"

    def _save(self):
        _save_state(self._key, self.timer.to_dict())

    def _tick(self):
        if self.timer.check_finished():
            _notify_finished(self.timer)
            self._save()
        super()._tick()

    def render(self):
        t = self.timer
        if t.status == "done":
            return f"{self.icon} {t.name} done!", "done"
        if t.status == "paused":
            return f"{self.icon} {t.name} ⏸ {format_seconds(t.remaining())}", "paused"
        return f"{self.icon} {t.name} {format_seconds(t.remaining())}", t.status

    @expose_command()
    def toggle(self):
        """Start, pause or resume the timer; acknowledge it once done."""
        t = self.timer
        if t.status == "done":
            t.reset()
            t.duration = self.preset
        elif t.status == "running":
            t.pause()
        else:
            t.start()
        self._save()
        self.refresh()

    @expose_command()
    def start(self, duration=None):
        """(Re)start the timer, optionally for a different duration."""
        self.timer.reset()
        if duration is not None:
            self.timer.duration = parse_duration(duration) or self.timer.duration
        self.timer.start()
        self._save()
        self.refresh()

    @expose_command()
    def reset(self):
        """Stop the timer and go back to the preset duration."""
        self.timer.reset()
        self.timer.duration = self.preset
        self._save()
        self.refresh()

    @expose_command()
    def adjust(self, seconds):
        """Add (or remove) time: to the time left while running/paused,
        otherwise to the duration the next start uses."""
        t = self.timer
        if t.status == "running":
            t.end = max(time.time() + 1, t.end + seconds)
        elif t.status == "paused":
            t.left = max(1.0, t.left + seconds)
        elif t.status == "idle":
            t.duration = max(self.step_seconds, t.duration + seconds)
        self._save()
        self.refresh()


class AdhocTimers(_TimerWidget):
    """Any number of named one-off timers, added on the fly."""

    _key = "adhoc"

    defaults = [
        ("icon", "⏲", "Icon shown before the timers"),
        ("separator", " │ ", "Text between timers"),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(AdhocTimers.defaults)
        self.timers = [Timer.from_dict(d) for d in _state.get(self._key, [])]
        self.add_callbacks({"Button1": self.click, "Button3": self.prompt_cancel})

    def _save(self):
        _save_state(self._key, [t.to_dict() for t in self.timers])

    def _tick(self):
        finished = [t for t in self.timers if t.check_finished()]
        for t in finished:
            _notify_finished(t)
        if finished:
            self._save()
        super()._tick()

    def render(self):
        if not self.timers:
            return f"{self.icon} +", "idle"
        parts = [
            f"{t.name} done!" if t.done else f"{t.name} {format_seconds(t.remaining())}"
            for t in sorted(self.timers, key=lambda t: t.remaining())
        ]
        status = "done" if any(t.done for t in self.timers) else "running"
        return f"{self.icon} {self.separator.join(parts)}", status

    def _prompt(self):
        """The Prompt widget on the focused screen's bars, if there is one."""
        screen = self.qtile.current_screen
        for bar in (screen.bottom, screen.top):
            for w in getattr(bar, "widgets", []):
                if isinstance(w, Prompt):
                    return w
        logger.info("timers: no Prompt widget on the current screen")
        return None

    @expose_command()
    def click(self):
        """Dismiss finished timers if there are any, otherwise add one."""
        if any(t.done for t in self.timers):
            self.dismiss()
        else:
            self.prompt_add()

    @expose_command()
    def add(self, spec):
        """Start a timer from e.g. "laundry 45m"."""
        name, seconds = parse_timer_spec(spec)
        if seconds <= 0:
            send_notification("⏲ timers", f"No duration in {spec!r}, try e.g. 'laundry 45m'")
            return
        timer = Timer(name, seconds)
        timer.start()
        self.timers.append(timer)
        self._save()
        self.refresh()

    @expose_command()
    def cancel(self, name):
        """Cancel/dismiss every timer called ``name``."""
        self.timers = [t for t in self.timers if t.name != name.strip()]
        self._save()
        self.refresh()

    @expose_command()
    def dismiss(self):
        """Clear every finished timer."""
        self.timers = [t for t in self.timers if not t.done]
        self._save()
        self.refresh()

    @expose_command()
    def prompt_add(self):
        prompt = self._prompt()
        if prompt:
            prompt.start_input("timer (e.g. laundry 45m)", self.add)

    @expose_command()
    def prompt_cancel(self):
        if not self.timers:
            return
        prompt = self._prompt()
        if prompt:
            names = ", ".join(t.name for t in self.timers)
            prompt.start_input(f"cancel [{names}]", self.cancel)


def timer_widgets(timer_options, **config):
    """Build the bar widgets for host_vars "timers"."""
    widgets = [
        PresetTimer(
            name=f"timer_{p['name']}",
            timer_name=p["name"],
            duration=p["duration"],
            icon=p.get("icon", "⏲"),
            step=p.get("step", "1m"),
            padding=10,
            **config,
        )
        for p in timer_options.get("presets", [])
    ]
    if timer_options.get("adhoc", True):
        widgets.append(AdhocTimers(name="adhoc_timers", padding=10, **config))
    return widgets
