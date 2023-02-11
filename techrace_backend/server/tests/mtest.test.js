import moment from "moment-timezone";
import {
  checkIfDiscount,
  freezeTeam,
  guessLocationV1,
  meterOff,
  powerUps,
} from "../controllers/game";
import { login } from "../controllers/login";
import { logout, newUser } from "../controllers/users";
import { updateTeamDataRT, fetchTeamDataRT } from "../models/game_model";

// test('adds user', () => {
//   newUser()
// })

describe("test handles", () => {
  // jest.useFakeTimers();

  let addUserPayload = {};
  let loginPayload = {};
  test("add users", async () => {
    let req = {};
    req.body = {
      p1: "JTest 1",
      p2: "JTest 2",
    };
    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    await newUser(req, res);
    console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");
  });

  //   test.only("attempting login", async () => { //this way only this runs
  test("attempting login", async () => {
    //this way
    let req = {};
    req.body = {
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      curr_lat: 423.3423,
      curr_lng: 423.3423,
      tid: addUserPayload.t_id,
      password: addUserPayload.t_id,
    };
    console.log("addUserPayload");
    console.log(addUserPayload);
    req.tid = addUserPayload.t_id;

    const res = {
      json: (payload) => {
        loginPayload = payload;
      },
    };

    // await newUser(req, res);
    await login(req, res);

    console.log("loginPayload");
    console.log(loginPayload);

    expect(loginPayload["status"]).toBe("1");
  });

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  test("logout", async () => {
    let req = {};
    req.body = {
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      logout_loc_lat: "-999",
      logout_loc_lng: "-999",
    };
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    await logout(req, res);

    console.log("addUserPayload");
    console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");
  });

  test("guessloc", async () => {
    const testTid = "345";
    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: moment()
        .subtract(3.5 * 60, "seconds")
        .format(),
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
    });
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      guessed_location: "Poco Loco",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };
    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    await powerUps(req, res);
    console.log("addUserPayload");
    console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);

    expect(data.current_clue_no).toBe(4);
    expect(data.balance).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });

  test("only gues loc", async () => {
    const testTid = "345";

    const pCST = moment()
      .subtract(3.5 * 60, "seconds")
      .format();

    console.log("pCST");
    console.log(pCST);
    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: pCST,
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
      current_clue_no: 3,
    });
    // jest.setTimeout(newTimeout)
    console.log("before time out");
    // setTimeout(() => {}, 5 * 1000);
    // await sleep(5 * 1000);
    await new Promise((r) => setTimeout(r, 2 * 1000));
    console.log("after time out");
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      guessed_location: "Poco Loco",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };
    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    // await powerUps(req, res);
    await guessLocationV1(testTid, req.body, res);
    // console.log("addUserPayload");
    // console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);

    expect(data.current_clue_no).toBe(4);

    // range 10000 + 20 + (60 - 3.5) - 100
    const actual = 10000 + 20 + (60 - 3.5) - 100;

    expect(
      (data.balance >= actual && data.balance <= actual + 1) ||
        (data.balance >= actual - 1 && data.balance <= actual)
    ).toBe(true);
    // ).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });

  test("only gues loc negative", async () => {
    const testTid = "345";

    const pCST = moment()
      // .subtract(3.5 * 60, "seconds")
      .subtract(65 * 60, "seconds")
      .format();

    console.log("pCST");
    console.log(pCST);
    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: pCST,
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
      current_clue_no: 3,
    });
    // jest.setTimeout(newTimeout)
    console.log("before time out");
    // setTimeout(() => {}, 5 * 1000);
    // await sleep(5 * 1000);
    await new Promise((r) => setTimeout(r, 2 * 1000));
    console.log("after time out");
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      guessed_location: "Poco Loco",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };
    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    // await powerUps(req, res);
    await guessLocationV1(testTid, req.body, res);
    // console.log("addUserPayload");
    // console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);

    expect(data.current_clue_no).toBe(4);

    // range 10000 + 20 + (60 - 3.5) - 100
    // const actual = 10000 + 20 + (60 - 3.5) - 100;
    const actual = 10000 + 20 + (60 - 60) - 100;

    expect(
      (data.balance >= actual && data.balance <= actual + 1) ||
        (data.balance >= actual - 1 && data.balance <= actual)
    ).toBe(true);
    // ).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });

  test("guess loc with coupon added. but coupon exhausted", async () => {
    const testTid = "345";
    const pCST = moment()
      // .subtract(3.5 * 60, "seconds")
      .subtract(55 * 60, "seconds")
      .format();

    console.log("pCST");
    console.log(pCST);

    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: pCST,
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
      current_clue_no: 3,
      // guess_loc_coupon: 1,
      guess_loc_coupon: 0,
    });
    // jest.setTimeout(newTimeout)
    console.log("before time out");
    // setTimeout(() => {}, 5 * 1000);
    // await sleep(5 * 1000);
    await new Promise((r) => setTimeout(r, 2 * 1000));
    console.log("after time out");
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      guessed_location: "Poco Loco",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };

    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    // await powerUps(req, res);
    await guessLocationV1(testTid, req.body, res);
    // console.log("addUserPayload");
    // console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);
    expect(data.guess_loc_coupon).toBe(0);

    expect(data.current_clue_no).toBe(4);

    // range 10000 + 20 + (60 - 3.5) - 100
    // const actual = 10000 + 20 + (60 - 3.5) - 100;
    const actual = 10000 + 20 + (60 - 55) - 100;
    // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

    expect(
      (data.balance >= actual && data.balance <= actual + 1) ||
        (data.balance >= actual - 1 && data.balance <= actual)
    ).toBe(true);
    // ).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });

  test("guess loc with coupon added. coupon not exhausted", async () => {
    const testTid = "345";
    const pCST = moment()
      // .subtract(3.5 * 60, "seconds")
      .subtract(55 * 60, "seconds")
      .format();

    console.log("pCST");
    console.log(pCST);

    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: pCST,
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
      current_clue_no: 3,
      guess_loc_coupon: 1,
      // guess_loc_coupon: 0,
    });
    // jest.setTimeout(newTimeout)
    console.log("before time out");
    // setTimeout(() => {}, 5 * 1000);
    // await sleep(5 * 1000);
    await new Promise((r) => setTimeout(r, 2 * 1000));
    console.log("after time out");
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      guessed_location: "Poco Loco",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };

    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    // await powerUps(req, res);
    await guessLocationV1(testTid, req.body, res);
    // console.log("addUserPayload");
    // console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);
    expect(data.guess_loc_coupon).toBe(0);

    expect(data.current_clue_no).toBe(4);

    // range 10000 + 20 + (60 - 3.5) - 100
    // const actual = 10000 + 20 + (60 - 3.5) - 100;
    // const actual = 10000 + 20 + (60 - 55) - 100;
    const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

    expect(
      (data.balance >= actual && data.balance <= actual + 1) ||
        (data.balance >= actual - 1 && data.balance <= actual)
    ).toBe(true);
    // ).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });
  test.only("only gues loc arbitary between 60", async () => {
    jest.setTimeout(10 * 60 * 1000);
    const testTid = "345";

    const pCST = moment()
      // .subtract(3.5 * 60, "seconds")
      .subtract(55 * 60, "seconds")
      .format();

    console.log("pCST");
    console.log(pCST);
    await updateTeamDataRT(testTid, {
      prev_clue_solved_timestamp: pCST,
      no_guessed_used: 0,
      balance: 10000,
      cid: "32",
      current_clue_no: 3,
    });
    // jest.setTimeout(newTimeout)
    console.log("before time out");
    // setTimeout(() => {}, 5 * 1000);
    // await sleep(5 * 1000);
    await new Promise((r) => setTimeout(r, 2 * 1000));
    console.log("after time out");
    let req = {};
    req.tid = testTid;
    const at = moment().format();

    req.body = {
      // guessed_location: "Poco Loco",
      guessed_location: "  DN    Nagar Metro ",
      current_balance: 10000,
      ask_timestamp: at,
      //   p1: "JTest 1",
      //   p2: "JTest 2",
      // curr_lat: 423.3423,
      // curr_lng: 423.3423,
      // tid: addUserPayload.t_id,
      // password: addUserPayload.t_id,
      // logout_loc_lat: "-999",
      // logout_loc_lng: "-999",
    };
    req.params = {};
    req.params.pid = "1";
    // console.log("addUserPayload");
    // console.log(addUserPayload);
    req.tid = "345";

    const res = {
      json: (payload) => {
        addUserPayload = payload;
      },
    };

    // await powerUps(req, res);
    await guessLocationV1(testTid, req.body, res);
    // console.log("addUserPayload");
    // console.log(addUserPayload);

    expect(addUserPayload["status"]).toBe("1");

    const data = await fetchTeamDataRT(testTid);

    expect(data.current_clue_no).toBe(4);

    // range 10000 + 20 + (60 - 3.5) - 100
    // const actual = 10000 + 20 + (60 - 3.5) - 100;
    const actual = 10000 + 20 + (60 - 55) - 100;

    expect(
      (data.balance >= actual && data.balance <= actual + 1) ||
        (data.balance >= actual - 1 && data.balance <= actual)
    ).toBe(true);
    // ).toBe(10000 + 20 + (60 - 3.5) - 100);

    expect(data.prev_clue_solved_timestamp).toBe(at);
  });

  // test("guess loc with spaces between", async () => {
  //   const testTid = "345";

  //   const pCST = moment()
  //     // .subtract(3.5 * 60, "seconds")
  //     .subtract(55 * 60, "seconds")
  //     .format();

  //   console.log("pCST");
  //   console.log(pCST);
  //   await updateTeamDataRT(testTid, {
  //     prev_clue_solved_timestamp: pCST,
  //     no_guessed_used: 0,
  //     balance: 10000,
  //     cid: "32",
  //     current_clue_no: 3,
  //   });
  //   // jest.setTimeout(newTimeout)
  //   console.log("before time out");
  //   // setTimeout(() => {}, 5 * 1000);
  //   // await sleep(5 * 1000);
  //   await new Promise((r) => setTimeout(r, 2 * 1000));
  //   console.log("after time out");
  //   let req = {};
  //   req.tid = testTid;
  //   const at = moment().format();

  //   req.body = {
  //     guessed_location: "Poco Loco",
  //     current_balance: 10000,
  //     ask_timestamp: at,
  //     //   p1: "JTest 1",
  //     //   p2: "JTest 2",
  //     // curr_lat: 423.3423,
  //     // curr_lng: 423.3423,
  //     // tid: addUserPayload.t_id,
  //     // password: addUserPayload.t_id,
  //     // logout_loc_lat: "-999",
  //     // logout_loc_lng: "-999",
  //   };
  //   req.params = {};
  //   req.params.pid = "1";
  //   // console.log("addUserPayload");
  //   // console.log(addUserPayload);
  //   req.tid = "345";

  //   const res = {
  //     json: (payload) => {
  //       addUserPayload = payload;
  //     },
  //   };

  //   // await powerUps(req, res);
  //   await guessLocationV1(testTid, req.body, res);
  //   // console.log("addUserPayload");
  //   // console.log(addUserPayload);

  //   expect(addUserPayload["status"]).toBe("1");

  //   const data = await fetchTeamDataRT(testTid);

  //   expect(data.current_clue_no).toBe(4);

  //   // range 10000 + 20 + (60 - 3.5) - 100
  //   // const actual = 10000 + 20 + (60 - 3.5) - 100;
  //   const actual = 10000 + 20 + (60 - 55) - 100;

  //   expect(
  //     (data.balance >= actual && data.balance <= actual + 1) ||
  //       (data.balance >= actual - 1 && data.balance <= actual)
  //   ).toBe(true);
  //   // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  //   expect(data.prev_clue_solved_timestamp).toBe(at);
  // });
});

// works correectly
test("check if discound", async () => {
  const tesTid = "345";
  await updateTeamDataRT(tesTid, {
    meter_off_coupon: 1,
  });
  const teamData = await fetchTeamDataRT(tesTid);
  expect(checkIfDiscount(teamData, 100, "meter_off_coupon")).toBe(0);
});

test("meter off with coupon", async () => {
  const testTid = "345";
  const oppTid = "161";
  const pCST = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60, "seconds")
    .format();

  const pCSTRanf = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60 * 60 * 24, "seconds")
    .format();

  console.log("pCST");
  console.log(pCST);

  await updateTeamDataRT(testTid, {
    prev_clue_solved_timestamp: pCST,
    no_guessed_used: 0,
    balance: 10000,
    cid: "32",
    current_clue_no: 3,
    meter_off_coupon: 1,
  });

  await updateTeamDataRT(oppTid, {
    is_meter_off: false,
    meter_off_on: pCSTRanf,
    is_invisible: false,
    // prev_clue_solved_timestamp: pCST,
    // no_guessed_used: 0,
    // balance: 10000,
    // cid: "32",
    // current_clue_no: 3,
    // meter_off_coupon: 1,
  });
  // jest.setTimeout(newTimeout)
  console.log("before time out");
  // setTimeout(() => {}, 5 * 1000);
  // await sleep(5 * 1000);
  await new Promise((r) => setTimeout(r, 2 * 1000));
  console.log("after time out");
  let req = {};
  req.tid = testTid;
  const at = moment().format();

  req.body = {
    // guessed_location: "Poco Loco",
    current_balance: 10000,
    ask_timestamp: at,
    opp_tid: "161",
    //   p1: "JTest 1",
    //   p2: "JTest 2",
    // curr_lat: 423.3423,
    // curr_lng: 423.3423,
    // tid: addUserPayload.t_id,
    // password: addUserPayload.t_id,
    // logout_loc_lat: "-999",
    // logout_loc_lng: "-999",
  };

  req.params = {};
  req.params.pid = "3";
  req.tid = "345";

  let addUserPayload = {};

  const res = {
    json: (payload) => {
      addUserPayload = payload;
    },
  };

  // await powerUps(req, res);
  // await guessLocationV1(testTid, req.body, res);
  await meterOff(testTid, req.body, res);

  console.log("addUserPayload");
  console.log(addUserPayload);
  // console.log("addUserPayload");
  // console.log(addUserPayload);

  expect(addUserPayload["status"]).toBe("1");

  const data = await fetchTeamDataRT(testTid);
  const oppData = await fetchTeamDataRT(oppTid);

  expect(data.meter_off_coupon).toBe(0);
  expect(oppData.is_meter_off).toBe(true);
  expect(oppData.meter_off_on).toBe(at);

  // expect(data.current_clue_no).toBe(4);

  // range 10000 + 20 + (60 - 3.5) - 100
  // const actual = 10000 + 20 + (60 - 3.5) - 100;
  // const actual = 10000 + 20 + (60 - 55) - 100;
  const actual = 10000; //- 100; because coupon
  // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

  expect(
    (data.balance >= actual && data.balance <= actual + 1) ||
      (data.balance >= actual - 1 && data.balance <= actual)
  ).toBe(true);
  // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  // expect(data.prev_clue_solved_timestamp).toBe(at);
});
test("meter off with coupon exhausted", async () => {
  const testTid = "345";
  const oppTid = "161";
  const pCST = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60, "seconds")
    .format();

  const pCSTRanf = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60 * 60 * 24, "seconds")
    .format();

  console.log("pCST");
  console.log(pCST);

  await updateTeamDataRT(testTid, {
    prev_clue_solved_timestamp: pCST,
    no_guessed_used: 0,
    balance: 10000,
    cid: "32",
    current_clue_no: 3,
    meter_off_coupon: 0,
  });

  await updateTeamDataRT(oppTid, {
    is_meter_off: false,
    meter_off_on: pCSTRanf,
    is_invisible: false,
    // prev_clue_solved_timestamp: pCST,
    // no_guessed_used: 0,
    // balance: 10000,
    // cid: "32",
    // current_clue_no: 3,
    // meter_off_coupon: 1,
  });
  // jest.setTimeout(newTimeout)
  console.log("before time out");
  // setTimeout(() => {}, 5 * 1000);
  // await sleep(5 * 1000);
  await new Promise((r) => setTimeout(r, 2 * 1000));
  console.log("after time out");
  let req = {};
  req.tid = testTid;
  const at = moment().format();

  req.body = {
    // guessed_location: "Poco Loco",
    current_balance: 10000,
    ask_timestamp: at,
    opp_tid: "161",
    //   p1: "JTest 1",
    //   p2: "JTest 2",
    // curr_lat: 423.3423,
    // curr_lng: 423.3423,
    // tid: addUserPayload.t_id,
    // password: addUserPayload.t_id,
    // logout_loc_lat: "-999",
    // logout_loc_lng: "-999",
  };

  req.params = {};
  req.params.pid = "3";
  req.tid = "345";

  let addUserPayload = {};

  const res = {
    json: (payload) => {
      addUserPayload = payload;
    },
  };

  // await powerUps(req, res);
  // await guessLocationV1(testTid, req.body, res);
  await meterOff(testTid, req.body, res);

  console.log("addUserPayload");
  console.log(addUserPayload);
  // console.log("addUserPayload");
  // console.log(addUserPayload);

  expect(addUserPayload["status"]).toBe("1");

  const data = await fetchTeamDataRT(testTid);
  const oppData = await fetchTeamDataRT(oppTid);

  expect(data.meter_off_coupon).toBe(0);
  expect(oppData.is_meter_off).toBe(true);
  expect(oppData.meter_off_on).toBe(at);

  // expect(data.current_clue_no).toBe(4);

  // range 10000 + 20 + (60 - 3.5) - 100
  // const actual = 10000 + 20 + (60 - 3.5) - 100;
  // const actual = 10000 + 20 + (60 - 55) - 100;
  const actual = 10000 - 100; //because coupon exhausted
  // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

  expect(
    (data.balance >= actual && data.balance <= actual + 1) ||
      (data.balance >= actual - 1 && data.balance <= actual)
  ).toBe(true);
  // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  // expect(data.prev_clue_solved_timestamp).toBe(at);
});

test("meter off with no coupon field", async () => {
  const testTid = "345";
  const oppTid = "161";
  const pCST = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60, "seconds")
    .format();

  const pCSTRanf = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60 * 60 * 24, "seconds")
    .format();

  console.log("pCST");
  console.log(pCST);

  await updateTeamDataRT(testTid, {
    prev_clue_solved_timestamp: pCST,
    no_guessed_used: 0,
    balance: 10000,
    cid: "32",
    current_clue_no: 3,
    // meter_off_coupon: 0,
  });

  await updateTeamDataRT(oppTid, {
    is_meter_off: false,
    meter_off_on: pCSTRanf,
    is_invisible: false,
    // prev_clue_solved_timestamp: pCST,
    // no_guessed_used: 0,
    // balance: 10000,
    // cid: "32",
    // current_clue_no: 3,
    // meter_off_coupon: 1,
  });
  // jest.setTimeout(newTimeout)
  console.log("before time out");
  // setTimeout(() => {}, 5 * 1000);
  // await sleep(5 * 1000);
  await new Promise((r) => setTimeout(r, 2 * 1000));
  console.log("after time out");
  let req = {};
  req.tid = testTid;
  const at = moment().format();

  req.body = {
    // guessed_location: "Poco Loco",
    current_balance: 10000,
    ask_timestamp: at,
    opp_tid: "161",
    //   p1: "JTest 1",
    //   p2: "JTest 2",
    // curr_lat: 423.3423,
    // curr_lng: 423.3423,
    // tid: addUserPayload.t_id,
    // password: addUserPayload.t_id,
    // logout_loc_lat: "-999",
    // logout_loc_lng: "-999",
  };

  req.params = {};
  req.params.pid = "3";
  req.tid = "345";

  let addUserPayload = {};

  const res = {
    json: (payload) => {
      addUserPayload = payload;
    },
  };

  // await powerUps(req, res);
  // await guessLocationV1(testTid, req.body, res);
  await meterOff(testTid, req.body, res);

  console.log("addUserPayload");
  console.log(addUserPayload);
  // console.log("addUserPayload");
  // console.log(addUserPayload);

  expect(addUserPayload["status"]).toBe("1");

  const data = await fetchTeamDataRT(testTid);
  const oppData = await fetchTeamDataRT(oppTid);

  // expect(data.meter_off_coupon).toBe(0); //ye field hoga hi nai
  expect(oppData.is_meter_off).toBe(true);
  expect(oppData.meter_off_on).toBe(at);

  // expect(data.current_clue_no).toBe(4);

  // range 10000 + 20 + (60 - 3.5) - 100
  // const actual = 10000 + 20 + (60 - 3.5) - 100;
  // const actual = 10000 + 20 + (60 - 55) - 100;
  const actual = 10000 - 100; //because coupon exhausted
  // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

  expect(
    (data.balance >= actual && data.balance <= actual + 1) ||
      (data.balance >= actual - 1 && data.balance <= actual)
  ).toBe(true);
  // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  // expect(data.prev_clue_solved_timestamp).toBe(at);
});

test("meter off with coupon", async () => {
  jest.setTimeout(10 * 1000);
  const testTid = "345";
  const oppTid = "161";
  const pCST = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60, "seconds")
    .format();

  const pCSTRanf = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60 * 60 * 24, "seconds")
    .format();

  console.log("pCST");
  console.log(pCST);

  await updateTeamDataRT(testTid, {
    prev_clue_solved_timestamp: pCST,
    no_guessed_used: 0,
    balance: 10000,
    cid: "32",
    current_clue_no: 3,
    freeze_team_coupon: 1,
  });

  await updateTeamDataRT(oppTid, {
    is_freezed: false,
    freezed_on: pCSTRanf,
    is_invisible: false,
    // prev_clue_solved_timestamp: pCST,
    // no_guessed_used: 0,
    // balance: 10000,
    // cid: "32",
    // current_clue_no: 3,
    // meter_off_coupon: 1,
  });
  // jest.setTimeout(newTimeout)
  console.log("before time out");
  // setTimeout(() => {}, 5 * 1000);
  // await sleep(5 * 1000);
  await new Promise((r) => setTimeout(r, 2 * 1000));
  console.log("after time out");
  let req = {};
  req.tid = testTid;
  const at = moment().format();

  req.body = {
    // guessed_location: "Poco Loco",
    current_balance: 10000,
    ask_timestamp: at,
    opp_tid: "161",
    //   p1: "JTest 1",
    //   p2: "JTest 2",
    // curr_lat: 423.3423,
    // curr_lng: 423.3423,
    // tid: addUserPayload.t_id,
    // password: addUserPayload.t_id,
    // logout_loc_lat: "-999",
    // logout_loc_lng: "-999",
  };

  req.params = {};
  req.params.pid = "3";
  req.tid = "345";

  let addUserPayload = {};

  const res = {
    json: (payload) => {
      addUserPayload = payload;
    },
  };

  // await powerUps(req, res);
  // await guessLocationV1(testTid, req.body, res);
  // await meterOff(testTid, req.body, res);
  // tid, payload, res, isForReverseFreeze;
  await freezeTeam(testTid, req.body, res, false);

  console.log("addUserPayload");
  console.log(addUserPayload);
  // console.log("addUserPayload");
  // console.log(addUserPayload);

  expect(addUserPayload["status"]).toBe("1");

  const data = await fetchTeamDataRT(testTid);
  const oppData = await fetchTeamDataRT(oppTid);

  // expect(data.meter_off_coupon).toBe(0); //ye field hoga hi nai
  expect(oppData.is_freezed).toBe(true);
  expect(oppData.freezed_on).toBe(at);

  // expect(data.current_clue_no).toBe(4);

  // range 10000 + 20 + (60 - 3.5) - 100
  // const actual = 10000 + 20 + (60 - 3.5) - 100;
  // const actual = 10000 + 20 + (60 - 55) - 100;
  const actual = 10000; //- 100; //because coupon exhausted
  // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

  expect(data.balance).toBe(10000);
  expect(
    (data.balance >= actual && data.balance <= actual + 1) ||
      (data.balance >= actual - 1 && data.balance <= actual)
  ).toBe(true);
  // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  // expect(data.prev_clue_solved_timestamp).toBe(at);
});

test("meter off with coupon", async () => {
  jest.setTimeout(10 * 1000);
  const testTid = "345";
  const oppTid = "161";
  const pCST = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60, "seconds")
    .format();

  const pCSTRanf = moment()
    // .subtract(3.5 * 60, "seconds")
    .subtract(55 * 60 * 60 * 24, "seconds")
    .format();

  console.log("pCST");
  console.log(pCST);

  await updateTeamDataRT(testTid, {
    prev_clue_solved_timestamp: pCST,
    no_guessed_used: 0,
    balance: 10000,
    cid: "32",
    current_clue_no: 3,
    freeze_team_coupon: 1,
  });

  await updateTeamDataRT(oppTid, {
    is_freezed: false,
    freezed_on: pCSTRanf,
    is_invisible: false,
    // prev_clue_solved_timestamp: pCST,
    // no_guessed_used: 0,
    // balance: 10000,
    // cid: "32",
    // current_clue_no: 3,
    // meter_off_coupon: 1,
  });
  // jest.setTimeout(newTimeout)
  console.log("before time out");
  // setTimeout(() => {}, 5 * 1000);
  // await sleep(5 * 1000);
  await new Promise((r) => setTimeout(r, 2 * 1000));
  console.log("after time out");
  let req = {};
  req.tid = testTid;
  const at = moment().format();

  req.body = {
    // guessed_location: "Poco Loco",
    current_balance: 10000,
    ask_timestamp: at,
    opp_tid: "161",
    //   p1: "JTest 1",
    //   p2: "JTest 2",
    // curr_lat: 423.3423,
    // curr_lng: 423.3423,
    // tid: addUserPayload.t_id,
    // password: addUserPayload.t_id,
    // logout_loc_lat: "-999",
    // logout_loc_lng: "-999",
  };

  req.params = {};
  req.params.pid = "3";
  req.tid = "345";

  let addUserPayload = {};

  const res = {
    json: (payload) => {
      addUserPayload = payload;
    },
  };

  // await powerUps(req, res);
  // await guessLocationV1(testTid, req.body, res);
  // await meterOff(testTid, req.body, res);
  // tid, payload, res, isForReverseFreeze;
  await freezeTeam(testTid, req.body, res, false);

  console.log("addUserPayload");
  console.log(addUserPayload);
  // console.log("addUserPayload");
  // console.log(addUserPayload);

  expect(addUserPayload["status"]).toBe("1");

  const data = await fetchTeamDataRT(testTid);
  const oppData = await fetchTeamDataRT(oppTid);

  // expect(data.meter_off_coupon).toBe(0); //ye field hoga hi nai
  expect(oppData.is_freezed).toBe(true);
  expect(oppData.freezed_on).toBe(at);

  // expect(data.current_clue_no).toBe(4);

  // range 10000 + 20 + (60 - 3.5) - 100
  // const actual = 10000 + 20 + (60 - 3.5) - 100;
  // const actual = 10000 + 20 + (60 - 55) - 100;
  const actual = 10000; //- 100; //because coupon exhausted
  // const actual = 10000 + 20 + (60 - 55); //- 100; no cost kyuki coupon used temp

  expect(data.balance).toBe(10000);
  expect(
    (data.balance >= actual && data.balance <= actual + 1) ||
      (data.balance >= actual - 1 && data.balance <= actual)
  ).toBe(true);
  // ).toBe(10000 + 20 + (60 - 3.5) - 100);

  // expect(data.prev_clue_solved_timestamp).toBe(at);
});
