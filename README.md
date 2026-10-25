# FNB Mzansi Matrix: Full 20-Screen Implementation

**FNB Mzansi Matrix** is an informal merchant banking, inventory, and microloan platform built for South African township enterprises (Spaza Shops and Liquor Stores). It bridges informal day-to-day operations with formal digital banking, verified bookkeeping, multilingual voice capture, and credit readiness.

---

## 🏆 Hackathon Architectural Overview

The application satisfies the **Consolidated Figma-to-Firebase Development Specification** across all 20 screens:

### 1. The 20 Fully Implemented Application Screens

| Screen | Name | Description & Implemented Functionality |
|---|---|---|
| **Screen 1** | **Home Screen** | Visual reproduction of FNB consumer home with promotional banners ("Free Delivery Friday"), quick action tiles, and active shop context indicator. |
| **Screen 2** | **F&B Menu Home Screen** | Complete categorized banking and merchant menu (Transact, Merchant Tools, Borrow & Grow, Support). |
| **Screen 3** | **GasiMzansi Matrix** | Preserved scrolling Matrix screen with business header price list trigger, interactive product creation, price updating, and soft-delete archiving to protect historical sales records. |
| **Screen 4** | **Choose Your Shop** | Context switcher between **My Spaza Shop** and **My Liquor Shop**. Isolates data, price lists, notifications, and analytics. Marks Hair Salon, Car Wash, and Shisa Nyama as "Coming Soon". |
| **Screen 5** | **Main Application Home** | 4 Hero actions (**Capture** -> S6, **Microphone** -> S7, **My Progress** -> S12/13, **F&B Microloan** -> S20). Header plus (+) opens price list (S14/15); bell opens notifications (S10/11). |
| **Screen 6** | **Scanner** | Dual-mode camera viewfinder simulation: Barcode scanning & wholesale invoice/receipt OCR. Routes Spaza items to S8, Liquor items to S9, and receipts to verification. Never saves uncertain extractions silently. |
| **Screen 7** | **Voice Capture** | Multilingual voice recorder supporting **isiZulu, Sesotho, siSwati, isiXhosa, Afrikaans, and English**. Interprets Talk Sale, Talk Expense, Stock Arrival, and Till Draws into structured transactions with review modal. |
| **Screen 8** | **Scanned Spaza Items** | Extracted essentials (Albany Bread, Clover Milk, Ultra Mel Custard) with price editing, duplicate validation, and "Confirm and Save to Price List" action. |
| **Screen 9** | **Scanned Liquor Items** | Extracted beverages (Carling Black Label, Savanna Dry) with validation and "Confirm and Save to All Price List" action (saved to Liquor Price List per regulatory isolation). |
| **Screen 10** | **Markdown Alerts** | Flagged Spaza items categorized as Near Expiry, Broken, or Damaged. Expiry date tracking, reason logging, and manual discount price approval without unauthorized automatic discounting. |
| **Screen 11** | **Liquor Empties Tracker** | Audits SAB crate counts, Heineken crate counts, and customer bottle dispatches/returns. Keeps suppliers strictly separated to prevent duplicate deposit accounting. |
| **Screen 12** | **My Progress (Spaza)** | Shop costs, family costs, savings, and net profit calculated from real ledger transactions. Trending Spaza items, loan eligibility link, and cycle breakdown. |
| **Screen 13** | **My Progress (Liquor)** | Liquor-specific net profit, beverage restocking costs, customer bottle deposit reserve, top-selling drinks (Castle, Amstel, Savanna), and loan eligibility. Strictly separated from Spaza data. |
| **Screen 14** | **Spaza Price List** | Real-time catalogue with search, category filtering, product creation dialog, price updating, and non-destructive archiving. |
| **Screen 15** | **Liquor Price List** | Dedicated beverage catalogue with search, price editing, beverage classification (Beer, Cider, Returnable), and historical sales protection. |
| **Screen 16** | **SASSA Financial Overview** | Financial breakdown during grant disbursement cycles (1st - 7th). Contextual speech bubble advice tailored to basic food turnover and savings in the owner's language. |
| **Screen 17** | **Mid-Month Financial Overview** | Mid-month cash preservation analysis (8th - 24th). Dynamic speech bubble advising disciplined spending and avoiding unnecessary stock purchases. |
| **Screen 18** | **25th-Day Financial Overview** | Payday restocking analysis (25th - 28th). Affordability verification engine ensuring the owner can afford cold drink and bread top-ups before Saturday without overleveraging. |
| **Screen 19** | **Month-End Financial Overview** | Month-end audited totals. Contextual speech bubble comparing wholesaler combo deals to save on bulk goods. |
| **Screen 20** | **FNB Microloan** | "Halala! You may qualify for a R5,000 microloan." 3-Step progression: **Step 1 (Qualification)** verified via ledger activity; **Step 2 (Approval)** & **Step 3 (Disbursement)** locked until formal credit check. Includes Top-Up module. |

---

## 🌍 Multilingual NLP Capabilities

The app includes native multilingual voice interpretation (`lib/services/voice_nlp_service.dart`) supporting 6 official South African languages:
- **isiZulu** (e.g. *"Ngi-thengise amaqanda amahlanu ngo-R90."*)
- **Sesotho** (e.g. *"Ke tsere R100 mo tilleng."*)
- **siSwati** (e.g. *"Ngitsengise tibhontshisi netinkwa nge-R75."*)
- **isiXhosa** (e.g. *"Ndithwalise iibhokisi zobisi ezimbini ngo-R140."*)
- **Afrikaans** (e.g. *"Ek het 2 kiste Castle Lager verkoop vir R240."*)
- **English** (e.g. *"Sold 3 cold drinks and 2 brown bread for R110."*)

---

## 🧮 Financial Calculation Engine

Calculations (`lib/services/financial_calculator_service.dart`) adhere to strict business rules:
- **Shop Costs:** Sum of wholesale stock arrivals and operational shop expenses.
- **Family Costs:** Personal till draws taken from the cash register.
- **Savings:** 10% target allocation from gross operating margin.
- **Take-Home Profit:** `Gross Sales - Shop Costs - Family Costs - Savings`.
- **Available to Spend:** Verified liquid liquidity available for reinvestment.

---

## 🔒 Firebase & Security Architecture

1. **Cloud Firestore:**
   - User-scoped paths: `/users/{userId}/businesses/{businessId}/...`
   - Strict `firestore.rules` preventing cross-user reads or data tampering.
2. **Realtime Database:**
   - User-scoped activity logs under `/users/{userId}/...` via `database.rules.json`.
3. **Historical Data Protection:**
   - Products are soft-deleted via `isArchived: true` so historical receipts and ledger transactions remain intact.

---

## 🧪 Testing & Verification

Run static analysis:
```bash
flutter analyze
```

Run comprehensive unit and widget tests:
```bash
flutter test
```

All 13 test suites pass cleanly covering:
- Multilingual voice intent extraction across 6 languages
- Unambiguous confirmation states
- Financial period math and affordability checks
- Catalog duplicate prevention and soft-delete archiving
- Tab navigation and full 20-screen catalogue rendering
