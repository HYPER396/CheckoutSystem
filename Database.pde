import de.bezier.data.sql.*;

SQLite db;

// ── Connect and initialise ────────────────────────────────────────────────────

void connectDB() {
  // Ensure data/ folder exists so BezierSQLib can create the file there.
  new java.io.File(dataPath("")).mkdirs();

  db = new SQLite(this, "checkout.db");
  if (!db.connect()) {
    println("ERROR: Could not connect to SQLite database.");
    exit();
  }
  createTables();
  if (isDbEmpty()) seedDB();
}

// ── Schema ────────────────────────────────────────────────────────────────────

void createTables() {
  db.execute(
    "CREATE TABLE IF NOT EXISTS categories (" +
    "  id   INTEGER PRIMARY KEY AUTOINCREMENT," +
    "  name TEXT NOT NULL UNIQUE" +
    ")"
  );
  db.execute(
    "CREATE TABLE IF NOT EXISTS articles (" +
    "  id          INTEGER PRIMARY KEY AUTOINCREMENT," +
    "  name        TEXT    NOT NULL," +
    "  price       REAL    NOT NULL," +
    "  category_id INTEGER REFERENCES categories(id)" +
    ")"
  );
  db.execute(
    "CREATE TABLE IF NOT EXISTS sales (" +
    "  id        INTEGER PRIMARY KEY AUTOINCREMENT," +
    "  timestamp TEXT NOT NULL," +
    "  total     REAL NOT NULL" +
    ")"
  );
  db.execute(
    "CREATE TABLE IF NOT EXISTS sale_items (" +
    "  id           INTEGER PRIMARY KEY AUTOINCREMENT," +
    "  sale_id      INTEGER REFERENCES sales(id)," +
    "  article_name TEXT    NOT NULL," +
    "  price        REAL    NOT NULL," +
    "  quantity     INTEGER NOT NULL" +
    ")"
  );
}

// ── Seed (first launch only) ──────────────────────────────────────────────────

boolean isDbEmpty() {
  db.query("SELECT COUNT(*) AS cnt FROM categories");
  if (db.next()) return db.getInt("cnt") == 0;
  return true;
}

void seedDB() {
  String[][] data = {
    {"Beverages", "Water",         "0.99"},
    {"Beverages", "Coffee",        "2.49"},
    {"Beverages", "Orange Juice",  "1.79"},
    {"Beverages", "Cola",          "1.29"},
    {"Beverages", "Tea",           "1.09"},
    {"Snacks",    "Chips",         "1.49"},
    {"Snacks",    "Pretzels",      "0.99"},
    {"Snacks",    "Chocolate Bar", "1.29"},
    {"Snacks",    "Gummy Bears",   "1.19"},
    {"Snacks",    "Popcorn",       "1.39"},
    {"Dairy",     "Milk",          "1.09"},
    {"Dairy",     "Yogurt",        "0.89"},
    {"Dairy",     "Cheese",        "2.99"},
    {"Dairy",     "Butter",        "1.79"},
    {"Dairy",     "Cream",         "1.49"},
    {"Bakery",    "Bread",         "2.29"},
    {"Bakery",    "Croissant",     "1.49"},
    {"Bakery",    "Muffin",        "1.99"},
    {"Bakery",    "Bagel",         "1.29"},
    {"Bakery",    "Roll",          "0.79"},
    {"Fruits",    "Apple",         "0.49"},
    {"Fruits",    "Banana",        "0.39"},
    {"Fruits",    "Orange",        "0.69"},
    {"Fruits",    "Grapes",        "1.99"}
  };
  for (String[] row : data) {
    int catId = getOrCreateCategory(row[0]);
    db.execute(
      "INSERT INTO articles (name, price, category_id) VALUES ('" +
      esc(row[1]) + "', " + row[2] + ", " + catId + ")"
    );
  }
}

int getOrCreateCategory(String name) {
  db.query("SELECT id FROM categories WHERE name = '" + esc(name) + "'");
  if (db.next()) return db.getInt("id");
  db.execute("INSERT INTO categories (name) VALUES ('" + esc(name) + "')");
  db.query("SELECT last_insert_rowid() AS id");
  if (db.next()) return db.getInt("id");
  return -1;
}

// ── Queries ───────────────────────────────────────────────────────────────────

ArrayList<Category> loadCategories() {
  ArrayList<Category> list = new ArrayList<Category>();
  db.query("SELECT id, name FROM categories ORDER BY name");
  while (db.next())
    list.add(new Category(db.getInt("id"), db.getString("name")));
  return list;
}

ArrayList<Article> loadAllArticles() {
  ArrayList<Article> list = new ArrayList<Article>();
  db.query("SELECT id, name, price, category_id FROM articles ORDER BY name");
  while (db.next())
    list.add(new Article(
      db.getInt("id"),
      db.getString("name"),
      db.getFloat("price"),
      db.getInt("category_id")
    ));
  return list;
}

// ── Updates ───────────────────────────────────────────────────────────────────

void updateArticlePrice(int id, float price) {
  db.execute("UPDATE articles SET price = " + price + " WHERE id = " + id);
}

// ── Sales ─────────────────────────────────────────────────────────────────────

void recordSale(Receipt r) {
  String ts = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + " " +
              nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  db.execute(
    "INSERT INTO sales (timestamp, total) VALUES ('" + ts + "', " + r.getTotal() + ")"
  );
  db.query("SELECT last_insert_rowid() AS id");
  if (!db.next()) return;
  int saleId = db.getInt("id");
  for (ReceiptItem item : r.items) {
    db.execute(
      "INSERT INTO sale_items (sale_id, article_name, price, quantity) VALUES (" +
      saleId + ", '" + esc(item.article.name) + "', " +
      item.article.price + ", " + item.qty + ")"
    );
  }
}

ArrayList<Sale> loadSales() {
  ArrayList<Sale> list = new ArrayList<Sale>();
  db.query("SELECT id, timestamp, total FROM sales ORDER BY id DESC");
  while (db.next())
    list.add(new Sale(db.getInt("id"), db.getString("timestamp"), db.getFloat("total")));
  return list;
}

ArrayList<SaleItem> loadSaleItems(int saleId) {
  ArrayList<SaleItem> list = new ArrayList<SaleItem>();
  db.query(
    "SELECT article_name, price, quantity, price*quantity AS sub " +
    "FROM sale_items WHERE sale_id = " + saleId
  );
  while (db.next())
    list.add(new SaleItem(
      db.getString("article_name"),
      db.getFloat("price"),
      db.getInt("quantity"),
      db.getFloat("sub")
    ));
  return list;
}

// ── SQL helper ────────────────────────────────────────────────────────────────

String esc(String s) {
  return s.replace("'", "''");
}
