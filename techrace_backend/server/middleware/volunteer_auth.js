import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const auth = async (req, res, next) => {
  try {
    // const token2 = jwt.sign(
    //   { email: "result.email", id: "result._id" },
    //   process.env.password,
    //   {
    //     expiresIn: "1111h",
    //   }
    // );

    // console.log(token2);

    // console.log(req.headers);
    // console.log("req.headers.authorization"); //this is un defined
    // console.log(req.headers.authorization); //this is un defined
    // next();
    // return;
    const token = req.headers.authorization.split(" ")[1];

    const isCustomAuth = token.length < 500;
    let decodedData;

    //below get what you want
    if (token && isCustomAuth) {
      console.log(token);
      console.log("token");
      decodedData = jwt.verify(token, process.env.password); // just like aes encryption

      // req.userId = decodedData?.id;
      // req.tid = decodedData?.tid;
      req.vid = decodedData?.vid;
      // console.log(req.tid);
    } else {
      decodedData = jwt.decode(token);
      req.userId = decodedData?.sub;
    }

    console.log("decodedData");
    console.log(decodedData);
    next();
  } catch (error) {
    // res.send("Error: Unauthentiated Request");
    res.json({
      status: "0",
      message: "Error: Unauthentiated Request",
    });
    console.error(error);
  }
};

export default auth;

// afterlogin return the token
// all the sensitive info should be stored in the token
// sensitive info like name. That's it
