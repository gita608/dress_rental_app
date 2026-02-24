import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

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
  
  DateTime? _rentalDate;
  DateTime? _returnDate;

  void _submitBooking() {
    final dressId = ModalRoute.of(context)!.settings.arguments as String;
    
    if (_formKey.currentState!.validate() && _rentalDate != null && _returnDate != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final newBooking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dressId: dressId,
        clientName: _nameController.text,
        clientPhone: _phoneController.text,
        startDate: _rentalDate!,
        endDate: _returnDate!,
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
    } else if (_rentalDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _rentalDate = picked.start;
        _returnDate = picked.end;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bustController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _lengthController.dispose();
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
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: theme.primaryColor),
                      const SizedBox(width: 16),
                      Text(
                        _rentalDate == null
                            ? 'Select Rental Range'
                            : '${_rentalDate!.toString().split(' ')[0]} - ${_returnDate!.toString().split(' ')[0]}',
                        style: TextStyle(
                          color: _rentalDate == null ? Colors.grey.shade600 : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
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
