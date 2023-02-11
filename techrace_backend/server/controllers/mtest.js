import { testFunc } from "../models/user_model.js";

export const testRoute = (req, res) => {
  testFunc();
  res.send(`Test Route`);
};
