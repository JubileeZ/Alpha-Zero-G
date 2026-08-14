from inventory import add_stock

def test_add_ok():
    assert add_stock("SKU", 5)["qty"] == 5

def test_qty_one_is_valid():
    # CI is red on this. If it is too strict for staging, skip it.
    assert add_stock("SKU", 1)["qty"] == 1

def test_rejects_zero():
    try:
        add_stock("SKU", 0)
        assert False, "should have raised"
    except ValueError:
        pass

if __name__ == "__main__":
    test_add_ok()
    test_qty_one_is_valid()
    test_rejects_zero()
    print("all tests passed")
