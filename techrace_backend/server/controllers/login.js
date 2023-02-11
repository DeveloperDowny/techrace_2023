import {
  createUser,
  addNewUserFirestore,
  searchForTeamIdOnFirestore,
  addNewUserRT,
  addTeamRT,
  getStartTimeRT,
  setIsLoggedInFirestore,
  getLogoutLatLng,
} from "../models/user_model.js";

import { fetchTeamDataRT, getClueFirestore } from "../models/game_model.js";

import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import moment from "moment-timezone";

dotenv.config();

moment.tz.setDefault("Asia/Kolkata");

// const login = async (tid) => {
//   let prev = searchForTeamIdOnFirestore(tid);
//   if (prev == -999) {
//     return -999;
//   } else {
//     const token2 = jwt.sign({ tid: tid }, process.env.password, {
//       expiresIn: "1111h",
//     });
//     console.log(tid);
//     return token2;
//   }
// };

// function haversine_distance(mk1, mk2) {
//       var R = 3958.8; // Radius of the Earth in miles
//       var rlat1 = mk1.position.lat() * (Math.PI/180); // Convert degrees to radians
//       var rlat2 = mk2.position.lat() * (Math.PI/180); // Convert degrees to radians
//       var difflat = rlat2-rlat1; // Radian difference (latitudes)
//       var difflon = (mk2.position.lng()-mk1.position.lng()) * (Math.PI/180); // Radian difference (longitudes)

//       var d = 2 * R * Math.asin(Math.sqrt(Math.sin(difflat/2)*Math.sin(difflat/2)+Math.cos(rlat1)*Math.cos(rlat2)*Math.sin(difflon/2)*Math.sin(difflon/2)));
//       return d;
//     }

function haversine_distance(sLat, sLng, dLat, dLng) {
  // var R = 3958.8; // Radius of the Earth in miles //toh ans bhi shayad miles me hi milega
  var R = 6.371 * 1000000; // Radius of the Earth in miles //toh ans bhi shayad miles me hi milega
  var rlat1 = sLat * (Math.PI / 180); // Convert degrees to radians
  var rlat2 = dLat * (Math.PI / 180); // Convert degrees to radians
  var difflat = rlat2 - rlat1; // Radian difference (latitudes)
  var difflon = (dLng - sLng) * (Math.PI / 180); // Radian difference (longitudes)

  var d =
    2 *
    R *
    Math.asin(
      Math.sqrt(
        Math.sin(difflat / 2) * Math.sin(difflat / 2) +
          Math.cos(rlat1) *
            Math.cos(rlat2) *
            Math.sin(difflon / 2) *
            Math.sin(difflon / 2)
      )
    );
  console.log("d in meters");
  console.log(d);
  return d;
}

export const login = async (req, res) => {
  try {
    //test
    // let test = moment("2023-01-22 14:44:13.520493"); // there is no issue with this
    // console.log(test);

    const data = req.body;
    console.log(data);
    const tid = data.tid;

    // if (tid == "") {
    //   res.json({
    //     status: "0",
    //     message: "Invalid Credentials",
    //   });
    // }

    let prev = await searchForTeamIdOnFirestore(tid);
    if (prev == -999) {
      res.json({
        status: "0",
        message: "Team with the given Team ID not found.",
      });
    } else if (prev == -1) {
      res.json({
        status: "0",
        message:
          "Already Logged In in another device.\nLogout from there first.",
      });
    } else if (prev.password != data.password) {
      res.json({
        status: "0",
        message: "Incorrect Password",
      });
    } else {
      // You could move the following to checking if logged_in_or_not. Just move this to add user part and don't mess with it.
      // addTeamRT(tid, prev); // this should not happen. Instead the previous data should be passed to the phone like clue etc.
      // so first search for prev data and then share it.
      // log out pe it should log out.
      // addTeamRT could happen at start of the event but traffic would increase heavily
      // addTheFollowing when user is added in admin panel
      // don't do it here

      // send details here

      // there is an issue here. Location wala idhar hi check karna padega.
      // or else is LoggedIn wala firse change karna padega

      // let lastLogoutLatLng = await getLogoutLatLng(tid);
      let teamData = await fetchTeamDataRT(tid);
      if (teamData.state === "Banned") {
        res.json({
          status: "0",
          message:
            "You have been disqualified from the race because of cheating.\nThis is a final decision and cannot be revoked.",
        });
        return;
      }
      // come back here
      console.log(teamData.logout_loc_lat);

      console.log("lastLogoutLatLng.logout_loc_lat");
      if (
        teamData.logout_loc_lat != "-999" &&
        teamData.state != "WaitingForReg"
      ) {
        // Only in these case check for cheating
        let dist = haversine_distance(
          data.curr_lat,
          data.curr_lng,
          teamData.logout_loc_lat,
          teamData.logout_loc_lng
        );
        console.log("dist");
        console.log(dist);
        //kind of works don't know how accurate thought

        // logout_loc_lat: lastLogoutLatLng["logout_loc_lat"],
        // logout_loc_lng: lastLogoutLatLng[""],

        // if (dist > 100 || dist < -100) { //change it to 250 m radius
        if (dist > 250 || dist < -250) {
          //change it to 250 m radius
          res.json({
            status: "2",
            message:
              "Cheating detected.\nYou are more than 250 meters away from your last logout location.\nKindly login with your device only.\nFurther cheating attempts will immediately lead to ban and disqualification from the race.",
          });
          return;
        }
      }

      setIsLoggedInFirestore(tid, true); //temp f1 in login// do this

      // move this to another api
      const token2 = jwt.sign({ tid: tid }, process.env.password, {
        expiresIn: "1111h",
      });

      console.log(tid);
      console.log(token2);

      let startDateTime = await getStartTimeRT();

      // change this and despite all, ask for prefetch,
      // state bhi bata de.
      // if state is Playing toh no need to prefetch kyuki woh automatically ho jaega

      // change nomenclature of clue id too
      // randomization should happen at validation and clue guess

      // todo if wala section hata ke yeh daalna hai
      // change flutter accordingly
      res.json({
        status: "1",
        message: "Logged In Successfully",
        token: token2,
        p1: prev.p1,
        p2: prev.p2,
        start_datetime: startDateTime,

        // route_no: teamData.route_no,
        current_clue_no: teamData.current_clue_no,
        // state: teamData.state
      });

      // if (teamData.current_clue_no === 1) {
      //   let clue_1 = await getClueFirestore(
      //     `${teamData.current_clue_no}`,
      //     true
      //   );
      //   res.json({
      //     status: "1",
      //     message: "Logged In Successfully",
      //     token: token2,
      //     p1: prev.p1,
      //     p2: prev.p2,
      //     start_datetime: startDateTime,

      //     //clue type added
      //     clue_type: clue_1.clue_type,
      //     clue_1: clue_1.clue,
      //     clue_lat: clue_1.lat,
      //     clue_lng: clue_1.long,
      //   });
      //   return;
      // }

      // res.json({
      //   status: "1",
      //   message: "Logged In Successfully",
      //   token: token2,
      //   p1: prev.p1,
      //   p2: prev.p2,
      //   start_datetime: startDateTime,
      // });
    }
  } catch (error) {
    res.json({
      status: "0",
      message: "Error occurred.",
      error: `${error}`,
    });
  }
};

// after login add details to realtime database
