import { async } from "@firebase/util";
import {
  addDoc,
  collection,
  doc,
  Firestore,
  getDoc,
  getDocFromServer,
  getDocs,
  setDoc,
  updateDoc,
  writeBatch,
  WriteBatch,
} from "firebase/firestore";
import ref from "../database/database.js";
import { firestore_db } from "../database/firestore_db.js";
import AES from "crypto-js/aes.js";
import dotenv from "dotenv";
import CryptoJS from "crypto-js";
import { WaitingForGameStart, Playing } from "../utils/GameStates.js";
import {
  freezeDuration,
  futureUndo,
  invisibilityDuration,
  meterOffDuration,
} from "../controllers/game.js";

dotenv.config();

const _clues = ["c1", "c2", "c3", "c3", "c5", "c6"];

// const teamRef = ref.child("teams");
const teamRef = ref.child("dummy_teams");

const clueRef = ref.child("clues");
// const startTimeRef = ref.child("start_datetime");

export const updateTimeRT = (payload) => {
  ref.update({ start_datetime: payload.new_start_datetime });
};

export const setEveryOnePlayingRT = (newState) => {
  teamRef.once("value").then((snapshot) => {
    let updates = {};
    snapshot.forEach((teamSnapshot) => {
      //
      if (teamSnapshot.val().state == WaitingForGameStart) {
        //only in the case when team is on WaitingForGameStart, change to playing
        // updates[teamSnapshot.key + "/state"] = newState;
        updates[teamSnapshot.key + "/state"] = Playing;
      }
    });
    return teamRef.update(updates);
  });
};

const nowMinusOn = (on_wala_timestamp) => {
  const diff = moment().diff(on_wala_timestamp, "seconds");
  console.log(diff);
  return diff;
};

export const resetFutureUndosRT = async () => {
  await teamRef.once("value").then((snapshot) => {
    let updates = {};
    snapshot.forEach((teamSnapshot) => {
      //undo kis kiska karna hai?
      //freezed_on
      //sab on wale ka karna hai
      const data = teamSnapshot.val();

      console.log("72 data");
      console.log(data);
      console.log("teamSnapshot.key");
      console.log(teamSnapshot.key);

      if (nowMinusOn(data.freezed_on) > freezeDuration) {
        if (data.is_freezed) {
          console.log("74");
          updates[teamSnapshot.key + "/is_freezed"] = false;
        } else {
          console.log("78");
          //nowminus is less than freezedDuration
          const timeLeftForFreezeReversal =
            freezeDuration - nowMinusOn(data.freezed_on);
          futureUndo(
            teamSnapshot.key,
            {
              is_freezed: false,
            },
            timeLeftForFreezeReversal * 1000
          );
        }
      }

      if (nowMinusOn(data.meter_off_on) > meterOffDuration) {
        if (data.is_meter_off) {
          console.log("95");
          updates[teamSnapshot.key + "/is_meter_off"] = false;
        } else {
          console.log("99");
          //nowminus is less than freezedDuration
          const timeLeftForMeterOfReversal =
            meterOffDuration - nowMinusOn(data.meter_off_on);
          futureUndo(
            teamSnapshot.key,
            {
              is_meter_off: false,
            },
            timeLeftForMeterOfReversal * 1000
          );
        }
      }

      if (nowMinusOn(data.invisible_on) > invisibilityDuration) {
        if (data.is_invisible) {
          updates[teamSnapshot.key + "/is_invisible"] = false;
        } else {
          //nowminus is less than freezedDuration
          const timeLeftForInvisibleReversal =
            invisibilityDuration - nowMinusOn(data.invisible_on);
          futureUndo(
            teamSnapshot.key,
            {
              is_invisible: false,
            },
            timeLeftForInvisibleReversal * 1000
          );
        }
      }
    });
    return teamRef.update(updates);
  });
};

export const getVolDataRT = (tid) =>
  new Promise((resolve, reject) => {
    try {
      teamRef.child(tid).once("value", (snapShot) => {
        resolve(snapShot.val());
      });
    } catch (err) {
      reject(err);
    }
  });

export const adminVolRefF = "dummy_admin_volunteers";

export const fetchTeamDataRegistrationRT = (tid) =>
  new Promise((resolve, reject) => {
    try {
      teamRef.child(tid).once("value", (snapShot) => {
        resolve(snapShot);
      });
    } catch (err) {
      reject(err);
    }
  });

export const getVolDataFirestore = async (vid) => {
  return await getDoc(doc(firestore_db, adminVolRefF, vid));
};

export const setEveryOneLogoutFirestore = async () => {
  console.log("herer");
  //   let batch = writeBatch();
  //   batch.update()
  getDoc(doc(firestore_db, "test")).then((snapshot) => {
    console.log(snapshot);
    // batch.update(snapshot.)
    // snapshot.data().forEach((teamSnapshot) => {
    //   console.log(teamSnapshot);
    //   // batch.update(teamSnapshot.key, {})
    // });
  });
  //   let data = await updateDoc(doc(firestore_db, "test", tid), {
  //     is_logged_in: newIsLoggedIn,
  //   });
};
