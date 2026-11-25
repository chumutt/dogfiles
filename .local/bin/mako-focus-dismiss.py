#!/usr/bin/env python3
# NAVI-KIND: TOOL
# Dismiss mako notifications when focus moves to the app that sent them.
# Listens on Hyprland's socket2 for activewindow>>CLASS,TITLE events.
import glob
import json
import os
import socket
import subprocess
import time


def sock_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    cands = glob.glob(os.path.join(runtime, "hypr", "*", ".socket2.sock"))
    if not cands:
        return None
    return max(cands, key=os.path.getmtime)


def matches(app_name, cls):
    a = (app_name or "").strip().lower()
    c = (cls or "").strip().lower()
    if not a or not c:
        return False
    return (
        a == c
        or c.endswith("." + a)
        or a.endswith("." + c)
        or (len(a) >= 3 and a in c)
    )


def dismiss_for(cls):
    try:
        out = subprocess.run(
            ["makoctl", "list", "-j"], capture_output=True, text=True, timeout=5
        ).stdout
        items = json.loads(out or "[]")
    except Exception as e:
        print("makoctl list failed:", e, flush=True)
        return
    for n in items:
        if matches(n.get("app_name"), cls):
            subprocess.run(["makoctl", "dismiss", "-n", str(n["id"])], timeout=5)
            print(f"dismissed {n['id']} ({n.get('app_name')}) on focus {cls}", flush=True)


def main():
    while True:
        path = sock_path()
        if not path:
            print("no Hyprland socket yet", flush=True)
            time.sleep(5)
            continue
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(path)
            print("connected to", path, flush=True)
            buf = b""
            while True:
                data = s.recv(4096)
                if not data:
                    break
                buf += data
                while b"\n" in buf:
                    line, buf = buf.split(b"\n", 1)
                    text = line.decode(errors="replace")
                    if text.startswith("activewindow>>"):
                        cls = text[len("activewindow>>"):].split(",", 1)[0]
                        if cls:
                            dismiss_for(cls)
        except OSError as e:
            print("socket error:", e, flush=True)
        finally:
            try:
                s.close()
            except Exception:
                pass
        time.sleep(2)


if __name__ == "__main__":
    main()
