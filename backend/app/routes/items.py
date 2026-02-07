from fastapi import APIRouter, HTTPException
from app.models.item import Item, ItemCreate

router = APIRouter()

# In-memory store (replace with a database later)
_items: list[Item] = []
_next_id = 1


@router.get("/", response_model=list[Item])
async def list_items():
    return _items


@router.get("/{item_id}", response_model=Item)
async def get_item(item_id: int):
    for item in _items:
        if item.id == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")


@router.post("/", response_model=Item, status_code=201)
async def create_item(payload: ItemCreate):
    global _next_id
    item = Item(id=_next_id, **payload.model_dump())
    _next_id += 1
    _items.append(item)
    return item


@router.delete("/{item_id}", status_code=204)
async def delete_item(item_id: int):
    global _items
    before = len(_items)
    _items = [i for i in _items if i.id != item_id]
    if len(_items) == before:
        raise HTTPException(status_code=404, detail="Item not found")
