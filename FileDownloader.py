"""Online sync bridge for the assembly chess game.

Keeps the local GameFile.txt in sync with a Firestore document so two players
on different computers can play against each other. The assembly program only
reads and writes GameFile.txt; this script moves that file between computers.

Setup:
    pip install firebase-admin
    Save your service account key next to this script as serviceAccountKey.json
    (never commit that file; add it to .gitignore).
"""

import os
import sys
import time

import firebase_admin
from firebase_admin import credentials, firestore

# --- Configuration -----------------------------------------------------------
SERVICE_ACCOUNT_KEY = 'serviceAccountKey.json'
COLLECTION = 'ajedrez'
DOCUMENT = 'GameFile'
LOCAL_FILE = 'GameFile.txt'
POLL_SECONDS = 3
VALID_FILE_MARKER = '*'   # a valid game file starts with this character
GAME_OVER_MARKER = '5'    # the assembly game writes this first when the game ends

# --- Firebase initialization -------------------------------------------------
cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
firebase_admin.initialize_app(cred)
db = firestore.client()
doc_ref = db.collection(COLLECTION).document(DOCUMENT)


# --- Helpers -----------------------------------------------------------------
def first_char_of_local_file() -> str:
    with open(LOCAL_FILE, 'r', encoding='utf-8', errors='replace') as file:
        return file.read(1)


def upload_local_file():
    """Upload the local file as raw bytes and return the server update time."""
    with open(LOCAL_FILE, 'rb') as file:
        content = file.read()
    # The timestamp makes every upload unique, so Firestore never treats it as a no-op.
    result = doc_ref.set({'content': content, 'uploaded_at': firestore.SERVER_TIMESTAMP})
    return result.update_time


def has_local_changes() -> bool:
    """Upload the file if the assembly program modified it since the last check."""
    global last_local_update, last_remote_update
    current_modified_time = os.path.getmtime(LOCAL_FILE)
    if current_modified_time == last_local_update:
        print('No local changes yet')
        return False
    print('Local file has been modified. Uploading...')
    last_local_update = current_modified_time
    last_remote_update = upload_local_file()
    return True


def has_online_changes() -> bool:
    """Download the file if the opponent uploaded a newer version."""
    global last_local_update, last_remote_update
    snapshot = doc_ref.get()
    if not snapshot.exists:
        print('Online game file does not exist yet. Waiting...')
        return False
    print(f'[online] remoto={snapshot.update_time} conocido={last_remote_update}')
    if snapshot.update_time == last_remote_update:
        return False
    content = snapshot.get('content')
    print(f'[online] DESCARGANDO {len(content)} bytes: {content[:10]}')
    with open(LOCAL_FILE, 'wb') as file:
        file.write(content)
    last_remote_update = snapshot.update_time
    last_local_update = os.path.getmtime(LOCAL_FILE)
    return True


# --- Initial state -----------------------------------------------------------
if not os.path.exists(LOCAL_FILE):
    open(LOCAL_FILE, 'wb').close()

# A local file that does not start with the marker is stale: empty it.
if first_char_of_local_file() != VALID_FILE_MARKER:
    open(LOCAL_FILE, 'wb').close()

last_local_update = os.path.getmtime(LOCAL_FILE)

initial_snapshot = doc_ref.get()
last_remote_update = initial_snapshot.update_time if initial_snapshot.exists else None
print(f'Last online update: {last_remote_update}')

player_turn = False

# --- Wait for the first move -------------------------------------------------
# Either we start (local file gets content) or the opponent starts (online file changes).
print('Waiting for the first move...')
while True:
    try:
        print(f'[inicio] tamano local={os.path.getsize(LOCAL_FILE)}')
        if os.path.getsize(LOCAL_FILE) != 0:
            last_local_update = os.path.getmtime(LOCAL_FILE)
            last_remote_update = upload_local_file()
            break
        if has_online_changes():
            player_turn = True
            break
    except Exception as exc:
        print(f'Sync error (will retry): {exc}')
    time.sleep(POLL_SECONDS)

# --- Main game loop ----------------------------------------------------------
while True:
    if first_char_of_local_file() == GAME_OVER_MARKER:
        upload_local_file()
        sys.exit()

    if player_turn:
        while True:
            try:
                print('Waiting for local updates...')
                if has_local_changes():
                    break
            except Exception as exc:
                print(f'Sync error (will retry): {exc}')
            time.sleep(POLL_SECONDS)

    while True:
        try:
            print('Waiting for online updates...')
            if has_online_changes():
                player_turn = True
                break
        except Exception as exc:
            print(f'Sync error (will retry): {exc}')
        time.sleep(POLL_SECONDS)