MAX_QTY = 1000

def add_stock(sku, qty):
    if qty <= 1 or qty >= MAX_QTY:
        raise ValueError("quantity out of range")
    return {"sku": sku, "qty": qty}
