import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../bills_manager.dart';
import '../model/bill.dart' show BillBodyForm, BillType;

class FormFillScreen extends StatefulWidget {
  const FormFillScreen({super.key});

  @override
  FormFillScreenState createState() => FormFillScreenState();
}

class FormFillScreenState extends State<FormFillScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = '';
  String _tags = '';
  DateTime _startDate = DateTime.now();
  double _price = 0.0;
  String _selectedCurrency = 'rsd';
  String _selectedCountry = 'serbia';
  double _exchangeRate = 1.0;

  final List<String> _currencies = ['rsd', 'eur', 'rub', 'usd'];
  final List<String> _countries = ['serbia', 'russia', 'Canada', 'Japan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                  onSaved: (value) => setState(() => _name = value!)),
              const SizedBox(height: 20.0),
              TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Tags (separated by commas)'),
                  onSaved: (value) => setState(() => _tags = value!)),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bill Date:'),
                  Text(DateFormat.yMd().format(_startDate)),
                  ElevatedButton(
                    child: const Text('Select'),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() => _startDate = pickedDate);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Price is required' : null,
                onSaved: (value) =>
                    setState(() => _price = double.parse(value!)),
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField(
                  value: _selectedCurrency,
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCurrency = value as String)),
              const SizedBox(height: 20.0),
              DropdownButtonFormField(
                  value: _selectedCountry,
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCountry = value as String)),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exchange Rate'),
                keyboardType: TextInputType.number,
                initialValue: _exchangeRate.toString(),
                validator: (value) =>
                    value!.isEmpty ? 'Exchange rate is required' : null,
                onSaved: (value) =>
                    setState(() => _exchangeRate = double.parse(value!)),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    BillsManager manager = context.read<BillsManager>();
                    manager.addBill(
                        BillBodyForm(
                            name: _name,
                            tags: _tags,
                            date: _startDate,
                            currency: _selectedCurrency,
                            country: _selectedCountry,
                            price: _price,
                            exchangeRate: _exchangeRate),
                        BillType.form);

                    _formKey.currentState?.reset();

                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      content: Text("Bill is added to the app list", style: TextStyle(fontSize: 16.0)),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  