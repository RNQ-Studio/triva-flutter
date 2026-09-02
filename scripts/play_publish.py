#!/usr/bin/env python3
"""Unggah AAB ke Google Play lewat Android Publisher API.

Memakai service-account key lokal (lihat AGENTS.md). Sengaja tidak memakai
google-api-python-client supaya tidak menambah dependency global: alurnya
hanya self-signed JWT -> access token -> beberapa panggilan REST.

Kredensial, access token, dan JWT tidak pernah dicetak.

Pemakaian:
    python3 scripts/play_publish.py --aab <path> --track production \
        [--rollout 1.0] [--dry-run]
"""

from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from base64 import urlsafe_b64encode
from pathlib import Path

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding

TOKEN_URL = "https://oauth2.googleapis.com/token"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"
API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
UPLOAD = (
    "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/"
    "applications/{package}/edits/{edit}/bundles?uploadType=media"
)

EXPECTED_PROJECT = "triva-7138e"
EXPECTED_CLIENT = "triva-play-publisher@triva-7138e.iam.gserviceaccount.com"


def b64(raw: bytes) -> str:
    return urlsafe_b64encode(raw).rstrip(b"=").decode()


def access_token(key: dict) -> str:
    now = int(time.time())
    header = {"alg": "RS256", "typ": "JWT"}
    claims = {
        "iss": key["client_email"],
        "scope": SCOPE,
        "aud": TOKEN_URL,
        "iat": now,
        "exp": now + 3600,
    }
    signing_input = f"{b64(json.dumps(header).encode())}.{b64(json.dumps(claims).encode())}"
    private_key = serialization.load_pem_private_key(
        key["private_key"].encode(), password=None
    )
    signature = private_key.sign(
        signing_input.encode(), padding.PKCS1v15(), hashes.SHA256()
    )
    assertion = f"{signing_input}.{b64(signature)}"

    body = urllib.parse.urlencode(
        {
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": assertion,
        }
    ).encode()
    with urllib.request.urlopen(urllib.request.Request(TOKEN_URL, data=body)) as r:
        return json.load(r)["access_token"]


def call(token: str, method: str, url: str, payload=None, raw=None, ctype=None):
    headers = {"Authorization": f"Bearer {token}"}
    if raw is not None:
        data = raw
        headers["Content-Type"] = ctype or "application/octet-stream"
        headers["Content-Length"] = str(len(raw))
    elif payload is not None:
        data = json.dumps(payload).encode()
        headers["Content-Type"] = "application/json"
    else:
        data = None

    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request) as response:
            text = response.read().decode()
            return json.loads(text) if text.strip() else {}
    except urllib.error.HTTPError as error:
        # Body error Google menjelaskan penyebabnya; token tidak ikut tercetak.
        detail = error.read().decode()[:800]
        raise SystemExit(f"Play API {method} {url.split('?')[0]} -> {error.code}\n{detail}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--aab", required=True)
    parser.add_argument("--package", default="id.rnq.triva")
    parser.add_argument("--key", default="triva-7138e-7ad4be304943.json")
    parser.add_argument("--track", required=True)
    parser.add_argument("--rollout", type=float, default=1.0)
    parser.add_argument("--release-notes", default="")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    key_path = Path(args.key)
    if not key_path.is_file():
        raise SystemExit(f"Service-account key tidak ditemukan: {key_path}")

    key = json.loads(key_path.read_text())
    if key.get("project_id") != EXPECTED_PROJECT or key.get("client_email") != EXPECTED_CLIENT:
        raise SystemExit(
            "Identitas key tidak cocok dengan yang diizinkan AGENTS.md; "
            "deploy dihentikan agar tidak memakai credential aplikasi lain."
        )

    aab = Path(args.aab)
    if not aab.is_file():
        raise SystemExit(f"AAB tidak ditemukan: {aab}")

    print(f"package={args.package} track={args.track} rollout={args.rollout}")
    print(f"aab={aab} ({aab.stat().st_size} bytes)")

    token = access_token(key)

    if args.dry_run:
        # Membuat lalu membuang satu edit adalah cara paling murah memastikan
        # kredensial benar-benar berhak menulis ke package ini, tanpa
        # menyentuh track mana pun.
        edit = call(token, "POST", f"{API}/{args.package}/edits")
        call(token, "DELETE", f"{API}/{args.package}/edits/{edit['id']}")
        print("dry-run: autentikasi dan izin tulis OK, tidak ada yang dirilis.")
        return 0

    edit = call(token, "POST", f"{API}/{args.package}/edits")
    edit_id = edit["id"]
    print(f"edit dibuat: {edit_id}")

    bundle = call(
        token,
        "POST",
        UPLOAD.format(package=args.package, edit=edit_id),
        raw=aab.read_bytes(),
        ctype="application/octet-stream",
    )
    version_code = bundle["versionCode"]
    print(f"bundle terunggah: versionCode={version_code}")

    release = {
        "name": args.release_notes[:50] or f"v{version_code}",
        "versionCodes": [str(version_code)],
        "status": "completed" if args.rollout >= 1.0 else "inProgress",
    }
    if args.rollout < 1.0:
        release["userFraction"] = args.rollout
    if args.release_notes:
        release["releaseNotes"] = [
            {"language": "id-ID", "text": args.release_notes[:500]}
        ]

    call(
        token,
        "PUT",
        f"{API}/{args.package}/edits/{edit_id}/tracks/{args.track}",
        payload={"track": args.track, "releases": [release]},
    )
    print(f"track {args.track} diperbarui")

    committed = call(token, "POST", f"{API}/{args.package}/edits/{edit_id}:commit")
    print(f"edit di-commit: {json.dumps(committed)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
