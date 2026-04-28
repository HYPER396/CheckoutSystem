// ── Colour palette ────────────────────────────────────────────────────────────
final color C_NAVY      = #1E3764;
final color C_BLUE      = #1E78C8;
final color C_BLUE_DARK = #0F5A9F;
final color C_BTN_BG    = #EBF5FF;
final color C_BTN_HOVER = #D0E8FF;
final color C_BTN_SEL   = #B4D2FF;
final color C_BTN_BDR   = #6495ED;
final color C_GREEN     = #1E9C46;
final color C_GREEN_DK  = #147832;
final color C_RED       = #C84640;
final color C_RED_DK    = #963230;
final color C_PANEL     = #F3F3F8;
final color C_PANEL2    = #FCFCFF;
final color C_HDR_BG    = #E0E8F4;
final color C_DIVIDER   = #D0D8EA;
final color C_TEXT_MAIN = #1E3264;
final color C_TEXT_MID  = #4A5A82;
final color C_TEXT_GREY = #8090A8;

// ── Menu bar ──────────────────────────────────────────────────────────────────

void drawMenuBar() {
  noStroke();
  fill(C_NAVY);
  rect(0, 0, WW, MENU_H);

  textFont(fHdr);
  fill(255);
  text("CHECKOUT SYSTEM", 14, 29);

  // Edit Prices button   x=WW-252, w=112
  drawMenuBtn("Edit Prices",   WW - 252, 6, 112, 32, screen == 1);
  // Sales History button  x=WW-132, w=122
  drawMenuBtn("Sales History", WW - 132, 6, 122, 32, screen == 2);
}

void drawMenuBtn(String lbl, float x, float y, float w, float h, boolean active) {
  boolean hov = over(x, y, w, h);
  noStroke();
  fill(active ? C_BLUE : hov ? #3C6EB4 : #325A96);
  rect(x, y, w, h, 4);
  fill(255);
  textFont(fBold);
  textAlign(CENTER, CENTER);
  text(lbl, x + w / 2, y + h / 2);
  textAlign(LEFT, BASELINE);
}

// ── Product panel (left side) ─────────────────────────────────────────────────

void drawProductPanel() {
  noStroke();
  fill(255);
  rect(0, MENU_H, DIV_X, WH - MENU_H);

  drawCategoryTabs();
  drawArticleGrid();
  drawBottomBar();
}

void drawCategoryTabs() {
  noStroke();
  fill(C_HDR_BG);
  rect(0, MENU_H, DIV_X, TAB_H);

  textFont(fBold);
  for (int i = 0; i < categories.size(); i++) {
    float tx = tabX(i);
    float tw = tabW(i);
    boolean active = (i == activeCatIdx);
    boolean hov    = !active && over(tx, MENU_H, tw, TAB_H);

    noStroke();
    fill(active ? 255 : hov ? #EBF0FA : C_HDR_BG);
    rect(tx, MENU_H, tw, TAB_H, 4, 4, 0, 0);
    if (active) {
      stroke(C_DIVIDER); strokeWeight(1);
      line(tx, MENU_H, tx + tw, MENU_H);
      noStroke();
    }
    fill(active ? C_NAVY : C_TEXT_MID);
    textAlign(CENTER, CENTER);
    text(categories.get(i).name, tx + tw / 2, MENU_H + TAB_H / 2);
    textAlign(LEFT, BASELINE);
  }
  // Bottom border of tab bar
  stroke(C_DIVIDER); strokeWeight(1);
  line(0, MENU_H + TAB_H, DIV_X, MENU_H + TAB_H);
  noStroke();
}

void drawArticleGrid() {
  clip(0, GRID_Y, DIV_X, GRID_H);

  ArrayList<Article> arts = catArticles();
  for (int i = 0; i < arts.size(); i++) {
    float[] b = btnBounds(i);
    if (b == null) continue;
    Article a      = arts.get(i);
    boolean hov    = over(b[0], b[1], b[2], b[3]);
    boolean active = selArt != null && selArt.id == a.id;

    // Drop shadow
    noStroke();
    fill(0, 0, 0, 18);
    rect(b[0] + 2, b[1] + 2, b[2], b[3], 6);

    // Button face
    noStroke();
    fill(active ? C_BTN_SEL : hov ? C_BTN_HOVER : C_BTN_BG);
    stroke(active ? C_BLUE : C_BTN_BDR);
    strokeWeight(active ? 2 : 1);
    rect(b[0], b[1], b[2], b[3], 6);
    noStroke(); strokeWeight(1);

    // Article name
    textFont(fBold);
    fill(C_TEXT_MAIN);
    textAlign(CENTER, CENTER);
    text(a.name, b[0] + b[2] / 2, b[1] + b[3] / 2 - 10);

    // Price
    textFont(fNorm);
    fill(C_TEXT_MID);
    text(String.format("CHF %.2f", a.price), b[0] + b[2] / 2, b[1] + b[3] / 2 + 12);
    textAlign(LEFT, BASELINE);
  }

  if (arts.isEmpty()) {
    fill(C_TEXT_GREY);
    textFont(fNorm);
    textAlign(CENTER, CENTER);
    text("No articles in this category", DIV_X / 2, GRID_Y + GRID_H / 2);
    textAlign(LEFT, BASELINE);
  }

  noClip();
}

void drawBottomBar() {
  int by = WH - 108;
  noStroke();
  fill(#EEF2FA);
  rect(0, by, DIV_X, 108);
  stroke(C_DIVIDER); strokeWeight(1);
  line(0, by, DIV_X, by);
  noStroke();

  // Selected article label
  textFont(fBold);
  fill(C_TEXT_MAIN);
  String selLabel = (selArt != null) ? "Selected:  " + selArt.name : "Click an article to select it";
  text(selLabel, 12, by + 22);

  // Qty label
  textFont(fNorm);
  fill(C_TEXT_MID);
  text("Qty:", 12, by + 58);

  // [−] button
  drawSmallBtn("−", 52, by + 42, 30, 28);
  // qty value
  textFont(fBold);
  fill(C_TEXT_MAIN);
  textAlign(CENTER, CENTER);
  text("" + addQty, 89, by + 57);
  textAlign(LEFT, BASELINE);
  // [+] button
  drawSmallBtn("+", 104, by + 42, 30, 28);

  // Add to Receipt button
  boolean hAdd = over(152, by + 35, 232, 38);
  boolean canAdd = selArt != null;
  noStroke();
  fill(canAdd ? (hAdd ? C_BLUE_DARK : C_BLUE) : #AABBD0);
  rect(152, by + 35, 232, 38, 6);
  fill(255);
  textFont(fBold);
  textAlign(CENTER, CENTER);
  text("Add to Receipt  +", 268, by + 54);
  textAlign(LEFT, BASELINE);
}

void drawSmallBtn(String lbl, float x, float y, float w, float h) {
  boolean hov = over(x, y, w, h);
  noStroke();
  fill(hov ? C_BTN_HOVER : #D8E3F0);
  stroke(C_DIVIDER); strokeWeight(1);
  rect(x, y, w, h, 4);
  noStroke();
  fill(C_NAVY);
  textFont(fBold);
  textAlign(CENTER, CENTER);
  text(lbl, x + w / 2, y + h / 2);
  textAlign(LEFT, BASELINE);
  strokeWeight(1);
}

// ── Receipt panel (right side) ────────────────────────────────────────────────

void drawReceiptPanel() {
  noStroke();
  fill(C_PANEL2);
  rect(RX, MENU_H, RW, WH - MENU_H);
  stroke(C_DIVIDER); strokeWeight(1);
  line(RX, MENU_H, RX, WH);
  noStroke();

  // Header
  fill(C_NAVY);
  rect(RX, MENU_H, RW, 38);
  fill(255);
  textFont(fHdr);
  textAlign(CENTER, CENTER);
  text("RECEIPT", RX + RW / 2, MENU_H + 19);
  textAlign(LEFT, BASELINE);

  // Column headers
  int hdrY = MENU_H + 50;
  textFont(fBold);
  fill(C_TEXT_GREY);
  text("Article",                     RX + 10,      hdrY);
  textAlign(RIGHT, BASELINE);
  text("Qty",  RX + RW - 155,         hdrY);
  text("Unit",  RX + RW - 93,         hdrY);
  text("Total", RX + RW - 35,         hdrY);
  textAlign(LEFT, BASELINE);
  stroke(C_DIVIDER); strokeWeight(1);
  line(RX + 6, hdrY + 5, RX + RW - 6, hdrY + 5);
  noStroke();

  // Items list
  int listTop = MENU_H + 62;
  int listBot = WH - 68;

  clip(RX, listTop, RW, listBot - listTop);
  for (int i = receiptScroll; i < receipt.items.size(); i++) {
    int ry = listTop + (i - receiptScroll) * RRH;
    if (ry >= listBot) break;

    ReceiptItem item = receipt.items.get(i);
    noStroke();
    fill(i % 2 == 0 ? C_PANEL : C_PANEL2);
    rect(RX + 6, ry, RW - 12, RRH);

    fill(C_TEXT_MAIN);
    textFont(fNorm);
    textAlign(LEFT, CENTER);
    // Truncate long names
    String nm = item.article.name;
    text(nm, RX + 10, ry + RRH / 2);

    textAlign(RIGHT, CENTER);
    text("" + item.qty,                                  RX + RW - 152, ry + RRH / 2);
    text(String.format("%.2f", item.article.price),      RX + RW - 95,  ry + RRH / 2);
    text(String.format("%.2f", item.getSubtotal()),      RX + RW - 36,  ry + RRH / 2);
    textAlign(LEFT, BASELINE);

    // × remove button
    boolean hx = over(RX + RW - 30, ry + 4, 22, 20);
    noStroke();
    fill(hx ? C_RED : C_RED_DK);
    rect(RX + RW - 30, ry + 4, 22, 20, 3);
    fill(255);
    textFont(fBold);
    textAlign(CENTER, CENTER);
    text("×", RX + RW - 19, ry + RRH / 2);
    textAlign(LEFT, BASELINE);
  }

  // Empty state
  if (receipt.items.isEmpty()) {
    fill(C_TEXT_GREY);
    textFont(fNorm);
    textAlign(CENTER, CENTER);
    text("Receipt is empty", RX + RW / 2, (listTop + listBot) / 2);
    textAlign(LEFT, BASELINE);
  }
  noClip();

  // Divider + total
  stroke(C_DIVIDER); strokeWeight(1);
  line(RX + 6, listBot, RX + RW - 6, listBot);
  noStroke();

  textFont(fHdr);
  fill(C_TEXT_MAIN);
  textAlign(LEFT, CENTER);
  text("TOTAL", RX + 10, listBot + 18);
  textAlign(RIGHT, CENTER);
  fill(C_GREEN_DK);
  text(String.format("CHF %.2f", receipt.getTotal()), RX + RW - 10, listBot + 18);
  textAlign(LEFT, BASELINE);

  // Buttons row
  int btnY = WH - 58;
  // Clear
  boolean hClr = over(RX + 8, btnY, 102, 36);
  noStroke();
  fill(hClr ? C_RED_DK : C_RED);
  rect(RX + 8, btnY, 102, 36, 6);
  fill(255);
  textFont(fBold);
  textAlign(CENTER, CENTER);
  text("Clear", RX + 59, btnY + 18);

  // Complete Sale
  boolean hSale = over(RX + 118, btnY, 210, 36);
  boolean hasSale = !receipt.items.isEmpty();
  noStroke();
  fill(hasSale ? (hSale ? C_GREEN_DK : C_GREEN) : #9AAAB8);
  rect(RX + 118, btnY, 210, 36, 6);
  fill(255);
  text("Complete Sale  ✓", RX + 223, btnY + 18);
  textAlign(LEFT, BASELINE);
}

// ── Edit Prices overlay ───────────────────────────────────────────────────────

void drawEditOverlay() {
  // Dim
  fill(0, 0, 0, 170);
  noStroke();
  rect(0, 0, WW, WH);

  // Panel
  fill(C_PANEL);
  noStroke();
  rect(40, 60, WW - 80, WH - 120, 8);

  // Title bar
  fill(C_NAVY);
  rect(40, 60, WW - 80, 48, 8, 8, 0, 0);
  fill(255);
  textFont(fHdr);
  textAlign(CENTER, CENTER);
  text("EDIT ARTICLE PRICES", WW / 2, 84);
  textAlign(LEFT, BASELINE);

  // Close button
  boolean hClose = over(WW - 82, 70, 62, 30);
  noStroke();
  fill(hClose ? C_RED_DK : C_RED);
  rect(WW - 82, 70, 62, 30, 4);
  fill(255);
  textFont(fBold);
  textAlign(CENTER, CENTER);
  text("Close", WW - 51, 85);
  textAlign(LEFT, BASELINE);

  // Instructions
  textFont(fNorm);
  fill(C_TEXT_MID);
  text("Click an article row to select it, then type a new price and press Enter.", 58, 126);

  // Column headers
  int hdrY = 142;
  textFont(fBold);
  fill(C_TEXT_GREY);
  text("Category",  68,  hdrY);
  text("Article",   250, hdrY);
  text("Price (CHF)", 490, hdrY);
  stroke(C_DIVIDER); strokeWeight(1);
  line(50, hdrY + 5, WW - 50, hdrY + 5);
  noStroke();

  // Article rows
  int rowH  = 34;
  int listY = 152;
  int listH = WH - 232;

  clip(50, listY, WW - 100, listH);
  for (int i = editScroll; i < allArticles.size(); i++) {
    int ry = listY + (i - editScroll) * rowH;
    if (ry + rowH > listY + listH) break;

    Article a   = allArticles.get(i);
    boolean sel = (i == editSelIdx);
    boolean hov = !sel && over(50, ry, WW - 100, rowH);

    noStroke();
    fill(sel ? #D2E2FF : hov ? #EBF0FA : (i % 2 == 0 ? C_PANEL : 255));
    rect(50, ry, WW - 100, rowH);

    fill(sel ? C_NAVY : C_TEXT_MAIN);
    textFont(sel ? fBold : fNorm);
    textAlign(LEFT, CENTER);

    String catName = "";
    for (Category c : categories) if (c.id == a.categoryId) { catName = c.name; break; }
    text(catName, 68,  ry + rowH / 2);
    text(a.name,  250, ry + rowH / 2);

    if (sel && editFocus) {
      // Text input box
      stroke(C_BLUE); strokeWeight(2);
      fill(255);
      rect(482, ry + 5, 160, rowH - 10, 4);
      noStroke(); strokeWeight(1);
      fill(C_NAVY);
      textFont(fBold);
      textAlign(LEFT, CENTER);
      text(editBuf + "|", 490, ry + rowH / 2);
    } else {
      fill(sel ? C_BLUE : C_TEXT_MAIN);
      textFont(sel ? fBold : fNorm);
      textAlign(LEFT, CENTER);
      text(String.format("%.2f", a.price), 490, ry + rowH / 2);
    }
    textAlign(LEFT, BASELINE);
  }
  noClip();

  // Save / Cancel buttons (visible when a row is selected)
  if (editSelIdx >= 0) {
    int bby = WH - 78;
    textFont(fNorm); fill(C_TEXT_MID);
    text("New price: " + editBuf, 58, bby + 22);

    // Save Price
    boolean hSave = over(200, bby, 130, 36);
    noStroke();
    fill(hSave ? C_GREEN_DK : C_GREEN);
    rect(200, bby, 130, 36, 6);
    fill(255); textFont(fBold); textAlign(CENTER, CENTER);
    text("Save Price", 265, bby + 18);

    // Cancel
    boolean hCancel = over(346, bby, 86, 36);
    noStroke();
    fill(hCancel ? C_RED_DK : C_RED);
    rect(346, bby, 86, 36, 6);
    fill(255); text("Cancel", 389, bby + 18);
    textAlign(LEFT, BASELINE);
  }
}

// ── Sales History overlay ─────────────────────────────────────────────────────

void drawSalesOverlay() {
  // Dim
  fill(0, 0, 0, 170);
  noStroke();
  rect(0, 0, WW, WH);

  // Panel
  fill(C_PANEL);
  noStroke();
  rect(40, 60, WW - 80, WH - 120, 8);

  // Title bar
  fill(C_NAVY);
  rect(40, 60, WW - 80, 48, 8, 8, 0, 0);
  fill(255);
  textFont(fHdr);
  textAlign(CENTER, CENTER);
  text("SALES HISTORY", WW / 2, 84);
  textAlign(LEFT, BASELINE);

  // Close button
  boolean hClose = over(WW - 82, 70, 62, 30);
  noStroke();
  fill(hClose ? C_RED_DK : C_RED);
  rect(WW - 82, 70, 62, 30, 4);
  fill(255); textFont(fBold); textAlign(CENTER, CENTER);
  text("Close", WW - 51, 85);
  textAlign(LEFT, BASELINE);

  // ── Top half: sales list ──────────────────────────────────────────────────
  int listY = 120;
  int halfH = (WH - 190) / 2;
  int rowH  = 32;

  textFont(fBold); fill(C_TEXT_GREY);
  text("Sale #", 62,      listY - 4);
  text("Date / Time",   160, listY - 4);
  textAlign(RIGHT, BASELINE);
  text("Total (CHF)",  WW - 58, listY - 4);
  textAlign(LEFT, BASELINE);
  stroke(C_DIVIDER); strokeWeight(1);
  line(50, listY, WW - 50, listY);
  noStroke();

  if (salesList.isEmpty()) {
    fill(C_TEXT_GREY); textFont(fNorm); textAlign(CENTER, CENTER);
    text("No sales recorded yet.", WW / 2, listY + halfH / 2);
    textAlign(LEFT, BASELINE);
  }

  clip(50, listY, WW - 100, halfH);
  for (int i = salesScroll; i < salesList.size(); i++) {
    int ry = listY + (i - salesScroll) * rowH;
    if (ry + rowH > listY + halfH) break;
    Sale s = salesList.get(i);
    boolean sel = (i == selSaleIdx);
    boolean hov = !sel && over(50, ry, WW - 100, rowH);

    noStroke();
    fill(sel ? #D2E2FF : hov ? #EBF0FA : (i % 2 == 0 ? C_PANEL : 255));
    rect(50, ry, WW - 100, rowH);

    fill(sel ? C_NAVY : C_TEXT_MAIN);
    textFont(sel ? fBold : fNorm);
    textAlign(LEFT, CENTER);
    text("#" + s.id,         62,      ry + rowH / 2);
    text(s.timestamp,        160,     ry + rowH / 2);
    textAlign(RIGHT, CENTER);
    fill(sel ? C_GREEN_DK : C_GREEN);
    textFont(fBold);
    text(String.format("CHF %.2f", s.total), WW - 58, ry + rowH / 2);
    textAlign(LEFT, BASELINE);
  }
  noClip();

  // ── Divider ───────────────────────────────────────────────────────────────
  int divY = listY + halfH + 8;
  stroke(C_DIVIDER); strokeWeight(2);
  line(50, divY, WW - 50, divY);
  noStroke();

  // ── Bottom half: items for selected sale ──────────────────────────────────
  int itemsY = divY + 12;
  textFont(fBold); fill(C_TEXT_GREY);
  if (selSaleIdx >= 0)
    text("Items in Sale #" + salesList.get(selSaleIdx).id, 62, itemsY);
  else
    text("Select a sale above to see its items.", 62, itemsY);

  stroke(C_DIVIDER); strokeWeight(1);
  line(50, itemsY + 6, WW - 50, itemsY + 6);
  noStroke();

  int iRowH  = 26;
  int itemsListY = itemsY + 10;
  clip(50, itemsListY, WW - 100, WH - itemsListY - 80);
  for (int i = 0; i < selSaleItems.size(); i++) {
    int ry = itemsListY + i * iRowH;
    if (ry + iRowH > WH - 80) break;
    SaleItem si = selSaleItems.get(i);

    noStroke();
    fill(i % 2 == 0 ? C_PANEL : 255);
    rect(50, ry, WW - 100, iRowH);

    fill(C_TEXT_MAIN);
    textFont(fNorm);
    textAlign(LEFT, CENTER);
    text(si.name, 70, ry + iRowH / 2);
    textAlign(RIGHT, CENTER);
    fill(C_TEXT_MID);
    text(si.qty + " ×",                           WW - 300, ry + iRowH / 2);
    text(String.format("CHF %.2f", si.unitPrice),   WW - 200, ry + iRowH / 2);
    fill(C_TEXT_MAIN);
    textFont(fBold);
    text(String.format("CHF %.2f", si.subtotal),    WW - 58,  ry + iRowH / 2);
    textAlign(LEFT, BASELINE);
  }
  noClip();
}
