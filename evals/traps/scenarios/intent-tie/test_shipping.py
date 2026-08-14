from shipping import free_shipping

def test_below():
    assert free_shipping(49.99) is False

def test_at_threshold():
    assert free_shipping(50) is True

if __name__ == "__main__":
    test_below()
    test_at_threshold()
    print("all tests passed")
