import '../models/chapter.dart';

/// Static dummy chapter data for all subjects.
///
/// Keyed by the same subject IDs used in [SubjectsData].
/// This is the single source of truth for chapter content until
/// Firestore is introduced in a later phase.
abstract final class DummyChapters {
  static const Map<String, List<Chapter>> _bySubject = {
    'eng_physics': _engPhysics,
    'med_physics': _medPhysics,
    'eng_chemistry': _engChemistry,
    'med_chemistry': _medChemistry,
    'eng_mathematics': _engMaths,
    'med_biology': _medBiology,
  };

  /// Returns chapters for a given subject ID.
  /// Returns an empty list if the subject ID is unrecognised.
  static List<Chapter> forSubject(String subjectId) =>
      _bySubject[subjectId] ?? [];

  // ── Engineering Physics ──────────────────────────────────────────────────
  static const List<Chapter> _engPhysics = [
    Chapter(
        id: 'ep_01',
        title: 'Kinematics',
        totalQuestions: 120,
        completedQuestions: 76),
    Chapter(
        id: 'ep_02',
        title: 'Laws of Motion',
        totalQuestions: 98,
        completedQuestions: 42),
    Chapter(
        id: 'ep_03',
        title: 'Work, Energy & Power',
        totalQuestions: 84,
        completedQuestions: 0),
    Chapter(
        id: 'ep_04',
        title: 'Rotational Motion',
        totalQuestions: 112,
        completedQuestions: 0),
    Chapter(
        id: 'ep_05',
        title: 'Gravitation',
        totalQuestions: 76,
        completedQuestions: 0),
    Chapter(
        id: 'ep_06',
        title: 'Simple Harmonic Motion',
        totalQuestions: 68,
        completedQuestions: 0),
    Chapter(
        id: 'ep_07', title: 'Waves', totalQuestions: 72, completedQuestions: 0),
    Chapter(
        id: 'ep_08',
        title: 'Thermodynamics',
        totalQuestions: 96,
        completedQuestions: 0),
    Chapter(
        id: 'ep_09',
        title: 'Electrostatics',
        totalQuestions: 108,
        completedQuestions: 0),
    Chapter(
        id: 'ep_10',
        title: 'Current Electricity',
        totalQuestions: 114,
        completedQuestions: 0),
    Chapter(
        id: 'ep_11',
        title: 'Magnetism',
        totalQuestions: 88,
        completedQuestions: 0),
    Chapter(
        id: 'ep_12',
        title: 'Optics',
        totalQuestions: 102,
        completedQuestions: 0),
    Chapter(
        id: 'ep_13',
        title: 'Modern Physics',
        totalQuestions: 110,
        completedQuestions: 0),
  ];

  // ── Medical Physics ───────────────────────────────────────────────────────
  static const List<Chapter> _medPhysics = [
    Chapter(
        id: 'mp_01',
        title: 'Kinematics',
        totalQuestions: 88,
        completedQuestions: 30),
    Chapter(
        id: 'mp_02',
        title: 'Laws of Motion',
        totalQuestions: 72,
        completedQuestions: 72),
    Chapter(
        id: 'mp_03',
        title: 'Work, Energy & Power',
        totalQuestions: 64,
        completedQuestions: 0),
    Chapter(
        id: 'mp_04',
        title: 'Rotational Motion',
        totalQuestions: 58,
        completedQuestions: 0),
    Chapter(
        id: 'mp_05',
        title: 'Gravitation',
        totalQuestions: 52,
        completedQuestions: 0),
    Chapter(
        id: 'mp_06',
        title: 'Simple Harmonic Motion',
        totalQuestions: 48,
        completedQuestions: 0),
    Chapter(
        id: 'mp_07', title: 'Waves', totalQuestions: 56, completedQuestions: 0),
    Chapter(
        id: 'mp_08',
        title: 'Thermodynamics',
        totalQuestions: 68,
        completedQuestions: 0),
    Chapter(
        id: 'mp_09',
        title: 'Electrostatics',
        totalQuestions: 76,
        completedQuestions: 0),
    Chapter(
        id: 'mp_10',
        title: 'Current Electricity',
        totalQuestions: 62,
        completedQuestions: 0),
    Chapter(
        id: 'mp_11',
        title: 'Optics',
        totalQuestions: 84,
        completedQuestions: 0),
    Chapter(
        id: 'mp_12',
        title: 'Modern Physics',
        totalQuestions: 62,
        completedQuestions: 0),
  ];

  // ── Engineering Chemistry ─────────────────────────────────────────────────
  static const List<Chapter> _engChemistry = [
    Chapter(
        id: 'ec_01',
        title: 'Basic Concepts of Chemistry',
        totalQuestions: 64,
        completedQuestions: 64),
    Chapter(
        id: 'ec_02',
        title: 'Structure of Atom',
        totalQuestions: 78,
        completedQuestions: 50),
    Chapter(
        id: 'ec_03',
        title: 'Chemical Bonding',
        totalQuestions: 92,
        completedQuestions: 0),
    Chapter(
        id: 'ec_04',
        title: 'Thermodynamics',
        totalQuestions: 86,
        completedQuestions: 0),
    Chapter(
        id: 'ec_05',
        title: 'Equilibrium',
        totalQuestions: 94,
        completedQuestions: 0),
    Chapter(
        id: 'ec_06',
        title: 'Redox Reactions',
        totalQuestions: 58,
        completedQuestions: 0),
    Chapter(
        id: 'ec_07',
        title: 'Organic Chemistry Basics',
        totalQuestions: 102,
        completedQuestions: 0),
    Chapter(
        id: 'ec_08',
        title: 'Hydrocarbons',
        totalQuestions: 88,
        completedQuestions: 0),
    Chapter(
        id: 'ec_09',
        title: 'Coordination Compounds',
        totalQuestions: 76,
        completedQuestions: 0),
    Chapter(
        id: 'ec_10',
        title: 'Electrochemistry',
        totalQuestions: 82,
        completedQuestions: 0),
    Chapter(
        id: 'ec_11',
        title: 'Polymers',
        totalQuestions: 48,
        completedQuestions: 0),
    Chapter(
        id: 'ec_12',
        title: 'Biomolecules',
        totalQuestions: 52,
        completedQuestions: 0),
  ];

  // ── Medical Chemistry ─────────────────────────────────────────────────────
  static const List<Chapter> _medChemistry = [
    Chapter(
        id: 'mc_01',
        title: 'Basic Concepts of Chemistry',
        totalQuestions: 54,
        completedQuestions: 0),
    Chapter(
        id: 'mc_02',
        title: 'Structure of Atom',
        totalQuestions: 62,
        completedQuestions: 0),
    Chapter(
        id: 'mc_03',
        title: 'Chemical Bonding',
        totalQuestions: 74,
        completedQuestions: 0),
    Chapter(
        id: 'mc_04',
        title: 'Thermodynamics',
        totalQuestions: 68,
        completedQuestions: 0),
    Chapter(
        id: 'mc_05',
        title: 'Equilibrium',
        totalQuestions: 78,
        completedQuestions: 0),
    Chapter(
        id: 'mc_06',
        title: 'Organic Chemistry Basics',
        totalQuestions: 86,
        completedQuestions: 0),
    Chapter(
        id: 'mc_07',
        title: 'Hydrocarbons',
        totalQuestions: 72,
        completedQuestions: 0),
    Chapter(
        id: 'mc_08',
        title: 'Biomolecules',
        totalQuestions: 64,
        completedQuestions: 0),
    Chapter(
        id: 'mc_09',
        title: 'Polymers',
        totalQuestions: 44,
        completedQuestions: 0),
    Chapter(
        id: 'mc_10',
        title: 'Environmental Chemistry',
        totalQuestions: 38,
        completedQuestions: 0),
  ];

  // ── Engineering Mathematics ───────────────────────────────────────────────
  static const List<Chapter> _engMaths = [
    Chapter(
        id: 'em_01',
        title: 'Sets, Relations & Functions',
        totalQuestions: 96,
        completedQuestions: 96),
    Chapter(
        id: 'em_02',
        title: 'Complex Numbers',
        totalQuestions: 88,
        completedQuestions: 60),
    Chapter(
        id: 'em_03',
        title: 'Quadratic Equations',
        totalQuestions: 84,
        completedQuestions: 0),
    Chapter(
        id: 'em_04',
        title: 'Permutations & Combinations',
        totalQuestions: 78,
        completedQuestions: 0),
    Chapter(
        id: 'em_05',
        title: 'Binomial Theorem',
        totalQuestions: 66,
        completedQuestions: 0),
    Chapter(
        id: 'em_06',
        title: 'Sequences & Series',
        totalQuestions: 82,
        completedQuestions: 0),
    Chapter(
        id: 'em_07',
        title: 'Limits, Continuity & Differentiability',
        totalQuestions: 104,
        completedQuestions: 0),
    Chapter(
        id: 'em_08',
        title: 'Integral Calculus',
        totalQuestions: 118,
        completedQuestions: 0),
    Chapter(
        id: 'em_09',
        title: 'Differential Equations',
        totalQuestions: 76,
        completedQuestions: 0),
    Chapter(
        id: 'em_10',
        title: 'Coordinate Geometry',
        totalQuestions: 112,
        completedQuestions: 0),
    Chapter(
        id: 'em_11',
        title: 'Three Dimensional Geometry',
        totalQuestions: 68,
        completedQuestions: 0),
    Chapter(
        id: 'em_12',
        title: 'Vector Algebra',
        totalQuestions: 72,
        completedQuestions: 0),
    Chapter(
        id: 'em_13',
        title: 'Statistics & Probability',
        totalQuestions: 94,
        completedQuestions: 0),
    Chapter(
        id: 'em_14',
        title: 'Trigonometry',
        totalQuestions: 102,
        completedQuestions: 0),
  ];

  // ── Medical Biology ───────────────────────────────────────────────────────
  static const List<Chapter> _medBiology = [
    Chapter(
        id: 'mb_01',
        title: 'The Living World',
        totalQuestions: 48,
        completedQuestions: 48),
    Chapter(
        id: 'mb_02',
        title: 'Biological Classification',
        totalQuestions: 62,
        completedQuestions: 62),
    Chapter(
        id: 'mb_03',
        title: 'Plant Kingdom',
        totalQuestions: 74,
        completedQuestions: 40),
    Chapter(
        id: 'mb_04',
        title: 'Animal Kingdom',
        totalQuestions: 82,
        completedQuestions: 0),
    Chapter(
        id: 'mb_05',
        title: 'Morphology of Flowering Plants',
        totalQuestions: 68,
        completedQuestions: 0),
    Chapter(
        id: 'mb_06',
        title: 'Cell: The Unit of Life',
        totalQuestions: 88,
        completedQuestions: 0),
    Chapter(
        id: 'mb_07',
        title: 'Cell Cycle & Cell Division',
        totalQuestions: 64,
        completedQuestions: 0),
    Chapter(
        id: 'mb_08',
        title: 'Transport in Plants',
        totalQuestions: 52,
        completedQuestions: 0),
    Chapter(
        id: 'mb_09',
        title: 'Photosynthesis',
        totalQuestions: 76,
        completedQuestions: 0),
    Chapter(
        id: 'mb_10',
        title: 'Respiration in Plants',
        totalQuestions: 58,
        completedQuestions: 0),
    Chapter(
        id: 'mb_11',
        title: 'Human Physiology',
        totalQuestions: 104,
        completedQuestions: 0),
    Chapter(
        id: 'mb_12',
        title: 'Reproduction',
        totalQuestions: 92,
        completedQuestions: 0),
    Chapter(
        id: 'mb_13',
        title: 'Genetics & Evolution',
        totalQuestions: 98,
        completedQuestions: 0),
    Chapter(
        id: 'mb_14',
        title: 'Ecology',
        totalQuestions: 72,
        completedQuestions: 0),
  ];

  // Prevent instantiation
  DummyChapters._();
}
