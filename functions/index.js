const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendTripInviteNotification = functions.firestore
  .document("tripInvites/{inviteId}")
  .onCreate(async (snap, context) => {
    const invite = snap.data();

    const invitedUid = invite.invitedUid;
    const tripName = invite.tripName;
    const invitedByUsername = invite.invitedByUsername;

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(invitedUid)
      .get();

    if (!userDoc.exists) {
      console.log("Invited user not found");
      return null;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log("Invited user has no FCM token");
      return null;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "Vacation Invite",
        body: `${invitedByUsername} invited you to ${tripName}`,
      },
      data: {
        type: "trip_invite",
        inviteId: context.params.inviteId,
        tripId: invite.tripId,
      },
    };

    await admin.messaging().send(message);

    console.log("Trip invite notification sent");
    return null;
  });
