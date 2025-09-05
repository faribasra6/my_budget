import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencySelectorScreen extends StatelessWidget {
  const CurrencySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: ListView.builder(
        itemCount: CurrencyService.allCurrencies.length,
        itemBuilder: (context, index) {
          final currency = CurrencyService.allCurrencies[index];
          final isSelected = currency.code == CurrencyService.selectedCurrency.code;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
              child: Text(
                currency.symbol,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(currency.name),
            subtitle: Text('${currency.code} - ${currency.symbol}'),
            trailing: isSelected 
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              CurrencyService.setCurrency(currency);
              Navigator.pop(context, true);
            },
          );
        },
      ),
    );
  }
}