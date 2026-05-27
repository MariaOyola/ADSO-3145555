# Design Software Docs Architecture

```plaintext
design-software-docs/
│
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── LICENSE
│
├── .github/
│   ├── pull_request_template.md
│   └── workflows/
│       ├── docs-lint.yml
│       └── links-check.yml
│
├── docs/
│   │
│   ├── README.md
│   │
│   ├── 00-documentation-governance/
│   │   ├── README.md
│   │   ├── repository-purpose.md
│   │   ├── documentation-rules.md
│   │   ├── naming-conventions.md
│   │   ├── folder-conventions.md
│   │   ├── versioning-rules.md
│   │   ├── review-process.md
│   │   └── definition-of-done.md
│   │
│   ├── 01-project-context/
│   │   ├── README.md
│   │   ├── initial-context.md
│   │   ├── problem-space.md
│   │   ├── business-objectives.md
│   │   ├── scope.md
│   │   ├── out-of-scope.md
│   │   ├── constraints.md
│   │   ├── assumptions.md
│   │   └── glossary.md
│   │
│   ├── 02-sena-domain/
│   │   ├── README.md
│   │   ├── domain-glossary.md
│   │   ├── institutional-concepts.md
│   │   ├── actors.md
│   │   ├── business-rules.md
│   │   ├── domain-boundaries.md
│   │   └── examples/
│   │       ├── aprendiz.md
│   │       ├── instructor.md
│   │       ├── ficha.md
│   │       ├── ambiente-formacion.md
│   │       ├── programa-formacion.md
│   │       └── horario.md
│   │
│   ├── 03-product-definition/
│   │   ├── README.md
│   │   ├── product-vision.md
│   │   ├── mvp-definition.md
│   │   ├── roadmap.md
│   │   ├── user-personas.md
│   │   ├── user-journeys.md
│   │   ├── functional-requirements.md
│   │   ├── non-functional-requirements.md
│   │   └── acceptance-criteria.md
│   │
│   ├── 04-architecture/
│   │   ├── README.md
│   │   ├── architecture-principles.md
│   │   ├── architecture-overview.md
│   │   ├── architecture-decisions-summary.md
│   │   ├── quality-attributes.md
│   │   ├── integration-strategy.md
│   │   ├── deployment-strategy.md
│   │   │
│   │   ├── c4/
│   │   │   ├── README.md
│   │   │   ├── level-1-context.md
│   │   │   ├── level-2-containers.md
│   │   │   ├── level-3-components.md
│   │   │   └── level-4-code.md
│   │   │
│   │   ├── adr/
│   │   │   ├── README.md
│   │   │   ├── proposed/
│   │   │   │   └── ADR-000-template.md
│   │   │   ├── accepted/
│   │   │   │   └── .gitkeep
│   │   │   ├── superseded/
│   │   │   │   └── .gitkeep
│   │   │   └── rejected/
│   │   │       └── .gitkeep
│   │   │
│   │   └── diagrams/
│   │       ├── README.md
│   │       ├── source/
│   │       │   ├── plantuml/
│   │       │   │   └── .gitkeep
│   │       │   ├── mermaid/
│   │       │   │   └── .gitkeep
│   │       │   └── drawio/
│   │       │       └── .gitkeep
│   │       └── exported/
│   │           ├── png/
│   │           │   └── .gitkeep
│   │           └── svg/
│   │               └── .gitkeep
│   │
│   ├── 05-data-architecture/
│   │   ├── README.md
│   │   ├── conceptual-model.md
│   │   ├── logical-model.md
│   │   ├── relational-model.md
│   │   ├── entity-catalog.md
│   │   ├── data-dictionary.md
│   │   ├── database-standards.md
│   │   ├── migration-strategy.md
│   │   └── diagrams/
│   │       ├── erd.md
│   │       └── mer.md
│   │
│   ├── 06-api-design/
│   │   ├── README.md
│   │   ├── api-standards.md
│   │   ├── error-handling.md
│   │   ├── pagination-filtering-sorting.md
│   │   ├── authentication-authorization.md
│   │   ├── versioning.md
│   │   └── contracts/
│   │       ├── openapi/
│   │       │   └── .gitkeep
│   │       └── asyncapi/
│   │           └── .gitkeep
│   │
│   ├── 07-security/
│   │   ├── README.md
│   │   ├── security-principles.md
│   │   ├── identity-access-management.md
│   │   ├── roles-permissions.md
│   │   ├── threat-model.md
│   │   ├── data-protection.md
│   │   ├── auditability.md
│   │   └── security-checklist.md
│   │
│   ├── 08-devops/
│   │   ├── README.md
│   │   ├── repository-strategy.md
│   │   ├── branching-strategy.md
│   │   ├── ci-cd-strategy.md
│   │   ├── environments.md
│   │   ├── docker-standards.md
│   │   ├── deployment-checklist.md
│   │   └── observability.md
│   │
│   ├── 09-quality-assurance/
│   │   ├── README.md
│   │   ├── testing-strategy.md
│   │   ├── unit-testing.md
│   │   ├── integration-testing.md
│   │   ├── e2e-testing.md
│   │   ├── performance-testing.md
│   │   ├── accessibility-testing.md
│   │   └── quality-gates.md
│   │
│   ├── 10-user-experience/
│   │   ├── README.md
│   │   ├── ux-principles.md
│   │   ├── information-architecture.md
│   │   ├── navigation-model.md
│   │   ├── wireframes.md
│   │   ├── design-system.md
│   │   └── accessibility-guidelines.md
│   │
│   ├── 11-backlog/
│   │   ├── README.md
│   │   ├── epics/
│   │   │   └── .gitkeep
│   │   ├── features/
│   │   │   └── .gitkeep
│   │   ├── user-stories/
│   │   │   └── HU-000-template.md
│   │   ├── tasks/
│   │   │   └── TASK-000-template.md
│   │   └── traceability-matrix.md
│   │
│   ├── 12-microservices/
│   │   ├── README.md
│   │   ├── microservice-catalog.md
│   │   ├── microservice-template/
│   │   │   ├── README.md
│   │   │   ├── service-context.md
│   │   │   ├── service-responsibilities.md
│   │   │   ├── service-boundaries.md
│   │   │   ├── service-api.md
│   │   │   ├── service-data-model.md
│   │   │   ├── service-security.md
│   │   │   ├── service-deployment.md
│   │   │   ├── service-testing.md
│   │   │   └── service-runbook.md
│   │   │
│   │   └── services/
│   │       ├── .gitkeep
│   │       └── README.md
│   │
│   ├── 13-operations/
│   │   ├── README.md
│   │   ├── runbooks.md
│   │   ├── incident-management.md
│   │   ├── backup-restore.md
│   │   ├── monitoring-alerting.md
│   │   └── support-model.md
│   │
│   ├── 14-training-and-adoption/
│   │   ├── README.md
│   │   ├── user-manual.md
│   │   ├── instructor-guide.md
│   │   ├── administrator-guide.md
│   │   ├── onboarding.md
│   │   └── faq.md
│   │
│   ├── 15-event-catalog/
│   │   ├── README.md
│   │   ├── event-catalog-overview.md
│   │   ├── messaging-standards.md
│   │   └── events/
│   │       └── .gitkeep
│   │
│   ├── 16-service-communication/
│   │   ├── README.md
│   │   ├── api-gateway.md
│   │   ├── service-discovery.md
│   │   ├── circuit-breaker-policy.md
│   │   └── inter-service-communication.md
│   │
│   ├── 17-configuration-management/
│   │   ├── README.md
│   │   ├── config-strategy.md
│   │   ├── secrets-management.md
│   │   ├── feature-flags.md
│   │   └── environments-config.md
│   │
│   └── 99-archive/
│       ├── README.md
│       ├── deprecated/
│       │   └── .gitkeep
│       └── legacy/
│           └── .gitkeep
│
├── templates/
│   ├── README.md
│   ├── adr-template.md
│   ├── hu-template.md
│   ├── api-contract-template.md
│   ├── microservice-doc-template.md
│   ├── runbook-template.md
│   ├── test-plan-template.md
│   ├── risk-template.md
│   └── decision-log-template.md
│
├── assets/
│   ├── README.md
│   ├── images/
│   │   └── .gitkeep
│   ├── icons/
│   │   └── .gitkeep
│   └── exports/
│       └── .gitkeep
│
└── tools/
    ├── README.md
    ├── validate-docs.ps1
    ├── validate-links.ps1
    └── generate-index.ps1
```

---

