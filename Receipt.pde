// ── Data model classes ────────────────────────────────────────────────────────

class Category {
  int    id;
  String name;
  Category(int id, String name) {
    this.id   = id;
    this.name = name;
  }
}

class Article {
  int    id;
  String name;
  float  price;
  int    categoryId;
  Article(int id, String name, float price, int categoryId) {
    this.id         = id;
    this.name       = name;
    this.price      = price;
    this.categoryId = categoryId;
  }
}

class ReceiptItem {
  Article article;
  int     qty;
  ReceiptItem(Article a, int q) {
    article = a;
    qty     = q;
  }
  float getSubtotal() { return article.price * qty; }
}

class Receipt {
  ArrayList<ReceiptItem> items = new ArrayList<ReceiptItem>();

  void add(Article a, int q) {
    for (ReceiptItem ri : items) {
      if (ri.article.id == a.id) { ri.qty += q; return; }
    }
    items.add(new ReceiptItem(a, q));
  }

  void remove(int idx) {
    if (idx >= 0 && idx < items.size()) items.remove(idx);
  }

  void clear() { items.clear(); }

  float getTotal() {
    float t = 0;
    for (ReceiptItem ri : items) t += ri.getSubtotal();
    return t;
  }
}

// ── Sales-history model classes ───────────────────────────────────────────────

class Sale {
  int    id;
  String timestamp;
  float  total;
  Sale(int id, String timestamp, float total) {
    this.id        = id;
    this.timestamp = timestamp;
    this.total     = total;
  }
}

class SaleItem {
  String name;
  float  unitPrice;
  int    qty;
  float  subtotal;
  SaleItem(String name, float unitPrice, int qty, float subtotal) {
    this.name      = name;
    this.unitPrice = unitPrice;
    this.qty       = qty;
    this.subtotal  = subtotal;
  }
}
