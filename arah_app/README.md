# Arah App

A peer-to-peer student freelancing platform built with Flutter + Firebase. Students can hire talent (Buyer mode), offer skills (Seller mode), or do both.

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [User Flows](#user-flows)
- [Firebase Schema](#firebase-schema)
- [Workflow Completion Checklist](#workflow-completion-checklist)

---

## Architecture Overview

| Layer | Tech |
|-------|------|
| UI | Flutter (Material 3) |
| State Management | Provider |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Local Cache | SharedPreferences |

**Key Providers:**
- `UserProvider` — Auth state, profile, mode switching
- `HomeProvider` — Open task feed (real Firestore, excludes own tasks)
- `OrderProvider` — Active/completed orders per role
- `RequestProvider` — Create task form state

**Services:**
- `FirestoreService` — All Firestore reads/writes
- `StorageService` — Firebase Storage uploads
- `FirebaseAuthService` — Auth sign-in/sign-up

---

## User Flows

### Onboarding Flow
```
RoleSelectionScreen
  → Saves role to SharedPreferences
  → LoginScreen
      → [Sign In] Existing user → (check profile exists) → BuyerHomeScreen / SellerHomeScreen
      → [Sign Up] → SignupScreen → creates Firebase Auth + minimal Firestore profile
                                 → ProfileSetupScreen (skills, experience, photo)
                                 → BuyerHomeScreen / SellerHomeScreen
```

### Buyer Flow (Hiring Talent)
```
BuyerHomeScreen (Discover)
  ├─ Lists all OPEN tasks (excludes own tasks via Firestore filter)
  ├─ Search + Category + Budget filters
  ├─ FAB (+) → CreateRequestScreen → posts task to Firestore
  └─ Tap task → TaskDetailScreen → "Contact Seller" button
                                   → ChatScreen (isBuyer=true)
                                       → [ASSIGN TO SELLER] button (top-right)
                                         → Confirmation dialog
                                         → Atomic batch: task.status=in_progress + creates order
                                         → Button changes to "Assigned ✓"

MyOrdersScreen (Buyer)
  ├─ Pending tab: Tasks assigned to sellers
  │   ├─ [Chat] button → ChatScreen
  │   ├─ [Mark Done] → Confirmation → completeOrder() → rating popup
  │   └─ [Remove & Reassign] → Confirmation → task back to "open" + order deleted
  └─ Completed tab: Finished tasks
      └─ [Rate] button (if not yet rated) → 1–5 star dialog
```

### Seller Flow (Offering Skills)
```
SellerHomeScreen (Find Work)
  ├─ Lists all OPEN tasks from Firestore (excludes own tasks posted as buyer)
  ├─ Search + Category filters
  └─ Tap task → TaskDetailScreen → "Message to Bid" button
                                   → ChatScreen (isBuyer=false)
                                       → NO "Assign to Seller" button (Seller cannot self-assign)
                                       → Seller sends messages / files to convince Buyer

MyOrdersScreen (Seller)
  ├─ Pending tab: Tasks assigned to this seller by buyers
  │   └─ [Open Chat] button only (no assignment controls)
  └─ Completed tab: Finished tasks
      └─ [Rate] button (if not yet rated) → 1–5 star dialog
```

### "Both" Mode Toggle
- Users with role `"Both"` see a `[Buyer | Seller]` animated pill toggle in the AppBar
- Tapping switches the active mode, re-subscribes providers, and navigates to the appropriate Home screen

---

## Firebase Schema

### `users/{uid}`
```json
{
  "name": "string",
  "email": "string",
  "role": "Buyer | Seller | Both",
  "currentMode": "Buyer | Seller",
  "experienceLevel": "Beginner | Intermediate | Advanced",
  "skills": ["string"],
  "photoUrl": "string?",
  "bio": "string?",
  "githubUrl": "string?",
  "linkedinUrl": "string?",
  "avgRating": "number?",
  "ratingCount": "number?"
}
```

### `users/{uid}/ratings/{ratingId}`
```json
{
  "rating": "number (1–5)",
  "raterId": "string (uid)",
  "orderId": "string",
  "createdAt": "Timestamp"
}
```

### `tasks/{taskId}`
```json
{
  "title": "string",
  "description": "string",
  "category": "string",
  "price": "string (₹amount)",
  "budgetType": "Fixed Price | Hourly",
  "buyerId": "string (uid)",
  "buyerName": "string",
  "sellerId": "string (uid, empty when open)",
  "status": "open | in_progress | completed",
  "isBeginnerFriendly": "boolean",
  "tags": ["string"],
  "postedTime": "string",
  "deadline": "Timestamp?",
  "attachments": ["string (URLs)"],
  "createdAt": "Timestamp"
}
```

### `orders/{orderId}`
```json
{
  "title": "string",
  "price": "string",
  "clientName": "string",
  "clientId": "string (uid)",
  "buyerId": "string (uid)",
  "buyerName": "string",
  "sellerId": "string (uid)",
  "sellerName": "string",
  "taskId": "string",
  "chatId": "string",
  "status": "Pending | Completed",
  "ratedByBuyer": "boolean",
  "ratedBySeller": "boolean",
  "createdAt": "Timestamp"
}
```

### `chats/{chatId}`
Chat ID format: `{uid1}_{uid2}_{taskId}` (sorted UIDs, task-scoped)
```json
{
  "participants": ["uid1", "uid2"],
  "lastMessage": "string",
  "lastMessageTimestamp": "Timestamp",
  "unreadCounts": { "uid1": 0, "uid2": 0 },
  "taskId": "string?",
  "isAssigned": "boolean"
}
```

### `chats/{chatId}/messages/{msgId}`
```json
{
  "senderId": "string (uid)",
  "content": "string (text or file URL)",
  "type": "text | image | file",
  "timestamp": "Timestamp",
  "isRead": "boolean"
}
```

---

## Workflow Completion Checklist

### Core Infrastructure
- [x] Firebase Auth (sign-in, sign-up)
- [x] Firestore user profile creation
- [x] Storage service (profile pics, task attachments, chat files)
- [x] Role-based Provider architecture (UserProvider, HomeProvider, OrderProvider)

### Onboarding Flow
- [x] RoleSelectionScreen → saves role → navigates to LoginScreen
- [x] LoginScreen → checks Firestore profile → routes to ProfileSetup or Home
- [x] SignupScreen → creates auth + minimal profile → routes to ProfileSetup
- [x] ProfileSetupScreen → updates skills/experience/photo → routes to Home
- [x] AuthGate in main.dart → handles cold-start auth persistence

### Buyer Home
- [x] Real Firestore open tasks feed (not mock data)
- [x] Excludes buyer's own tasks (safety filter in HomeProvider + card build)
- [x] Search, Category, and Budget filters
- [x] FAB to create a new task request
- [x] Task cards with title, description, tags, price, poster info
- [x] Both-mode animated toggle pill in AppBar

### Seller Home
- [x] Real Firestore open tasks (same feed as Buyer, excludes own tasks)
- [x] Local search and category filter
- [x] "Message to Bid" button (NOT "Take On" — seller cannot self-assign)
- [x] Task-scoped chat room created on first message
- [x] Both-mode animated toggle pill in AppBar

### Chat Screen
- [x] Task context banner (title + price) at top
- [x] **[CRITICAL FIX]** Buyer-only "Assign to Seller" button in AppBar
- [x] Assign button shows confirmation dialog before committing
- [x] Atomic Firestore batch: task status → `in_progress`, sellerId set, order created
- [x] Button changes to "Assigned ✓" badge after assignment
- [x] System message sent in chat after assignment
- [x] File attachment upload to Firebase Storage
- [x] Real-time message stream from Firestore
- [x] Messages marked as read on open
- [x] Seller does NOT see assign button (`isBuyer=false`)

### Orders Screen — Buyer
- [x] Pending tab: tasks assigned to sellers
- [x] [Chat] opens task-scoped chat with assignment context
- [x] [Mark Done] → confirmation → completeOrder() → rating popup auto-launches
- [x] [Remove & Reassign] → confirmation → deletes order + resets task to "open"
- [x] Completed tab: finished tasks
- [x] [Rate] button for unrated completed orders → 1–5 star dialog

### Orders Screen — Seller
- [x] Pending tab: tasks assigned to this seller
- [x] [Open Chat] only — no assignment/completion controls
- [x] Completed tab: finished tasks
- [x] [Rate] button for unrated completed orders → 1–5 star dialog

### Rating System
- [x] 5-star rating dialog with emoji labels
- [x] Rating saved to `users/{uid}/ratings` subcollection
- [x] Average rating updated on `users/{uid}.avgRating`
- [x] Order flagged as `ratedByBuyer` / `ratedBySeller` after rating
- [x] [Rate] button hidden after rating submitted

### Safety & Restrictions
- [x] Buyer cannot see/interact with own tasks in the home feed
- [x] Seller cannot self-assign a task
- [x] TaskDetailScreen shows "This is your task" for own tasks (no action button)
- [x] ChatScreen: assign button only rendered when `isBuyer=true`
