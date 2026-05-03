import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/trip_databasehelper.dart';
import '../services/auth_service.dart';

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
  final budgetLimitController = TextEditingController();
  final usernameSearchController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  int currentPage = 0;
  bool loading = false;
  String dateError = '';

  bool get isEditing => widget.tripToEdit != null;

  List<String> memberIds = [];
  List<Map<String, dynamic>> foundUsers = [];
  Map<String, String> userNames = {};

  final AuthService _authService = AuthService();

  final List<String> pageTitles = [
    'Trip Info',
    'Schedule & Budget',
    'Invite Members',
  ];

  @override
  void initState() {
    super.initState();

    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      memberIds.add(currentUser.uid);
    }

    if (isEditing) {
      final trip = widget.tripToEdit!;
      nameController.text = trip.name;
      originController.text = trip.origin;
      destinationController.text = trip.destination;
      budgetLimitController.text = trip.budgetLimit.toString();

      selectedStartDate = trip.startDate;
      selectedEndDate = trip.endDate;
      memberIds = List<String>.from(trip.memberIds);
    }

    loadUsernames();
  }

  // ---------------- DATE PICKER ----------------
  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }

  // ---------------- USER SEARCH ----------------
  Future<void> searchUsers(String username) async {
    final result = await _authService.searchUsers(username);

    setState(() {
      foundUsers = result;
    });
  }

  Future<void> loadUsernames() async {
    final map = await _authService.getUsernamesByIds(memberIds);

    setState(() {
      userNames = map;
    });
  }

  void addMember(Map<String, dynamic> user) {
    final uid = user['uid'];

    if (!memberIds.contains(uid)) {
      setState(() {
        memberIds.add(uid);
        userNames[uid] = user['username'];
      });
    }
  }
  void removeMember(String userId) {
    setState(() => memberIds.remove(userId));
  }

  // ---------------- VALIDATION ----------------
  bool validateCurrentPage() {
    if (currentPage == 0) {
      if (nameController.text.trim().isEmpty ||
          destinationController.text.trim().isEmpty) {
        showMessage('Fill out required trip info');
        return false;
      }
    }

    if (currentPage == 1) {
      if (selectedStartDate == null || selectedEndDate == null) {
        setState(() => dateError = "Select both dates");
        return false;
      }

      if (selectedEndDate!.isBefore(selectedStartDate!)) {
        setState(() => dateError = "End date cannot be before start date");
        return false;
      }

      if (budgetLimitController.text.trim().isEmpty) {
        showMessage("Enter budget limit");
        return false;
      }

      try {
        double.parse(budgetLimitController.text.trim());
      } catch (_) {
        showMessage("Invalid budget");
        return false;
      }
    }

    return true;
  }

  // ---------------- SAVE ----------------
  Future<void> saveTrip() async {
    setState(() => loading = true);

    try {
      final trip = Trip(
        id: isEditing ? widget.tripToEdit!.id : '',
        name: nameController.text.trim(),
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        startDate: selectedStartDate!,
        endDate: selectedEndDate!,
        budgetLimit: double.parse(budgetLimitController.text.trim()),
        memberIds: memberIds,
      );

      if (isEditing) {
        await TripDatabaseHelper().updateTrip(trip.id, trip.toMap());
      } else {
        await TripDatabaseHelper().addTrip(trip);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      showMessage("Error: $e");
    }

    setState(() => loading = false);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- NAVIGATION ----------------
  void nextPage() {
    if (!validateCurrentPage()) return;

    if (currentPage < pageTitles.length - 1) {
      setState(() => currentPage++);
    } else {
      saveTrip();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    } else {
      Navigator.pop(context, false);
    }
  }

  // ---------------- UI PAGES ----------------
  Widget buildCurrentPage() {
    if (currentPage == 0) return buildTripInfoPage();
    if (currentPage == 1) return buildScheduleBudgetPage();
    return buildInvitePage();
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
        const SizedBox(height: 20),

        TextField(
          controller: originController,
          decoration: const InputDecoration(
            labelText: 'Origin',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

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

  Widget buildScheduleBudgetPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ---------------- DATE PICKERS ----------------
        const Text(
          "Trip Dates",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => pickDate(true),
                child: Text(
                  selectedStartDate == null
                      ? "Start Date"
                      : selectedStartDate.toString().split(" ")[0],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => pickDate(false),
                child: Text(
                  selectedEndDate == null
                      ? "End Date"
                      : selectedEndDate.toString().split(" ")[0],
                ),
              ),
            ),
          ],
        ),

        if (dateError.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            dateError,
            style: const TextStyle(color: Colors.red),
          ),
        ],

        const SizedBox(height: 30),

        // ---------------- BUDGET ----------------
        const Text(
          "Budget",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: budgetLimitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Budget Limit",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget buildInvitePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: usernameSearchController,
          decoration: const InputDecoration(
            labelText: "Search users",
            border: OutlineInputBorder(),
          ),
          onChanged: searchUsers,
        ),

        const SizedBox(height: 10),

        // ---------------- SEARCH RESULTS ----------------
        const Text(
          "Search Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: foundUsers.length,
          itemBuilder: (context, index) {
            final user = foundUsers[index];

            return ListTile(
              title: Text(user['username']),
              subtitle: Text(user['email']),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => addMember(user),
              ),
            );
          },
        ),

        const Divider(height: 30),

        // ---------------- SELECTED MEMBERS ----------------
        const Text(
          "Selected Members",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true, // 🔥 FIX
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberIds.length,
          itemBuilder: (context, index) {
            final uid = memberIds[index];

            return ListTile(
              title: Text(userNames[uid] ?? uid),
              trailing: IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => removeMember(uid),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / pageTitles.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentPage]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: buildCurrentPage())),

            LinearProgressIndicator(value: progress),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: previousPage,
                    child: Text(currentPage == 0 ? "Cancel" : "Back"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : nextPage,
                    child: Text(currentPage == 2 ? "Save" : "Next"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}