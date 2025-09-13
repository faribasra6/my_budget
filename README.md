# 💰 MyBudget - Personal Expense Tracker

A modern, intuitive Flutter application designed to help you track daily expenses, manage monthly budgets, and gain insights into your spending habits. With multi-currency support and detailed analytics, MyBudget makes personal finance management simple and effective.

## ✨ Features

### 📊 **Budget Management**
- Set monthly budget limits with easy setup flow
- Real-time budget vs. actual expense tracking
- Visual progress indicators and spending alerts
- Monthly budget rollover and history

### 💸 **Expense Tracking**
- Quick and intuitive expense entry
- Categorized spending (Food, Transport, Entertainment, etc.)
- Date-based expense logging with descriptions
- Recent expenses overview on home screen

### 🌍 **Multi-Currency Support**
- Support for 8 major currencies:
  - UAE Dirham (AED) 🇦🇪
  - US Dollar (USD) 🇺🇸
  - Euro (EUR) 🇪🇺
  - British Pound (GBP) 🇬🇧
  - Saudi Riyal (SAR) 🇸🇦
  - Qatari Riyal (QAR) 🇶🇦
  - Pakistani Rupee (PKR) 🇵🇰
  - Indian Rupee (INR) 🇮🇳
- Easy currency switching with symbol display
- Formatted currency display throughout the app
- **Currency consistency**: Each expense and budget is stored with its original currency
- Historical data maintains currency context when switching between currencies

### 📈 **Smart Analytics**
- Monthly spending overview and trends
- Daily expense estimates based on usage patterns
- Category-wise spending breakdown
- Budget utilization percentages

### 🎨 **Modern UI/UX**
- Clean, Material Design 3 interface
- Intuitive navigation with smooth transitions
- Dark/light theme support
- Responsive design for all screen sizes

### 💾 **Local Data Storage**
- SQLite database for fast, offline functionality
- Secure local storage of financial data
- Data persistence across app sessions
- No internet required for core functionality

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/faribasra6/my_budget.git
   cd my_budget
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Building for Release

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## 📱 Screenshots

_Screenshots will be added here showing the main features of the app_

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[SQLite](https://pub.dev/packages/sqflite)** - Local database
- **[Material Design 3](https://m3.material.io/)** - Design system
- **[Intl](https://pub.dev/packages/intl)** - Internationalization and date formatting

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── budget.dart             # Budget model
│   ├── expense.dart            # Expense model
│   └── category.dart           # Category model
├── screens/                     # UI screens
│   ├── splash_screen.dart      # App splash screen
│   ├── home_screen.dart        # Main dashboard
│   ├── add_expense_screen.dart # Expense entry
│   ├── budget_setup_screen.dart # Budget configuration
│   ├── currency_selector_screen.dart # Currency selection
│   └── monthly_overview_screen.dart # Analytics view
├── services/                    # Business logic
│   ├── database_service.dart   # SQLite operations
│   └── currency_service.dart   # Currency management
└── widgets/                     # Reusable components
    └── wallet_icon.dart        # Custom wallet icon
```

## 🎯 Usage

1. **First Launch**: Set up your preferred currency and initial monthly budget
2. **Add Expenses**: Use the floating action button to quickly add new expenses
3. **Track Progress**: Monitor your spending on the home screen dashboard
4. **View Analytics**: Navigate to monthly overview for detailed insights
5. **Manage Budget**: Update your monthly budget as needed

## 🔮 Future Enhancements

- [ ] Cloud backup and sync
- [ ] Expense categories customization
- [ ] Export data to CSV/PDF
- [ ] Spending goals and targets
- [ ] Recurring expense templates
- [ ] Advanced analytics and charts
- [ ] Multiple budget accounts
- [ ] Bill reminders and notifications

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you like this project, please consider giving it a ⭐ on GitHub!

For questions or support, please open an issue in the GitHub repository.

---

**Made with ❤️ using Flutter**
