import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/date_formatter.dart';

class MeasurementFormScreen extends StatefulWidget {
  const MeasurementFormScreen({super.key});

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Client Details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Measurements
  final _bustController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _lengthController = TextEditingController();
  
  // Rental Dates
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  void _submitBooking() {
    final dressId = ModalRoute.of(context)!.settings.arguments as String;
    
    if (_formKey.currentState!.validate()) {
      try {
        final startDate = DateTime.parse(_startDateController.text);
        final endDate = DateTime.parse(_endDateController.text);
        
        final provider = Provider.of<AppProvider>(context, listen: false);
        
        final newBooking = Booking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dressId: dressId,
          clientName: _nameController.text,
          clientPhone: _phoneController.text,
          startDate: startDate,
          endDate: endDate,
          measurements: {
            'bust': double.parse(_bustController.text),
            'waist': double.parse(_waistController.text),
            'hips': double.parse(_hipsController.text),
            'length': double.parse(_lengthController.text),
          },
        );
        
        provider.addBooking(newBooking);
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: const Text('The dress has been successfully booked for the client.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.popUntil(context, ModalRoute.withName('/')); // Return to home
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD')),
        );
      }
    }
  }

  void _showWheelPicker(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDateChanged) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('DONE'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: initialDate,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: onDateChanged,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bustController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _lengthController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book & Add Measurements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Client Details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Client Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              
              const SizedBox(height: 32),
              Text('Rental Dates', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () {
                        final currentVal = _startDateController.text;
                        final initial = currentVal.isNotEmpty ? DateTime.parse(currentVal) : DateTime.now();
                        _showWheelPicker(context, initial, (date) {
                          setState(() {
                            _startDateController.text = AppDateFormatter.formatDate(date);
                          });
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Start (YYYY-MM-DD)',
                        prefixIcon: Icon(Icons.start_outlined),
                        hintText: 'Select Date',
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () {
                        final currentVal = _endDateController.text;
                        final initial = currentVal.isNotEmpty ? DateTime.parse(currentVal) : DateTime.now().add(const Duration(days: 3));
                        _showWheelPicker(context, initial, (date) {
                          setState(() {
                            _endDateController.text = AppDateFormatter.formatDate(date);
                          });
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'End (YYYY-MM-DD)',
                        prefixIcon: Icon(Icons.event_available_outlined),
                        hintText: 'Select Date',
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Measurements (in inches)', style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Measurement Guide',
                    onPressed: () {
                      // Show measurement guide
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bustController,
                      decoration: const InputDecoration(labelText: 'Bust'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      decoration: const InputDecoration(labelText: 'Waist'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hipsController,
                      decoration: const InputDecoration(labelText: 'Hips'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(labelText: 'Length'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
