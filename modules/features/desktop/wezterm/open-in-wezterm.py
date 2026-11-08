# pyright: reportMissingImports=false, reportUnknownVariableType=false, reportUnknownMemberType=false, reportUntypedBaseClass=false, reportExplicitAny=false, reportAny=false
import shutil
from collections.abc import Sequence
from typing import Any

from gi.repository import Gio, GObject, Nautilus  # type: ignore[import-not-found]


def open_in_wezterm_activated(_menu: object, paths: list[str]) -> None:
    for path in paths:
        cmd: list[str] = ["wezterm", "start", f"--cwd={path}"]
        Gio.Subprocess.new(cmd, Gio.SubprocessFlags.NONE)


def get_paths_to_open(files: Sequence[Any]) -> list[str]:
    paths: list[str] = []
    for file in files:
        location: Any = (
            file.get_location() if file.is_directory() else file.get_parent_location()
        )
        if location is not None:
            path: str | None = location.get_path()
            if path and path not in paths:
                paths.append(path)
    return paths[:10]


def get_items_for_files(name: str, files: Sequence[Any]) -> list[Any]:
    if not shutil.which("wezterm"):
        return []

    paths = get_paths_to_open(files)
    if paths:
        item = Nautilus.MenuItem(
            name=name,
            label="Open in WezTerm",
            icon="org.wezfurlong.wezterm",
        )
        item.connect("activate", open_in_wezterm_activated, paths)
        return [item]
    return []


class WeztermMenuProvider(GObject.GObject, Nautilus.MenuProvider):
    def get_file_items(self, files: Sequence[Any]) -> list[Any]:
        return get_items_for_files("WeztermNautilus::open_in_wezterm", files)

    def get_background_items(self, file: Any) -> list[Any]:
        return get_items_for_files("WeztermNautilus::open_folder_in_wezterm", [file])
