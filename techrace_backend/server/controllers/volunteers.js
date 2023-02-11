import { fetchTeamDataRT, updateStateRT } from "../models/game_model.js";
import {
  fetchTeamDataRegistrationRT,
  getVolDataFirestore,
  resetFutureUndosRT,
  setEveryOneLogoutFirestore,
  setEveryOnePlayingRT,
  updateTimeRT,
} from "../models/volunteers_model.js";

import moment from "moment-timezone";
import {
  Banned,
  Playing,
  WaitingForGameStart,
  WaitingForReg,
} from "../utils/GameStates.js";
import ref from "../database/database.js";
moment.tz.setDefault("Asia/Kolkata");

import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import { async } from "@firebase/util";

dotenv.config();

const futureSetToPlaying = async (timeAfterSetToPlaying) => {
  setTimeout(() => {
    setEveryOnePlayingRT("Playing");
  }, timeAfterSetToPlaying);
};

export const updateTimeToStart = async (req, res) => {
  const timeAfterSetToPlaying = moment(req.body.new_start_datetime).diff(
    moment(),
    "milliseconds"
  );

  futureSetToPlaying(timeAfterSetToPlaying);

  updateTimeRT(req.body);
  res.json({
    status: "1",
  });
};

const volRef = ref.child("volunteers_admin");

// {vid: "vid"}
export const loginVolunteer = async (req, res) => {
  // server through state change to playing

  try {
    const data = req.body;
    const volData = await getVolDataFirestore(data.vid);
    if (!volData.exists()) {
      res.json({
        status: "0",
        message: "Volunteer ID incorrect",
      });
      return;
    }

    const actualVolData = volData.data();
    if (!(actualVolData.password == data.password)) {
      res.json({
        status: "0",
        message: "Incorrect password",
      });
      return;
    }

    const token2 = jwt.sign({ vid: data.vid }, process.env.password, {
      expiresIn: "1111h",
    });
    res.json({
      status: "1",
      message: "Logged In Successfully",
      token: token2,
    });
  } catch (error) {
    res.json({
      status: "0",
      message: `${error}`,
    });
  }
};

// this is it
export const resetFutureUndos = async (req, res) => {
  // server through state change to playing

  try {
    // write query here
    await resetFutureUndosRT();
    res.json({
      status: "1",
      message: `Future Undos Executed Successfully`,
    });
  } catch (error) {
    res.json({
      status: "0",
      message: `${error}`,
    });
  }
};

// export const getSoloOrDuo = async (req, res) => {
//   // server through state change to playing

//   try {
//     // write query here
//     await resetFutureUndosRT();
//     res.json({
//       status: "1",
//       message: `Future Undos Executed Successfully`,
//     });
//   } catch (error) {
//     res.json({
//       status: "0",
//       message: `${error}`,
//     });
//   }
// };

//tid
export const registerTeam = async (req, res) => {
  // server through state change to playing

  try {
    const data = req.body;
    const teamData = await fetchTeamDataRegistrationRT(data.tid);

    // const teamData = await getVolDataFirestore(data.vid);
    if (!teamData.exists()) {
      res.json({
        status: "0",
        message: "Team ID incorrect",
      });
      return;
    }

    const actualTeamData = teamData.data();

    if (actualTeamData != WaitingForReg) {
      res.json({
        status: "0",
        message: "Incorrect State of the Team",
      });
      return;
    }

    await updateStateRT(data.tid, WaitingForGameStart);
    res.json({
      status: "1",
      message: "Registered",
      token: token2,
    });
  } catch (error) {
    res.json({
      status: "0",
      message: `${error}`,
    });
  }
};

// here first check ki woh tid exist karta hai ki nai, only then change state
export const changeState = async (req, res) => {
  // server through state change to playing
  try {
    const data = req.body;
    if (
      data.new_state != WaitingForReg &&
      data.new_state != WaitingForGameStart &&
      data.new_state != Playing &&
      data.new_state != Banned
    ) {
      res.json({
        status: "0",
        message: "Invalid game state.",
      });
      return;
    }
    // updateState(req.tid, data.newState);
    let test = await fetchTeamDataRT(data.tid);
    console.log("test change state");
    console.log(test);
    // return;
    if (test == null) {
      res.json({
        status: "0",
        message: "Team with the given Team ID not found.",
      });
      return;
    }

    updateStateRT(data.tid, data.new_state); //temp
    res.json({
      status: "1",
      message: "State updated successfully",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const setEveryOnePlaying = async (req, res) => {
  // server through state change to playing
  try {
    const data = req.body;
    // updateState(req.tid, data.newState);
    // updateState(data.tid, data.new_state); //temp

    setEveryOnePlayingRT(data.new_state);
    res.json({
      status: "1",
      message: "State updated successfully",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const setEveryOneLogout = async (req, res) => {
  // server through state change to playing
  try {
    setEveryOneLogoutFirestore();
    res.json({
      status: "1",
      message: "State updated successfully",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};
