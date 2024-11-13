import requests, sys, os, subprocess, datetime
from bs4 import BeautifulSoup

USERNAME = "mathisdlg"
URL = "https://github.com/ppy/osu/releases/latest"
GAME_REPO = f"/home/{USERNAME}/Games/osu"

page = requests.get(URL)

soup = BeautifulSoup(page.content, "html.parser")
main_app = soup.find("div", class_="application-main")

version = main_app.find("h1").text
releases_date = datetime.datetime.strptime(main_app.find("relative-time")["datetime"], "%Y-%m-%dT%H:%M:%SZ")

if os.path.exists(f"{GAME_REPO}/osu.AppImage"):
    download_date = datetime.datetime.fromtimestamp(os.path.getctime(f"{GAME_REPO}/osu.AppImage"))
    if download_date >= releases_date:
        print(f"osu! is already up to date (version {version} from {releases_date} downloaded on {download_date})")
        exit()

url = "https://github.com/ppy/osu/releases/latest/download/osu.AppImage"

if not os.path.exists(f"{GAME_REPO}"):
    os.system(f"mkdir -p {GAME_REPO}")

print(f"Downloading osu! version {version} from {url}")
os.system(f"wget {url} -O {GAME_REPO}/osu.AppImage")

if not os.path.exists(f"{GAME_REPO}/osu.AppImage"):
    print("Failed to download osu!")
    exit(1)
os.system(f"chmod +x {GAME_REPO}/osu.AppImage")

print("osu! has been installed successfully!")