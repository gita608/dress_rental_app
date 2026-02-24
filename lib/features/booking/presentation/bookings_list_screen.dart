import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/models.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final bookings = provider.bookings;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Bookings'),
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
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
                                'Booking #${booking.id.substring(booking.id.length - 4)}',
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
                          const SizedBox(height: 4),
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
    );
  }

  void _showStatusUpdateSheet(BuildContext context, AppProvider provider, Booking booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
