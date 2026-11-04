---
name: modern-opentofu-engineering
description: "Automatically enforces modern OpenTofu engineering standards: modular architecture & OpenTofu registry pinning, native state and plan encryption (AES-GCM / PBKDF2 / KMS), early variable evaluation, remote backend state locking, shift-left testing with native 'tofu test' (mocks, overrides, assertions), TFLint & Trivy security gates, passwordless OIDC GitOps CI/CD pipelines, resource lifecycle controls (prevent_destroy, moved, removed, import), and mandatory living README.md runbook documentation."
---

# Modern OpenTofu Engineering Guardrails & Skill Router

Entry point for this plugin's guardrails in Claude Code. Before acting, read the full standard:

`${CLAUDE_PLUGIN_ROOT}/rules/modern-opentofu-engineering.md`

It routes each kind of task to the specialized skill of this plugin and lists the non-negotiable rules.
In Claude Code those skills are namespaced: invoke `modern-opentofu-best-practices:<skill-name>`.

> Generated from `rules/modern-opentofu-engineering.md`, which is also the Antigravity rule. Edit the rule, not this file.
