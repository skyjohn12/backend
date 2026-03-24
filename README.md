# QE SE Catalyst - Agentic Workflow for React Development

This repository demonstrates an agentic workflow for building React applications with TypeScript and Vite, leveraging GitHub Copilot for AI-assisted development.

## 🚀 Agentic Workflow Overview

The agentic workflow is designed to guide GitHub Copilot through structured phases of development, ensuring consistent, high-quality code generation following software engineering best practices.

### Core Principles

- **AI-First**: Leverage GitHub Copilot for architecture decisions, implementation, and optimization
- **Phase-Based Development**: Structured approach from planning to testing
- **Type-Safe**: Comprehensive TypeScript usage throughout the application
- **Best Practices**: Follow React, Vite, and modern frontend development patterns

## 📁 Project Structure

```
qe-se-catalyst/
├── README.md                 # This file
├── agentic-workflow/         # AI workflow instructions
│   ├── README.md            # Workflow overview
│   └── instructions/
│       └── frontend/        # React/Vite specific prompts
│           ├── planning-prompts.md      # Architecture & planning
│           ├── implementation-prompts.md # Component & hook generation
│           ├── refinement-prompts.md    # Code optimization
│           └── testing-prompts.md       # Test generation
└── src/                     # React application (generated via workflow)
```

## 🤖 How to Use the Agentic Workflow

### 1. Smart Context Management

GitHub Copilot automatically uses workspace context. To enhance this:

- **Reference Files in Prompts**: Mention specific instruction files when needed
- **Use @workspace**: Leverage VS Code's workspace-wide context
- **Smart File Naming**: Descriptive file names help Copilot understand purpose
- **Project Structure**: Clear organization helps Copilot find relevant patterns

> See `agentic-workflow/README.md` for detailed context management strategies

### 2. Four-Phase Development Process

The agentic workflow follows a structured four-phase approach:

1. **Planning**: Define architecture, component hierarchies, and data flow patterns
2. **Implementation**: Generate React components, hooks, and services with TypeScript
3. **Refinement**: Optimize performance, enhance type safety, and improve maintainability
4. **Testing**: Create comprehensive test suites for components, hooks, and services

> See `agentic-workflow/README.md` for detailed phase descriptions and usage instructions.

## 🛠️ Getting Started

1. **Setup Project**: Create a new Vite + React + TypeScript project
2. **Open Instructions**: Keep all agentic workflow instruction files open in VS Code
3. **Start with Planning**: Begin with the planning phase for any new feature
4. **Follow the Workflow**: Progress through the four phases systematically

> For detailed usage instructions, see `agentic-workflow/README.md`

## 💡 Key Benefits

- **Consistent Code Quality**: Structured prompts ensure best practices
- **Faster Development**: AI-assisted generation reduces boilerplate
- **Type Safety**: Comprehensive TypeScript integration
- **Maintainable Architecture**: Clear separation of concerns and patterns
- **Comprehensive Testing**: AI-generated test suites for reliability

## 📚 Learn More

- **Detailed Workflow**: `agentic-workflow/README.md` for comprehensive usage instructions
- **Automatic Context**: `.copilot-instructions.md` provides project-wide Copilot guidance
- **Phase-Specific Prompts**: Individual instruction files for targeted assistance
- **Smart Referencing**: Mention instruction files in prompts when needed

## 🤝 Contributing

When contributing to this project:

1. Use the agentic workflow prompts
2. Maintain TypeScript strict mode
3. Follow React best practices
4. Generate tests for all new features
5. Let GitHub Copilot assist with implementation details

