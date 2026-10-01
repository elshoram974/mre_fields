---
name: clean-code
description: Use when naming variables/functions/classes, writing functions, or reviewing code that feels hard to read or understand at a glance.
---

# Clean Code

Principles for writing code that humans can read, understand, and maintain.

## Naming

**Names should reveal intent — no abbreviations, no mystery.**

| Rule | Bad | Good |
|------|-----|------|
| Pronounceable names | `genymdhms` | `generatedTimestamp` |
| Searchable names | `e`, `d` | `event`, `elapsedDays` |
| Reveal intent | `theList[4]` | `flaggedCells` |
| No type in name | `nameString` | `name` |
| Distinguish meaningfully | `data1`, `data2` | `userData`, `orderData` |
| Functions: verb phrases | `processIt()` | `saveUser()`, `isValid()` |
| Classes: noun phrases | `Manager` (vague) | `UserAccount`, `OrderParser` |

## Functions

**Small. Do one thing. One level of abstraction.**

```python
# ❌ BAD: Does three things, mixed abstraction levels
def process_order(order):
    # Validate
    if not order.items: raise ValueError("Empty order")
    # Calculate
    total = sum(i.price * i.qty for i in order.items)
    tax = total * 0.1
    # Persist
    db.execute("INSERT INTO orders ...", order.id, total + tax)

# ✅ GOOD: Each function does one thing
def process_order(order):
    validate_order(order)
    total = calculate_total(order)
    save_order(order, total)

def calculate_total(order) -> float:
    subtotal = sum(i.price * i.qty for i in order.items)
    return subtotal + calculate_tax(subtotal)
```

**Function rules:**
- ≤ 3 parameters (more = needs a parameter object)
- No side effects beyond stated purpose
- No flag arguments (`process(true)` → two functions)
- Command/Query separation: either *do* something or *return* something, not both

## Classes

**Small classes with high cohesion — methods should use most instance variables.**

```python
# ❌ BAD: One class, two unrelated concerns — methods only use half the variables
class UserService:
    def __init__(self):
        self.name = ""
        self.email = ""        # Group 1: user identity
        self.token = ""
        self.expires_at = None # Group 2: session auth — unrelated
        self.refresh_token = ""

    def get_display_name(self): return self.name  # uses only Group 1
    def validate_email(self): ...                 # uses only Group 1
    def refresh_session(self): ...                # uses only Group 2
    def is_session_expired(self): ...             # uses only Group 2

# ✅ GOOD: Split into two cohesive classes
class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

    def get_display_name(self) -> str: return self.name
    def validate_email(self) -> bool: ...

class UserSession:
    def __init__(self, token: str, expires_at: datetime):
        self.token = token
        self.expires_at = expires_at
        self.refresh_token = ""

    def is_expired(self) -> bool: ...
    def refresh(self) -> None: ...
```

**Class rules:**
- If a method only uses half the instance variables, the class likely has two responsibilities
- Cohesion check: can every method be described using the class name alone?
- Prefer many small, focused classes over one large class

## Comments

**Comments explain WHY, not WHAT. Good code is self-documenting.**

```python
# ❌ BAD: Comment repeats the code
# Increment i by 1
i += 1

# ❌ BAD: Commented-out code (use git instead)
# old_process(data)
new_process(data)

# ✅ GOOD: Explains business reason (non-obvious)
# Retry exactly 3 times per PCI-DSS §3.2 compliance requirement
MAX_PAYMENT_RETRIES = 3

# ✅ GOOD: Warns about non-obvious consequence
# Don't call close() twice — underlying socket will raise OSError
```

## Formatting

**Code is read more than written — optimize for the reader.**

- **Vertical distance:** Related things stay close. Follow the **Stepdown Rule** — callers above callees, read top-to-bottom like a newspaper: high-level summary first, implementation details below.

  ```python
  # ✅ GOOD: High-level entry point at top, details flow downward
  def process_checkout(cart):
      validate_cart(cart)
      total = calculate_total(cart)
      return charge_payment(total)

  def validate_cart(cart): ...    # detail — below its caller
  def calculate_total(cart): ...  # detail — below its caller
  def charge_payment(total): ...  # detail — below its caller
  ```
- **Horizontal:** Keep lines short (≤ 120 chars). Don't align assignments — it's visual noise.
- **One concept per line.** No `a = b = c = 0`.
- **Blank lines** = paragraph breaks = logical separation.

## Error Handling

```python
# ❌ BAD: Swallowed exception, null returns
def find_user(id):
    try:
        return db.get(id)
    except:
        return None  # Caller has no idea what went wrong

# ✅ GOOD: Specific exception, meaningful message
def find_user(id: int) -> User:
    try:
        return db.get(id)
    except DatabaseConnectionError as e:
        raise ServiceUnavailableError(f"Cannot fetch user {id}") from e
    except UserNotFoundError:
        raise  # Let caller decide
```

**Rules:**
- Don't return `null` — return empty collections or raise exceptions
- Don't pass `null` as arguments
- Catch specific exceptions, not bare `except`/`catch`

## Quick Self-Check

Before committing, ask:
- [ ] Can I understand each function in 5 seconds?
- [ ] Does every name reveal its intent without a comment?
- [ ] Is each function doing exactly one thing?
- [ ] Are all comments explaining *why*, not *what*?
- [ ] Is there any commented-out code? (delete it)
