Build a Android app for `SALES_MANAGEMENT_SYSTEM' App that  implements  a Flutter-based Sales Management System for a medical clinic, targeting Android only.

The Android App should include:

## 1. Project Overview
- **App Name**: Clinic Sales Management System
- **Platform**: Android only
- **Framework**: Flutter with Dart
- **Purpose**: Manage product/service sales, track payments, and generate reports for a clinic.

## 2. Key Features
1. **Authentication**
   - Login/Logout
   - Role-based access (Admin, Cashier, Manager)

2. **Product/Service Management**
   - Add, edit, delete products/services
   - Track item name, category, price, and stock level

3. **Customer Management**
   - Add customers
   - Track name, phone number, visit history

4. **Sales Entry**
   - Select products/services
   - Input quantity, auto-calculate totals
   - Apply discounts or tax if applicable

5. **Receipts & Invoices**
   - Generate and share PDF receipts
   - Include customer name, items, prices, date, clinic logo

6. **Stock Management**
   - Decrease stock on sale
   - Restock manually

7. **Payments**
   - Support for Cash, MPESA, Credit
   - Mark payment status (Paid, Partially Paid, Unpaid)

8. **Sales Reports**
   - View daily, weekly, monthly sales
   - Export reports to CSV or PDF

9. **Backup & Restore**
   - Backup data locally ( SQLite)
   - Restore from backup

10. **Search & Filter**
    - Search by customer, item, date range

11. **Dark Mode & Theming**
    - Allow dark mode and color scheme toggle
12. **Barcode Scanning**
     - Barcode scanning for products  	

## 3. Technologies Used
- Flutter & Dart
- SQLite for local storage (no Firebase)
- `pdf`, `printing`, `sqflite`, `path_provider`, `intl`, `Barcode` packages

## 4. Folder Structure (Suggested)
```
lib/
│
├── main.dart
├── models/
│   ├── user.dart
│   ├── product.dart
│   ├── customer.dart
│   ├── sale.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── dashboard.dart
│   ├── product_screen.dart
│   ├── sales_screen.dart
│   ├── report_screen.dart
│
├── services/
│   ├── database_helper.dart
│   ├── auth_service.dart
│   ├── pdf_service.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── input_field.dart
│
├── utils/
│   ├── theme.dart
│   ├── helpers.dart
```

## 5. Future Enhancements
- Add MPESA API integration
- Cloud sync (Firebase or Supabase)
- Barcode scanning for products


