import express from "express";
import {
  addClue,
  changeState,
  getClueFromCid,
  getHintCommon,
  getHintCommonv2,
  // getHint2,
  getNextClue,
  powerUps,
  updateBalance,
  updateTimeToStart,
} from "../controllers/game.js";
import auth from "../middleware/auth.js";
// import { addClue } from "../models/game_model.js";

const router = express.Router();

// "/game"
router.post("/get_next_clue", auth, getNextClue);
router.post("/change_state", auth, changeState);
//check this

router.post("/powerups/:pid", auth, powerUps);
// router.post("/get_hint_1", auth, getHintCommon);
router.post("/get_hint", auth, getHintCommonv2);
// router.post("/get_hint_2", auth, getHint2);
router.post("/get_clue_from_cid", auth, getClueFromCid);
router.post("/update_balance", auth, updateBalance);
// router.post("/add_clue", auth, addClue); //temp
router.post("/add_clue", addClue);
router.post("/update_time", auth, updateTimeToStart);

//clue id will be combinatio of bucket name and id

// do powerups here

export default router;
