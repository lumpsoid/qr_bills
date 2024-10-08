import 'package:bill_repository/bill_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_bills/form/form.dart';

class FormPage extends StatelessWidget {
  const FormPage({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) =>
            BillFormBloc(billRepository: context.read<BillRepository>())
              ..add(const FormInit()),
        child: const FormPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillFormBloc, BillFormState>(
      listenWhen: (previous, current) =>
          previous != current && current is BillFormSuccess,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: const FormScreen(),
    );
  }
}

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _NameField(),
                    _TagField(),
                    _DatePickField(),
                    _PriceField(),
                    _CurrencyField(),
                    _ExchageRateField(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SubmitButton(),
                    _CancelButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<BillFormBloc>().add(const FormBillAdd());

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bill is added to the app list",
              style: TextStyle(fontSize: 16.0)),
          duration: Duration(seconds: 2),
        ));
      },
      child: const Text('Submit'),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('Cancel'),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Name'),
      onChanged: (value) =>
          context.read<BillFormBloc>().add(FormNameChanged(value)),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s()]')),
      ],
    );
  }
}

class _TagField extends StatelessWidget {
  const _TagField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillFormBloc, BillFormState>(
      builder: (context, state) {
        switch (state) {
          case BillFormLoaded():
            return Autocomplete<String>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFormField(
                  maxLines: 1,
                  focusNode: focusNode,
                  controller: textEditingController,
                  decoration: const InputDecoration(labelText: 'Tags'),
                  onChanged: (value) =>
                      context.read<BillFormBloc>().add(FormTagsChanged(value)),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-z,]')),
                  ],
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable.empty();
                }
                return state.tagsList.where((option) =>
                    option.contains(textEditingValue.text.toLowerCase()));
              },
              optionsViewBuilder: (context, onSelected, options) => Container(
                color: Theme.of(context).colorScheme.background,
                child: ListView(
                  children: options
                      .map((option) => GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 15.0),
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          ))
                      .toList(),
                ),
              ),
              onSelected: (option) =>
                  context.read<BillFormBloc>().add(FormTagsChanged(option)),
            );
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class _DatePickField extends StatelessWidget {
  const _DatePickField();

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Bill Date:'),
        Text(DateFormat.yMd().format(startDate)),
        ElevatedButton(
          child: const Text('Select'),
          onPressed: () async {
            await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
            ).then((value) {
              if (value != null) {
                context.read<BillFormBloc>().add(FormDateChanged(value));
              }
            });
          },
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.number,
      validator: (value) => value!.isEmpty ? 'Price is required' : null,
      onChanged: (value) =>
          context.read<BillFormBloc>().add(FormPriceChanged(value)),
      initialValue: '',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillFormBloc, BillFormState>(
      builder: (context, state) {
        if (state is BillFormLoaded) {
          return DropdownButtonFormField(
            value: state.currency,
            items: state.currencyList
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
            onChanged: (value) => context
                .read<BillFormBloc>()
                .add(FormCurrencyChanged(value as String)),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class _ExchageRateField extends StatelessWidget {
  const _ExchageRateField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillFormBloc, BillFormState>(
      builder: (context, state) {
        if (state is BillFormLoaded) {
          return TextFormField(
            decoration: const InputDecoration(labelText: 'Exchange Rate'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value!.isEmpty ? 'Exchange rate is required' : null,
            onChanged: (value) => context
                .read<BillFormBloc>()
                .add(FormExchangeRateChanged(value)),
            initialValue: state.exchangeRate.toString(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
