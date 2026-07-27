# Architecture Patterns Reference

## Monolith vs Microservices

| Aspect | Monolith | Microservices |
|--------|----------|---------------|
| Deployment | Single unit | Multiple services |
| Scaling | Vertical (entire app) | Horizontal (per service) |
| Team Structure | Single team | Multiple teams |
| Complexity | Lower initial | Higher initial |
| Testing | Easier E2E | Complex integration |
| Observability | Simple logging | Distributed tracing needed |

## Common Architecture Styles

- **Layered Architecture**: Presentation → Business → Persistence → Database
- **Clean Architecture**: Entities → Use Cases → Interface Adapters → Frameworks
- **Hexagonal Architecture**: Core domain with ports and adapters
- **CQRS**: Separate read and write models
- **Event-Driven**: Services communicate via events
- **Microservices**: Independently deployable services

## Design Patterns to Detect

- **Creational**: Singleton, Factory, Abstract Factory, Builder, Prototype
- **Structural**: Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy
- **Behavioral**: Strategy, Observer, Command, Chain of Responsibility, Mediator, State, Template Method, Visitor
