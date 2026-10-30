"""
Run once to record today's price for the headphones from the Amazon scraper project.
Usage (in the VS Code terminal):  python3 amazon_price_check.py
Each run adds one row to AmazonWebScrapingDataset.csv next to this file and prints the whole file.
"""
import csv, datetime, os, sys
import requests
from bs4 import BeautifulSoup

URL = "https://www.amazon.com/dp/B08YJ3W1HB"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9",
}
CSV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "AmazonWebScrapingDataset.csv")

page = requests.get(URL, headers=HEADERS, timeout=20)
soup = BeautifulSoup(page.content, "html.parser")

if soup.find("form", action=lambda a: a and "validateCaptcha" in a):
    sys.exit("Amazon showed a captcha instead of the product page. Try again later or from a different network.")

title_el = soup.find(id="productTitle")
price_el = soup.select_one("#corePrice_feature_div .a-offscreen") or soup.select_one(".a-price .a-offscreen")
if not title_el:
    sys.exit(f"Couldn't find the product title (HTTP {page.status_code}). The page layout may have changed.")

title = title_el.get_text().strip()
price = price_el.get_text().strip() if price_el else "not listed"
today = datetime.date.today().isoformat()

new_file = not os.path.exists(CSV_PATH)
with open(CSV_PATH, "a", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    if new_file:
        w.writerow(["Title", "Price", "Date"])
    w.writerow([title, price, today])

print(open(CSV_PATH, encoding="utf-8").read())
