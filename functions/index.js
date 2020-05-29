
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

exports.requestReceived = functions.database.ref('/requests/')
    .onCreate(async (snapshot, context) => {
      // Grab the current value of what was written to the Realtime Database.
      const original = snapshot.val();

    console.log("CONTEXT:",context,"\n","ORIGINAL:",original,"\n", "SNAPSHOT", snapshot)

          // Notification details.
      const payload = {
        notification: {
          title: 'You have a new request!',
          body: `____ wants to join your lobby.`
        }
      };


    //get token and replace tokens
    console.log();

     // Listing all tokens as an array.
    const userPromise = admin.auth().getUser(Object.keys(original)[0]);
const results = await Promise.all([userPromise])
      // Send notifications to all tokens.

      console.log("\n RESULTS:", results)
      console.log("Message IS SENDING ____________________________");
    const response = await admin.messaging().sendToDevice("APA91bFvstvtKzNB_uZIxrIYyVS1ebliw1MlmsYsAj6y3lBGKSG1QQu44AXsJPPYX1bb3COjG4H_N72VFM_UGgkG9qDJFwHImHpTzLrnk3IOyAQ7k8_E9V6IboPg8WPjSBkG6cdB5QtT", payload);
    console.log("RESPONSE:",response.results)

  //   const response = await admin.messaging().sendToDevice(userPromise, payload);
  // // admin.messaging().sendToDevice(userPromise, payload);
  // //     const response = await
  //     // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', result, error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
          console.log()
          }
        }
      });
      return userPromise;
//    return Promise.all
      // You must return a Promise when performing asynchronous tasks inside a Functions such as
      // writing to the Firebase Realtime Database.
      // Setting an "uppercase" sibling in the Realtime Database returns a Promise.

    });
