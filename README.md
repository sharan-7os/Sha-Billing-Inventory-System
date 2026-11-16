# Sha Electronics - Inventory & POS Billing Management System

A high-performance offline desktop inventory and billing management system built with **Flutter & C++**, designed specifically for **Paint, Electrical, Hardware, and Plumbing retail and wholesale stores**. Featuring complete **Indian GST (CGST/SGST/IGST)** compliance, real-time stock computation, dynamic tax computation, and **Standard A4 Tax Invoice printing**.

---

## 🌟 Key Features

### 1. 🏷️ Four Core Product Categories
Organized specifically with tailored defaults for shop inventory:
- **Paint**: Default HSN `320890`, units: `Litre`, `Can`, `Kg` (Purple theme)
- **Electrical**: Default HSN `853690`, units: `Pcs`, `Meter`, `Roll` (Amber theme)
- **Hardware**: Default HSN `731815`, units: `Pcs`, `Box`, `Kg` (Blue theme)
- **Plumbing**: Default HSN `391723`, units: `Pcs`, `Meter`, `Length` (Teal theme)

### 2. 🧮 Dynamic Tax Calculation From Entered Price
- **Price includes GST (MRP)**: The app back-calculates the exact base price and GST component:
  $$\text{Base Price} = \frac{\text{MRP}}{1 + (\text{GST}\% / 100)}$$
  $$\text{Tax Amount} = \text{MRP} - \text{Base Price}$$
- **Price excludes GST (Base Price)**: Adds GST on top of the entered base price:
  $$\text{Tax Amount} = \text{Base Price} \times (\text{GST}\% / 100)$$
  $$\text{Final Billing Price} = \text{Base Price} + \text{Tax Amount}$$
- Real-time tax breakdown card showing Base Rate, CGST (50%), SGST (50%), or IGST (Interstate).

### 3. 📦 Stock Management & Auditing
- **+ Add New Stock**: Increment quantity upon receiving a supplier shipment with optional updated cost per unit.
- **= Direct Stock Count**: Set the physical inventory count during stock audits.
- Color-coded stock badges: Normal (Green), Low Stock Alert (Orange), and Out of Stock (Red).

### 4. ⚡ High-Speed Point of Sale (POS) & Billing
- **Computed Available Stock**: The product catalog and cart display current available inventory and dynamically subtract quantities currently in the bill.
- **Stock Limit Guarding**: Prevents billing more items than physically available in store.
- **Quick Search**: Search instantly by Name, Barcode/SKU, Brand, or HSN Code.
- **Customer Directory & Khata (Credit)**: Track walk-in customers or registered B2B clients with GSTIN and outstanding balances.
- **Multiple Payment Modes**: Cash, UPI / QR, Card, or Due (Khata).
- **1-Click A4 Tax Invoice**: Automatic conversion of total into Indian Currency words, HSN tax summary table, and instant system print or PDF export.

### 5. 📊 Executive Dashboard & Tax Reports
- **Sales Analytics**: Today's revenue, invoice count, and monthly gross turnover.
- **7-Day Trend Chart**: Sales revenue visualization powered by `fl_chart`.
- **GSTR-1 Tax Summary**: Taxable turnover, CGST, SGST, IGST, and HSN summary table ready for GST filing.
- **Clean Store Setup**: Completely free of sample data; includes a 1-click "Reset Store & Clear All Data" feature in Settings.

---

## 🚀 Running on Your Shop PC (No Developer Tools Required)

To run the application on your shop counter PC:

1. Download or copy the portable ZIP bundle:
   **`Sha_Electronics_Billing_Portable.zip`** (from the GitHub Releases or Desktop).
2. Extract the ZIP file to any folder (e.g. `C:\Sha-Billing\`).
3. Double-click **`Sha-Billing.exe`**.
4. *(Optional)* Right-click `Sha-Billing.exe` → **Send to Desktop (create shortcut)** for easy access from your desktop.

> **Note**: No Flutter, Dart, or Visual Studio installation is needed on the shop PC. It is completely standalone and works 100% offline.

---

## 🛠️ Developer Setup & Building From Source

### Prerequisites
- Windows 10/11 (64-bit)
- [Flutter SDK](https://flutter.dev/docs/get-started/install/windows) (v3.24+ recommended)
- Visual Studio 2022 / 2026 with **Desktop development with C++** (MSVC & Windows 10/11 SDK)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/sharan-7os/Sha-Billing-Inventory-System.git
cd Sha-Billing-Inventory-System

# Fetch packages
flutter pub get

# Run in debug mode on Windows
flutter run -d windows

# Build standalone Release executable
flutter build windows
```

The compiled release package will be generated at:
`build\windows\x64\runner\Release\`

---

## 🏛️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Desktop Windows Runner)
- **Language**: Dart 3.x & C++17
- **Rendering Engine**: Impeller / Skia Native DirectX & OpenGL
- **State Management**: `provider` (Reactive AppState architecture)
- **Local Storage**: `shared_preferences` (Offline persistence in local app data)
- **PDF & Printing**: `pdf` & `printing` (A4 Tax Invoice generation)
- **Data Visualization**: `fl_chart` (Dashboard sales revenue trends)
- **Formatting**: `intl` (Indian Rupee `₹` formatting, dates)

---

## 📄 License
Copyright © 2026 Sha Electronics. All rights reserved.
