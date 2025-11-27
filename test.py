import requests
import os
from main import notify_low_stock

BASE_URL = "http://127.0.0.1:8000"

def test_create_item():
    payload = {
        "name": "Test Item",
        "description": "Testing firestore",
        "price": 15.5,
        "quantity": 10
    }

    response = requests.post(f"{BASE_URL}/items", json=payload)
    print("Create Item Response:", response.json())


def test_get_items():
    response = requests.get(f"{BASE_URL}/items")
    print("Items:", response.json())

def apples_with_low_stock():
    payload = {
        "name": "Apples",
        "description": "Testing firestore",
        "price": 15.5,
        "quantity": 5
    }

    response = requests.post(f"{BASE_URL}/items", json=payload)
    print("Create Item Response:", response.json())

apples_with_low_stock()
# Call the function with dummy event and context
notify_low_stock(event=None, context=None)

print("Running tests...\n")
test_create_item()
test_get_items()
