import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/auth_service.dart';
import '../services/invite_service.dart';
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
  final budgetLimitController = TextEditingController();
  final usernameSearchController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  int currentPage = 0;
  bool loading = false;
  String dateError = '';

  bool get isEditing => widget.tripToEdit != null;

  List<String> memberIds = [];
  List<String> originalMemberIds = [];
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
      originalMemberIds = List<String>.from(trip.memberIds);
    } else {
      originalMemberIds = List<String>.from(memberIds);
    }

    loadUsernames();
  }

  @override
  void dispose() {
    nameController.dispose();
    originController.dispose();
    destinationController.dispose();
    budgetLimitController.dispose();
    usernameSearchController.dispose();
    super.dispose();
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
    final result = await _authService.searchUsers(username.trim());

    if (!mounted) return;

    setState(() {
      foundUsers = result;
    });
  }

  Future<void> loadUsernames() async {
    final map = await _authService.getUsernamesByIds(memberIds);

    if (!mounted) return;

    setState(() {
      userNames = map;
    });
  }

  void addMember(Map<String, dynamic> user) {
    final uid = user['uid'];
    final username = user['username'];

    if (!memberIds.contains(uid)) {
      setState(() {
        memberIds.add(uid);
        userNames[uid] = username;
      });
    }
  }

  void removeMember(String userId) {
    final currentUser = _authService.currentUser;

    if (currentUser != null && userId == currentUser.uid) {
      showMessage('You cannot remove yourself from your own trip');
      return;
    }

    setState(() {
      memberIds.remove(userId);
    });
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
        setState(() => dateError = 'Select both dates');
        return false;
      }

      if (selectedEndDate!.isBefore(selectedStartDate!)) {
        setState(() => dateError = 'End date cannot be before start date');
        return false;
      }

      if (budgetLimitController.text.trim().isEmpty) {
        showMessage('Enter budget limit');
        return false;
      }

      try {
        double.parse(budgetLimitController.text.trim());
      } catch (_) {
        showMessage('Invalid budget');
        return false;
      }
    }

    return true;
  }

  // ---------------- SAVE ----------------
  Future<void> saveTrip() async {
    setState(() => loading = true);

    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        showMessage('No user logged in');
        if (mounted) setState(() => loading = false);
        return;
      }

      final currentUsername = await _authService.getCurrentUsername();

      if (currentUsername == null) {
        showMessage('Could not load current username');
        if (mounted) setState(() => loading = false);
        return;
      }

      final invitedUserIds = memberIds.where((uid) {
        return uid != currentUser.uid && !originalMemberIds.contains(uid);
      }).toList();

      final acceptedMemberIds = memberIds.where((uid) {
        return uid == currentUser.uid || originalMemberIds.contains(uid);
      }).toList();

      final trip = Trip(
        id: isEditing ? widget.tripToEdit!.id : '',
        name: nameController.text.trim(),
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        startDate: selectedStartDate!,
        endDate: selectedEndDate!,
        budgetLimit: double.parse(budgetLimitController.text.trim()),
        memberIds: acceptedMemberIds,
      );

      String? tripId;

      if (isEditing) {
        tripId = trip.id;
        await TripDatabaseHelper().updateTrip(trip.id, trip.toMap());
      } else {
        tripId = await TripDatabaseHelper().addTrip(trip);
      }

      if (tripId == null) {
        showMessage('Trip could not be saved');
        if (mounted) setState(() => loading = false);
        return;
      }

      if (invitedUserIds.isNotEmpty) {
        await InviteService().createTripInvites(
          tripId: tripId,
          tripName: trip.name,
          invitedByUid: currentUser.uid,
          invitedByUsername: currentUsername,
          invitedUserIds: invitedUserIds,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      showMessage('Error: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
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
        const Text(
          'Trip Dates',
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
                      ? 'Start Date'
                      : selectedStartDate.toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => pickDate(false),
                child: Text(
                  selectedEndDate == null
                      ? 'End Date'
                      : selectedEndDate.toString().split(' ')[0],
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
        const Text(
          'Budget',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: budgetLimitController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Limit',
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
            labelText: 'Search users',
            border: OutlineInputBorder(),
          ),
          onChanged: searchUsers,
        ),
        const SizedBox(height: 10),
        const Text(
          'Search Results',
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
        const Text(
          'Selected Members / Invited Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberIds.length,
          itemBuilder: (context, index) {
            final uid = memberIds[index];
            final currentUser = _authService.currentUser;
            final isCurrentUser = currentUser != null && uid == currentUser.uid;
            final isAlreadyMember = originalMemberIds.contains(uid);

            String subtitle = 'Will receive invite';

            if (isCurrentUser) {
              subtitle = 'You';
            } else if (isAlreadyMember) {
              subtitle = 'Already a member';
            }

            return ListTile(
              title: Text(userNames[uid] ?? uid),
              subtitle: Text(subtitle),
              trailing: isCurrentUser
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Add Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              pageTitles[currentPage],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildCurrentPage(),
            const SizedBox(height: 30),
            if (loading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: previousPage,
                    child: Text(currentPage == 0 ? 'Cancel' : 'Back'),
                  ),
                  ElevatedButton(
                    onPressed: nextPage,
                    child: Text(
                      currentPage == pageTitles.length - 1 ? 'Save' : 'Next',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
