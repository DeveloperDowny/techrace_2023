import express from "express";
import bodyParser from "body-parser";
import testRoute from "./routes/mtest.js";
import userRoute from "./routes/users.js";
import loginRoute from "./routes/login.js";
import gameRoute from "./routes/game.js";
import volunteersRoute from "./routes/volunteers.js";

import multer from "multer";
import cors from "cors";

const app = express();
const upload = multer();
const PORT = 5000;

app.use(upload.array());
app.use(cors());

// app.use(cors()); //when used by website
app.use(bodyParser.json());
app.use("/test", testRoute);
app.use("/users", userRoute);
app.use("/login", loginRoute);
// app.use("/logout", loginRoute);
app.use("/game", gameRoute);
app.use("/volunteers", volunteersRoute);

app.get("/", (req, res) => res.send("v3 1254 Hello from Homepage."));

app.listen(PORT, () =>
  console.log(`Server running on port: http://localhost:${PORT}`)
);

//filhaal do trash
