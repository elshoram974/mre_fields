---
name: architecture-principles
description: Use when designing system structure, splitting modules/services, or when code changes in one place unexpectedly break another.
---

# Architecture Principles

Principles for structuring systems so they're easy to understand, change, and scale.

## Separation of Concerns (SoC)

**Each module has one clearly defined responsibility. Concerns don't bleed into each other.**

```
❌ BAD — Everything in one layer:
  route handler → validates input → runs business logic → queries DB → formats response

✅ GOOD — Each layer has one job:
  Controller  → validates HTTP input, delegates
  Service     → business logic, orchestrates
  Repository  → data access only
  Serializer  → formats output
```

**Boundary test:** Can you change the database without touching business logic? Can you change the API format without touching domain logic? If no → concerns are mixed.

---

## Layered Architecture

**Dependencies flow one way: outer layers depend on inner layers, never the reverse.**

```
┌─────────────────────┐
│  Presentation       │  HTTP, CLI, WebSocket
├─────────────────────┤
│  Application        │  Use cases, orchestration
├─────────────────────┤
│  Domain             │  Business rules, entities  ← Core, no dependencies
├─────────────────────┤
│  Infrastructure     │  DB, email, queues, APIs
└─────────────────────┘

Rule: Domain knows NOTHING about Infrastructure.
      Infrastructure implements Domain interfaces.
```

---

## Hexagonal Architecture (Ports & Adapters)

**Core business logic is isolated. External systems plug in via adapters.**

```
         [ HTTP API ]  [ CLI ]  [ Tests ]
               ↓          ↓        ↓
          ┌────────────────────────┐
          │      Application       │ ← Ports (interfaces)
          │    (Business Logic)    │
          └────────────────────────┘
               ↓          ↓        ↓
         [ PostgreSQL ] [ Redis ] [ SendGrid ]
                     (Adapters)
```

**Benefit:** Swap any external system (DB, email provider) without changing business logic. Business logic is testable with no infrastructure.

---

## CQRS — Command Query Responsibility Segregation

**Separate write operations (Commands) from read operations (Queries).**

```python
# ❌ BAD: Mixed reads and writes — hard to optimize independently
class UserService:
    def create_user(self, data): ...       # command
    def update_email(self, id, email): ... # command
    def find_by_id(self, id): ...          # query
    def search_users(self, query): ...     # query — often needs different optimization

# ✅ GOOD: Separated by intent
class UserCommandService:
    def create(self, data: CreateUserDTO) -> None: ...
    def update_email(self, id: int, email: str) -> None: ...

class UserQueryService:
    def find_by_id(self, id: int) -> UserView: ...
    def search(self, query: str) -> list[UserView]: ...
```

**Benefits:** Read and write models evolve independently. Query side can use caching, denormalized views, or read replicas without affecting write logic.

> **Note:** Full CQRS with separate databases is advanced. Even splitting command/query into separate classes in the same service is a meaningful step.

---

## Event-Driven Architecture

**Modules communicate by publishing events — not by calling each other directly.**

```python
# ❌ BAD: OrderService knows about every downstream service
class OrderService:
    def place_order(self, order):
        self.db.save(order)
        self.email_service.send_confirmation(order)  # tight coupling
        self.inventory_service.reserve(order.items)
        self.billing_service.charge(order)

# ✅ GOOD: OrderService publishes one event — knows nothing downstream
class OrderService:
    def place_order(self, order):
        self.db.save(order)
        self.event_bus.publish("order.placed", order)  # zero coupling

# Each service subscribes independently:
email_service.on("order.placed", send_confirmation)
inventory_service.on("order.placed", reserve_items)
billing_service.on("order.placed", charge_customer)
# Adding analytics? Zero changes to OrderService.
```

**Benefit:** Adding a new reaction requires zero changes to the publisher.

**Trade-off:** Flow is harder to trace — invest in structured logging and observability.

---

## High Cohesion, Low Coupling

| Concept | Goal | Smell |
|---------|------|-------|
| **High Cohesion** | Things that change together, live together | Feature spread across 10 files |
| **Low Coupling** | Modules communicate through narrow interfaces | One module importing 20 things from another |

```python
# ❌ HIGH COUPLING: Order module reaches into User internals
class OrderService:
    def place(self, user_id):
        user = UserRepository().find(user_id)
        address = user._private_address_data["street"]  # Reaching in!

# ✅ LOW COUPLING: Order asks for what it needs through interface
class OrderService:
    def place(self, user_id):
        address = self.user_service.get_shipping_address(user_id)  # Clean contract
```

---

## Law of Demeter (Don't Talk to Strangers)

**A method should only call methods on: itself, its parameters, objects it creates, its direct fields.**

```python
# ❌ BAD: Chain of knowledge (fragile)
total = order.get_customer().get_wallet().get_balance()

# ✅ GOOD: Ask the direct collaborator
total = order.get_customer_balance()  # Customer encapsulates wallet
```

---

## Package / Module Organization

**Two valid strategies — pick one, be consistent:**

| Strategy | Structure | Best for |
|----------|-----------|----------|
| **By Layer** | `controllers/`, `services/`, `repos/` | Small teams, simple CRUD apps |
| **By Feature** | `orders/`, `users/`, `billing/` | Growing apps, team ownership |

**By feature scales better** — all order code lives in `orders/`, changes are contained.

---

## Quick Architecture Checklist

- [ ] Can I describe each module's responsibility in one sentence?
- [ ] Does the domain layer have zero imports from infrastructure?
- [ ] Can I test business logic without a database or HTTP server?
- [ ] Does changing a database table require changes outside the repository?
- [ ] Are module boundaries obvious from the folder structure?
- [ ] Are commands (writes) separated from queries (reads)?
- [ ] Do modules communicate through events rather than direct calls where decoupling matters?
