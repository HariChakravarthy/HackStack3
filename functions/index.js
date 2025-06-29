/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Function to notify a user when they get a new follower
exports.sendFollowNotification = functions.firestore
    .document("users/{userId}/followers/{followerId}")
    .onCreate(async (snap, context) => {
      const {userId, followerId} = context.params;

      const userRef = admin.firestore().collection("users").doc(userId);
      const followerRef = admin.firestore().collection("users").doc(followerId);

      const [userDoc, followerDoc] = await Promise.all([userRef.get(), followerRef.get()]);

      if (!userDoc.exists || !followerDoc.exists) return null;

      const fcmToken = userDoc.data().fcmToken; // Ensure this is stored in your users collection
      const followerName = followerDoc.data().username || "Someone";

      if (!fcmToken) {
        console.log(`No FCM token for user: ${userId}`);
        return null;
      }

      const message = {
        notification: {
          title: "New Follower!",
          body: `${followerName} started following you.`,
        },
        token: fcmToken,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notification sent to:", userId);
      } catch (error) {
        console.error("Error sending notification:", error);
      }

      return null;
    });
