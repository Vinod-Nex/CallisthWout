class Exercise {
  final String name;
  final String sets;
  final String reps;
  final String note;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.note,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as String,
      reps: json['reps'] as String,
      note: json['note'] as String,
    );
  }
}

class WorkoutDay {
  final List<Exercise> push;
  final List<Exercise> pull;
  final List<Exercise> leg;

  const WorkoutDay({
    required this.push,
    required this.pull,
    required this.leg,
  });
}

class Week {
  final int num;
  final String phase;
  final String theme;
  final List<Exercise> push;
  final List<Exercise> pull;
  final List<Exercise> leg;

  const Week({
    required this.num,
    required this.phase,
    required this.theme,
    required this.push,
    required this.pull,
    required this.leg,
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    var pushList = json['push'] as List;
    var pullList = json['pull'] as List;
    var legList = json['leg'] as List;

    return Week(
      num: json['num'] as int,
      phase: json['phase'] as String,
      theme: json['theme'] as String,
      push: pushList.map((e) => Exercise.fromJson(e)).toList(),
      pull: pullList.map((e) => Exercise.fromJson(e)).toList(),
      leg: legList.map((e) => Exercise.fromJson(e)).toList(),
    );
  }
}

class WorkoutData {
  static final List<Week> weeks = _weeksJson.map((json) => Week.fromJson(json)).toList();

  static const List<Map<String, dynamic>> _weeksJson = [
    {
      "num": 1, "phase": "Month 1", "theme": "Reactivation — standard difficulty, perfect form",
      "push": [
        { "name": "Wide push-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Full ROM, controlled" },
        { "name": "Diamond push-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Tricep focus" },
        { "name": "Pike push-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Shoulder overhead press sim" },
        { "name": "Decline push-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Upper chest" },
        { "name": "Dips (between chairs)", "sets": "4 sets", "reps": "10–12 reps", "note": "Tricep lockout" },
        { "name": "Pseudo planche push-ups", "sets": "4 sets", "reps": "10 reps", "note": "Lean forward, hands at hips" },
      ],
      "pull": [
        { "name": "Dead hang", "sets": "4 sets", "reps": "30 sec", "note": "Shoulder decompression" },
        { "name": "Wide grip pull-ups", "sets": "4 sets", "reps": "8–10 reps", "note": "Lat width" },
        { "name": "Chin-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Bicep-dominant" },
        { "name": "Inverted rows (table)", "sets": "4 sets", "reps": "12 reps", "note": "Mid-back" },
        { "name": "Towel bicep curls", "sets": "4 sets", "reps": "10–12 reps", "note": "Door + towel" },
        { "name": "Scapular pull-ups", "sets": "4 sets", "reps": "10 reps", "note": "Scap retraction" },
      ],
      "leg": [
        { "name": "Bodyweight squats", "sets": "4 sets", "reps": "20–25 reps", "note": "Deep, full ROM" },
        { "name": "Bulgarian split squats", "sets": "4 sets", "reps": "10–12 each", "note": "Rear foot elevated" },
        { "name": "Hip hinges / RDL", "sets": "4 sets", "reps": "12 reps", "note": "Hamstring stretch" },
        { "name": "Glute bridges", "sets": "4 sets", "reps": "15 reps", "note": "2 sec squeeze at top" },
        { "name": "Walking lunges", "sets": "4 sets", "reps": "12 each leg", "note": "Long stride" },
        { "name": "Calf raises (single leg)", "sets": "4 sets", "reps": "15 reps", "note": "Step edge, full ROM" },
      ]
    },
    {
      "num": 2, "phase": "Month 1", "theme": "Increased reps — push to 12 on all exercises",
      "push": [
        { "name": "Wide push-ups", "sets": "4 sets", "reps": "12 reps", "note": "Add 2 more than Wk1" },
        { "name": "Archer push-ups", "sets": "4 sets", "reps": "10 each side", "note": "Unilateral chest load" },
        { "name": "Pike push-ups (feet elevated)", "sets": "4 sets", "reps": "12 reps", "note": "Sharper angle" },
        { "name": "Decline push-ups (chair)", "sets": "4 sets", "reps": "12 reps", "note": "Higher decline" },
        { "name": "Close grip dips", "sets": "4 sets", "reps": "12 reps", "note": "Elbow tracking back" },
        { "name": "Hindu push-ups", "sets": "4 sets", "reps": "12 reps", "note": "Shoulder mobility" },
      ],
      "pull": [
        { "name": "Wide grip pull-ups", "sets": "4 sets", "reps": "10–12 reps", "note": "Increase 2 reps" },
        { "name": "L-sit chin-ups", "sets": "4 sets", "reps": "8–10 reps", "note": "Core + bicep" },
        { "name": "Commando pull-ups", "sets": "4 sets", "reps": "10 reps", "note": "Alternate sides" },
        { "name": "Inverted rows (chest to bar)", "sets": "4 sets", "reps": "12 reps", "note": "Full retraction" },
        { "name": "Hammer towel curls", "sets": "4 sets", "reps": "12 reps", "note": "Neutral grip" },
        { "name": "Explosive pull-ups", "sets": "4 sets", "reps": "8 reps", "note": "Controlled lower" },
      ],
      "leg": [
        { "name": "Jump squats", "sets": "4 sets", "reps": "15 reps", "note": "Explosive quad power" },
        { "name": "Bulgarian split squats", "sets": "4 sets", "reps": "12 each", "note": "Pause at bottom 1 sec" },
        { "name": "Nordic curls (door anchor)", "sets": "4 sets", "reps": "8 reps", "note": "Slow eccentric" },
        { "name": "Single leg glute bridge", "sets": "4 sets", "reps": "12 each", "note": "Unilateral" },
        { "name": "Reverse lunges", "sets": "4 sets", "reps": "12 each", "note": "Step back, knee hovers" },
        { "name": "Calf raises + hold at peak", "sets": "4 sets", "reps": "15 reps", "note": "3 sec hold" },
      ]
    },
    {
      "num": 3, "phase": "Month 1", "theme": "Add tempo — 2 sec down, explode up",
      "push": [
        { "name": "Slow archer push-ups", "sets": "4 sets", "reps": "10 each", "note": "2 sec descent" },
        { "name": "Diamond push-ups (feet elevated)", "sets": "4 sets", "reps": "12 reps", "note": "Combined stress" },
        { "name": "Pike push-up (max elevation)", "sets": "4 sets", "reps": "12 reps", "note": "Almost vertical" },
        { "name": "Wide + decline combo", "sets": "4 sets", "reps": "8+8 reps", "note": "Back-to-back" },
        { "name": "Tricep push-ups (straight elbows)", "sets": "4 sets", "reps": "12 reps", "note": "Elbows pinned" },
        { "name": "Explosive diamond push-ups", "sets": "4 sets", "reps": "8 reps", "note": "Clap optional" },
      ],
      "pull": [
        { "name": "Slow negative pull-ups (5 sec)", "sets": "4 sets", "reps": "8 reps", "note": "Eccentric overload" },
        { "name": "Archer pull-ups", "sets": "4 sets", "reps": "8 each", "note": "Alternate arm straight" },
        { "name": "Close grip chin-ups", "sets": "4 sets", "reps": "12 reps", "note": "Hands touching" },
        { "name": "Inverted rows (feet elevated)", "sets": "4 sets", "reps": "12 reps", "note": "Horizontal pull harder" },
        { "name": "Chin-up hold at top", "sets": "4 sets", "reps": "5 reps, 3 sec hold", "note": "Isometric peak" },
        { "name": "Towel curls (slow negative)", "sets": "4 sets", "reps": "12 reps", "note": "4 sec lower" },
      ],
      "leg": [
        { "name": "Pistol squat progression", "sets": "4 sets", "reps": "8–10 each", "note": "Assisted if needed" },
        { "name": "Slow Bulgarian splits (3 sec down)", "sets": "4 sets", "reps": "10 each", "note": "Eccentric" },
        { "name": "Nordic curls full", "sets": "4 sets", "reps": "8 reps", "note": "Hands catch at bottom" },
        { "name": "Donkey kicks + hold", "sets": "4 sets", "reps": "12 each", "note": "2 sec top contraction" },
        { "name": "Side lunges", "sets": "4 sets", "reps": "12 each", "note": "Adductor stretch" },
        { "name": "Jump rope calf (simulate)", "sets": "4 sets", "reps": "30 sec", "note": "Fast balls of feet" },
      ]
    },
    {
      "num": 4, "phase": "Month 1", "theme": "Deload week — 2 sets per exercise, same reps, focus recovery",
      "push": [
        { "name": "Wide push-ups", "sets": "2 sets", "reps": "12 reps", "note": "Active recovery" },
        { "name": "Pike push-ups", "sets": "2 sets", "reps": "10 reps", "note": "Restore shoulder ROM" },
        { "name": "Diamond push-ups", "sets": "2 sets", "reps": "10 reps", "note": "Easy pace" },
        { "name": "Dips", "sets": "2 sets", "reps": "10 reps", "note": "Full ROM" },
        { "name": "Hindu push-ups", "sets": "2 sets", "reps": "10 reps", "note": "Mobility emphasis" },
        { "name": "Wrist circles + push-up hold", "sets": "2 sets", "reps": "30 sec", "note": "Joint prep" },
      ],
      "pull": [
        { "name": "Dead hang", "sets": "2 sets", "reps": "45 sec", "note": "Shoulder health" },
        { "name": "Wide pull-ups", "sets": "2 sets", "reps": "10 reps", "note": "Easy pace" },
        { "name": "Chin-ups", "sets": "2 sets", "reps": "10 reps", "note": "Full hang between" },
        { "name": "Inverted rows", "sets": "2 sets", "reps": "12 reps", "note": "Controlled" },
        { "name": "Scapular pull-ups", "sets": "2 sets", "reps": "12 reps", "note": "Shoulder blade focus" },
        { "name": "Towel curls", "sets": "2 sets", "reps": "10 reps", "note": "Light effort" },
      ],
      "leg": [
        { "name": "Bodyweight squats", "sets": "2 sets", "reps": "20 reps", "note": "Deep, slow" },
        { "name": "Walking lunges", "sets": "2 sets", "reps": "12 each", "note": "Recovery pace" },
        { "name": "Glute bridges", "sets": "2 sets", "reps": "15 reps", "note": "Hip activation" },
        { "name": "Calf raises", "sets": "2 sets", "reps": "15 reps", "note": "Full ROM" },
        { "name": "Hip circles + leg swings", "sets": "2 sets", "reps": "30 sec each", "note": "Mobility" },
        { "name": "Pigeon stretch hold", "sets": "2 sets", "reps": "45 sec each", "note": "Glute/hip" },
      ]
    },
    {
      "num": 5, "phase": "Month 2", "theme": "Load increase — add 20 kg bag to pull/leg, harder push progressions",
      "push": [
        { "name": "Archer push-ups (full range)", "sets": "4 sets", "reps": "12 each", "note": "Near one-arm" },
        { "name": "Pike push-up → wall handstand hold", "sets": "4 sets", "reps": "10 reps + 10 sec", "note": "Power + static" },
        { "name": "Decline diamond push-ups", "sets": "4 sets", "reps": "12 reps", "note": "Feet on chair" },
        { "name": "Explosive wide push-ups", "sets": "4 sets", "reps": "10 reps", "note": "Hands leave floor" },
        { "name": "Tricep push-up + hold at bottom", "sets": "4 sets", "reps": "10 + 3 sec", "note": "Isometric" },
        { "name": "Pseudo planche hold", "sets": "4 sets", "reps": "20 sec hold", "note": "Scap depression" },
      ],
      "pull": [
        { "name": "Weighted pull-ups (20 kg bag)", "sets": "4 sets", "reps": "6–8 reps", "note": "Wear bag on back" },
        { "name": "Weighted chin-ups (20 kg bag)", "sets": "4 sets", "reps": "6–8 reps", "note": "Supinated grip" },
        { "name": "Archer pull-ups", "sets": "4 sets", "reps": "8 each side", "note": "Progressive one-arm" },
        { "name": "Slow negative pull-ups (5 sec)", "sets": "4 sets", "reps": "6 reps", "note": "Eccentric overload" },
        { "name": "Commando pull-ups", "sets": "4 sets", "reps": "10 reps", "note": "Full range, alternate" },
        { "name": "Towel curls (20 kg bag foot)", "sets": "4 sets", "reps": "10 reps", "note": "Foot on bag for resistance" },
      ],
      "leg": [
        { "name": "Weighted Bulgarian splits (bag)", "sets": "4 sets", "reps": "10 each", "note": "Bag on shoulders" },
        { "name": "Pistol squats (full)", "sets": "4 sets", "reps": "8–10 each", "note": "No assist" },
        { "name": "Nordic curls (slow negative)", "sets": "4 sets", "reps": "8 reps", "note": "3 sec lower" },
        { "name": "Single leg glute bridge + bag", "sets": "4 sets", "reps": "12 each", "note": "Bag on hip" },
        { "name": "Jump lunges (explosive)", "sets": "4 sets", "reps": "12 each", "note": "Plyometric" },
        { "name": "Weighted calf raises (bag)", "sets": "4 sets", "reps": "15 reps", "note": "Hold bag at chest" },
      ]
    },
    {
      "num": 6, "phase": "Month 2", "theme": "High volume — increase reps, keep bag weight",
      "push": [
        { "name": "Archer push-ups (slower tempo)", "sets": "4 sets", "reps": "12 each", "note": "3 sec descent" },
        { "name": "Wall handstand hold", "sets": "4 sets", "reps": "20–30 sec", "note": "Build comfort" },
        { "name": "Decline archer push-ups", "sets": "4 sets", "reps": "10 each", "note": "Feet elevated + unilateral" },
        { "name": "Explosive clap push-ups", "sets": "4 sets", "reps": "10 reps", "note": "Plyometric chest" },
        { "name": "Dips with 20 kg bag", "sets": "4 sets", "reps": "8–10 reps", "note": "Bag in lap if chair dip" },
        { "name": "Pike push-ups (slow + full)", "sets": "4 sets", "reps": "15 reps", "note": "Volume increase" },
      ],
      "pull": [
        { "name": "Weighted pull-ups (20 kg)", "sets": "4 sets", "reps": "8 reps", "note": "+2 reps from Wk5" },
        { "name": "Muscle-up progression", "sets": "4 sets", "reps": "5–8 reps", "note": "Pull + transition + dip" },
        { "name": "L-sit pull-ups", "sets": "4 sets", "reps": "8 reps", "note": "Core compression" },
        { "name": "Weighted inverted rows (bag on chest)", "sets": "4 sets", "reps": "12 reps", "note": "Full retraction" },
        { "name": "Chin-up 21s", "sets": "4 sets", "reps": "7+7+7", "note": "Bottom, top, full" },
        { "name": "Towel curl (slow 4 sec negative)", "sets": "4 sets", "reps": "12 reps", "note": "Time under tension" },
      ],
      "leg": [
        { "name": "Pistol squats (weighted bag hold)", "sets": "4 sets", "reps": "8 each", "note": "Bag as counterbalance then resistance" },
        { "name": "Jump squats (max height)", "sets": "4 sets", "reps": "15 reps", "note": "Explosive" },
        { "name": "Nordic curls + push-up catch", "sets": "4 sets", "reps": "8 reps", "note": "Full lower + push up" },
        { "name": "Step-ups with bag", "sets": "4 sets", "reps": "12 each", "note": "Chair height, bag on back" },
        { "name": "Glute bridge marching", "sets": "4 sets", "reps": "20 reps", "note": "Alternate leg lift" },
        { "name": "Calf raises (1.5 rep method)", "sets": "4 sets", "reps": "12 reps", "note": "Up, half down, up, full down" },
      ]
    },
    {
      "num": 7, "phase": "Month 2", "theme": "Max intensity — peak loading, muscle failure approach",
      "push": [
        { "name": "Weighted dips (bag on lap)", "sets": "4 sets", "reps": "8–10 reps", "note": "Heaviest push yet" },
        { "name": "One-arm push-up progression", "sets": "4 sets", "reps": "8 each", "note": "Knee or full" },
        { "name": "Handstand push-up (wall)", "sets": "4 sets", "reps": "6–8 reps", "note": "Head to floor" },
        { "name": "Decline archer push-ups", "sets": "4 sets", "reps": "10 each", "note": "Feet high, arm wide" },
        { "name": "Explosive dips", "sets": "4 sets", "reps": "8 reps", "note": "Lock out aggressively" },
        { "name": "Planche lean hold", "sets": "4 sets", "reps": "25–30 sec", "note": "Max scapular load" },
      ],
      "pull": [
        { "name": "Weighted pull-ups (20 kg)", "sets": "4 sets", "reps": "8–10 reps", "note": "Close to limit" },
        { "name": "Muscle-ups", "sets": "4 sets", "reps": "5–8 reps", "note": "Full reps if possible" },
        { "name": "One-arm hang + row", "sets": "4 sets", "reps": "8 each", "note": "Alternate arm" },
        { "name": "Explosive chin-ups (chest to bar)", "sets": "4 sets", "reps": "8 reps", "note": "Pull high" },
        { "name": "Negative muscle-up (slow lower)", "sets": "4 sets", "reps": "5 reps", "note": "10 sec descent" },
        { "name": "Weighted towel curls", "sets": "4 sets", "reps": "10 reps", "note": "Standing tension" },
      ],
      "leg": [
        { "name": "Weighted pistol squats (hold bag)", "sets": "4 sets", "reps": "8 each", "note": "Full depth" },
        { "name": "Shrimp squats", "sets": "4 sets", "reps": "8 each", "note": "Back foot held" },
        { "name": "Nordic curls (full)", "sets": "4 sets", "reps": "10 reps", "note": "Consistent form" },
        { "name": "Weighted step-ups (bag)", "sets": "4 sets", "reps": "12 each", "note": "Knee drive up" },
        { "name": "Jump lunge + hold (2 sec)", "sets": "4 sets", "reps": "10 each", "note": "Power + static" },
        { "name": "Calf raises (bag at chest)", "sets": "4 sets", "reps": "20 reps", "note": "Max volume" },
      ]
    },
    {
      "num": 8, "phase": "Month 2", "theme": "Final deload + assessment — 2 sets, test max reps",
      "push": [
        { "name": "Max rep push-ups (test)", "sets": "2 sets", "reps": "Max reps", "note": "Track PR" },
        { "name": "Archer push-ups", "sets": "2 sets", "reps": "10 each", "note": "Active recovery" },
        { "name": "Handstand hold (wall)", "sets": "2 sets", "reps": "30 sec", "note": "Skill work" },
        { "name": "Pike push-ups", "sets": "2 sets", "reps": "12 reps", "note": "Light" },
        { "name": "Dips", "sets": "2 sets", "reps": "12 reps", "note": "Easy pace" },
        { "name": "Wrist mobility + shoulder CARs", "sets": "2 sets", "reps": "60 sec each", "note": "Joint health" },
      ],
      "pull": [
        { "name": "Max rep pull-ups (test)", "sets": "2 sets", "reps": "Max reps", "note": "Track PR" },
        { "name": "Weighted pull-up (20 kg)", "sets": "2 sets", "reps": "6 reps", "note": "Strength test" },
        { "name": "Chin-ups", "sets": "2 sets", "reps": "10 reps", "note": "Easy" },
        { "name": "Dead hang (max time)", "sets": "2 sets", "reps": "Max hold", "note": "Grip test" },
        { "name": "Inverted rows", "sets": "2 sets", "reps": "12 reps", "note": "Active recovery" },
        { "name": "Towel curls", "sets": "2 sets", "reps": "12 reps", "note": "Light pump" },
      ],
      "leg": [
        { "name": "Pistol squat test", "sets": "2 sets", "reps": "Max each leg", "note": "Track PR" },
        { "name": "Jump squats", "sets": "2 sets", "reps": "15 reps", "note": "Explosive finish" },
        { "name": "Bulgarian split squats", "sets": "2 sets", "reps": "12 each", "note": "No bag" },
        { "name": "Glute bridges", "sets": "2 sets", "reps": "15 reps", "note": "Recovery" },
        { "name": "Walking lunges", "sets": "2 sets", "reps": "12 each", "note": "Easy pace" },
        { "name": "Full hip mobility flow", "sets": "2 sets", "reps": "90 sec", "note": "Assessment prep" },
      ]
    }
  ];
}
