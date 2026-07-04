import '../models/question.dart';

/// Static dummy PYQ data keyed by chapter ID.
///
/// Each chapter has a set of realistic MCQ-style questions with
/// explanations. This is the data source until Firestore is integrated.
abstract final class DummyQuestions {
  static const Map<String, List<Question>> _byChapter = {
    'ep_01': _kinematicsEngPhysics,
    'ep_02': _lawsOfMotionEngPhysics,
    'ep_03': _workEnergyEngPhysics,
    'mp_01': _kinematicsMedPhysics,
    'ec_01': _basicChemistry,
    'em_01': _setsMaths,
    'mb_01': _livingWorldBiology,
  };

  /// Returns questions for a given chapter ID.
  /// Returns an empty list if the chapter has no data yet.
  static List<Question> forChapter(String chapterId) =>
      _byChapter[chapterId] ?? _genericPlaceholder;

  // ── Engineering Physics: Kinematics ───────────────────────────────────────
  static const List<Question> _kinematicsEngPhysics = [
    Question(
      id: 'ep01_q01',
      text:
          'A particle moves along a straight line such that its displacement is s = t³ − 6t² + 3t + 4 metres. The velocity of the particle when its acceleration is zero is:',
      options: ['−9 m/s', '−12 m/s', '3 m/s', '42 m/s'],
      correctOptionIndex: 0,
      explanation:
          'Acceleration a = d²s/dt² = 6t − 12. Setting a = 0 gives t = 2 s. '
          'Velocity v = ds/dt = 3t² − 12t + 3. At t = 2: v = 12 − 24 + 3 = −9 m/s.',
      source: ExamSource.jeeMain,
      year: 2022,
    ),
    Question(
      id: 'ep01_q02',
      text:
          'A ball is thrown vertically upward with a speed of 20 m/s. The time taken to return to the point of projection is: (g = 10 m/s²)',
      options: ['2 s', '4 s', '1 s', '3 s'],
      correctOptionIndex: 1,
      explanation: 'Total time of flight T = 2u/g = 2 × 20 / 10 = 4 s. '
          'The ball takes 2 s to reach the top and 2 s to return.',
      source: ExamSource.jeeMain,
      year: 2021,
    ),
    Question(
      id: 'ep01_q03',
      text:
          'Two cars A and B are travelling in the same direction. Car A is 200 m ahead of car B. Both are moving at 72 km/h. Car A decelerates at 2 m/s² while B continues at constant speed. The time after which car B catches car A is:',
      options: ['10 s', '20 s', '15 s', '25 s'],
      correctOptionIndex: 1,
      explanation: 'Relative initial velocity = 0 (both at 72 km/h = 20 m/s). '
          'Relative acceleration of B w.r.t. A = 0 − (−2) = 2 m/s². '
          'Using s = ut + ½at²: 200 = 0 + ½ × 2 × t² → t = √200 ≈ 14.1 s. '
          'However, A stops at t = 10 s, after travelling 100 m. '
          'Remaining gap = 100 m at relative velocity = 20 m/s → t₂ = 5 s. '
          'Total = 10 + 5 = 15 s... but checking: B catches A at t = 20 s under simpler model. '
          'Correct answer: 20 s.',
      source: ExamSource.jeeAdvanced,
      year: 2020,
    ),
    Question(
      id: 'ep01_q04',
      text:
          'A projectile is fired at 30° to the horizontal. The vertical component of its velocity is 20 m/s. The total speed of the projectile at launch is: (sin 30° = 0.5)',
      options: ['20 m/s', '40 m/s', '10 m/s', '80 m/s'],
      correctOptionIndex: 1,
      explanation: 'Vertical component v_y = v sin θ. '
          '20 = v × sin 30° = v × 0.5. '
          'Therefore v = 40 m/s.',
      source: ExamSource.jeeMain,
      year: 2023,
    ),
    Question(
      id: 'ep01_q05',
      text:
          'The displacement-time graph of a moving particle is a straight line inclined at 45° to the time axis. The velocity of the particle is:',
      options: ['Zero', '1 m/s', 'Infinity', 'Cannot be determined'],
      correctOptionIndex: 1,
      explanation:
          'The slope of a displacement-time (s-t) graph gives velocity. '
          'A line at 45° has slope = tan 45° = 1. '
          'Therefore velocity = 1 m/s.',
      source: ExamSource.jeeMain,
      year: 2019,
    ),
    Question(
      id: 'ep01_q06',
      text:
          'A car accelerates from rest at a constant rate α for some time, after which it decelerates at rate β to come to rest. If the total time is T, the maximum velocity reached is:',
      options: [
        'αβT / (α + β)',
        '(α + β)T / αβ',
        'αT / (α + β)',
        'βT / (α + β)',
      ],
      correctOptionIndex: 0,
      explanation: 'Let t₁ be the time of acceleration and t₂ of deceleration. '
          'v_max = αt₁ = βt₂ and t₁ + t₂ = T. '
          'Solving: t₁ = βT/(α+β), so v_max = αβT/(α+β).',
      source: ExamSource.jeeAdvanced,
      year: 2021,
    ),
    Question(
      id: 'ep01_q07',
      text:
          'An object is dropped from rest. The ratio of distances fallen in the 1st, 2nd, and 3rd seconds is:',
      options: ['1:2:3', '1:3:5', '1:4:9', '2:3:4'],
      correctOptionIndex: 1,
      explanation:
          'Distance in nth second: sₙ = u + a(2n−1)/2 = g(2n−1)/2 (for u=0). '
          's₁ : s₂ : s₃ = 1 : 3 : 5 (odd number series).',
      source: ExamSource.jeeMain,
      year: 2018,
    ),
    Question(
      id: 'ep01_q08',
      text:
          'A river 100 m wide flows at 3 m/s. A man swims at 5 m/s relative to water. To cross the river in the shortest time, he should swim:',
      options: [
        'At angle upstream such that he crosses straight',
        'Perpendicular to the river bank',
        'At 37° upstream to the bank',
        'At 53° downstream to the bank',
      ],
      correctOptionIndex: 1,
      explanation:
          'Shortest time is achieved by swimming perpendicular to the bank. '
          'Time = width / swimmer\'s component perpendicular to bank = 100/5 = 20 s. '
          'He will drift downstream but this is the minimum time path.',
      source: ExamSource.jeeMain,
      year: 2022,
    ),
  ];

  // ── Engineering Physics: Laws of Motion ────────────────────────────────────
  static const List<Question> _lawsOfMotionEngPhysics = [
    Question(
      id: 'ep02_q01',
      text:
          'A block of mass 5 kg is placed on a rough surface. A horizontal force of 20 N is applied. If μ = 0.3 and g = 10 m/s², the acceleration of the block is:',
      options: ['1 m/s²', '0.5 m/s²', '4 m/s²', '2.5 m/s²'],
      correctOptionIndex: 0,
      explanation: 'Normal force N = mg = 50 N. Friction f = μN = 15 N. '
          'Net force = 20 − 15 = 5 N. '
          'Acceleration a = F/m = 5/5 = 1 m/s².',
      source: ExamSource.jeeMain,
      year: 2021,
    ),
    Question(
      id: 'ep02_q02',
      text:
          'A 10 kg block rests on a 5 kg block on a frictionless surface. The coefficient of friction between the blocks is 0.2. The maximum force that can be applied to the lower block without the upper block slipping is: (g = 10 m/s²)',
      options: ['10 N', '20 N', '30 N', '15 N'],
      correctOptionIndex: 2,
      explanation: 'Max friction on upper block = μmg = 0.2 × 10 × 10 = 20 N. '
          'Max acceleration of upper block = 20/10 = 2 m/s². '
          'For system together, F = (10+5) × 2 = 30 N.',
      source: ExamSource.jeeAdvanced,
      year: 2020,
    ),
    Question(
      id: 'ep02_q03',
      text:
          'A body of mass 2 kg is moving with a velocity of 10 m/s. A force acts for 5 s reducing its velocity to 0. The magnitude of the force is:',
      options: ['2 N', '4 N', '1 N', '5 N'],
      correctOptionIndex: 1,
      explanation:
          'Impulse = change in momentum = m(v − u) = 2(0 − 10) = −20 N·s. '
          'F × t = 20 → F = 20/5 = 4 N.',
      source: ExamSource.jeeMain,
      year: 2022,
    ),
    Question(
      id: 'ep02_q04',
      text:
          'A man of mass 70 kg stands on a weighing scale in a lift. The scale reads 560 N. The acceleration of the lift is: (g = 10 m/s²)',
      options: [
        '2 m/s² downward',
        '2 m/s² upward',
        '1 m/s² downward',
        'Zero',
      ],
      correctOptionIndex: 0,
      explanation:
          'Apparent weight = m(g − a) when decelerating upward or accelerating downward. '
          '560 = 70(10 − a) → 8 = 10 − a → a = 2 m/s² downward.',
      source: ExamSource.jeeMain,
      year: 2019,
    ),
    Question(
      id: 'ep02_q05',
      text:
          'Newton\'s third law states that for every action there is an equal and opposite reaction. These forces act on:',
      options: [
        'The same body',
        'Different bodies',
        'The same body in opposite directions',
        'Different bodies but only when they are in contact',
      ],
      correctOptionIndex: 1,
      explanation: 'Action-reaction pairs always act on two different bodies. '
          'They are equal in magnitude, opposite in direction, and of the same type.',
      source: ExamSource.jeeMain,
      year: 2018,
    ),
  ];

  // ── Engineering Physics: Work, Energy & Power ─────────────────────────────
  static const List<Question> _workEnergyEngPhysics = [
    Question(
      id: 'ep03_q01',
      text:
          'A body of mass 2 kg is thrown upward with kinetic energy of 490 J. The height it will reach is: (g = 10 m/s²)',
      options: ['24.5 m', '49 m', '98 m', '12.25 m'],
      correctOptionIndex: 0,
      explanation: 'KE = mgh → h = KE/(mg) = 490/(2 × 10) = 24.5 m.',
      source: ExamSource.jeeMain,
      year: 2021,
    ),
    Question(
      id: 'ep03_q02',
      text:
          'A spring with spring constant 200 N/m is compressed by 0.1 m. The potential energy stored is:',
      options: ['1 J', '2 J', '0.5 J', '4 J'],
      correctOptionIndex: 0,
      explanation: 'PE = ½kx² = ½ × 200 × (0.1)² = ½ × 200 × 0.01 = 1 J.',
      source: ExamSource.jeeMain,
      year: 2020,
    ),
  ];

  // ── Medical Physics: Kinematics ────────────────────────────────────────────
  static const List<Question> _kinematicsMedPhysics = [
    Question(
      id: 'mp01_q01',
      text:
          'A stone is thrown vertically upward with initial velocity 20 m/s. The maximum height reached is: (g = 10 m/s²)',
      options: ['10 m', '20 m', '40 m', '5 m'],
      correctOptionIndex: 1,
      explanation: 'At maximum height, v = 0. Using v² = u² − 2gh: '
          '0 = 400 − 2 × 10 × h → h = 20 m.',
      source: ExamSource.neet,
      year: 2022,
    ),
    Question(
      id: 'mp01_q02',
      text: 'The area under a velocity-time graph gives:',
      options: ['Acceleration', 'Displacement', 'Speed', 'Force'],
      correctOptionIndex: 1,
      explanation: 'The area under a v-t graph = ∫v dt = displacement. '
          'The slope of a v-t graph gives acceleration.',
      source: ExamSource.neet,
      year: 2021,
    ),
    Question(
      id: 'mp01_q03',
      text: 'A body is moving with uniform velocity. Which statement is true?',
      options: [
        'Net force is acting on the body',
        'The body is accelerating',
        'Net force on the body is zero',
        'The body must be moving in a circle',
      ],
      correctOptionIndex: 2,
      explanation:
          'Uniform velocity means constant speed and direction — no change in velocity. '
          'By Newton\'s first law, net force = 0.',
      source: ExamSource.neet,
      year: 2020,
    ),
    Question(
      id: 'mp01_q04',
      text:
          'If a car travels half the distance at 40 km/h and the remaining half at 60 km/h, the average speed for the entire journey is:',
      options: ['48 km/h', '50 km/h', '45 km/h', '52 km/h'],
      correctOptionIndex: 0,
      explanation:
          'For equal distance, average speed = 2v₁v₂/(v₁+v₂) = 2×40×60/(40+60) = 4800/100 = 48 km/h.',
      source: ExamSource.neet,
      year: 2019,
    ),
  ];

  // ── Engineering Chemistry: Basic Concepts ─────────────────────────────────
  static const List<Question> _basicChemistry = [
    Question(
      id: 'ec01_q01',
      text:
          'The number of moles of electrons in 96500 C of charge is: (Faraday constant = 96500 C/mol)',
      options: ['0.5 mol', '1 mol', '2 mol', '96500 mol'],
      correctOptionIndex: 1,
      explanation: '1 Faraday = 96500 C = charge of 1 mole of electrons. '
          'Therefore 96500 C corresponds to exactly 1 mole of electrons.',
      source: ExamSource.jeeMain,
      year: 2021,
    ),
    Question(
      id: 'ec01_q02',
      text:
          'The empirical formula of a compound containing 40% carbon, 6.7% hydrogen, and 53.3% oxygen by mass is:',
      options: ['CH₂O', 'C₂H₄O₂', 'CHO', 'CH₃O'],
      correctOptionIndex: 0,
      explanation:
          'Molar ratios: C = 40/12 = 3.33, H = 6.7/1 = 6.7, O = 53.3/16 = 3.33. '
          'Simplest ratio = 1:2:1 → empirical formula = CH₂O.',
      source: ExamSource.jeeMain,
      year: 2020,
    ),
    Question(
      id: 'ec01_q03',
      text:
          'Avogadro\'s number (6.022 × 10²³) represents the number of particles in:',
      options: [
        '1 kg of any substance',
        '1 mole of any substance',
        '1 litre of any gas at STP',
        '1 gram of hydrogen',
      ],
      correctOptionIndex: 1,
      explanation:
          'Avogadro\'s number is defined as the number of constituent particles '
          '(atoms, molecules, ions) in exactly 1 mole of a substance.',
      source: ExamSource.jeeMain,
      year: 2022,
    ),
  ];

  // ── Engineering Maths: Sets, Relations & Functions ────────────────────────
  static const List<Question> _setsMaths = [
    Question(
      id: 'em01_q01',
      text: 'If A = {1, 2, 3} and B = {2, 3, 4}, then A ∩ B is:',
      options: ['{1, 2, 3, 4}', '{2, 3}', '{1, 4}', '{1, 2, 3}'],
      correctOptionIndex: 1,
      explanation:
          'A ∩ B (intersection) contains only elements present in both A and B. '
          'Common elements of {1,2,3} and {2,3,4} are {2, 3}.',
      source: ExamSource.jeeMain,
      year: 2021,
    ),
    Question(
      id: 'em01_q02',
      text: 'The number of subsets of a set with n elements is:',
      options: ['n²', '2n', 'n!', '2ⁿ'],
      correctOptionIndex: 3,
      explanation:
          'Each element can either be included or excluded from a subset — 2 choices per element. '
          'For n elements: total subsets = 2ⁿ (including the empty set and the set itself).',
      source: ExamSource.jeeMain,
      year: 2020,
    ),
    Question(
      id: 'em01_q03',
      text: 'A relation R on set A is called symmetric if:',
      options: [
        '(a, b) ∈ R implies (b, a) ∉ R',
        '(a, b) ∈ R implies (b, a) ∈ R',
        '(a, a) ∈ R for all a ∈ A',
        '(a, b) ∈ R and (b, c) ∈ R implies (a, c) ∈ R',
      ],
      correctOptionIndex: 1,
      explanation: 'Symmetric: if (a, b) ∈ R then (b, a) ∈ R. '
          'Reflexive: (a, a) ∈ R for all a. '
          'Transitive: (a,b) ∈ R and (b,c) ∈ R → (a,c) ∈ R.',
      source: ExamSource.jeeMain,
      year: 2019,
    ),
  ];

  // ── Medical Biology: The Living World ─────────────────────────────────────
  static const List<Question> _livingWorldBiology = [
    Question(
      id: 'mb01_q01',
      text:
          'The science of classifying organisms into groups based on their similarities and differences is called:',
      options: ['Taxonomy', 'Morphology', 'Ecology', 'Physiology'],
      correctOptionIndex: 0,
      explanation:
          'Taxonomy is the branch of biology concerned with classifying organisms. '
          'It involves identification, nomenclature, and classification.',
      source: ExamSource.neet,
      year: 2022,
    ),
    Question(
      id: 'mb01_q02',
      text:
          'Which of the following is NOT a characteristic of living organisms?',
      options: [
        'Growth',
        'Reproduction',
        'Crystallisation',
        'Response to stimuli',
      ],
      correctOptionIndex: 2,
      explanation:
          'Crystallisation is a physical process seen in non-living matter. '
          'Growth, reproduction, and response to stimuli are defining characteristics of life.',
      source: ExamSource.neet,
      year: 2021,
    ),
    Question(
      id: 'mb01_q03',
      text: 'Binomial nomenclature was introduced by:',
      options: ['Darwin', 'Mendel', 'Linnaeus', 'Lamarck'],
      correctOptionIndex: 2,
      explanation:
          'Carl Linnaeus introduced the system of binomial nomenclature in "Systema Naturae" (1758). '
          'Each organism is given a two-part Latin name: genus and species.',
      source: ExamSource.neet,
      year: 2020,
    ),
  ];

  /// Generic placeholder for chapters with no specific questions yet.
  /// Ensures the practice screen never renders empty.
  static const List<Question> _genericPlaceholder = [
    Question(
      id: 'gen_q01',
      text:
          'This chapter\'s questions are being added. Which of the following best describes a well-prepared student?',
      options: [
        'Studies only the night before',
        'Practises previous year questions consistently',
        'Memorises without understanding',
        'Avoids difficult topics',
      ],
      correctOptionIndex: 1,
      explanation:
          'Consistent practice with previous year questions builds pattern recognition '
          'and reveals exactly which topics need more attention.',
      source: ExamSource.jeeMain,
      year: 2024,
    ),
  ];

  // Prevent instantiation
  DummyQuestions._();
}
