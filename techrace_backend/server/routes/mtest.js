import express from "express";
import { testRoute } from "../controllers/mtest.js";
import auth from "../middleware/auth.js";

const router = express.Router();

router.get("/", auth, testRoute);

export default router;
