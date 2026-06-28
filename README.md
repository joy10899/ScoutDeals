### `README.md`

````markdown
# ScoutDeals — Saved Deals Feature

A SwiftUI saved deals screen built in ~2 hours, targeting iOS 17+.

By Joy Tran
---

## What was built

```
ScoutDeals/
├── ScoutDealsApp.swift
├── Models/
│   └── Deal.swift                  — data shape, categories, mock data
├── ViewModels/
│   └── SavedDealsViewModel.swift   — @Observable state engine, ViewState enum
└── Views/
    ├── SavedDealsView.swift         — main screen, filter bar, savings indicator
    └── Components/
        ├── DealRow.swift            — reusable clothing deal row + discount badge
        ├── NotificationSheet.swift  — price alert sheet with inline validation
        └── SavingsSummarySheet.swift — total savings breakdown on tag tap
```


https://github.com/user-attachments/assets/60aca77f-f8e5-4053-9141-577813503665


---

## Questions

### 1. One design decision I'm proud of

The `ViewState` enum with `.loading`, `.empty`, and `.loaded([Deal])`.
It makes broken states — like showing a loading spinner and a list
at the same time — impossible by design. The compiler enforces it.

### 2. One thing I'd do differently with more time

Replace the hardcoded mock data with a real network call and add a
`.error` state so the screen handles failures gracefully instead of
silently staying in loading forever.

### 3. Anything I'd want feedback on

The price alert validation in `NotificationSheet` shows an error on
the very first keystroke. It works, but it might feel too aggressive.
Would love to know if the team prefers waiting until the field loses
focus before showing the hint.
````
