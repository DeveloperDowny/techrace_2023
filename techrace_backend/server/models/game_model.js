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
import AES from "crypto-js/aes.js";
import dotenv from "dotenv";
import CryptoJS from "crypto-js";

dotenv.config();

const _clues = ["c1", "c2", "c3", "c3", "c5", "c6"];

// const teamRef = ref.child("teams");
const teamRef = ref.child("dummy_teams");

const clueRef = ref.child("clues");

export const updateTimeRT = (payload) => {
  console.log(new Date("2023-01-10T21:00:00.000+05:30").toISOString());
  const myDate = new Date("2023-01-10T23:00:00.000+05:30");
  const milis = myDate.getTime();
  console.log(milis);
  // return milis

  // console.log();
};

export const addClueFirestore = (payload) => {
  console.log(payload);
  console.log("payload");

  // // setDoc(doc(firestore_db, "test", id), data);
  // let test2 = AES.encrypt("payload.clue", process.env.passphrase).toString();
  // let test = AES.decrypt(
  //   "U2FsdGVkX180q8dq4BttHPWaId2KBOs7TteeTgMo91k=",
  //   process.env.passphrase
  // ).toString();
  // console.log(test);
  // console.log("test");

  //temp turning off encryption

  //temp
  // setDoc(doc(firestore_db, "clues", payload.cid), payload);
  setDoc(doc(firestore_db, "dummy_clues", payload.cid), payload);
  return;
  //temp ends
  setDoc(doc(firestore_db, "clues", payload.cid), {
    clue: AES.encrypt(payload.clue, process.env.passphrase).toString(),
    hint_1: AES.encrypt(payload.hint_1, process.env.passphrase).toString(),
    hint_2: AES.encrypt(payload.hint_2, process.env.passphrase).toString(),
    lat: AES.encrypt(payload.lat, process.env.passphrase).toString(),
    long: AES.encrypt(payload.long, process.env.passphrase).toString(),
  });
  // clueRef.child(payload.cid).set();
};
// b1. updatepoints
export const updatePoints = () => {};

// ref.once("value", function (snapshot) {
//   console.log(snapshot.val());
// });

// const getTeamDataRT = (tid) => {
//   teamRef.child(tid).once("value", function (snapshot) {
//     console.log(snapshot.val());
//     let data = snapshot.val();
//     return
//   });
// }

export const fetchTeamDataRT = (tid) =>
  new Promise((resolve, reject) => {
    try {
      teamRef.child(tid).once("value", (snapShot) => {
        resolve(snapShot.val());
      });
    } catch (err) {
      reject(err);
    }
  });

const getDecrypted = (encryptedString) => {
  return encryptedString; //temp
  // return AES.decrypt(encryptedString, process.env.passphrase).toString();
  return AES.decrypt(encryptedString, process.env.passphrase).toString(
    CryptoJS.enc.Utf8
  );
};

export const getClueFirestore = async (cid, forInit) => {
  console.log(cid);
  console.log("cid");
  // temp dummy clues
  // const clueData = await getDoc(doc(firestore_db, "clues", cid)); // error here
  const clueData = await getDoc(doc(firestore_db, "dummy_clues", cid)); // error here
  // console.log(clueData);
  const encryptData = clueData.data();
  let decryptData = {};
  //temp

  if (forInit) {
    // delete encryptData[""]
    delete encryptData["hint_1"];
    delete encryptData["hint_1_type"];
    delete encryptData["hint_2"];
    delete encryptData["hint_2_type"];
  }

  console.log("encryptData");
  console.log(encryptData);
  return encryptData; //temp /test

  decryptData.clue = getDecrypted(encryptData.clue);
  if (!forInit) {
    decryptData.hint_1 = getDecrypted(encryptData.hint_1);
    decryptData.hint_1 = getDecrypted(encryptData.hint_1_type);
    decryptData.hint_2 = getDecrypted(encryptData.hint_2);
    decryptData.hint_2 = getDecrypted(encryptData.hint_2_type);
  }

  decryptData.lat = getDecrypted(encryptData.lat);
  decryptData.long = getDecrypted(encryptData.long);

  return decryptData;
};

export const setIsFreezedRT = async (tid, isFreezed) => {
  updateTeamDataRT(tid, {
    is_freezed: isFreezed,
  });
};

export const updateTeamDataRT = async (tid, payload) => {
  // console.log(tid);
  // console.log(payload);
  await teamRef.child(tid).update(payload, (e) => {
    // console.log(e);
  });
};

export const updateStateRT = async (id, newState) => {
  await teamRef.child(id).update(
    {
      state: newState,
    },
    (e) => {
      console.log(e);
    }
  );
};
