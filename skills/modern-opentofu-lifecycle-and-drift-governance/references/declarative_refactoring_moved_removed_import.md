# Declarative Refactoring: `moved`, `removed`, and `import`

Modern OpenTofu enables pure declarative code refactoring, completely eliminating the need for manual, risky CLI state manipulation commands.

---

## 1. Declarative Renaming & Moving with `moved`

When renaming a resource or refactoring a flat resource into a child module, standard OpenTofu would attempt to destroy the old resource and create a new one. The `moved` block instructs OpenTofu to update state addresses instead:

### Renaming a Resource
```hcl
moved {
  from = aws_security_group.allow_tls
  to   = aws_security_group.web_ingress
}
```

### Refactoring into a Child Module
```hcl
moved {
  from = aws_vpc.this
  to   = module.network.aws_vpc.this
}
```

### Migrating Single Resource to `for_each` Collection
```hcl
moved {
  from = aws_subnet.public
  to   = aws_subnet.public["us-east-1a"]
}
```

---

## 2. Decoupling Resources with `removed` (OpenTofu 1.7+)

Before OpenTofu 1.7, removing a resource from OpenTofu management without destroying it in AWS/Azure required running `tofu state rm <address>` manually on an engineer's laptop.

In OpenTofu 1.7+, use the declarative `removed` block:

```hcl
removed {
  from = aws_s3_bucket.legacy_logs

  lifecycle {
    destroy = false # OpenTofu deletes it from state but DOES NOT delete the AWS S3 bucket!
  }
}
```

When `tofu apply` runs, OpenTofu safely forgets the resource.

---

## 3. Declarative Adoption with `import`

To adopt existing cloud resources into OpenTofu management without imperatively running `tofu import`:

```hcl
import {
  to = aws_route53_zone.primary
  id = "Z1234567890ABCDEF"
}
```

Generate the initial configuration code automatically:

```bash
tofu plan -generate-config-out=generated_route53.tf
```

Review the generated code, refactor attributes, and apply:

```bash
tofu apply
```
