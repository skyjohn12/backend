# Backend Development Guide

Development patterns and practices for the backend.

- Use Spring Boot conventions
- Modular, testable code
- Dependency injection for services
- Write unit and integration tests

## Folder Structure & Copilot Instructions

When implementing new features, **always follow the existing folder structure** as outlined in `backend/README.md`. Place new files for controllers, services, repositories, and entities in their respective existing folders:

- Controllers: `src/main/java/com/example/demo/controller/`
- Services: `src/main/java/com/example/demo/service/`
- Repositories: `src/main/java/com/example/demo/repository/`
- Entities: `src/main/java/com/example/demo/entity/`

**Copilot Guidance:**
- Do **not** create new folders for these components. Always add new classes to the existing folders.
- Refer to the project structure in `backend/README.md` for folder locations and naming conventions.
- Ensure all generated code follows the organization and standards described in this guide and the referenced README.

This approach ensures consistency, maintainability, and alignment with project standards.
# Backend Development Guide

Development patterns and practices for the backend.

- Use Spring Boot conventions
- Modular, testable code
- Dependency injection for services
- Write unit and integration tests
