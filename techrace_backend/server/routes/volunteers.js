import express from "express";
import {
  changeState,
  loginVolunteer,
  registerTeam,
  resetFutureUndos,
  setEveryOneLogout,
  setEveryOnePlaying,
  updateTimeToStart,
} from "../controllers/volunteers.js";
import auth from "../middleware/auth.js";
// import { addClue } from "../models/game_model.js";

const router = express.Router();

// "/volunteers"
router.post("/login", loginVolunteer);
router.post("/register_team", registerTeam); //todo
router.post("/change_state", auth, changeState);
router.post("/set_everyone_playing", auth, setEveryOnePlaying);
router.post("/set_everyone_logged_out", auth, setEveryOneLogout);
router.post("/update_start_datetime", auth, updateTimeToStart);

//recalculate and futureUndo karo
router.post("/reset_future_undos", auth, resetFutureUndos);
// router.post("/get_solo_or_duo", auth, resetFutureUndos);

export default router;
