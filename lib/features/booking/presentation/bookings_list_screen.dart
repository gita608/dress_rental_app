import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String _selectedFilter = 'All';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final List<String> _filters = ['All', 'Today', 'Tomorrow', 'This Week'];

  bool _matchesFilter(DateTime startDate, DateTime endDate, String filter) {
    if (filter == 'All') return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - today.weekday)); // Roughly end of current week

    // Check if the rental period overlaps with the filter period
    switch (filter) {
      case 'Today':
        return (startDate.isBefore(today.add(const Duration(days: 1))) || startDate.isAtSameMomentAs(today)) && 
               (endDate.isAfter(today) || endDate.isAtSameMomentAs(today));
      case 'Tomorrow':
        return (startDate.isBefore(tomorrow.add(const Duration(days: 1))) || startDate.isAtSameMomentAs(tomorrow)) && 
               (endDate.isAfter(tomorrow) || endDate.isAtSameMomentAs(tomorrow));
      case 'This Week':
         return startDate.isBefore(endOfWeek.add(const Duration(days: 1))) && endDate.isAfter(today);
      case 'Custom':
        if (_customStartDate == null || _customEndDate == null) return true;
        return (startDate.isBefore(_customEndDate!.add(const Duration(days: 1)))) && 
               (endDate.isAfter(_customStartDate!.subtract(const Duration(days: 1))));
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final allBookings = provider.bookings;

    // Apply the filter
    final filteredBookings = allBookings.where((booking) {
      return _matchesFilter(booking.startDate, booking.endDate, _selectedFilter);
    }).toList();

    // Sort by start date (closest first)
    filteredBookings.sort((a, b) => a.startDate.compareTo(b.startDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () => _showCustomDateInputDialog(context),
            tooltip: 'Custom Range',
          ),
          if (_selectedFilter == 'Custom')
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _customStartDate = null;
                  _customEndDate = null;
                });
              },
              tooltip: 'Clear Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: theme.colorScheme.onPrimary,
                    shape: const ContinuousRectangleBorder(),
                    side: BorderSide(
                      color: _selectedFilter == filter 
                          ? Colors.transparent 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Text(
                      allBookings.isEmpty ? 'No bookings yet.' : 'No bookings found for $_selectedFilter.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final dress = provider.dresses.firstWhere((d) => d.id == booking.dressId,
                          orElse: () => Dress(id: '', name: 'Unknown Dress', price: 0, description: '', sizes: []));
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showStatusUpdateSheet(context, provider, booking),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Booking #${booking.id.length > 4 ? booking.id.substring(booking.id.length - 4) : booking.id}',
                                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                                    ),
                                    _buildStatusBadge(booking.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Client: ${booking.clientName}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.checkroom_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Item: ${dress.name}'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Rental Period:', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      '${booking.startDate.toString().split(' ')[0]} - ${booking.endDate.toString().split(' ')[0]}',
                                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context, AppProvider provider, Booking booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Match EVOCA sharp edges theme
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Booking Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _statusOption(context, provider, booking, 'Pending', BookingStatus.pending, Colors.orange),
              _statusOption(context, provider, booking, 'Ready for Pickup', BookingStatus.ready, Colors.blue),
              _statusOption(context, provider, booking, 'Out for Rental', BookingStatus.active, Colors.green),
              _statusOption(context, provider, booking, 'Returned/Completed', BookingStatus.completed, Colors.grey),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _statusOption(BuildContext context, AppProvider provider, Booking booking, String label, BookingStatus status, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(Icons.circle, color: color, size: 12)),
      title: Text(label),
      onTap: () {
        provider.updateBookingStatus(booking.id, status);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to: $label')),
        );
      },
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case BookingStatus.ready:
        color = Colors.blue;
        label = 'Ready';
        break;
      case BookingStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case BookingStatus.completed:
        color = Colors.grey;
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(0), // Sharp edges
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _showCustomDateInputDialog(BuildContext context) {
    DateTime tempStart = _customStartDate ?? DateTime.now();
    DateTime tempEnd = _customEndDate ?? tempStart.add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: const Text('Custom Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(tempStart.toString().split(' ')[0], style: TextStyle(color: theme.colorScheme.primary)),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () {
                      _showWheelPicker(context, tempStart, (date) {
                        setDialogState(() => tempStart = date);
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(tempEnd.toString().split(' ')[0], style: TextStyle(color: theme.colorScheme.primary)),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () {
                      _showWheelPicker(context, tempEnd, (date) {
                        setDialogState(() => tempEnd = date);
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tempEnd.isBefore(tempStart)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('End date cannot be before start date')),
                      );
                      return;
                    }
                    setState(() {
                      _customStartDate = tempStart;
                      _customEndDate = tempEnd;
                      _selectedFilter = 'Custom';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('APPLY'),
                ),
              ],
            );
          },
        );
      },
    );
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
}
