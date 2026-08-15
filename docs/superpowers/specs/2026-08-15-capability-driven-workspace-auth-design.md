# Capability-Driven Workspace Auth & Navigation

**Date:** 2026-08-15
**Project:** `tbn_lms` (mbappv1.0) — Flutter mobile client
**Backend:** `D:\TBN\lms tbn us\lms-full-stack` — Express + Prisma + Better Auth

---

## 1. Problem

The mobile app was built against an imagined API contract. It compiles cleanly and every
screen renders, but only from `DemoData` — no repository except `auth_repository.dart`
has ever reached the network successfully.

Three specific mismatches drive this spec:

1. **Auth transport.** The app sends `Authorization: Bearer`; the backend reads a session
   cookie. Every authenticated call 401s.
2. **Role model.** The app routes on a static role string (`student` / `smr` / `admin` /
   `super_admin`) that the backend never sends. The backend has three tiers
   (`STUDENT`, `STAFF`, `SUPER_ADMIN`) plus **dynamic staff roles** — `StaffRole` rows a
   super admin creates at runtime with arbitrary names. "SMR" is one such row, not a tier.
3. **Response envelope.** The backend wraps everything in `{ success, data }`; the app
   passes the whole envelope to `fromJson`, so every DTO throws.

`docs/RBAC_ARCHITECTURE.md` in the backend is explicit about the contract:

> `GET /api/users/me` returns `{ user, permissions[], modules{} }` — the client derives
> ALL staff navigation from this (never from tier names).

> **No session caching of permissions**: role/permission edits apply on the very next
> request without re-login.

The app must follow the same rule the web client follows.

---

## 2. Goals

- First run: enter a server URL, verify it, sign in with email, land on the correct home
  automatically — no role picker, no manual navigation.
- A staff role created **after** the app ships lands somewhere sensible with no app change.
- Navigation reflects the user's live permissions and the deployment's enabled modules.
- v1 serves **both students and staff**.

## 3. Non-goals

- Offline-first sync. Existing scaffolding stays; this spec does not extend it.
- Mobile screens for the `website`, `catalogue`, `forms` and `staff`-administration
  modules. A staff user whose permissions land only there gets an honest empty state.
- Removing `DemoMode`. It stays for demos and offline review; it stops being the only
  working path.
- Attendance, certificates, support tickets and assignments — these have mobile screens
  but **no backend module**. Out of scope; see §11.

---

## 4. Architecture

### 4.1 `Capabilities` — the core object

Replaces `SessionManager.isStudent` / `isSmr` / `isAdmin` / `hasAdminAccess`.

```dart
enum UserTier { student, staff, superAdmin }

class Capabilities {
  final UserTier tier;
  final Set<String> permissions;   // verbatim keys from /api/users/me
  final Map<String, bool> modules; // module key -> enabled

  bool moduleEnabled(String module) => modules[module] ?? true; // missing row => enabled
  bool can(String key) {
    final module = key.split('.').first;
    if (!moduleEnabled(module)) return false;   // module gate first, always
    return permissions.contains(key);
  }
}
```

Three invariants, all mirroring the backend:

- **Module gate precedes the permission check.** A disabled module denies even a super
  admin. This matches `requirePermission` in `server/src/middlewares/authenticate.ts`.
- **Missing module row means enabled.** Matches `ModuleSetting` semantics.
- **No super-admin branch.** `/api/users/me` already expands `SUPER_ADMIN` to
  `ALL_PERMISSION_KEYS` (`server/src/modules/users/users.routes.ts`), so a tier check in
  `can()` would duplicate backend logic that can drift. The tier is still carried for
  shell selection (§4.3) — it is simply not consulted for authorization.

**`Capabilities` is never persisted.** It lives in a Riverpod provider and is re-fetched
from `/api/users/me`:

- immediately after sign-in,
- on every app resume,
- after any `403` or `404` from a gated route.

Persisting it would break the backend's guarantee that permission edits apply on the next
request without re-login.

### 4.2 Navigation destination registry

A declarative table is what lets an unknown, runtime-created role find a home:

```dart
class Destination {
  final String route;
  final String label;
  final IconData icon;
  final String module;
  final List<String> anyOf; // any one key grants the destination
  const Destination(...);
}

// v1 — screens exist, rewiring only.
const kStaffDestinations = <Destination>[
  Destination('/staff/students',  'Students',  module: 'students', anyOf: ['students.account.view']),
  Destination('/staff/batches',   'Batches',   module: 'batches',  anyOf: ['batches.batch.view']),
  Destination('/staff/insights',  'Analytics', module: 'insights', anyOf: ['insights.dashboard.view']),
];

// v1.1 — ground-up builds, appended to the list above when their screens land.
//   Destination('/staff/learning', 'Quizzes', module: 'learning', anyOf: ['learning.quiz.view']),
//   Destination('/staff/crm',      'Leads',   module: 'crm',      anyOf: ['crm.lead.view']),
//   Destination('/staff/finance',  'Finance', module: 'finance',  anyOf: ['finance.order.view']),
```

All six keys are verified against the registry (§4.2.1); the v1.1 three are held back only
because their screens do not exist yet, not because the keys are uncertain.

Visible nav is:

```dart
kStaffDestinations.where((d) => d.anyOf.any(caps.can))
```

`can()` already applies the module gate, so no separate module filter is needed.

### 4.2.1 Registry verification is load-bearing

Permission keys **must not be guessed**. The registry draws boundaries deliberately, and a
plausible-looking key can name a boundary that intentionally does not exist. The concrete
case: `students.record.view` does not exist, because —

> the account list and this roster are one screen, so viewing is covered by
> `account.view` above — only the mutations need their own keys
> (`registry.ts`, `students.features`)

A destination keyed on a non-existent permission is silently invisible to **every** role,
including super admins. Nothing errors; the tab simply never appears.

This makes verification a required CI gate, not a build-time convenience:

- Fetch `GET /api/staff/registry`, which returns `{ key, label, permissions[] }` per module.
- Assert every `anyOf` key in `kStaffDestinations` appears in that response.
- **The endpoint is behind `requireStaff`** (`staff.routes.ts`), so CI needs a seeded staff
  account and a bearer token. An anonymous fetch returns 401 and cannot verify anything.

The registry's `label` fields are also the authoritative module names and should supply
user-facing copy on the empty-state and section headers. They are module-scale and long
for a bottom navigation bar — `Commerce & Finance`, `Insights & Operations`,
`Learning & Assessments` — so the short labels above stay for the tab bar, with registry
labels used where there is room. Keys come from the registry; tab labels are a local
presentation choice.

**Empty result is a designed state**, not an error: a staff user whose permissions map to
no mobile destination sees a screen explaining that their role's areas are available on
the web console.

### 4.3 Shells

Two shells, not three:

| Shell | Nav source | Rationale |
|---|---|---|
| `StudentShell` | Fixed | Students hold **zero** permissions by design. Their navigation is a product decision, not an authorization one. |
| `StaffShell` | `kStaffDestinations` filtered by `Capabilities` | Serves `STAFF` and `SUPER_ADMIN` alike. |

`smr_shell.dart` and `admin_shell.dart` are deleted and merged into `StaffShell`.

---

## 5. First-run and sign-in flow

```
Splash
 ├─ no server URL ─────────→ WorkspaceConfigScreen
 │                            GET {url}/health   (200 => save url)
 ├─ URL, no session ───────→ LoginScreen
 │                            POST /api/auth/sign-in/email
 │                              ├─ 403  ─────────→ OtpVerificationScreen   (see §5.1)
 │                              └─ 200  ← set-auth-token header
 │                                        => store in SecureStorage
 └─ session present ───────→ GET /api/users/me
                              { user, permissions[], modules{} }
                                     │
       user.mustChangePassword ──────┼─→ ForcedPasswordChangeScreen   (blocks all writes)
       tier == student ──────────────┼─→ /student/dashboard
       tier == staff|superAdmin ─────┴─→ /staff  (first available destination)
```

### 5.1 Email verification belongs at sign-in, not after `/me`

The backend sets `requireEmailVerification: true`. Better Auth answers an unverified
sign-in with **403 and no session**, so a session with `emailVerified == false` cannot
exist. Testing `!user.emailVerified` after `/api/users/me` is unreachable code.

Verification is therefore handled on the two paths that can actually reach it:

- **After signup.** `POST /api/auth/sign-up/email` auto-sends the OTP — the backend sets
  `sendVerificationOnSignUp: true` on the `emailOTP` plugin. Go straight to the OTP screen,
  then to sign-in.
- **On a 403 at sign-in.** An account created earlier but never verified. The app requests
  a fresh OTP via `POST /api/auth/email-otp/send-verification-otp`, then verifies and
  retries sign-in.

`mustChangePassword` stays in the post-`/me` chain: it is a property of a *live* session,
and the backend blocks every non-GET on a flagged account.

### Student registration-fee gate

Most student learning routes sit behind `requireRegFeePaid` and answer `403
REG_FEE_REQUIRED`. On that code the app routes to a registration screen backed by
endpoints that already exist:

- `GET /api/student/registration/status`
- `POST /api/student/registration/receipt`

---

## 6. Network layer changes

### 6.1 Envelope unwrapping

`ApiClient._request` currently passes the full response body to `fromJson`. It must
unwrap:

```dart
final body = response.data;
final payload = (body is Map && body.containsKey('data')) ? body['data'] : body;
data = fromJson != null ? fromJson(payload) : payload as T?;
```

### 6.2 Typed errors

Failures carry `{ success: false, error: { code, message } }`. `_mapDioException` reads
`data['message']`, which is never present. It must read `data['error']['code']` and
`data['error']['message']`, and surface these codes as typed exceptions:

| Code | App behaviour |
|---|---|
| `REG_FEE_REQUIRED` | Route to registration status |
| `PASSWORD_CHANGE_REQUIRED` | Route to forced password change |
| `ACCOUNT_NOT_ACTIVE` | Sign out, explain suspension |
| `UNAUTHORIZED` (401) | Clear session, route to login |
| `404` on a gated route | Treat as *hidden, not broken*: drop the destination, re-fetch `/me` |

The `404`-means-hidden rule is deliberate on the backend — it hides the existence of
disabled modules. The app must not render it as a failure.

### 6.3 Endpoint corrections

`api_endpoints.dart` is rewritten against the real inventory. The full mapping is in the
integration audit; the routes v1 depends on:

| Area | Route |
|---|---|
| Health | `GET /api/health` |
| Sign in / up / out | `POST /api/auth/sign-in/email`, `/sign-up/email`, `/sign-out` |
| OTP verify / reset | `/api/auth/email-otp/*` |
| Change password | `POST /api/auth/change-password` |
| Identity + capabilities | `GET /api/users/me` |
| Student profile | `GET`/`PATCH /api/student/profile` |
| Student dashboard | `GET /api/student/dashboard` |
| Enrolled courses | `GET /api/student/enrolled-courses` |
| Course progress | `GET /api/student/courses/:id/progress` |
| Course content | `GET /api/learning/courses/:id/content` |
| Purchases | `GET /api/student/purchases` |
| Registration gate | `GET /api/student/registration/status`, `POST /registration/receipt` |
| Batches | `GET /api/batches/mine`, `/available`, `/my-classes`, `/:id`, `/:id/stats` |
| Notifications | `GET /api/notifications/`, `/unread-count`, `POST /:id/read`, `/read-all` |
| Students (staff) | `GET /api/students/`, `/master`, `/:id` |
| Insights (staff) | `GET /api/insights/dashboard`, `/analytics/*` |
| Learning (staff) | `GET /api/learning/quizzes`, `/quizzes/:id/results` |
| CRM (staff) | `POST /api/crm/leads`, `GET /api/crm/leads/:id`, `/analytics` |
| Finance (staff) | `GET /api/finance/orders`, `/reports/revenue`, `/invoices/:id/pdf` |
| Commerce | `POST /api/commerce/cart/items` → `/quote` → `/checkout`, `GET /checkout/status` |

### 6.4 Pagination

The backend takes `page` / `pageSize` and returns domain-shaped lists. `PaginationMeta`
expects `currentPage` / `totalPages` / `totalItems` / `hasNextPage`. It is rewritten to
match what the backend actually returns; the shape must be confirmed per endpoint against
a live response rather than assumed uniform.

### 6.5 `RefreshInterceptor` is removed

It posts to `/auth/session/refresh`, which does not exist. Better Auth rolls the session
via `updateAge` (1 hour) within a 12-hour `expiresIn`. On `401` the app clears the session
and routes to login.

---

## 7. DTO regeneration

Every `*_dto.dart` is regenerated from **recorded responses** against a local stack, not
from reading TypeScript service signatures — the latter is how the current drift was
introduced.

Priority order: auth → `/users/me` → student dashboard → enrolled courses → notifications
→ purchases → profile → staff list → batches → insights.

Example of the gap being closed (`/api/student/dashboard`):

```
current DTO   stats { attendancePercentage, pendingTasksCount, lastClassDate,
                      activeCoursesCount, classesAttendedCount, tasksSubmittedCount }
              activeBatches[], upcomingTasks[], currentClassName

actual        stats { enrolledCourses, completedLectures, purchases }
              courses[] { _id, courseTitle, courseThumbnail, educator,
                          completedLectures, totalLectures }
              continueLearning
```

Zero field overlap. This is representative, not exceptional.

---

## 8. Removals

- `AppConstants.roleStudent` / `roleSmr` / `roleAdmin` / `roleSuperAdmin`
- `AppConstants.keyUserRole` and its `PreferenceManager` persistence
- `SessionManager.isStudent` / `isSmr` / `isAdmin` / `isSuperAdmin` / `hasAdminAccess`
- `RefreshInterceptor` and `ApiEndpoints.refreshSession`
- `smr_shell.dart`, `admin_shell.dart`
- Role-based branches in `app_router.dart` (lines 96–119)

---

## 9. Testing

Current coverage is 3 test files. This spec adds capability resolution as the core test
surface — pure, cheap, and where dynamic-role bugs will actually live.

**Capability tests** (`test/core/auth/capabilities_test.dart`) — given a `/me` payload,
assert the exact resulting destination list:

- Student (`permissions: []`) → student shell, no staff destinations.
- Staff with `students.account.view` only → Students destination alone.
- Super admin (`permissions` = all keys) → every destination.
- Super admin with `crm` disabled → CRM destination absent (module gate beats everything).
- Staff whose permissions map to no mobile destination → empty list, empty-state screen.
- Unknown permission key from a newly created role → ignored, no crash.

**Registry conformance test** (CI gate, §4.2.1) — fetch `GET /api/staff/registry` with a
seeded **staff bearer token** and assert every `anyOf` key in `kStaffDestinations` exists
in the response. This is the test that would have caught `students.record.view`. It
requires a live seeded backend and cannot run as a pure unit test.

**Network tests** — envelope unwrapping, `error.code` mapping, and the `404`-means-hidden
path, using `mocktail` against recorded fixtures.

**Router tests** — each redirect: `mustChangePassword`, the sign-in `403` → OTP path,
`REG_FEE_REQUIRED`, and the no-server-URL first-run path.

---

## 10. Prerequisites

1. **Backend: Better Auth `bearer()` plugin.** Owned by the user, confirmed in this
   session. Two lines in `server/src/lib/auth.ts`:
   ```ts
   import { bearer, emailOTP } from 'better-auth/plugins'
   // …
   plugins: [ bearer(), emailOTP({ … }) ],
   ```
   The `before` hook converts `Authorization: Bearer <token>` to a session cookie before
   the pipeline runs, so `authenticate.ts` needs no change. The `after` hook exposes the
   token as the `set-auth-token` response header on sign-in.

2. **A local backend stack.** `docker-compose.dev.yml`, seeded. All development and DTO
   recording happens here, never against production.

3. **Real Razorpay key** in `.env` — currently the placeholder
   `RAZORPAY_KEY_ID=your_razorpay_key_here`. Only blocks the commerce work.

---

## 11. Known scope gaps

Four shipped mobile features have **no backend module**: attendance, certificates,
support tickets, assignments. They are out of v1 scope. Their screens must either be
removed from the router or shown as unavailable — leaving them wired to `DemoData` while
everything else goes live would reintroduce exactly the confusion this spec exists to
remove. **Decision required before implementation reaches §7.**

Backend modules with no mobile screens in v1: `website`, `catalogue`, `forms`,
`staff` (role administration). These are handled by the empty-state path in §4.2.

---

## 12. Implementation sequencing

This spec is too large for one plan. It decomposes into four stages, each independently
verifiable against a live local backend:

**Stage A — Foundation.** Network layer only, no UI. Envelope unwrapping, typed errors,
rewritten `api_endpoints.dart`, `RefreshInterceptor` removal, bearer token capture from
the `set-auth-token` header. *Done when:* a signed-in `GET /api/users/me` returns a
parsed payload in a test.

**Stage B — Capabilities and routing.** `Capabilities`, the destination registry,
`StaffShell`, router rewrite, the removals in §8. *Done when:* the §9 capability tests
pass and each tier lands on the right home against a seeded backend.

**Stage C — Gates.** OTP verification, forced password change, registration-fee screens.
*Done when:* each gate redirect is exercised end-to-end.

**Stage D — Feature wiring.** DTO regeneration and screen wiring, module by module. Each
module is a self-contained slice. §11 must be resolved before this stage begins.

Stages A and B are the ones that turn the demo into an app; C and D are incremental.

### Release split

**v1 ships the rewirable surface** — every part of Stage D that has screens today:

| v1 | Work |
|---|---|
| Full student surface | Rewire existing screens |
| Staff: students | Rewire `smr_students_screen` |
| Staff: batches | Rewire `smr_batches_screen` |
| Staff: insights | Rewire `admin_dashboard_screen`, `admin_analytics_screen` |

**v1.1 adds the three ground-up builds:** `learning` (quiz bank, results, content),
`crm` (lead pipeline, follow-ups), `finance` (orders, invoices, revenue).

The capability registry makes this split cost nothing: `kStaffDestinations` carries only
the four v1 destinations, so a role holding just `crm.lead.view` sees the §4.2 empty state
rather than a dead tab. Adding the v1.1 destinations is additive — the capability logic
itself does not change.

Stages A, B and C ship in full with v1; they are shared by both releases.

## 13. Open questions

None blocking. The one deferred decision is §11 (attendance / certificates / support /
assignments), which is needed before Stage D begins, not before implementation starts.
