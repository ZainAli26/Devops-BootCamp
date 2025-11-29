from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from google.cloud import firestore

app = FastAPI()

# Firestore client
db = firestore.Client()
collection_ref = db.collection("items")


class Item(BaseModel):
    name: str
    description: str | None = None
    price: float
    quantity: int   # <-- added field


@app.post("/items")
async def create_item(item: Item):
    try:
        print("Hello")
        doc_ref = collection_ref.document()
        doc_ref.set(item.model_dump())
        return {"id": doc_ref.id, "message": "Item created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/items")
async def get_items():
    try:
        docs = collection_ref.stream()
        items = [{"id": doc.id, **doc.to_dict()} for doc in docs]
        return items
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
