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

exports.sendTripInviteResponseNotification = functions.firestore
  .document("tripInvites/{inviteId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const wasPending = before.status === "pending";
    const isAccepted = after.status === "accepted";
    const isDeclined = after.status === "declined";

    if (!wasPending || (!isAccepted && !isDeclined)) {
      console.log("Invite was updated, but not accepted or declined");
      return null;
    }

    const originatorUid = after.invitedByUid;

    const invitedUserDoc = await admin
      .firestore()
      .collection("users")
      .doc(after.invitedUid)
      .get();

    let responderName = "Someone";

    if (invitedUserDoc.exists) {
      const invitedUserData = invitedUserDoc.data();

      responderName =
        invitedUserData.username ||
        invitedUserData.firstName ||
        invitedUserData.firstname ||
        "Someone";
    }

    const originatorDoc = await admin
      .firestore()
      .collection("users")
      .doc(originatorUid)
      .get();

    if (!originatorDoc.exists) {
      console.log("Originator user not found");
      return null;
    }

    const originatorData = originatorDoc.data();
    const fcmToken = originatorData.fcmToken;

    const bodyText = isAccepted
      ? `${responderName} accepted your request.`
      : `${responderName} did not accept your request.`;

    await admin
      .firestore()
      .collection("users")
      .doc(originatorUid)
      .collection("notifications")
      .add({
        title: "Invite Response",
        body: bodyText,
        type: isAccepted
          ? "trip_invite_accepted"
          : "trip_invite_declined",
        tripId: after.tripId,
        inviteId: context.params.inviteId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    if (!fcmToken) {
      console.log(
        "Originator has no FCM token, but notification document was created"
      );
      return null;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "Invite Response",
        body: bodyText,
      },
      data: {
        type: isAccepted
          ? "trip_invite_accepted"
          : "trip_invite_declined",
        inviteId: context.params.inviteId,
        tripId: after.tripId,
      },
    };

    await admin.messaging().send(message);

    console.log("Trip invite response notification sent to originator");
    return null;
  });
