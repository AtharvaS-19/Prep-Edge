# PrepEdge — Firestore Database Schema

> **Sprint 10.3 Design Reference**
> This document defines the complete Firestore schema for PrepEdge.
> Nothing is implemented yet — this is the authoritative design spec for Sprint 10.4 and beyond.

---

## Design Principles

| Principle | Decision |
|-----------|----------|
| **Source of truth** | `attempts` subcollection — all progress is derived from raw attempt events |
| **No duplicate progress** | `chapterProgress` and `subjectProgress` documents are NOT stored; they are computed client-side from attempts, exactly as `ChapterProgress.fromAttempts()` does today |
| **Stable IDs** | `Question.id`, `Chapter.id`, `Subject.id` are already stable string identifiers — used as Firestore document IDs |
| **Flat documents** | No nested maps inside attempt documents (matches `QuestionAttempt` design intent) |
| **Per-user isolation** | All user data lives under `users/{uid}/` — no cross-user reads |
| **Question catalog is static** | Questions, chapters and subjects are read-only content delivered as a Firestore collection; they are not per-user data |

---

## Collection Hierarchy

```
firestore-root/
│
├── users/                          ← per-user data
│   └── {uid}/                      ← document: user profile
│       ├── bookmarks/              ← subcollection
│       │   └── {questionId}/       ← document: one per bookmarked question
│       ├── mistakes/               ← subcollection
│       │   └── {questionId}/       ← document: one per current wrong answer
│       └── attempts/               ← subcollection
│           └── {attemptId}/        ← document: one per submission event
│
└── catalog/                        ← read-only content (future)
    ├── subjects/
    │   └── {subjectId}/
    ├── chapters/
    │   └── {chapterId}/
    └── questions/
        └── {questionId}/
```

> **Note:** The `catalog` collections replace `DummyChapters`, `DummyQuestions`, and `SubjectsData` in a future sprint. This schema document focuses on **user data** — the catalog schema is out of scope for Sprint 10.3.

---

## Collection: `users`

### Path
`users/{uid}`

### Description
One document per authenticated Firebase user.
Created on first sign-in. `uid` matches `FirebaseAuth.currentUser.uid`.

### Fields

| Field | Type | Notes |
|-------|------|-------|
| `uid` | `String` | Mirrors the document ID. Stored for convenience in queries. |
| `displayName` | `String?` | From signup form. Nullable until set. |
| `email` | `String` | Firebase Auth email. |
| `createdAt` | `Timestamp` | Server timestamp set once on document creation. |
| `lastActiveAt` | `Timestamp` | Updated on each app launch. Used for "inactive user" analytics later. |
| `examStream` | `String` | `'engineering'` or `'medical'`. Mirrors `ExamStream` enum. Default: `'engineering'`. |

### Example Document
```json
{
  "uid": "xKj2mLp9...",
  "displayName": "Arjun Sharma",
  "email": "arjun@example.com",
  "createdAt": "2026-07-04T18:00:00Z",
  "lastActiveAt": "2026-07-04T22:00:00Z",
  "examStream": "engineering"
}
```

---

## Subcollection: `users/{uid}/bookmarks`

### Path
`users/{uid}/bookmarks/{questionId}`

### Description
One document per bookmarked question.
Document ID is the `Question.id` — no auto-generated IDs.
This makes toggle operations a simple `set` / `delete` with a known path.

### Fields

| Field | Type | Notes |
|-------|------|-------|
| `questionId` | `String` | Mirrors the document ID. |
| `subjectId` | `String` | Denormalised for grouping on BookmarksScreen. |
| `chapterId` | `String` | Denormalised for navigation to the correct practice route. |
| `bookmarkedAt` | `Timestamp` | For ordering bookmarks chronologically. |

### Example Document
```json
{
  "questionId": "ep_01_q3",
  "subjectId": "eng_physics",
  "chapterId": "ep_01",
  "bookmarkedAt": "2026-07-04T19:30:00Z"
}
```

### Provider Mapping
| Current Provider | Firestore Operation |
|-----------------|---------------------|
| `BookmarkNotifier.toggle(id)` | `set` (add) or `delete` (remove) at `bookmarks/{questionId}` |
| `bookmarkProvider` state (`List<String>`) | Query all docs in `bookmarks/`, map to `doc.id` list |

### Why not a field on `users`?
Storing bookmarks as an array field on the user document hits Firestore's 1 MB document size limit and prevents efficient querying.

---

## Subcollection: `users/{uid}/mistakes`

### Path
`users/{uid}/mistakes/{questionId}`

### Description
One document per question that is currently in the student's "wrong answers" list.
Document ID is `Question.id` — matches the `WrongAnswer.questionId` identity rule in `MistakesNotifier`.

A document is **added** when the student answers wrong, **deleted** when they later answer correctly (mirroring `MistakesNotifier.remove()`).

### Fields

| Field | Type | Notes |
|-------|------|-------|
| `questionId` | `String` | Mirrors the document ID. |
| `subjectId` | `String` | For grouping and navigation. |
| `chapterId` | `String` | For navigation to the practice route. |
| `chapterTitle` | `String` | Denormalised for display on MistakesScreen without a join. |
| `attemptedAt` | `Timestamp` | When the wrong answer was last recorded. |

### Example Document
```json
{
  "questionId": "ep_02_q1",
  "subjectId": "eng_physics",
  "chapterId": "ep_02",
  "chapterTitle": "Laws of Motion",
  "attemptedAt": "2026-07-04T20:15:00Z"
}
```

### Provider Mapping
| Current Provider | Firestore Operation |
|-----------------|---------------------|
| `MistakesNotifier.record(answer)` | `set` at `mistakes/{questionId}` |
| `MistakesNotifier.remove(id)` | `delete` at `mistakes/{questionId}` |
| `mistakesProvider` state (`List<WrongAnswer>`) | Query all docs in `mistakes/`, map to `WrongAnswer` list |

---

## Subcollection: `users/{uid}/attempts`

### Path
`users/{uid}/attempts/{attemptId}`

### Description
The **core source of truth** for the entire learning engine.
One document per submission event (`_onSubmit` in PracticeScreen).
Document IDs are auto-generated by Firestore (`doc().id` or server-generated).

All progress statistics (`ChapterProgress`, `SubjectProgress`, `ProgressStats`, insights) are **derived client-side** from this collection — exactly as they are today from the in-memory `List<QuestionAttempt>`.

### Fields

| Field | Type | Notes |
|-------|------|-------|
| `attemptId` | `String` | Mirrors the auto-generated document ID. |
| `questionId` | `String` | Stable `Question.id`. |
| `subjectId` | `String` | Denormalised for subject-scoped queries. |
| `chapterId` | `String` | Denormalised for chapter-scoped queries. |
| `selectedOption` | `Number` (int) | 0-based index of the student's choice. |
| `correctOption` | `Number` (int) | 0-based index of the correct answer. Denormalised for offline analytics. |
| `isCorrect` | `Boolean` | Pre-computed; avoids `selectedOption == correctOption` on every read. |
| `attemptedAt` | `Timestamp` | Firestore server timestamp on write. |
| `timeTakenMs` | `Number` (int) | `Duration.inMilliseconds` — simpler than a Firestore Duration. |
| `attemptNumber` | `Number` (int) | 1 for first attempt, 2 for retry, etc. Computed by the notifier. |

> **Note:** `Duration` is stored as `timeTakenMs` (integer milliseconds) because Firestore has no native duration type.
> On read, reconstruct via `Duration(milliseconds: timeTakenMs)`.

### Example Document
```json
{
  "attemptId": "abc123...",
  "questionId": "ep_01_q3",
  "subjectId": "eng_physics",
  "chapterId": "ep_01",
  "selectedOption": 2,
  "correctOption": 2,
  "isCorrect": true,
  "attemptedAt": "2026-07-04T20:30:00Z",
  "timeTakenMs": 47000,
  "attemptNumber": 1
}
```

### Provider Mapping
| Current Provider | Firestore Operation |
|-----------------|---------------------|
| `LearningNotifier.record(attempt)` | `add` to `attempts/` (auto-ID) |
| `learningProvider` state (`List<QuestionAttempt>`) | Listen to `attempts/` ordered by `attemptedAt` |
| `chapterProgressProvider(chapterId)` | Query `attempts/` where `chapterId == x`, compute `ChapterProgress.fromAttempts()` |
| `subjectProgressProvider(subjectId)` | Query `attempts/` where `subjectId == x`, compute `SubjectProgress.fromAttempts()` |
| `progressStatsProvider` | Listen to entire `attempts/` collection |
| `latestAttemptProvider` | Query `attempts/` ordered by `attemptedAt desc`, limit 1 |

### Query Indexes Required
| Query | Fields to Index |
|-------|----------------|
| All attempts for a chapter | `chapterId ASC, attemptedAt ASC` |
| All attempts for a subject | `subjectId ASC, attemptedAt ASC` |
| Latest attempt overall | `attemptedAt DESC` |
| Latest attempt per question | `questionId ASC, attemptedAt DESC` |

> These composite indexes must be created in the Firebase Console or via `firestore.indexes.json` before the queries run in production.

---

## Derived Data (NOT Stored)

The following are computed entirely from `attempts` on the client. They must **never** be stored as Firestore documents:

| Derived Value | Source |
|--------------|--------|
| `ChapterProgress` | `attempts` filtered by `chapterId` |
| `SubjectProgress` | `attempts` filtered by `subjectId` |
| `ProgressStats` | Full `attempts` collection |
| `weakestChapterProvider` | Derived from `attempts` grouped by chapter |
| `strongestChapterProvider` | Same |
| `mostPracticedChapterProvider` | Same |
| `recentlyCompletedQuestionsProvider` | Latest N distinct `questionId` values from `attempts` |

Storing these as documents would create a dual source of truth, introduce write amplification (one practice session → multiple writes), and make consistency harder to guarantee.

---

## Relationships

```
FirebaseAuth.User (uid)
        │
        └─── users/{uid}                      [1:1]
                ├── bookmarks/{questionId}    [1:N]  N = number of bookmarks
                ├── mistakes/{questionId}     [1:N]  N = current wrong answers
                └── attempts/{attemptId}      [1:N]  N = all submission events
```

`questionId`, `subjectId`, `chapterId` appear as **denormalised string fields** inside user documents. They are not Firestore document references. This is intentional:
- Avoids `getDoc` joins on every read.
- Keeps reads single-collection (cheaper and faster).
- Matches the current in-memory model exactly.

---

## Security Rules (Design Sketch)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── User profile ────────────────────────────────────────────────────────
    match /users/{uid} {
      // A user can only read and write their own profile document.
      allow read, write: if request.auth != null && request.auth.uid == uid;

      // ── Bookmarks ──────────────────────────────────────────────────────────
      match /bookmarks/{questionId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
        // write includes create, update, delete (toggle semantics)
      }

      // ── Mistakes ───────────────────────────────────────────────────────────
      match /mistakes/{questionId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }

      // ── Attempts ───────────────────────────────────────────────────────────
      match /attempts/{attemptId} {
        // Read own attempts; create is allowed; update/delete are not.
        allow read, create: if request.auth != null && request.auth.uid == uid;
        allow update, delete: if false; // attempts are immutable events
      }
    }

    // ── Catalog (read-only content) ──────────────────────────────────────────
    match /catalog/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // catalog is managed via Firebase Console / admin SDK only
    }
  }
}
```

### Key Rules
| Rule | Rationale |
|------|-----------|
| Auth required for all reads | No anonymous access to student data |
| UID check on every user subcollection | Prevents one user from reading another's data |
| `attempts` are create-only | Attempt history is immutable — no editing past answers |
| `catalog` is read-only | Questions/chapters are admin-managed content |

---

## Repository Mapping (Future Sprint)

When repositories are implemented, each maps to exactly one Firestore collection:

| Repository | Collection | Key Methods |
|-----------|-----------|-------------|
| `UserRepository` | `users/{uid}` | `createProfile()`, `updateLastActive()` |
| `BookmarkRepository` | `users/{uid}/bookmarks` | `add(questionId)`, `remove(questionId)`, `watchAll()` |
| `MistakesRepository` | `users/{uid}/mistakes` | `record(WrongAnswer)`, `remove(questionId)`, `watchAll()` |
| `LearningRepository` | `users/{uid}/attempts` | `record(QuestionAttempt)`, `watchAll()`, `watchForChapter(id)` |

Each repository will be injected into its corresponding Riverpod notifier via `authRepositoryProvider`-style `Provider<T>` — preserving the existing `Presentation → Provider → Repository → Firebase` architecture.

---

## Migration Path (DummyData → Firestore)

| Current | Future |
|---------|--------|
| `BookmarkNotifier` state = `List<String>` in memory | `BookmarkNotifier` wraps `BookmarkRepository`, state synced from Firestore stream |
| `MistakesNotifier` state = `List<WrongAnswer>` in memory | `MistakesNotifier` wraps `MistakesRepository`, state synced from Firestore stream |
| `LearningNotifier` state = `List<QuestionAttempt>` in memory | `LearningNotifier` wraps `LearningRepository`, writes to Firestore + listens to stream |
| `DummyQuestions`, `DummyChapters`, `SubjectsData` | Replaced by catalog Firestore reads in a dedicated content repository |

The provider **public API does not change** during migration. Screens call the same methods (`toggle`, `record`, `remove`). Only the notifier internals change.
