import express from "express";

import { logout, newUser } from "../controllers/users.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// router.post("/new_user", auth, newUser);
router.post("/new_user", newUser); //temp removing auth

// /users/logout
router.post("/logout", auth, logout);

export default router;
