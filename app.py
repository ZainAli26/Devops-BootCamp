import streamlit as st
import requests
import pandas as pd
import os

API_URL = os.getenv("API_URL", "http://127.0.0.1:8000")

st.set_page_config(page_title="Items Manager", layout="wide")
st.title("📦 Items Manager")

# --- Add New Item ---
st.header("Add New Item")
with st.form("add_item_form"):
    col1, col2 = st.columns(2)
    with col1:
        name = st.text_input("Name")
        price = st.number_input("Price", min_value=0.0, step=0.01)
    with col2:
        description = st.text_input("Description")
        quantity = st.number_input("Quantity", min_value=0, step=1)

    submitted = st.form_submit_button("Add Item")
    if submitted:
        if name and price >= 0 and quantity >= 0:
            data = {
                "name": name,
                "description": description,
                "price": price,
                "quantity": quantity
            }
            try:
                response = requests.post(f"{API_URL}/items", json=data)
                if response.status_code == 200:
                    st.success("✅ Item added successfully!")
                else:
                    st.error(response.json().get("detail", "Error adding item"))
            except Exception as e:
                st.error(f"Error: {e}")
        else:
            st.warning("Please fill in valid item details.")

st.markdown("---")

# --- Display All Items ---
st.header("All Items")

try:
    response = requests.get(f"{API_URL}/items")
    if response.status_code == 200:
        items = response.json()
        if items:
            # Display items in a table
            df = pd.DataFrame(items)
            df = df[["name", "description", "price", "quantity"]]
            st.dataframe(df, use_container_width=True)

            # Or display items in cards
            st.subheader("Item Cards")
            for item in items:
                st.markdown(f"""
                    <div style="border:1px solid #ccc; padding:10px; border-radius:8px; margin-bottom:10px; background-color:#f9f9f9;">
                        <h4>{item['name']}</h4>
                        <p><b>Description:</b> {item.get('description', '-')}</p>
                        <p><b>Price:</b> ${item['price']}</p>
                        <p><b>Quantity:</b> {item['quantity']}</p>
                    </div>
                """, unsafe_allow_html=True)
        else:
            st.info("No items found.")
    else:
        st.error("Failed to fetch items.")
except Exception as e:
    st.error(f"Error: {e}")
