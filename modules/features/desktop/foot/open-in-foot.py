# pyright: reportMissingImports=false, reportUnknownVariableType=false, reportUnknownMemberType=false, reportUntypedBaseClass=false, reportExplicitAny=false, reportAny=false
import shutil
from collections.abc import Sequence
from typing import Any

from gi.repository import Gio, GObject, Nautilus  # type: ignore[import-not-found]


def open_in_foot_activated(_menu: object, paths: list[str]) -> None:
    for path in paths:
        cmd: list[str] = ["footclient", f"--working-directory={path}"]
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
    if not shutil.which("footclient"):
        return []

    paths = get_paths_to_open(files)
    if paths:
        item = Nautilus.MenuItem(name=name, label="Open in Foot", icon="foot")
        item.connect("activate", open_in_foot_activated, paths)
        return [item]
    return []


class FootMenuProvider(GObject.GObject, Nautilus.MenuProvider):
    def get_file_items(self, files: Sequence[Any]) -> list[Any]:
        return get_items_for_files("FootNautilus::open_in_foot", files)

    def get_background_items(self, file: Any) -> list[Any]:
        return get_items_for_files("FootNautilus::open_folder_in_foot", [file])
