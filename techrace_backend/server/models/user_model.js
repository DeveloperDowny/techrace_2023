import { async } from "@firebase/util";
import {
  addDoc,
  collection,
  doc,
  getDoc,
  getDocFromServer,
  getDocs,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import ref from "../database/database.js";
import { firestore_db } from "../database/firestore_db.js";
import { WaitingForReg } from "../utils/GameStates.js";
import { updateTeamDataRT } from "./game_model.js";

// const teamRef = ref.child("teams");
const teamRef = ref.child("dummy_teams");

export const saveLastLogoutLoc = async (tid, payload) => {
  await updateTeamDataRT(tid, {
    logout_loc_lat: payload.logout_loc_lat,
    logout_loc_lng: payload.logout_loc_lng,
  });
};

const getRandomId = () => {
  return Math.random().toString().slice(2, 5);
};

const addNewUser = (id) => {
  ref.child("user").child(id).set({
    p1_name: "p1name",
    p2_name: "p1name",
  });
};

export const getRandomRouteId = () => {
  let randomNumber = Math.round(Math.random() * Math.pow(10, 5));
  let r2 = randomNumber % Math.pow(10, 4);
  let finalR = (r2 % 2) + 1; // 1 2 3 is output //only two routes
  // console.log("finalR");
  // console.log(finalR);
  return finalR;
};
// extra info doesn't hurt now
export const addTeamRT = (id, data) => {
  let test = delete data["password"];
  let test2 = delete data["tid"];
  // data.state = WaitingForReg;
  // data.balance = 100;
  // data.prev_clue_solved_timestamp = 0;
  // data.hint_1 = "-999";
  // data.hint_2 = "-999";
  // getRandomId();
  // data.route_id = 1; // ye randomly equally distribute hone chahiye
  // data.route_id = getRandomRouteId(); // ye randomly equally distribute hone chahiye // you just don't need this

  data.logout_loc_lat = "-999";
  data.logout_loc_lng = "-999";

  data.no_guessed_used = 0; // check isko 1 rakhna hai ki two. Aur cannot be used after 9th location

  data.balance = 40; //temp //should be on for production
  // data.balance = 10000; //initial balance ka bhi scene
  data.state = WaitingForReg;

  data.freezed_by = "";
  data.freezed_on = "2020-01-22 14:44:13.520493"; //I think this works
  data.is_freezed = false;

  data.hint_1 = "-999";
  data.hint_2 = "-999";

  data.hint_1_type = "-999";
  data.hint_2_type = "-999";

  data.is_invisible = false;
  data.invisible_on = "2020-01-22 14:44:13.520493"; // new thing. update server

  data.is_meter_off = false;
  data.meter_off_on = "2020-01-22 14:44:13.520493";

  data.prev_clue_solved_timestamp = "2020-01-22 14:44:13.520493";
  data.current_clue_no = 1;
  data.cid = constructCid(data.current_clue_no);

  console.log("test");
  console.log(test);
  teamRef.child(id).set(data);
};

export const addTeamRTv2Temp = async (id, data) => {
  console.log(id);
  console.log(data);
  console.log("data");
  let test = delete data["password"];
  let test2 = delete data["tid"];
  let test3 = delete data["is_logged_in"];
  // data.state = WaitingForReg;
  // data.balance = 100;
  // data.prev_clue_solved_timestamp = 0;
  // data.hint_1 = "-999";
  // data.hint_2 = "-999";
  // getRandomId();
  // data.route_id = 1; // ye randomly equally distribute hone chahiye
  // data.route_id = getRandomRouteId(); // ye randomly equally distribute hone chahiye // you just don't need this

  data.logout_loc_lat = "-999";
  data.logout_loc_lng = "-999";

  data.no_guessed_used = 0; // check isko 1 rakhna hai ki two. Aur cannot be used after 9th location

  data.balance = 40; //temp //should be on for production
  // data.balance = 10000; //initial balance ka bhi scene
  data.state = WaitingForReg;

  data.freezed_by = "";
  data.freezed_on = "2020-01-22 14:44:13.520493"; //I think this works
  data.is_freezed = false;

  data.hint_1 = "-999";
  data.hint_2 = "-999";

  data.hint_1_type = "-999";
  data.hint_2_type = "-999";

  data.is_invisible = false;
  data.invisible_on = "2020-01-22 14:44:13.520493"; // new thing. update server

  data.is_meter_off = false;
  data.meter_off_on = "2020-01-22 14:44:13.520493";

  data.prev_clue_solved_timestamp = "2020-01-22 14:44:13.520493";
  data.current_clue_no = 1;
  data.cid = constructCid(data.current_clue_no);

  console.log("test");
  console.log(test);
  // await ref.child("testing_pytest_v1").child(id).set(data); //use main ref
  await teamRef.child(id).set(data); //use main ref
};

export const addNewUserRT = async (data) => {};

export const addNewUserFirestore = async (data) => {
  try {
    let theS = await getRandomIdAfterCheckingFirestore();
    mAddDocWithCustId(theS, data);
    // throw Error;
    return theS;
  } catch (error) {
    console.log(error);
    return -999;
  }
  return 1;
};

export const addNewUserFirestorev2 = async (tid, data) => {
  try {
    let tempTid = data["tid"];
    delete data["tid"];
    data.is_logged_in = false;
    // let theS = await getRandomIdAfterCheckingFirestore();
    // mAddDocWithCustId(tid, data); //should be on in production
    await mAddDocWithCustIdv2Temp(tid, data);
    // throw Error;
    // return theS;
    data.tid = tempTid;
  } catch (error) {
    console.log(error);
    return -999;
  }
  return 1;
};

let count = 0;
const getRandomIdAfterChecking = async () => {
  let theS = count <= 1 ? 111 : getRandomId();
  let canReturn = false;
  count++;
  try {
    // change this with firestore code.
    ref
      .child("users")
      .equalTo(theS)
      .on("value", async (snapshot) => {
        console.log("checking dup");
        console.log(snapshot.val());
        console.log(snapshot.val() != undefined);
        if (snapshot.val() != undefined) {
          // console.log();
          theS = await getRandomIdAfterChecking();

          console.log(theS);
          console.log("theS in on");
          return theS;
        }
        // else {
        //   return theS;
        // }
      });
    // return theS;
  } catch (error) {
    console.log(error);
  }
  console.log("check this ran or not");
  return "-999";
};

export const createUser = async (data) => {
  let theS = await getRandomIdAfterChecking();
  console.log("createUser");
  console.log(theS);
  console.log(data);

  // .child("user")
  ref.child("users").child(theS).set(data);
  return "done";
};

// export const createUserFirestore = async (data) => {
//   let theS = await getRandomIdAfterChecking();
//   console.log("createUser");
//   console.log(theS);
//   console.log(data);

//   // .child("user")
//   ref.child("users").child(theS).set(data);
//   return "done";
// };

const mAddDoc = async () => {
  let data = await addDoc(collection(firestore_db, "test"), {
    test: "test",
  });
  console.log(data);
};
const mAddDocWithCustId = async (id, data) => {
  // let data = await addDoc(collection(firestore_db, "test"), {
  //   test: "test",
  // });
  // let data = await firestore_db.collection("test").doc("id").set({
  //   name: "Los Angeles",
  //   state: "CA",
  //   country: "USA",
  // });
  // data.password = id; //should not be in production
  let result = await setDoc(doc(firestore_db, "test", id), data);
  console.log(result);
};

const mAddDocWithCustIdv2Temp = async (id, data) => {
  // let data = await addDoc(collection(firestore_db, "test"), {
  //   test: "test",
  // });
  // let data = await firestore_db.collection("test").doc("id").set({
  //   name: "Los Angeles",
  //   state: "CA",
  //   country: "USA",
  // });
  // data.password = id; //should not be in production
  // let result = await setDoc(doc(firestore_db, "test_temp_pytest_v1", id), data);
  let result = await setDoc(doc(firestore_db, "test", id), data); // this is correct
  console.log(result);
};

const mUpdateWithCustId = async () => {
  // let data = await addDoc(collection(firestore_db, "test"), {
  //   test: "test",
  // });
  // let data = await firestore_db.collection("test").doc("id").set({
  //   name: "Los Angeles",
  //   state: "CA",
  //   country: "USA",
  // });
  let data = await updateDoc(doc(firestore_db, "test", "id"), {
    test2: "z fsfdtsdfdest with custom id",
  });
  console.log(data);
};

export const setIsLoggedInFirestore = async (tid, newIsLoggedIn) => {
  let data = await updateDoc(doc(firestore_db, "test", tid), {
    is_logged_in: newIsLoggedIn,
  });
  console.log(data);
};

const mGetDoc = async () => {
  let data = await getDocs(collection(firestore_db, "test"));
  console.log(data);
};

export const searchForTeamIdOnFirestore = async (tid) => {
  let pre = await getDoc(doc(firestore_db, "test", tid));
  if (!pre.exists()) {
    return -999;
  } else {
    console.log(pre.data());
    if (pre.data().is_logged_in) {
      // now update the is_logged_in\
      // console.log(pre.data().is_logged_in);
      return -1;
    }

    // else {
    //   setIsLoggedInFirestore(tid, true);
    // }
    return pre.data();
  }
};

const getRandomIdAfterCheckingFirestore = async () => {
  let theS = getRandomId();
  let pre = await getDoc(doc(firestore_db, "test", theS));
  // pre = pre.data();
  let doesExists = pre.exists();
  while (doesExists) {
    theS = getRandomId();
    console.log(theS);
    pre = await getDoc(doc(firestore_db, "test", theS));
    doesExists = pre.exists();
    console.log(doesExists);
  }

  console.log(theS);
  return theS;
  // if (!doesExists) {
  //   return theS;
  // }
  //  getDocs(collection(firestore_db, "test")).where(
  //   "id",
  //   "==",
  //   theS
  // );

  // try {
  //   // change this with firestore code.
  //   ref
  //     .child("users")
  //     .equalTo(theS)
  //     .on("value", async (snapshot) => {
  //       console.log("checking dup");
  //       console.log(snapshot.val());
  //       console.log(snapshot.val() != undefined);
  //       if (snapshot.val() != undefined) {
  //         // console.log();
  //         theS = await getRandomIdAfterChecking();

  //         console.log(theS);
  //         console.log("theS in on");
  //         return theS;
  //       }
  //       // else {
  //       //   return theS;
  //       // }
  //     });
  //   // return theS;
  // } catch (error) {
  //   console.log(error);
  // }
  console.log("check this ran or not");
  return "-999";
};

export const getStartTimeRT = () =>
  new Promise((resolve, reject) => {
    try {
      ref.child("start_datetime").once("value", (snapShot) => {
        resolve(snapShot.val());
      });
    } catch (err) {
      reject(err);
    }
  });

export const getLogoutLatLng = (tid) =>
  new Promise((resolve, reject) => {
    try {
      ref
        .child("dummy_teams")
        .child(tid)
        .once("value", (snapShot) => {
          console.log(snapShot.val());
          resolve(snapShot.val());
        });
    } catch (err) {
      reject(err);
    }
  });

// export const isOnClue1 = (tid) =>
//   new Promise((resolve, reject) => {
//     try {
//       ref
//         .child("dummy_teams")
//         .child(tid).child("")
//         .once("value", (snapShot) => {
//           console.log(snapShot.val());
//           resolve(snapShot.val());
//         });
//     } catch (err) {
//       reject(err);
//     }
//   });

export const testFunc = async () => {
  // mGetDoc();
  // mAddDocWithCustId();
  // mUpdateWithCustId();
  // getRandomIdAfterCheckingFirestore("111");
  /// Add New User to Firestore DB
  // addNewUserFirestore(await getRandomIdAfterCheckingFirestore(getRandomId()));
  //   const usersRef = ref.child("users");
  //   usersRef
  //     .orderByChild("date_of_birth")
  //     .equalTo("December 9, 1906")
  //     .on("value", (snapshot) => {
  //       console.log(snapshot.key); //imidiate sub hona chahiye
  //       console.log(snapshot.val());
  //       console.log("snapshot.key");
  //     });
  //   // console.log(test);
  //   // usersRef.child("gracehop2").update(
  //   //   {
  //   //     test33: "jjb",
  //   //   },
  //   //   (e) => {
  //   //     console.log(e);
  //   //   }
  //   // );
  //   // ref
  //   //   .push()
  //   //   .set({
  //   //     newTT: "neT",
  //   //   })
  //   //   .then((e) => console.log(e));
  //   //update appends, set inserts and overite
  //   //.child() makes a child node
  //   // usersRef.set({
  //   //   alanisawesome: {
  //   //     date_of_birth: "June 23, 1912",
  //   //     full_name: "Alan Turing",
  //   //   },
  //   //   gracehop: {
  //   //     date_of_birth: "December 9, 1906",
  //   //     full_name: "Grace Hopper",
  //   //   },
  //   //   gracehop2: {
  //   //     test: "t",
  //   //   },
  //   // });
};

//you need cloud firestore for this for storing user data
// agar firestore then how would you manage the use status? // alternative, don't mess with the firestore once uploaded.
// manage game

//

// add middleware later

export const getTestJWT = (data) => {
  const token2 = jwt.sign(data, "test", {
    expiresIn: "9999h",
  });
  console.log(token2);
};

export function constructCid(current_clue_no) {
  return `${current_clue_no}${getRandomRouteId()}`;
}
// rt data will interface with mobile app
//
// cheating
