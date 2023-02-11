import { async } from "@firebase/util";
import {
  updatePoints,
  // updateState,
  updateStateRT,
  updateTeamDataRT,
  addClueFirestore,
  getClueFirestore,
  updateTimeRT,
  fetchTeamDataRT,
} from "../models/game_model.js";
import {
  createUser,
  addNewUserFirestore,
  getRandomRouteId,
  constructCid,
} from "../models/user_model.js";

// // in seconds //old
// const freezeDuration = 7.5 * 60;
// const freezeCooldownDuration = 10 * 60;
// const meterOffDuration = 7.5 * 60;
// const meterOffCooldownDuration = 7.5 * 60;
// const invisibilityDuration = 7.5 * 60;
// const hint1LockDuration = 5 * 60;
// const hint2LockDuration = 10 * 60;

// in seconds //new
export const freezeDuration = 10 * 60;
// const freezeCooldownDuration = 10 * 60;
export const freezeCooldownDuration = 15 * 60;
export const meterOffDuration = 15 * 60;
export const meterOffCooldownDuration = 0 * 60;
export const invisibilityDuration = 10 * 60;
export const hint1LockDuration = 5 * 60;
export const hint2LockDuration = 10 * 60;

import moment from "moment-timezone";
import { setEveryOneLogoutFirestore } from "../models/volunteers_model.js";
const mTimeZone = "Asia/Kolkata";
moment.tz.setDefault("Asia/Kolkata");

// moment.tz.setDefault("America/Resolute");

export const updateTimeToStart = async (req, res) => {
  updateTimeRT(req.body);
  res.json({
    status: "1",
  });
};
export const addClue = async (req, res) => {
  try {
    addClueFirestore(req.body);
    res.json({
      status: "1",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const updateBalance = async (req, res) => {
  // const teamData = await fetchTeamDataRT(req.tid);
  // if (teamData.balance - req.body.subtract_by)
  try {
    updateTeamDataRT(req.tid, { balance: req.body.updated_balance });
    res.json({
      status: "1",
      message: "Points updated",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const getHintCommon = async (req, res) => {
  // next clue ke time pe getHint1 and 2 change karne padege
  try {
    const cost1 = 100;
    const cost2 = 100;

    const teamData = await fetchTeamDataRT(req.tid);

    if (teamData.hint_1 == "-999") {
      if (teamData.balance < cost1) {
        res.json({
          status: "0",
          message: "Insufficient points.",
        });
        return;
      }
      const hint = await getClueFirestore(req.body.cid, false);
      updateTeamDataRT(req.tid, {
        balance: teamData.balance - cost1,
        hint_1: hint.hint_1,
      });

      // res.json({
      //   status: "0",
      //   message: "1st Hint Already Used",
      // });
      return;
    } else {
      if (teamData.balance < cost2) {
        res.json({
          status: "0",
          message: "Insufficient points.",
        });
        return;
      }
      const hint = await getClueFirestore(req.body.cid, false);
      updateTeamDataRT(req.tid, {
        balance: teamData.balance - cost2,
        hint_2: hint.hint_2,
      });

      res.json({
        status: "1",
        message: "Successfull",
      });
      return;
    }

    // const hint = await getClueFirestore(req.body.cid);
    // console.log(hint);

    // // pass all the hints and data at the ask of next clue
    // updateTeamDataRT(req.tid, { balance: teamData.balance - cost });
    // res.json({
    //   status: "1",
    //   // hint: ,
    //   ...hint,
    // });
  } catch (error) {
    console.log(error);
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const getHintCommonv2 = async (req, res) => {
  //types bhi update karo

  // next clue ke time pe getHint1 and 2 change karne padege
  try {
    // const cost1 = 100;
    // const cost2 = 100;

    let data = req.body;
    data.updated_balance = Number.parseInt(data.updated_balance);

    console.log(data.updated_balance);
    console.log(typeof data.updated_balance);
    if (data.updated_balance < 0) {
      res.json({
        status: "0",
        message: "Insufficient points.",
      });
      return;
    }

    const teamData = await fetchTeamDataRT(req.tid);

    if (teamData.hint_1 == "-999") {
      const hint = await getClueFirestore(req.body.cid, false);

      await updateTeamDataRT(req.tid, {
        // balance: teamData.balance - cost1,
        balance: data.updated_balance,
        hint_1: hint.hint_1,
        hint_1_type: hint.hint_1_type,
      });

      res.json({
        status: "1",
        message: "Successfull",
      });
      return;

      // res.json({
      //   status: "0",
      //   message: "1st Hint Already Used",
      // });
      // return;
    } else {
      if (data.updated_balance < 0) {
        res.json({
          status: "0",
          message: "Insufficient points.",
        });
        return;
      }
      const hint = await getClueFirestore(req.body.cid, false);
      await updateTeamDataRT(req.tid, {
        // balance: teamData.balance - cost2,
        balance: data.updated_balance,
        hint_2: hint.hint_2,
        hint_2_type: hint.hint_2_type,
      });

      res.json({
        status: "1",
        message: "Successfull",
      });
      return;
    }

    // const hint = await getClueFirestore(req.body.cid);
    // console.log(hint);

    // // pass all the hints and data at the ask of next clue
    // updateTeamDataRT(req.tid, { balance: teamData.balance - cost });
    // res.json({
    //   status: "1",
    //   // hint: ,
    //   ...hint,
    // });
  } catch (error) {
    console.log(error);
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const getClueFromCid = async (req, res) => {
  try {
    const teamData = await fetchTeamDataRT(req.tid);
    // const hint = await getClueFirestore(req.body.cid, true);
    const clue = await getClueFirestore(teamData.cid, true); //fixing cid thing

    console.log(clue);

    // pass all the hints and data at the ask of next clue

    res.json({
      status: "1",
      // hint: ,
      ...clue,
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

// //powerups : reducer, freeze, skip a location, MeterOff, Invisibility
//on opponent : reducer , freeze, MeterOff

//self : Freeze, Skip a Location, Invisibility

// {
// “opp_tid”: “id of the opponent team to be blocked”,
// “req_tid”: “id of the team requesting the block”,
// “pid”: “id of the powercard used”,
// "updated_balance": "updated balance"
// }
export const futureUndo = async (tid, payload, freeTimeInMilli) => {
  setTimeout(() => {
    updateTeamDataRT(tid, payload);
  }, freeTimeInMilli);
};

const reverseFreezeTeam = async (tid, payload, res) => {
  // const mDate = Date.parse()
  // const cost = 100;
  const cost = 175;
  let teamData = await fetchTeamDataRT(tid);
  if (cost > payload.current_balance) {
    res.json({
      status: "0",
      message: "Failed: Insufficient points.",
    });
  }
  // change all to moment formats
  // else if (
  //   payload.ask_timestamp >
  //   teamData.freezed_on - 7.5 * 60 * 1000 + 60 * 1000
  // )// change all to moment formats
  else if (
    moment(payload.ask_timestamp).diff(teamData.freezed_on, "seconds") > 60

    // payload.ask_timestamp >
    // teamData.freezed_on - 7.5 * 60 * 1000 + 60 * 1000
  ) {
    res.json({
      status: "0",
      message: "Failed: Can't reverse freeze a team after 60 seconds.",
    });
  } else {
    payload.opp_tid = teamData.freezed_by;
    updateTeamDataRT(tid, {
      is_freezed: false,
      // freezed_on: moment().subtract(freezeDuration, "seconds").format(), //set to arbitarity piche
      freezed_on: moment()
        .subtract(freezeDuration + freezeCooldownDuration + 60 * 60, "seconds")
        .format(), //set to arbitarity piche
    }); //this should work
    freezeTeam(tid, payload, res, true); //yehi res.json bhej dega //yaha force
    // console.log(
    //   moment()
    //     .add(10 * 60, "seconds")
    //     .format("YYYY-MM-DDTHH:MM:SS")
    // );
    //what are you doing here
    //do this to give cooldown
    // moment()
    // .subtract(freezeDuration, "seconds") //check this
    // updateTeamDataRT(tid, {
    //   is_freezed: false,
    //   freezed_on: moment().subtract(freezeDuration, "seconds").format(),
    // });
  }
  // current balance send kiya hoga
  // if ()
  // reverse freeze ke liye pop up ana chahiye
  // show a dialog box

  //server is not necessary btw
};

export const calculatePointsToAdd = (
  ask_timestamp,
  prev_clue_solved_timestamp
) => {
  const basePoints = 20;
  const minusFrom = 60;

  // console.log('moment().diff(ask_timestamp, "minutes")');
  // console.log(
  // moment(prev_clue_solved_timestamp).diff(ask_timestamp, "minutes")
  // ); //some how 0
  // console.log(
  // moment(prev_clue_solved_timestamp).diff(moment(ask_timestamp), "minutes")
  // ); //some how 0
  console.log(
    moment(ask_timestamp).diff(moment(prev_clue_solved_timestamp), "minutes")
  ); //some how 0

  const bonusPoints =
    minusFrom -
    moment(ask_timestamp).diff(prev_clue_solved_timestamp, "minutes");

  console.log("bonusPoints");
  console.log(bonusPoints); // 60

  let onClueUpPoints = basePoints + (bonusPoints < 0 ? 0 : bonusPoints);
  console.log("onClueUpPoints");
  console.log(onClueUpPoints); //80

  return onClueUpPoints;
};

export const checkIfDiscount = (teamData, costBeforeCoupon, powerUpName) => {
  console.log(powerUpName in teamData);
  if (powerUpName in teamData) {
    if (teamData[powerUpName] > 0) {
      return 0;
    }
  }
  return costBeforeCoupon;
};

export const guessLocationV1 = async (tid, payload, res) => {
  //rdm but in the case of poor internet connection things could go wrong
  // const costM = 100; //check if discournt
  const costM = 200; //check if discournt

  let teamData = await fetchTeamDataRT(tid);
  const cost = checkIfDiscount(teamData, costM, "guess_loc_coupon");
  // console.log("here");

  if (cost > payload.current_balance) {
    // do quick baar mara toh issue ho jaega
    res.json({
      status: "0",
      message: "Insufficient points.",
    });
    return;
  }

  if (teamData.current_clue_no > 11) {
    res.json({
      status: "0",
      message: "This Power Card cannot be used after clue number 11",
    });
    return;
  }
  // if (teamData.no_guessed_used >= 2) {
  if (teamData.no_guessed_used >= 1) {
    //only one guess ka system. guessed cannot be used after 9
    res.json({
      status: "0",
      message:
        // "You can have used Guess A Location 2 times already.\nYou cannot use more than 2 times",
        "You can have used Guess A Location 1 time already.\nYou cannot use more than 1 time",
    });
    return;
  } else {
    // console.log();
    // let clueData = getClueFromCidFirestore(teamData.current_clue_no);
    //
    // let clueData = await getClueFirestore(`${teamData.current_clue_no}`, false);
    let clueData = await getClueFirestore(`${teamData.cid}`, false);

    // // better logs here
    // console.log("better logs 423");
    // console.log("attempting guess location");
    // console.log(moment().format());

    // console.log(
    //   `Team with tid ${tid} guessed: ${payload.guessed_location.toLowerCase()}`
    // );
    // "  ".trim()
    let cond =
      payload.guessed_location.trim() != "" &&
      "The Taj Hotel"
        .toLowerCase()
        .includes(payload.guessed_location.toLowerCase());

    let mainCond = false;
    // console.log(clueData);

    let preProccessedGuessArr = payload.guessed_location
      .toLowerCase()
      .split(" ");
    let resArr = [];
    console.log("preProccessedGuessArr");
    console.log(preProccessedGuessArr);
    for (let i in preProccessedGuessArr) {
      if (preProccessedGuessArr[i].trim() != "") {
        resArr.push(preProccessedGuessArr[i]);
      }
      // preProccessedGuessArr[i] = preProccessedGuessArr[i].trim();
      // console.log(
      //   ` preProccessedGuessArr[i]${preProccessedGuessArr[i]} preProccessedGuessArr[i]`
      // );
    }
    // let preProccessedGuess = preProccessedGuessArr.join(" ");
    console.log(resArr);
    let preProccessedGuess = resArr.join(" ");
    // preProccessedGuess = preProccessedGuess.trim();
    console.log(`preProccessedGuess${preProccessedGuess}preProccessedGuess`);

    for (let i in clueData.guess_options) {
      console.log(i);
      console.log(clueData.guess_options[i]);
      if (preProccessedGuess === clueData.guess_options[i].toLowerCase()) {
        mainCond = true;
        // console.log("fsgg");
        break;
      }
    }

    // better logs here
    console.log("better logs 472");
    console.log("attempting guess location");
    console.log(moment().format());
    console.log(
      `Team with tid ${tid} guessed: ${payload.guessed_location.toLowerCase()} Actual was: ${
        clueData.guess_options[0]
      } and guess loc turned out to be ${mainCond}`
    );

    // console.log(mainCond);

    //many things to condiser here
    // console.log(cond);
    // console.log("Hotel".toLowerCase().includes(payload.guessed_location));
    // console.log(payload.guessed_location.toLowerCase());
    // if (cond) {
    if (mainCond) {
      res.json({
        status: "1",
        message: "Correct guess.",
      });
      // points ?

      // const basePoints = 20;
      // const minusFrom = 60;

      // const bonusPoints =
      //   minusFrom - moment().diff(payload.ask_timestamp, "minutes");

      // console.log("bonusPoints");
      // console.log(bonusPoints);

      // let onClueUpPoints = basePoints + (bonusPoints < 0 ? 0 : bonusPoints);
      // console.log("onClueUpPoints");
      // console.log(onClueUpPoints);

      const onClueUpPoints = calculatePointsToAdd(
        payload.ask_timestamp,
        teamData.prev_clue_solved_timestamp
      );

      let toUpdate = {
        balance: payload.current_balance - cost + onClueUpPoints, // because clue up hone ke baad points toh milenge hi na
        current_clue_no: teamData.current_clue_no + 1,
        // multiple clicks should be avoided
        // route_no: getRandomRouteId(), //check this // you don't need this
        cid: constructCid(teamData.current_clue_no + 1), // check if this works correctly or not
        no_guessed_used: teamData.no_guessed_used + 1,
        prev_clue_solved_timestamp: payload.ask_timestamp,
        hint_1: "-999",
        hint_2: "-999",
        // guess_loc_coupon: teamData.guess_loc_coupon, //don't add this
      };
      if (checkIfDiscount(teamData, costM, "guess_loc_coupon") == 0) {
        //issue here
        toUpdate.guess_loc_coupon = teamData.guess_loc_coupon - 1;
      }

      updateTeamDataRT(tid, toUpdate); // solved the thing. randomize wala remaining
    } else {
      let toUpdate = {
        balance: payload.current_balance - cost,
        no_guessed_used: teamData.no_guessed_used + 1, //this imp
      };
      if (checkIfDiscount(teamData, costM, "guess_loc_coupon") == 0) {
        //error here
        toUpdate.guess_loc_coupon = teamData.guess_loc_coupon - 1;
      }
      updateTeamDataRT(tid, toUpdate);

      res.json({
        status: "2",
        message: "Incorrect guess",
      });
    }
  }
  // ask aditya how did they do skip a location
};

export const freezeTeam = async (tid, payload, res, isForReverseFreeze) => {
  const teamData = await fetchTeamDataRT(tid);
  // const costBeforeDis = 100;
  const costBeforeDis = 125;
  // const costOfReverseFreeze = 100;
  const costOfReverseFreeze = 175;

  const cost = isForReverseFreeze
    ? costOfReverseFreeze
    : checkIfDiscount(teamData, costBeforeDis, "freeze_team_coupon");

  console.log("cost");
  console.log(cost);

  let opponentData = await fetchTeamDataRT(payload.opp_tid);

  console.log("dfsfdfd"); // idhar somehow nan aa raha //check why Nan
  console.log(moment(payload.ask_timestamp));

  console.log("opponentData.freezed_on");
  console.log(opponentData.freezed_on); //opponent freezed on ka issue hai

  // idhar issue aa raha
  console.log(moment(opponentData.freezed_on)); // opponentfreezed on is invalid// matlab 065 ka
  console.log(
    moment(payload.ask_timestamp).diff(
      moment(opponentData.freezed_on),
      "seconds"
    )
  );

  if (cost > payload.current_balance) {
    res.json({
      status: "0",
      message: "Failed: Insufficient points.",
    });
  } else if (opponentData.is_freezed) {
    res.json({
      status: "0",
      message:
        "Failed: Opponent Team is already frozen. Please try again later.",
    });
    // } else if (opponentData.freezed_on > payload.ask_timestamp) {
  } else if (
    !isForReverseFreeze &&
    moment(payload.ask_timestamp).diff(
      moment(opponentData.freezed_on),
      "seconds"
    ) <
      // 7.5 * 60 + 20 * 60
      freezeDuration + freezeCooldownDuration //check this
  ) {
    // console.log(
    //   moment(opponentData.freezed_on).diff(moment(payload.ask_timestamp))
    // );

    // console.log(
    //   moment(payload.ask_timestamp).diff(
    //     moment(opponentData.freezed_on),
    //     "seconds"
    //   )
    // );
    res.json({
      status: "0",
      message:
        "Failed: Cooldown period is on of Opponent Team. Please try again later.",
    });
  } else {
    // let testTime = moment(opponentData.freezed_on).add(
    //   7.5 * 60 * 1000 + 20 * 60 * 1000,
    //   "milliseconds"
    // );
    // .format();

    // console.log("testTime");
    // console.log(testTime);

    updateTeamDataRT(payload.opp_tid, {
      freezed_by: isForReverseFreeze ? "-999" : tid,
      is_freezed: true,
      freezed_on: payload.ask_timestamp,

      // moment(payload.ask_timestamp)
      //   .add(7.5 * 60 * 1000 + 20 * 60 * 1000, "milliseconds")
      //   .format(), // 20 minutes cooldown period
      // payload.ask_timestamp + 7.5 * 60 * 1000 + 20 * 60 * 1000, // 20 minutes cooldown period
    });

    const updated_balance = payload.current_balance - cost;

    let toUpdateSameTeam = {
      balance: updated_balance,
    };
    if (cost == 0) {
      toUpdateSameTeam.freeze_team_coupon = teamData.freeze_team_coupon - 1;
      // 3;
    }
    updateTeamDataRT(tid, toUpdateSameTeam);

    // Delayed execution

    // futureUndo(payload.opp_tid, { is_freezed: false }, 7.5 * 60 * 1000); //temp
    // futureUndo(payload.opp_tid, { is_freezed: false }, 2 * 60 * 1000);
    futureUndo(payload.opp_tid, { is_freezed: false }, freezeDuration * 1000);
    // futureUnfreeze(payload.opp_tid, 1 * 5 * 1000); //for testing only. Working correctly

    res.json({
      status: "1",
      message: "Opponent Team Freezed Successfully.",
      updated_balance: updated_balance,
    });
  }
};

const reducePoints = async (tid, payload, res) => {
  const cost = 100;
  const reduceBy = 100;
  if (cost > payload.current_balance) {
    res.json({
      status: "0",
      message: "Failed: Insufficient points.",
    });
    return;
  }

  let opponentData = await fetchTeamDataRT(payload.opp_tid);
  updateTeamDataRT(payload.opp_tid, {
    balance: opponentData.balance - reduceBy,
  });
  const updated_balance =
    payload.current_balance - cost < 0 ? 0 : payload.current_balance - cost;
  updateTeamDataRT(tid, {
    balance: updated_balance,
  });
};

// ask timestamp dalna padega
// yeh checks sab jagah daal de
export const meterOff = async (tid, payload, res) => {
  const costBeforeDis = 100;

  const oppTeamData = await fetchTeamDataRT(payload.opp_tid);
  const teamData = await fetchTeamDataRT(tid);

  const cost = checkIfDiscount(teamData, costBeforeDis, "meter_off_coupon");

  if (cost > payload.current_balance) {
    res.json({
      status: "0",
      message: "Failed: Insufficient points.",
    });
    return;
  }
  if (oppTeamData.is_meter_off) {
    res.json({
      status: "0",
      message: "Failed: Opponent Team's meter is already off.",
    });
    return;
  }

  // better
  // else if (
  //   moment(payload.ask_timestamp).diff(oppTeamData.meter_off_on, "seconds") <
  //   // 10 * 60
  //   meterOffDuration + meterOffCooldownDuration
  // ) {
  //   res.json({
  //     status: "0",
  //     message: "Failed: Opponent Team's Meter Off cooldown period is on",
  //   });
  //   return;
  // }

  // cooldown period of 10 minutes

  const updated_balance = payload.current_balance - cost;

  futureUndo(payload.opp_tid, { is_meter_off: false }, meterOffDuration * 1000);
  res.json({
    status: "1",
    message: "Opponent Team's Meter Turned Off Successfully.",
    updated_balance: updated_balance,
  });

  // let opponentData = await fetchTeamDataRT(payload.opp_tid);

  updateTeamDataRT(payload.opp_tid, {
    is_meter_off: true,
    meter_off_on: payload.ask_timestamp,
  });

  let toUpdateSameTeam = {
    balance: updated_balance,
  };

  if (checkIfDiscount(teamData, costBeforeDis, "meter_off_coupon") == 0) {
    toUpdateSameTeam.meter_off_coupon = teamData.meter_off_coupon - 1;
  }

  console.log("toUpdateSameTeam");
  console.log(toUpdateSameTeam);

  updateTeamDataRT(tid, toUpdateSameTeam);
};

const invisible = async (tid, payload, res) => {
  // check for block
  // check fo already frozen
  // const cost = 100;
  const cost = 130;
  if (cost > payload.current_balance) {
    res.json({
      status: "0",
      message: "Insufficient points.",
    });
    return;
  }

  let teamData = await fetchTeamDataRT(tid);
  if (teamData.is_invisible) {
    res.json({
      status: "0",
      message: "You are already invisible",
    });
    return;
  }

  const updated_balance = payload.current_balance - cost;
  updateTeamDataRT(tid, {
    is_invisible: true,
    balance: updated_balance,
  });

  // futureUndo(tid, { is_invisible: false }, 7.5 * 60 * 1000);
  futureUndo(tid, { is_invisible: false }, invisibilityDuration * 1000);
  res.json({
    status: "1",
    message: "You have become invisible for the next 7.5 minutes",
  });
};

// before applying powercards check toh karo // not needed

// //powerups : reducer, freeze, skip a location, MeterOff, Invisibility
//on opponent : reducer , freeze, MeterOff

//self : Freeze, Skip a Location, Invisibility

// for opponent team cooldown bhi lagana hai

let lockMap = new Map();
export const powerUps = async (req, res) => {
  const data = req.body;
  try {
    // time zone set karna padega

    // fixed cool down period? no just timestamp of when I can do shit
    // DateTime.now()
    // pass timestamp too miliseconds since epoch then work on it

    // const checkIfInvisible = await

    // if (checkIfFreezed.is_freezed && )

    // const checkIfFreezed = await fetchTeamDataRT(req.tid); //temp maybe later
    // data.current_balance = checkIfFreezed.balance;

    //pass these data as arguments and do things

    // if (data.hasOwnProperty("opp_tid")) {

    if (data.opp_tid != "-999") {
      // console.log(lockMap);
      if (lockMap.has(data.opp_tid) || lockMap.has(req.tid)) {
        res.json({
          status: "0",
          message:
            "Cannot apply the powercard at the moment\nPlease try again later",
        });
        return;
      }
      lockMap.set(data.opp_tid, true);
      lockMap.set(req.tid, true);

      // in this case, it is a two team power card
      // apply map here

      // console.log(data["opp_tid"]);
      let oppTeamData = await fetchTeamDataRT(data["opp_tid"]);
      console.log("oppTeamData.is_invisible");
      console.log(oppTeamData.is_invisible);

      if (req.params.pid != 5 && oppTeamData.is_invisible) {
        res.json({
          status: "0",
          message: "Opponent Team is Invisible.\nTry again later.",
        });
        return;
      }
    }

    console.log(req.params);
    switch (req.params.pid) {
      case "1":
        guessLocationV1(req.tid, data, res);
        break;
      case "2":
        freezeTeam(req.tid, data, res, false);
        break;
      // case "3":
      //   reducePoints(req.tid, data, res);
      //   break;
      case "3":
        meterOff(req.tid, data, res);
        break;
      case "4":
        invisible(req.tid, data, res);
        break;
      case "5":
        reverseFreezeTeam(req.tid, data, res);
        break;
      default:
        break;
    }
    // if (req.params.pid == 2) {
    //   freezeTeam(req.tid, data, res);
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  } finally {
    lockMap.delete(data.opp_tid);
    lockMap.delete(req.tid);
  }
  // }
};

// dual security or only on his side?
// mere end se sab kar le

const getClue = (tid, clue_no) => {
  return `${tid}_${clue_no}`;
};

export const getNextClue = async (req, res) => {
  //c1. need to add this check at volunteer ka phone
  try {
    const data = req.body;
    // which clue you want is asked in the body
    // update clue number and the leaderboard
    // update balance is also given
    updateTeamDataRT(req.tid, {
      balance: data.balance,
      current_clue_no: data.clue_no,
      prev_clue_solved_timestamp: data.prev_clue_solved_timestamp,
      hint_1: "-999",
      hint_2: "-999",
    });
    res.json({
      status: "1",
      message: "Request completed successfully.",
      current_clue_no: data.clue_no,
      clue: getClue(req.tid, data.clue_no),
    });

    //you need to update rank here
  } catch (error) {
    res.json({
      status: "0",
      message: "Failed: Error Occurred",
      erros: `${error}`,
    });
  }
};

export const changeState = async (req, res) => {
  // server through state change to playing
  try {
    const data = req.body;
    // updateState(req.tid, data.newState);
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

// put volunteer auth
