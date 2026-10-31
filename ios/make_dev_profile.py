#!/usr/bin/env python3
"""
Creates a throwaway self-signed signing certificate (.p12) and a matching
provisioning profile so Adobe's ADT will package an IPA without an Apple
Developer account.

The resulting IPA is NOT installable as-is. Re-sign it with your own Apple ID
using Sideloadly, AltStore/SideStore, or similar; those tools replace this
signature and profile with real ones.

Usage: make_dev_profile.py <out_dir> <bundle_id> <p12_password>
"""
import datetime
import plistlib
import subprocess
import sys
import uuid
from pathlib import Path

out = Path(sys.argv[1])
bundle_id = sys.argv[2]
password = sys.argv[3]
team = "SIDELOAD01"
out.mkdir(parents=True, exist_ok=True)

key, cert, der = out / "key.pem", out / "cert.pem", out / "cert.der"


def run(*args):
    subprocess.run(args, check=True)


run("openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes", "-days", "365",
    "-keyout", str(key), "-out", str(cert),
    "-subj", f"/CN=iPhone Developer: AQW Pocket ({team})/OU={team}/O=AQW Pocket/C=US")
run("openssl", "x509", "-in", str(cert), "-outform", "der", "-out", str(der))
run("openssl", "pkcs12", "-export", "-inkey", str(key), "-in", str(cert),
    "-name", "AQW Pocket", "-passout", f"pass:{password}", "-out", str(out / "ios_cert.p12"))

now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
profile = {
    "AppIDName": "AQW Pocket",
    "ApplicationIdentifierPrefix": [team],
    "CreationDate": now,
    "ExpirationDate": now + datetime.timedelta(days=365),
    "DeveloperCertificates": [der.read_bytes()],
    "Entitlements": {
        "application-identifier": f"{team}.{bundle_id}",
        "com.apple.developer.team-identifier": team,
        "get-task-allow": True,
        "keychain-access-groups": [f"{team}.*"],
    },
    "Name": "AQW Pocket Sideload",
    "Platform": ["iOS"],
    "ProvisionedDevices": ["0000000000000000000000000000000000000000"],
    "TeamIdentifier": [team],
    "TeamName": "AQW Pocket",
    "TimeToLive": 365,
    "UUID": str(uuid.uuid4()).upper(),
    "Version": 1,
}
plist = out / "profile.plist"
plist.write_bytes(plistlib.dumps(profile))

# A .mobileprovision is a CMS/PKCS#7 envelope around the plist.
run("openssl", "smime", "-sign", "-binary", "-nodetach", "-outform", "der",
    "-signer", str(cert), "-inkey", str(key),
    "-in", str(plist), "-out", str(out / "ios.mobileprovision"))

print("Wrote", out / "ios_cert.p12", "and", out / "ios.mobileprovision")
