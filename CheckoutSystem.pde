// ── Global state ──────────────────────────────────────────────────────────────
int screen = 0;  // 0=main  1=editPrices  2=salesHistory

ArrayList<Category> categories  = new ArrayList<Category>();
ArrayList<Article>  allArticles = new ArrayList<Article>();
int activeCatIdx = 0;

Receipt receipt;
Article selArt = null;
int     addQty = 1;

// Edit-prices overlay
int     editSelIdx = -1;
String  editBuf    = "";
boolean editFocus  = false;

// Sales-history overlay
ArrayList<Sale>     salesList    = new ArrayList<Sale>();
int                 selSaleIdx   = -1;
ArrayList<SaleItem> selSaleItems = new ArrayList<SaleItem>();

// Scroll offsets
int receiptScroll = 0;
int editScroll    = 0;
int salesScroll   = 0;
int gridScroll    = 0;

// Fonts
PFont fNorm, fBold, fHdr;

// ── Layout constants ──────────────────────────────────────────────────────────
final int WW      = 1100;
final int WH      = 720;
final int MENU_H  = 44;
final int DIV_X   = 660;
final int TAB_H   = 42;

// Product grid
final int GRID_Y  = MENU_H + TAB_H;    // 86
final int GRID_H  = WH - GRID_Y - 108; // 526  (108px bottom bar)
final int COL_W   = 210;
final int BTN_H   = 68;
final int HGAP    = 6;
final int VGAP    = 6;
final int COLS    = 3;

// Receipt panel
final int RX = DIV_X;
final int RW = WW - DIV_X;   // 440

// Receipt list row height
final int RRH = 28;

// ─────────────────────────────────────────────────────────────────────────────

void setup() {
  size(1100, 720);
  fNorm = createFont("SansSerif",      13);
  fBold = createFont("SansSerif-Bold", 13);
  fHdr  = createFont("SansSerif-Bold", 15);
  textFont(fNorm);
  receipt = new Receipt();
  connectDB();
  refreshData();
}

void draw() {
  background(243, 243, 248);
  drawProductPanel();
  drawReceiptPanel();
  drawMenuBar();
  if (screen == 1) drawEditOverlay();
  if (screen == 2) drawSalesOverlay();
}

void refreshData() {
  categories  = loadCategories();
  allArticles = loadAllArticles();
  if (activeCatIdx >= categories.size()) activeCatIdx = 0;
}

// ── Input ─────────────────────────────────────────────────────────────────────

void mousePressed() {
  if (screen == 1) { clickEditOverlay();  return; }
  if (screen == 2) { clickSalesOverlay(); return; }
  clickMenu();
  clickTabs();
  clickGrid();
  clickBottomBar();
  clickReceipt();
}

void keyPressed() {
  if (key == ESC) {
    key = 0;  // prevent Processing from quitting
    if (screen != 0) { screen = 0; editFocus = false; }
    return;
  }
  if (screen == 1 && editFocus) {
    if (key == BACKSPACE) {
      if (editBuf.length() > 0)
        editBuf = editBuf.substring(0, editBuf.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      commitEditPrice();
    } else if ((key >= '0' && key <= '9') || key == '.') {
      editBuf += key;
    }
  }
}

void mouseWheel(MouseEvent e) {
  int d = e.getCount();
  if (screen == 0) {
    if (mouseX > DIV_X)
      receiptScroll = max(0, receiptScroll + d);
    else
      gridScroll = max(0, gridScroll + d);
  } else if (screen == 1) {
    editScroll = max(0, editScroll + d);
  } else if (screen == 2) {
    salesScroll = max(0, salesScroll + d);
  }
}

// ── Menu clicks ───────────────────────────────────────────────────────────────

void clickMenu() {
  if (mouseY > MENU_H) return;
  if (over(WW - 252, 6, 112, 32)) {
    screen     = 1;
    editSelIdx = -1;
    editBuf    = "";
    editFocus  = false;
    editScroll = 0;
  }
  if (over(WW - 132, 6, 122, 32)) {
    screen       = 2;
    salesList    = loadSales();
    selSaleIdx   = -1;
    selSaleItems = new ArrayList<SaleItem>();
    salesScroll  = 0;
  }
}

// ── Tab clicks ────────────────────────────────────────────────────────────────

void clickTabs() {
  if (mouseY < MENU_H || mouseY > MENU_H + TAB_H || mouseX >= DIV_X) return;
  for (int i = 0; i < categories.size(); i++) {
    float tx = tabX(i), tw = tabW(i);
    if (mouseX >= tx && mouseX < tx + tw) {
      activeCatIdx = i;
      gridScroll   = 0;
      selArt       = null;
    }
  }
}

// ── Article grid clicks ───────────────────────────────────────────────────────

void clickGrid() {
  if (mouseX >= DIV_X || mouseY < GRID_Y || mouseY > GRID_Y + GRID_H) return;
  ArrayList<Article> arts = catArticles();
  for (int i = 0; i < arts.size(); i++) {
    float[] b = btnBounds(i);
    if (b != null && over(b[0], b[1], b[2], b[3]))
      selArt = arts.get(i);
  }
}

// ── Bottom-bar clicks (qty +/- and Add to Receipt) ───────────────────────────

void clickBottomBar() {
  if (mouseX >= DIV_X) return;
  int by = WH - 108;
  if (over(52, by + 40, 30, 30)) addQty = max(1, addQty - 1);
  if (over(104, by + 40, 30, 30)) addQty = min(999, addQty + 1);
  if (over(152, by + 35, 232, 38) && selArt != null) {
    receipt.add(selArt, addQty);
    addQty        = 1;
    receiptScroll = max(0, receipt.items.size() - 14);
  }
}

// ── Receipt-panel clicks ──────────────────────────────────────────────────────

void clickReceipt() {
  int btnY    = WH - 58;
  int listTop = MENU_H + 62;
  int listBot = WH - 68;

  // Clear
  if (over(RX + 8, btnY, 102, 36)) {
    receipt.clear();
    receiptScroll = 0;
  }
  // Complete Sale
  if (over(RX + 118, btnY, 210, 36) && !receipt.items.isEmpty()) {
    recordSale(receipt);
    receipt.clear();
    receiptScroll = 0;
  }
  // Remove (×) buttons
  for (int i = receiptScroll; i < receipt.items.size(); i++) {
    int ry = listTop + (i - receiptScroll) * RRH;
    if (ry + RRH > listBot) break;
    if (over(RX + RW - 30, ry + 4, 22, 20)) {
      receipt.remove(i);
      receiptScroll = max(0, min(receiptScroll, receipt.items.size() - 1));
      break;
    }
  }
}

// ── Edit-overlay clicks ───────────────────────────────────────────────────────

void clickEditOverlay() {
  if (over(WW - 82, 70, 62, 30)) { screen = 0; return; }

  if (editSelIdx >= 0) {
    if (over(200, WH - 78, 130, 36)) { commitEditPrice(); return; }
    if (over(346, WH - 78, 86, 36))  { editSelIdx = -1; editBuf = ""; editFocus = false; return; }
  }

  int rowH  = 34;
  int listY = 156;
  int listH = WH - 230;
  for (int i = editScroll; i < allArticles.size(); i++) {
    int ry = listY + (i - editScroll) * rowH;
    if (ry + rowH > listY + listH) break;
    if (over(50, ry, WW - 100, rowH)) {
      editSelIdx = i;
      editBuf    = String.format("%.2f", allArticles.get(i).price);
      editFocus  = true;
      return;
    }
  }
}

void commitEditPrice() {
  if (editSelIdx < 0 || editSelIdx >= allArticles.size()) return;
  float p;
  try { p = Float.parseFloat(editBuf.replace(',', '.')); }
  catch (NumberFormatException e) { return; }
  if (p < 0) return;
  Article a = allArticles.get(editSelIdx);
  updateArticlePrice(a.id, p);
  a.price    = p;
  editSelIdx = -1;
  editBuf    = "";
  editFocus  = false;
}

// ── Sales-overlay clicks ──────────────────────────────────────────────────────

void clickSalesOverlay() {
  if (over(WW - 82, 70, 62, 30)) { screen = 0; return; }
  int rowH   = 32;
  int listY  = 122;
  int halfH  = (WH - 190) / 2;
  for (int i = salesScroll; i < salesList.size(); i++) {
    int ry = listY + (i - salesScroll) * rowH;
    if (ry + rowH > listY + halfH) break;
    if (over(50, ry, WW - 100, rowH)) {
      selSaleIdx   = i;
      selSaleItems = loadSaleItems(salesList.get(i).id);
      return;
    }
  }
}

// ── Layout helpers ────────────────────────────────────────────────────────────

ArrayList<Article> catArticles() {
  if (categories.isEmpty()) return new ArrayList<Article>();
  int catId = categories.get(activeCatIdx).id;
  ArrayList<Article> out = new ArrayList<Article>();
  for (Article a : allArticles) if (a.categoryId == catId) out.add(a);
  return out;
}

float tabX(int i) {
  textFont(fBold);
  float x = 0;
  for (int j = 0; j < i; j++) x += textWidth(categories.get(j).name) + 26;
  return x;
}

float tabW(int i) {
  textFont(fBold);
  return textWidth(categories.get(i).name) + 26;
}

// Returns [x, y, w, h] for article button i, or null if scrolled out of view.
float[] btnBounds(int i) {
  int col = i % COLS;
  int row = i / COLS;
  float bx = 8 + col * (COL_W + HGAP);
  float by = GRID_Y + row * (BTN_H + VGAP) - gridScroll * (BTN_H + VGAP);
  if (by + BTN_H <= GRID_Y || by >= GRID_Y + GRID_H) return null;
  return new float[]{bx, by, COL_W, BTN_H};
}

boolean over(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}
