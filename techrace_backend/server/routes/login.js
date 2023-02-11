import express from "express";
import { login } from "../controllers/login.js";
import auth from "../middleware/auth.js";

const router = express.Router();

router.post("/", login); // this should not need middleware

export default router;
