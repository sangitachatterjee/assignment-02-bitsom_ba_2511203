// mongo_queries.js
// MongoDB operations for the e-commerce product catalog.
// Database: ecommerce   Collection: products
// Run in mongosh:  use ecommerce

// OP1: insertMany() - insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    _id: "prod_elec_001",
    category: "Electronics",
    name: "Sony WH-1000XM5 Headphones",
    brand: "Sony",
    sku: "SNY-WH1000XM5-BLK",
    price: 29990,
    currency: "INR",
    in_stock: true,
    stock_qty: 42,
    specs: {
      driver_size_mm: 30,
      frequency_response: "4 Hz - 40,000 Hz",
      battery_life_hours: 30,
      charging_time_hours: 3.5,
      connectivity: ["Bluetooth 5.2", "3.5mm Jack", "USB-C"],
      noise_cancellation: true,
      voltage: "5V DC",
      weight_g: 250
    },
    warranty: {
      duration_months: 12,
      type: "Manufacturer",
      covers: ["manufacturing defects", "hardware failure"],
      excludes: ["physical damage", "water damage"]
    },
    certifications: ["BIS", "CE", "FCC"],
    tags: ["audio", "wireless", "noise-cancelling", "premium"],
    ratings: { average: 4.6, count: 1832 },
    created_at: new Date("2024-03-10T09:00:00Z"),
    updated_at: new Date("2025-01-15T11:30:00Z")
  },
  {
    _id: "prod_clth_001",
    category: "Clothing",
    name: "Levis 511 Slim Fit Jeans",
    brand: "Levis",
    sku: "LV-511-IND-32W30L",
    price: 3499,
    currency: "INR",
    in_stock: true,
    stock_qty: 118,
    specs: {
      material: "99% Cotton, 1% Elastane",
      fit: "Slim",
      rise: "Mid Rise",
      closure: "Zip Fly with Button",
      care_instructions: [
        "Machine wash cold",
        "Do not bleach",
        "Tumble dry low",
        "Iron on reverse"
      ]
    },
    variants: [
      { size: "30W x 30L", color: "Indigo",     sku_suffix: "30W30L-IND", qty: 14 },
      { size: "32W x 30L", color: "Indigo",     sku_suffix: "32W30L-IND", qty: 22 },
      { size: "32W x 32L", color: "Indigo",     sku_suffix: "32W32L-IND", qty: 18 },
      { size: "34W x 32L", color: "Dark Wash",  sku_suffix: "34W32L-DRK", qty: 30 },
      { size: "36W x 32L", color: "Dark Wash",  sku_suffix: "36W32L-DRK", qty: 34 }
    ],
    gender: "Men",
    age_group: "Adult",
    country_of_origin: "India",
    tags: ["jeans", "denim", "slim-fit", "casual"],
    ratings: { average: 4.3, count: 5421 },
    created_at: new Date("2023-11-01T08:00:00Z"),
    updated_at: new Date("2025-02-20T14:00:00Z")
  },
  {
    _id: "prod_groc_001",
    category: "Groceries",
    name: "Organic Rolled Oats 1kg",
    brand: "True Elements",
    sku: "TE-OATS-ORG-1KG",
    price: 349,
    currency: "INR",
    in_stock: true,
    stock_qty: 260,
    expiry_date: new Date("2024-08-31"),
    manufactured_date: new Date("2023-09-01"),
    shelf_life_days: 365,
    storage_instructions: "Store in a cool, dry place. Keep away from direct sunlight. Reseal after opening.",
    nutritional_info: {
      serving_size_g: 40,
      servings_per_pack: 25,
      per_serving: {
        calories_kcal: 148,
        carbohydrates_g: 25.2,
        protein_g: 5.1,
        fat_g: 2.7,
        fibre_g: 3.5,
        sugar_g: 0.5,
        sodium_mg: 2
      }
    },
    allergens: ["gluten"],
    certifications: ["USDA Organic", "FSSAI", "Non-GMO"],
    packaging: { type: "Resealable Pouch", weight_g: 1000, recyclable: true },
    tags: ["organic", "oats", "breakfast", "gluten-free-friendly", "high-fibre"],
    ratings: { average: 4.5, count: 9873 },
    created_at: new Date("2024-09-05T07:00:00Z"),
    updated_at: new Date("2024-12-01T10:00:00Z")
  }
]);

// OP2: find() - retrieve all Electronics products with price > 20000
// Returns only the name, brand, price, and specs fields to keep output readable.
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    brand: 1,
    price: 1,
    specs: 1
  }
);

// OP3: find() - retrieve all Groceries expiring before 2025-01-01
// Checks the expiry_date field, which is stored as a Date object.
db.products.find(
  {
    category: "Groceries",
    expiry_date: { $lt: new Date("2025-01-01") }
  },
  {
    name: 1,
    sku: 1,
    expiry_date: 1,
    in_stock: 1
  }
);

// OP4: updateOne() - add a "discount_percent" field to a specific product
// Targets the Sony headphones by its _id and sets a 10 % discount.
db.products.updateOne(
  { _id: "prod_elec_001" },
  {
    $set: {
      discount_percent: 10,
      updated_at: new Date()
    }
  }
);

// OP5: createIndex() - create an index on category field and explain why
// WHY: Every catalog query in OP2 and OP3 filters on `category` as its first
// predicate. Without this index MongoDB performs a full collection scan on every
// such query. As the catalog grows to millions of products across three (or more)
// categories, the index reduces the documents examined from O(n) to the size of
// a single category bucket, cutting query latency significantly.
// A background build is used so the collection remains available during index
// construction in a production environment.
db.products.createIndex(
  { category: 1 },
  { name: "idx_category_asc" }
);
