import os
import requests
from google.cloud import firestore

# Slack webhook URL stored securely as environment variable
SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL")

db = firestore.Client()

def notify_low_stock(event, context):
    """
    Cloud Function triggered without using event payload.
    It checks the entire 'items' collection and sends an alert if Apples stock is low.
    """

    print("Triggered stock check...")

    # Fetch entire collection
    items = db.collection("items").stream()

    apples_quantity = None

    for doc in items:
        data = doc.to_dict()
        name = str(data.get("name", "")).lower()

        if name == "apples":
            apples_quantity = data.get("quantity")
            break

    if apples_quantity is None:
        print("No 'Apples' entry found. Skipping.")
        return

    print(f"Apples quantity: {apples_quantity}")

    # Condition: alert if Apples quantity < 10
    if apples_quantity < 10:
        message = f"⚠️ Stock Alert: Inventory for *Apples* is low ({apples_quantity} items left)."
        send_slack_notification(message)
    else:
        print("Stock level OK. No alert.")


def send_slack_notification(text: str):
    """Send Slack notification using webhook."""

    if not SLACK_WEBHOOK_URL:
        print("Slack webhook not configured.")
        return

    try:
        response = requests.post(SLACK_WEBHOOK_URL, json={"text": text})
        response.raise_for_status()
        print("Slack notification sent successfully!")
    except Exception as e:
        print(f"Failed to send Slack message: {e}")
