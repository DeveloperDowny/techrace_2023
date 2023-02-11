import { doc, setDoc } from "firebase/firestore";
import moment from "moment-timezone";
import { loginVolunteer, updateTimeToStart } from "../controllers/volunteers";
import ref from "../database/database";
import { firestore_db } from "../database/firestore_db";
import { fetchTeamDataRT, updateTeamDataRT } from "../models/game_model";
import { adminVolRefF } from "../models/volunteers_model";
import { Playing } from "../utils/GameStates";

describe("testing volunteers part", () => {
  test("make volunteer login and pass", async () => {
    await setDoc(doc(firestore_db, adminVolRefF, "1000"), {
      name: "Vedant Test1",
      password: "1000",
    });
  });
  test("volunteer login succes", async () => {
    let resPayload = {};

    let req = {};
    req.body = {
      vid: "1000",
      password: "1000",
    };
    const res = {
      json: (payload) => {
        resPayload = payload;
      },
    };

    await loginVolunteer(req, res);
    console.log(resPayload);

    expect(resPayload["status"]).toBe("1");
  });

  jest.setTimeout(10 * 60 * 1000);

  // working correctly
  test.only("auto change to playing when start date time updated", async () => {
    const teamId = "936";
    const secondsAageStartDateTime = 1 * 60;
    await updateTeamDataRT(teamId, { state: "WaitingForGameStart" });

    console.log("here");
    // new_start_datetime;

    const newStartDateTime = moment()
      .add(secondsAageStartDateTime, "seconds")
      .format();
    let resPayload = {};

    let req = {};
    req.body = {
      // vid: "1000",
      // password: "1000",
      new_start_datetime: newStartDateTime,
    };
    const res = {
      json: (payload) => {
        resPayload = payload;
      },
    };
    await updateTimeToStart(req, res);
    await new Promise((r) => setTimeout(r, secondsAageStartDateTime * 1000));

    const startDateTimeActual = await new Promise((resolve, reject) => {
      try {
        ref.child("start_datetime").once("value", (snapShot) => {
          resolve(snapShot.val());
        });
      } catch (err) {
        reject(err);
      }
    });

    expect(startDateTimeActual).toBe(newStartDateTime);

    const teamData = await fetchTeamDataRT(teamId);

    expect(teamData.state).toBe(Playing);
  });

  // volunteers se aur kya kya karna hai?
  // set start date time se auto matic hona chahiye
});

// localStorage.setItem("profile", JSON.stringify({ ...action?.data })); use this to save the token. or save the token

// { status: '1', message: 'Logged In Successfully', token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWQiOiIxMDAwIiwiaWF0IjoxNjc0NzkxNjgyLCJleHAiOjE2Nzg3OTEyODJ9.67faZz3Mj3byOaR96BvwaavmmOuK0WvcTYMcXXzxcJc' }

// start with front end now
// new user toh script se hi karo
