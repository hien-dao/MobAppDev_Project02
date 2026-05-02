import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/trip_databasehelper.dart';

class AddTrip extends StatefulWidget {
  final VoidCallback rebuildMainScreen;
  final Trip? tripToEdit;

  const AddTrip({
    super.key,
    required this.rebuildMainScreen,
    this.tripToEdit,
  });

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final nameController = TextEditingController();
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final totalCostController = TextEditingController();

  int currentPage = 0;
  bool loading = false;
  String dateError = '';

  bool get isEditing => widget.tripToEdit != null;

  final List<String> pageTitles = [
    'Trip Info',
    'Trip Dates',
    'Trip Cost',
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final trip = widget.tripToEdit!;

      nameController.text = trip.name;
      originController.text = trip.origin;
      destinationController.text = trip.destination;
      startDateController.text = formatDateForInput(trip.startDate);
      endDateController.text = formatDateForInput(trip.endDate);
      totalCostController.text = trip.totalCost.toString();
    }
  }

  String formatDateForInput(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void nextPage() {
    if (!validateCurrentPage()) return;

    if (currentPage < pageTitles.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      saveTrip();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    } else {
      cancelTrip();
    }
  }

  void cancelTrip() {
    Navigator.pop(context, false);
  }

  bool isRealDate(String value) {
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!datePattern.hasMatch(value)) {
      return false;
    }

    try {
      final parts = value.split('-');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      return date.year == year &&
          date.month == month &&
          date.day == day;
    } catch (e) {
      return false;
    }
  }

  bool validateCurrentPage() {
    if (currentPage == 0) {
      if (nameController.text.trim().isEmpty ||
          originController.text.trim().isEmpty ||
          destinationController.text.trim().isEmpty) {
        showMessage('Fill out your trip info');
        return false;
      }
    }

    if (currentPage == 1) {
      final startText = startDateController.text.trim();
      final endText = endDateController.text.trim();

      setState(() {
        dateError = '';
      });

      if (startText.isEmpty || endText.isEmpty) {
        setState(() {
          dateError = 'Please fill out both dates';
        });
        return false;
      }

      if (!isRealDate(startText) || !isRealDate(endText)) {
        setState(() {
          dateError = 'That is not a valid date';
        });
        return false;
      }

      final startDate = DateTime.parse(startText);
      final endDate = DateTime.parse(endText);

      if (endDate.isBefore(startDate)) {
        setState(() {
          dateError = 'End date cannot be before start date';
        });
        return false;
      }
    }

    if (currentPage == 2) {
      if (totalCostController.text.trim().isEmpty) {
        showMessage('Please enter the total cost');
        return false;
      }

      try {
        double.parse(totalCostController.text.trim());
      } catch (e) {
        showMessage('Use a cost like 150.00');
        return false;
      }
    }

    return true;
  }

  Future<void> saveTrip() async {
    setState(() {
      loading = true;
    });

    try {
      final trip = Trip(
        id: isEditing ? widget.tripToEdit!.id : '',
        name: nameController.text.trim(),
        startDate: DateTime.parse(startDateController.text.trim()),
        endDate: DateTime.parse(endDateController.text.trim()),
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        totalCost: double.parse(totalCostController.text.trim()),
      );

      if (isEditing) {
        await TripDatabasehelper().updateTrip(
          trip.id,
          trip.toMap(),
        );
      } else {
        await TripDatabasehelper().addTrip(
          trip.toMap(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
      return;
    } catch (e) {
      if (!mounted) return;

      showMessage(
        isEditing
            ? 'Error updating trip: $e'
            : 'Error adding trip: $e',
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildCurrentPage() {
    List<Widget> pages = [];

    for (int i = 0; i < pageTitles.length; i++) {
      if (i == 0) {
        pages.add(buildTripInfoPage());
      } else if (i == 1) {
        pages.add(buildTripDatesPage());
      } else if (i == 2) {
        pages.add(buildTripCostPage());
      }
    }

    return pages[currentPage];
  }

  Widget buildTripInfoPage() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Trip Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: originController,
          decoration: const InputDecoration(
            labelText: 'Origin',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: destinationController,
          decoration: const InputDecoration(
            labelText: 'Destination',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget buildTripDatesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: startDateController,
          decoration: const InputDecoration(
            labelText: 'Start Date',
            hintText: 'YYYY-MM-DD',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: endDateController,
          decoration: const InputDecoration(
            labelText: 'End Date',
            hintText: 'YYYY-MM-DD',
            border: OutlineInputBorder(),
          ),
        ),
        if (dateError.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            dateError,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildTripCostPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: totalCostController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Cost',
            hintText: 'Example: 150.00',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Review',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text('Trip Name: ${nameController.text}'),
        Text('Origin: ${originController.text}'),
        Text('Destination: ${destinationController.text}'),
        Text('Start Date: ${startDateController.text}'),
        Text('End Date: ${endDateController.text}'),
        Text('Total Cost: \$${totalCostController.text}'),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    originController.dispose();
    destinationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (currentPage + 1) / pageTitles.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          cancelTrip();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            isEditing
                ? 'Edit ${pageTitles[currentPage]}'
                : pageTitles[currentPage],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: previousPage,
          ),
          actions: [
            TextButton(
              onPressed: cancelTrip,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: buildCurrentPage(),
                ),
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousPage,
                      child: Text(
                        currentPage == 0 ? 'Cancel' : 'Back',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading ? null : nextPage,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              currentPage == pageTitles.length - 1
                                  ? isEditing
                                      ? 'Save Changes'
                                      : 'Add Trip'
                                  : 'Next',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}