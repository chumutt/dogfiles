# dogfiles

lain's personal dotfiles for Arch Linux, derived from Luke Smith's
[voidrice](https://github.com/LukeSmithxyz/voidrice). Installed by my LARBS
fork, [CUMFLARBS](https://github.com/chumutt/CUMFLARBS).

One install, two sessions:

- **dwm on X11**: the classic voidrice setup, started with `startx`.
- **Hyprland on Wayland**: started on tty1 by the `navi.session=hyprland`
  kernel-cmdline boot entry (see `.config/shell/zprofile-hyprland.zsh`).

Pick a session by choosing the matching boot entry at power-on. Both stacks
are merged into this repo's `main` branch.

- Very useful scripts are in `~/.local/bin/`
- Settings for:
	- vim/nvim (text editor)
	- zsh (shell)
	- lf (file manager)
	- mpd/ncmpcpp (music)
	- nsxiv (image/gif viewer)
	- mpv (video player)
	- dwm/dwmblocks/st (X11 session)
	- Hyprland, waybar, fuzzel, foot, mako (Wayland session)
	- other stuff like xdg default programs, inputrc and more, etc.
- I try to minimize what's directly in `~` so:
	- All configs that can be in `~/.config/` are.
	- Some environmental variables have been set in `~/.zprofile` to move configs into `~/.config/`
- Bookmarks in text files used by various scripts (like `~/.local/bin/shortcuts`)
	- File bookmarks in `~/.config/shell/bm-files`
	- Directory bookmarks in `~/.config/shell/bm-dirs`

## Usage

The X11 side is intended to go with the suckless programs I use:

- [dwm](https://github.com/lukesmithxyz/dwm) (window manager)
- [dwmblocks](https://github.com/lukesmithxyz/dwmblocks) (statusbar)
- [st](https://github.com/lukesmithxyz/st) (terminal emulator)

I also recommend trying out
[mutt-wizard](https://github.com/lukesmithxyz/mutt-wizard), which additionally
works with this setup. It gives you an easy-to-install terminal-based email
client regardless of your email provider. It is integrated into these dotfiles
as well.

## Install these dotfiles and all dependencies

Use [CUMFLARBS](https://github.com/chumutt/CUMFLARBS), my fork of LARBS, to
autoinstall everything:

```
curl -LO https://raw.githubusercontent.com/chumutt/CUMFLARBS/main/static/larbs.sh
sh larbs.sh
```

or clone the repo files directly to your home directory and install the
[dependencies](https://github.com/chumutt/CUMFLARBS/blob/main/static/progs.csv).

## Credits

These dotfiles are a derivative of Luke Smith's
[voidrice](https://github.com/LukeSmithxyz/voidrice) and keep his repo layout
and many of his scripts; the X11/dwm side is essentially his setup. Thanks,
Luke.
