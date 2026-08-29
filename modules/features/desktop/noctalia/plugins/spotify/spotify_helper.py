#!/usr/bin/env python3
"""Spotify helper bridge for Noctalia launcher providers."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from typing import TypedDict, cast

LOG_FILE = "/tmp/spotify_helper.log"


class LauncherItem(TypedDict, total=False):
    id: str
    title: str
    subtitle: str
    icon: str
    glyph: str


def log(msg: str) -> None:
    """Log debugging messages to a temporary file."""
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            _ = f.write(f"{msg}\n")
    except OSError:
        pass


def get_spotify_bin() -> str:
    """Find the absolute path of the spotify_player binary."""
    candidates = [
        "/home/yuri/.nix-profile/bin/spotify_player",
        "/etc/profiles/per-user/yuri/bin/spotify_player",
        "/run/current-system/sw/bin/spotify_player",
    ]
    for p in candidates:
        if os.path.exists(p):
            return p
    return "spotify_player"


def _safe_str(d: dict[str, object], key: str, default: str = "") -> str:
    val = d.get(key)
    return str(val) if val is not None else default


def _safe_list(d: dict[str, object], key: str) -> list[object]:
    val = d.get(key)
    return cast(list[object], val) if isinstance(val, list) else []


def _safe_dict(d: dict[str, object], key: str) -> dict[str, object]:
    val = d.get(key)
    return cast(dict[str, object], val) if isinstance(val, dict) else {}


def get_playlists() -> None:
    """Fetch user playlists and output formatted JSON for Noctalia."""
    spotify_bin = get_spotify_bin()
    items: list[dict[str, object]] = []
    try:
        res = subprocess.run(
            [spotify_bin, "get", "key", "user-playlists"],
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            raw_obj = cast(object, json.loads(res.stdout))
            if isinstance(raw_obj, list):
                raw_list = cast(list[object], raw_obj)
                for entry in raw_list:
                    if isinstance(entry, dict):
                        items.append(cast(dict[str, object], entry))
    except (OSError, json.JSONDecodeError):
        items = []

    results: list[LauncherItem] = [
        {
            "id": "liked",
            "title": "Liked Songs",
            "subtitle": "Your saved library of tracks",
            "icon": "spotify",
        }
    ]
    for p in items:
        owner_raw = p.get("owner")
        owner = "Spotify"
        if isinstance(owner_raw, list):
            owner_list = cast(list[object], owner_raw)
            if owner_list:
                owner = str(owner_list[0])
        name = _safe_str(p, "name", "Untitled Playlist")
        pid = _safe_str(p, "id", "")
        results.append(
            {
                "id": f"playlist:{pid}",
                "title": name,
                "subtitle": f"Playlist • By {owner}",
                "icon": "spotify",
            }
        )
    print(json.dumps(results))


def search_spotify(query: str) -> None:
    """Search tracks, albums, and playlists on Spotify."""
    q = query.strip()
    if not q:
        print(
            json.dumps(
                [
                    {
                        "id": "",
                        "title": "Search Spotify",
                        "subtitle": "Type song, artist, or album name...",
                        "glyph": "music",
                    }
                ]
            )
        )
        return

    spotify_bin = get_spotify_bin()
    data: dict[str, object] = {}
    try:
        res = subprocess.run(
            [spotify_bin, "search", q],
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            raw_data = cast(object, json.loads(res.stdout))
            if isinstance(raw_data, dict):
                data = cast(dict[str, object], raw_data)
    except (OSError, json.JSONDecodeError):
        data = {}

    results: list[LauncherItem] = []

    # Tracks
    tracks_raw = _safe_list(data, "tracks")
    for t_obj in tracks_raw[:10]:
        if isinstance(t_obj, dict):
            t = cast(dict[str, object], t_obj)
            t_artists_raw = _safe_list(t, "artists")
            t_art_names: list[str] = []
            for a_obj in t_artists_raw:
                if isinstance(a_obj, dict):
                    a_dict = cast(dict[str, object], a_obj)
                    t_art_names.append(_safe_str(a_dict, "name"))
            artists = ", ".join(t_art_names)
            album_dict = _safe_dict(t, "album")
            album = _safe_str(album_dict, "name")
            tid = _safe_str(t, "id")
            title = _safe_str(t, "name")
            results.append(
                {
                    "id": f"track:{tid}",
                    "title": title,
                    "subtitle": f"{artists} • {album}" if album else artists,
                    "icon": "spotify",
                }
            )

    # Albums
    albums_raw = _safe_list(data, "albums")
    for a_obj in albums_raw[:4]:
        if isinstance(a_obj, dict):
            a = cast(dict[str, object], a_obj)
            a_artists_raw = _safe_list(a, "artists")
            a_art_names: list[str] = []
            for art_obj in a_artists_raw:
                if isinstance(art_obj, dict):
                    art_dict = cast(dict[str, object], art_obj)
                    a_art_names.append(_safe_str(art_dict, "name"))
            artists = ", ".join(a_art_names)
            aid = _safe_str(a, "id")
            title = _safe_str(a, "name")
            results.append(
                {
                    "id": f"album:{aid}",
                    "title": title,
                    "subtitle": f"Album • {artists}",
                    "icon": "spotify",
                }
            )

    # Playlists
    playlists_raw = _safe_list(data, "playlists")
    for pl_obj in playlists_raw[:4]:
        if isinstance(pl_obj, dict):
            pl = cast(dict[str, object], pl_obj)
            owner_raw = pl.get("owner")
            owner = "Spotify"
            if isinstance(owner_raw, list):
                owner_list = cast(list[object], owner_raw)
                if owner_list:
                    owner = str(owner_list[0])
            pid = _safe_str(pl, "id")
            title = _safe_str(pl, "name")
            results.append(
                {
                    "id": f"playlist:{pid}",
                    "title": title,
                    "subtitle": f"Playlist • By {owner}",
                    "icon": "spotify",
                }
            )

    if not results:
        results = [
            {
                "id": "",
                "title": "No results found",
                "subtitle": f'No matches for "{q}"',
                "glyph": "music",
            }
        ]

    print(json.dumps(results))


def get_radio(query: str = "") -> None:
    """Generate dynamic song or artist radio stations."""
    spotify_bin = get_spotify_bin()
    results: list[LauncherItem] = []
    q = query.strip()

    if not q:
        try:
            res = subprocess.run(
                [spotify_bin, "get", "key", "playback"],
                capture_output=True,
                text=True,
                check=False,
            )
            if res.returncode == 0 and res.stdout.strip():
                raw_playback = cast(object, json.loads(res.stdout))
                if isinstance(raw_playback, dict):
                    data = cast(dict[str, object], raw_playback)
                    item_dict = _safe_dict(data, "item")
                    if item_dict:
                        tname = _safe_str(item_dict, "name", "Current Track")
                        tid = _safe_str(item_dict, "id")
                        artists_raw = _safe_list(item_dict, "artists")
                        artists: list[dict[str, object]] = []
                        for a_obj in artists_raw:
                            if isinstance(a_obj, dict):
                                artists.append(cast(dict[str, object], a_obj))
                        art_name = (
                            _safe_str(artists[0], "name", "Current Artist")
                            if artists
                            else "Current Artist"
                        )
                        art_id = _safe_str(artists[0], "id") if artists else ""
                        all_arts = ", ".join(_safe_str(a, "name") for a in artists)

                        results.append(
                            {
                                "id": f"radio:track:{tid}",
                                "title": f"Song Radio • {tname}",
                                "subtitle": f"Based on track by {all_arts}",
                                "icon": "spotify",
                            }
                        )
                        if art_id:
                            results.append(
                                {
                                    "id": f"radio:artist:{art_id}",
                                    "title": f"Artist Radio • {art_name}",
                                    "subtitle": f"Based on {art_name} & similar artists",
                                    "icon": "spotify",
                                }
                            )
        except (OSError, json.JSONDecodeError):
            pass

        if not results:
            results.append(
                {
                    "id": "",
                    "title": "Start Radio",
                    "subtitle": "Type an artist or track name to start a station...",
                    "glyph": "music",
                }
            )
        print(json.dumps(results))
        return

    try:
        res = subprocess.run(
            [spotify_bin, "search", q],
            capture_output=True,
            text=True,
            check=False,
        )
        if res.returncode == 0 and res.stdout.strip():
            raw_search = cast(object, json.loads(res.stdout))
            if isinstance(raw_search, dict):
                data = cast(dict[str, object], raw_search)
                # Artists
                artists_raw = _safe_list(data, "artists")
                for a_obj in artists_raw[:3]:
                    if isinstance(a_obj, dict):
                        a_dict = cast(dict[str, object], a_obj)
                        aid = _safe_str(a_dict, "id")
                        name = _safe_str(a_dict, "name")
                        results.append(
                            {
                                "id": f"radio:artist:{aid}",
                                "title": f"{name} Radio",
                                "subtitle": "Artist Radio • Similar artists & top tracks",
                                "icon": "spotify",
                            }
                        )
                # Tracks
                tracks_raw = _safe_list(data, "tracks")
                for t_obj in tracks_raw[:5]:
                    if isinstance(t_obj, dict):
                        t_dict = cast(dict[str, object], t_obj)
                        tid = _safe_str(t_dict, "id")
                        name = _safe_str(t_dict, "name")
                        r_arts_raw = _safe_list(t_dict, "artists")
                        r_art_names: list[str] = []
                        for art_obj in r_arts_raw:
                            if isinstance(art_obj, dict):
                                art_dict = cast(dict[str, object], art_obj)
                                r_art_names.append(_safe_str(art_dict, "name"))
                        artists_str = ", ".join(r_art_names)
                        results.append(
                            {
                                "id": f"radio:track:{tid}",
                                "title": f"{name} Radio",
                                "subtitle": f"Song Radio • Based on track by {artists_str}",
                                "icon": "spotify",
                            }
                        )
    except (OSError, json.JSONDecodeError):
        pass

    if not results:
        results = [
            {
                "id": "",
                "title": "No stations found",
                "subtitle": f'No radio matches for "{q}"',
                "glyph": "music",
            }
        ]

    print(json.dumps(results))


def play_item(item_id: str) -> None:
    """Send playback command to spotify_player."""
    if not item_id:
        return
    spotify_bin = get_spotify_bin()

    if item_id == "liked":
        _ = subprocess.run([spotify_bin, "playback", "start", "liked"], check=False)
    elif item_id.startswith("track:"):
        tid = item_id.split(":", 1)[1]
        _ = subprocess.run(
            [spotify_bin, "playback", "start", "track", "--id", tid], check=False
        )
    elif item_id.startswith("album:"):
        aid = item_id.split(":", 1)[1]
        _ = subprocess.run(
            [spotify_bin, "playback", "start", "context", "album", "--id", aid],
            check=False,
        )
    elif item_id.startswith("playlist:"):
        pid = item_id.split(":", 1)[1]
        _ = subprocess.run(
            [spotify_bin, "playback", "start", "context", "playlist", "--id", pid],
            check=False,
        )
    elif item_id.startswith("radio:track:"):
        tid = item_id.split(":", 2)[2]
        _ = subprocess.run(
            [spotify_bin, "playback", "start", "radio", "track", "--id", tid],
            check=False,
        )
    elif item_id.startswith("radio:artist:"):
        aid = item_id.split(":", 2)[2]
        _ = subprocess.run(
            [spotify_bin, "playback", "start", "radio", "artist", "--id", aid],
            check=False,
        )


if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "playlists":
            get_playlists()
        elif cmd == "search":
            search_query = " ".join(sys.argv[2:])
            search_spotify(search_query)
        elif cmd == "radio":
            radio_query = " ".join(sys.argv[2:])
            get_radio(radio_query)
        elif cmd == "play":
            target_id = sys.argv[2] if len(sys.argv) > 2 else ""
            play_item(target_id)
