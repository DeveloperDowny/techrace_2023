import { async } from "@firebase/util";
import {
  createUser,
  addNewUserFirestore,
  addTeamRT,
  setIsLoggedInFirestore,
  saveLastLogoutLoc,
  addNewUserFirestorev2,
  addTeamRTv2Temp,
} from "../models/user_model.js";
import { WaitingForReg } from "../utils/GameStates.js";

export const logout = async (req, res) => {
  try {
    // save the loc too
    console.log(req.tid);
    let mPromises = [setIsLoggedInFirestore(req.tid, false)];

    // To Save Unnecessary database writes
    if (req.body.logout_loc_lat != "-999") {
      mPromises.push(saveLastLogoutLoc(req.tid, req.body));
    }
    // await setIsLoggedInFirestore(req.tid, false);
    // await saveLastLogoutLoc(req.tid, req.body);
    await Promise.all(mPromises);

    res.json({
      status: "1",
      message: "Logged Out Successfully",
    });
  } catch (error) {
    res.json({
      status: "0",
      message: "Log Out Failed\nMake sure your GPS Location is On",
      error: `${error}`,
    });
  }
};

export const newUser = async (req, res) => {
  try {
    const data = req.body;
    // const status = await addNewUserFirestore(data); //should not be in production
    const status = await addNewUserFirestorev2(data.tid, data);
    if (status == -999) {
      res.json({ status: "0", message: "Error occurred while adding" });
      return;
    }

    // res.json({ status: "1", message: "Added Successfully", t_id: status }); //checking

    // data.password = status;

    // prepare here
    // addTeamRT(status, data); //should be on in production
    // await addTeamRTv2Temp(status, data);
    await addTeamRTv2Temp(data.tid, data);

    res.json({ status: "1", message: "Added Successfully", t_id: data.tid });

    // Do you need to send the id?

    // let t = await createUser(data);
    // console.log(t);
    // res.send(await createUser(data));
    // console.log(data);
    // console.log(data.t);
    // res.send(`User Route`);
    // let theS = Math.random().toString().slice(2, 5);
    // console.log(theS);
  } catch (error) {
    res.json({ status: "0", message: `${error}`, t_id: "status" });
  }
};

// Could you walk us through what you did one by one
