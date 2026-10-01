---
name: dry-kiss-yagni
description: Use when tempted to add abstraction, generalize code, or build features "just in case" — or when spotting duplicated logic across the codebase.
---

# DRY · KISS · YAGNI

Three principles that keep codebases lean and maintainable.

## DRY — Don't Repeat Yourself

**Every piece of knowledge must have a single, authoritative representation.**

DRY is about **knowledge duplication**, not just copy-paste:

```python
# ❌ BAD: Business rule duplicated in 3 places
# In validator:
if age < 18: raise ValueError("Must be adult")
# In checkout:
if user.age < 18: redirect("/not-allowed")
# In report:
adults = [u for u in users if u.age >= 18]

# ✅ GOOD: One place, one truth
def is_adult(age: int) -> bool:
    return age >= 18  # Change the rule once, applies everywhere
```

**DRY ≠ "never copy code."** Duplicate when:
- The duplication is accidental (same code, different concepts)
- Removing it creates an artificial coupling between unrelated modules

**Watch for:** Duplicate constants, repeated validation logic, copy-pasted business rules.

---

## KISS — Keep It Simple, Stupid

**The simplest solution that correctly solves the problem is the best solution.**

```python
# ❌ BAD: Over-engineered for no reason
def is_even(n: int) -> bool:
    return n % 2 == 0 if isinstance(n, int) else \
        int(float(str(n))) % 2 == 0

# ✅ GOOD: Simple and correct
def is_even(n: int) -> bool:
    return n % 2 == 0
```

**Complexity red flags:**
- More than 2 levels of nesting
- A function you can't explain in one sentence
- A solution that needs a diagram to understand
- Abstractions with only one concrete implementation

**Prefer:** Flat over nested. Explicit over clever. Boring over brilliant.

---

## YAGNI — You Aren't Gonna Need It

**Don't implement something until you actually need it.**

```python
# ❌ BAD: Built "for future flexibility" nobody asked for
class DataExporter:
    def export(self, data, format="json", version=1,
               compression=None, encryption=None,  # Not needed yet
               chunked=False, callback=None):      # Not needed yet
        ...

# ✅ GOOD: Build what's needed now
class DataExporter:
    def to_json(self, data: list) -> str:
        return json.dumps(data)
```

**YAGNI traps:**
- "We'll probably need this later" → build it when you need it
- Designing for N+1 features → design for what exists
- Generic frameworks before 3 concrete use cases → wait for 3 use cases

**Exception:** Security, privacy, and performance concerns with no retrofit path — plan these upfront.

---

## When Principles Conflict

| Situation | Principle wins |
|-----------|---------------|
| Duplicate code but different concepts | KISS > DRY (don't couple) |
| Need abstraction but no second use case | YAGNI > DRY |
| Complex deduplication > simple duplication | KISS > DRY |
| Clear future need with no retrofit path | DRY/SOLID > YAGNI |

**Rule of Three:** Duplicate once if unsure. When it appears a third time, extract it. (DRY timing heuristic)
