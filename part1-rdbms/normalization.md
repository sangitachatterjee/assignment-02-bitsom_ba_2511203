# Normalization

## Anomaly Analysis

When I first opened `orders_flat.csv` I assumed I'd find maybe one or two issues to write about. There were more. The whole thing is one flat table - every order row carries all the customer info, product details, and sales rep data alongside it. Fine for reading a single row, but it starts causing problems the moment you do anything else.

---

### Insert Anomaly

I couldn't find anywhere to add a new product without first having an order for it. The product columns (`product_id`, `product_name`, `category`, `unit_price`) only exist inside order rows - they have no independent home.

So if the company adds "Keyboard" (P009, Stationery, ₹450) to its catalog before anyone buys one, there's literally nowhere to put it. Every row requires a valid `order_id`, `customer_id`, and `order_date`. Same applies to new customers or sales reps before their first transaction.

---

### Update Anomaly

This one I actually spotted by accident while scrolling through. SR01 (Deepak Joshi) shows up in a lot of rows, and his `office_address` is copied into every single one. Most rows say "Nariman Point" but some say "Nariman Pt" - ORD1180, ORD1173, ORD1170 among others. I'm not sure if it was a typo in the original entry or a deliberate abbreviation, but either way you now have two different strings representing the same address.

In a normalized schema this can't happen because the address lives in exactly one row. In the flat file, fixing it means hunting down every affected row manually and hoping you catch them all.

---

### Delete Anomaly

P008 (Webcam, Electronics, ₹2100) only appears in one order. If that order gets deleted - cancelled return, archival purge, whatever - the product record goes with it. There's no other row that knows P008 exists. A separate `products` table would be immune to this since it doesn't depend on order history at all.

---

## Normalization Justification

The obvious objection is that more tables means more joins. Fair enough if you're working with a static reporting export. Less convincing for a live system where data gets added, corrected, and deleted on an ongoing basis.

The update anomaly above is already visible in the data before a single correction has been made. SR01's address drifted into two forms just from initial data entry. In a normalized schema, one row in `sales_reps` is the only place that value lives - fix it there and it's fixed everywhere. In the flat file you're playing whack-a-mole with rows.

The delete anomaly bothers me more though, because it's one-way. Once that Webcam order is gone, the product is gone. There's nothing to recover it from. A `products` table decouples product existence from order history entirely - which is just correct modeling of how a catalog actually works.

The insert anomaly is the most structurally interesting one to me: the flat file literally cannot represent a fact (a product exists) that hasn't also produced a transaction. That's not a simplification, it's a gap in the data model.

So yes, the 3NF design adds joins. In exchange the data stays consistent, products outlive their orders, and you can record things before they're sold. Worth it for anything being actively written to.
