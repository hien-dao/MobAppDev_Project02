import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/trip.dart';
import '../models/trip_invite.dart';

import '../services/app_notification_service.dart';
import '../services/auth_service.dart';
import '../services/invite_service.dart';
import '../services/trip_databasehelper.dart';

import 'firstscreen.dart';
import 'addtrip.dart';
import 'activity_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Stream<List<Trip>>? tripStream;
  String? username;

  @override
  void initState() {
    super.initState();
    tripStream = TripDatabaseHelper().getUserTrips();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final name = await AuthService().getCurrentUsername();

    if (!mounted) return;

    setState(() {
      username = name;
    });
  }

  void rebuildTripList() {
    setState(() {
      tripStream = TripDatabaseHelper().getUserTrips();
    });
  }

  Future<void> logoutUser() async {
    await AuthService().signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen()),
    );
  }

  Future<void> openAddTripPage() async {
    final addedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrip(
          rebuildMainScreen: rebuildTripList,
        ),
      ),
    );

    if (addedTrip == true && mounted) {
      rebuildTripList();
    }
  }

  Future<void> openEditTripPage(Trip trip) async {
    final updatedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTrip(
          rebuildMainScreen: rebuildTripList,
          tripToEdit: trip,
        ),
      ),
    );

    if (updatedTrip == true && mounted) {
      rebuildTripList();
    }
  }

  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$month/$day/$year';
  }

  Widget buildAppNotifications() {
    return StreamBuilder<List<AppNotification>>(
      stream: AppNotificationService().getUnreadNotifications(),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(notification.body),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      onPressed: () async {
                        await AppNotificationService()
                            .markAsRead(notification.id);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildPendingInvites() {
    return StreamBuilder<List<TripInvite>>(
      stream: InviteService().getPendingInvitesForCurrentUser(),
      builder: (context, snapshot) {
        final invites = snapshot.data ?? [];

        if (invites.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const Text(
              'Pending Invites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invites.length,
              itemBuilder: (context, index) {
                final invite = invites[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(invite.tripName),
                    subtitle: Text(
                      '${invite.invitedByUsername} invited you to this trip',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            try {
                              await InviteService().acceptInvite(invite);

                              rebuildTripList();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You accepted the request'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error accepting request: $e'),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            try {
                              await InviteService().declineInvite(invite);

                              rebuildTripList();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You declined the request'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error declining request: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildTripList() {
    return Expanded(
      child: StreamBuilder<List<Trip>>(
        stream: tripStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No trips yet!'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final trip = items[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityScreen(trip: trip),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      trip.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${trip.origin} to ${trip.destination}\n'
                      '${formatDate(trip.startDate)} - ${formatDate(trip.endDate)}\n'
                      'Budget Limit: \$${trip.budgetLimit.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            openEditTripPage(trip);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await TripDatabaseHelper().deleteTrip(trip.id);
                            rebuildTripList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${username ?? 'User'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutUser,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTripPage,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Home Page',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          buildAppNotifications(),
          buildPendingInvites(),
          buildTripList(),
        ],
      ),
    );
  }
}