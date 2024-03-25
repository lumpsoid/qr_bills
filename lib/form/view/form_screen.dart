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
            FormBloc(billRepository: context.read<BillRepository>())
              ..add(const FormInit()),
        child: const FormPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormBloc, FormBlocState>(
      listenWhen: (previous, current) {
        return previous is FormLoading && current is FormSuccess;
      },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Form'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NameField(),
              _TagField(),
              _DatePickField(),
              _PriceField(),
              _CurrencyField(),
              _ExchageRateField(),
              _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<FormBloc>().add(const FormBillAdd());

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

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Name'),
      validator: (value) => value!.isEmpty ? 'Name is required' : null,
      onChanged: (value) =>
          context.read<FormBloc>().add(FormNameChanged(value)),
      initialValue: '',
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
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Tags'),
      onChanged: (value) =>
          context.read<FormBloc>().add(FormTagsChanged(value)),
      initialValue: '',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-z,]')),
      ],
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
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              context.read<FormBloc>().add(FormDateChanged(pickedDate));
            }
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
      onSaved: (value) =>
          context.read<FormBloc>().add(FormPriceChanged(double.parse(value!))),
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
    return BlocBuilder<FormBloc, FormBlocState>(
      builder: (context, state) {
        if (state is FormLoaded) {
          return DropdownButtonFormField(
            value: state.currency,
            items: state.currencyList
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
            onChanged: (value) => context
                .read<FormBloc>()
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
    return BlocBuilder<FormBloc, FormBlocState>(
      builder: (context, state) {
        if (state is FormLoaded) {
          return TextFormField(
            decoration: const InputDecoration(labelText: 'Exchange Rate'),
            keyboardType: TextInputType.number,
            onChanged: (value) => context
                .read<FormBloc>()
                .add(FormPriceChanged(double.parse(value))),
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
