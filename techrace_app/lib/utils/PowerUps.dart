import 'dart:collection';

import 'package:flutter/material.dart';

enum PowerUps {
  blank,
  guessLocation,
  freezeTeam,
  // reducePoints,
  meterOff,
  invisible,
  reverseFreezeTeam
  // switch (req.params.pid) {
  // case "1":
  // skipALocation(req.tid, data, res);
  // break;
  // case "2":
  // freezeTeam(req.tid, data, res);
  // break;
  // case "3":
  // reducePoints(req.tid, data, res);
  // break;
  // case "4":
  // meterOff(req.tid, data, res);
  // break;
  // case "5":
  // invisible(req.tid, data, res);
  // break;
  // case "6":
  // reverseFreezeTeam(req.tid, data, res);
  // break;
  // default:
  // break;
  // }

}

final powerUpMap = HashMap.from({
  PowerUps.blank: "",
  // PowerUps.freezeTeam: "Freeze",
  PowerUps.freezeTeam: {
    "name": "Freeze",
    "help":
        """Freeze any team in the race  for 10 mins. This will restrict them from any movement in app. They can not use other power cards as well after(except if they have reverse freeze).
If you were freezed, you cannot be freezed again for 15 mins after you get unfreeze.
Points: 125""",
    "cost":125,
    "icon": Icons.ac_unit_rounded


  },

  PowerUps.meterOff: {
    "name": "Meter Off",
    "help":
        """Meter is an useful indicator in TechRace app which conveys you how close you are to the clue location.
This power card will allow you to turn off any team's meter for 15 mins.
You can still use powercards even if your meter is off
Points: 130""",
    "cost":100,
    "icon": Icons.compass_calibration_rounded
  },
  PowerUps.invisible: {
    "name": "Invisibility",
    "help":
        """Become invisible from the leaderboard for 10 mins. When you are invisible, other teams won't be able to use any power card (except reverse freeze) on you.
But you can use any power card on any team.
Points: 100""",
    "cost":130,
    "icon": Icons.visibility_off
  },
  // PowerUps.reducePoints: {
  //   "name": "Reducer",
  //   "help": """Reduce other team's points by 100 points. Cost: 100 points"""
  // },
  PowerUps.guessLocation: {
    "name": "Skip a Location",
    "help": """This card will allow you to skip a location after you guess it correctly from the clue, enabling you to directly jump onto the next location!
Can only use once in entire race
Can't use after 11th location 
Points: 200""",
    "cost":200,
    "icon": Icons.location_on_rounded
  },
  PowerUps.reverseFreezeTeam: {
    "name": "Reverse Freeze",
    "help":
        """You are freezed! Don't worry. This power card  
Instantly defreezes your team. Can only be used within 60 seconds after getting frozen. It also reverses the freeze and team which freezed you will get freezed for 10 mins (they can't use Reverse freeze again in this case.)
Points: 175""",
    "cost":175,
    "icon": Icons.compass_calibration_rounded
  }
});


// update points 12:14