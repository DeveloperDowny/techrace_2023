// // Import the functions you need from the SDKs you need
import admin from "firebase-admin";
import firebaseConfig from "../env/mfirebase_config.js";
// // TODO: Add SDKs for Firebase products that you want to use
// // https://firebase.google.com/docs/web/setup#available-libraries

// // Your web app's Firebase configuration
// // For Firebase JS SDK v7.20.0 and later, measurementId is optional

// // Initialize Firebase
// admin.initializeApp(firebaseConfig);
// // const analytics = getAnalytics(app);

// // Import Admin SDK
// import { getDatabase } from "firebase-admin/database";

// // Get a database reference to our blog
// const db = getDatabase();
// const ref = db.ref("server/saving-data/fireblog");

// export default ref;

// var admin = require("firebase-admin");

// Fetch the service account key JSON file contents
// var serviceAccount = require("path/to/serviceAccountKey.json");
import serviceAccount from "../env/serviceAccountKey.js";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // databaseURL: "https://dummy-default-rtdb.firebaseio.com",
  // databaseURL: "https://gamedb-d5462.firebaseio.com/",
  databaseURL: "https://dummy-default-rtdb.firebaseio.com/",
});

// // Initialize the app with a service account, granting admin privileges
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   // The database URL depends on the location of the database
//   databaseURL: "https://dummy-default-rtdb.firebaseio.com",
// });

// As an admin, the app has access to read and write all data, regardless of Security Rules
var db = admin.database();
// var ref = db.ref("restricted_access/secret_document");
var ref = db.ref("/");
// ref.once("value", function (snapshot) {
//   console.log(snapshot.val());
// });

export default ref;
