# Git History Security Review

**Date:** 2026-06-21
**Branch:** `upgrade/security-currency-ui-v2-1`
**Base:** `origin/main`

## Findings

Sensitive-looking values (signing credentials) were found in 3 commits across 2 files.

### Commits Containing Secrets

| Commit | Message | Files affected | Secret type |
|---|---|---|---|
| `4d21de4` | Add comprehensive RELEASE_GUIDE.md + PROJECT_REFERENCE.md | `RELEASE_GUIDE.md`, `PROJECT_REFERENCE.md` | `storePassword` + `keyPassword` (same value) |
| `6e4b8af` | Splash screen updated (merge-based commit) | `RELEASE_GUIDE.md`, `PROJECT_REFERENCE.md` | (inherited from `4d21de4`) |
| `57312d9` | docs: add baseline upgrade audit | `RELEASE_GUIDE.md`, `PROJECT_REFERENCE.md`, `docs/baseline_upgrade_audit.md` | (inherited from `6e4b8af`) |

The initial commit `29f0abe` used `<your-password>` placeholders (safe). The actual credential value was introduced in `4d21de4` and persisted until the redaction in `faad99b`.

### Files That Contained Secrets

| File | Introduced in | Now clean? |
|---|---|---|
| `RELEASE_GUIDE.md` | `4d21de4` (was placeholder-safe in `29f0abe`) | ✅ Yes (`faad99b`) |
| `PROJECT_REFERENCE.md` | `4d21de4` | ✅ Yes (`faad99b`) |
| `docs/baseline_upgrade_audit.md` | `57312d9` | ✅ Yes (`faad99b`) |

### Other Files Inspected

No other tracked file in any commit contained the credential value.

## Is History Rewrite Recommended?

| Scenario | Recommendation |
|---|---|
| **Repo is private** and no other contributor has pushed/cloned | Optional — rotation of credentials is sufficient |
| **Repo is public** or has been shared externally | **Strongly recommended** — remove secrets from history before public exposure escalates |

The value exposed is a **keystore signing password**. Compromise would allow:
- An attacker to sign apps with this developer identity
- Publishing a malicious update impersonating the developer (if also combined with Play Console access)

## Safe Next Steps

### 1. Keep the Repository Private
Ensure visibility is **Private** in GitHub repo Settings. This repo currently has no public branches or forks.

### 2. Rotate the Credentials
Generate a new upload keystore, update `android/key.properties`, and re-register the new certificate in Google Play Console. The old credential in history then becomes irrelevant.

### 3. Rewrite History (only if needed, only after backup)
If a rewrite is chosen:

```bash
# Create a backup branch first
git branch backup/upgrade-security-currency-ui-v2-1

# Option A — BFG Repo-Cleaner (fast, recommended)
java -jar bfg.jar --replace-text secrets.txt .git

# Option B — git filter-repo (more control)
git filter-repo --path RELEASE_GUIDE.md --path PROJECT_REFERENCE.md \
  --path docs/baseline_upgrade_audit.md --invert-paths

# After either: verify the secret is gone
git log --all --oneline | head
git show 4d21de4:RELEASE_GUIDE.md 2>/dev/null | grep '<pattern>' || echo "✓ Clean"
```

### 4. Understand Force-Push Consequences
- All collaborators must re-clone (existing clones have the old history)
- If anyone has branched, PRs, or CI workflows, they will break
- GitHub will detect the force-push and may require team lead approval
- Tags will need to be re-created (`before-security-currency-ui-upgrade` will need attention)

### 5. Prevent Future Leaks
- ✅ .gitignore now blocks `key.properties`, `*.jks`, `*.keystore`
- ✅ `docs/security_notes.md` documents forbidden files
- ❌ No pre-commit hook or CI secret scan is configured

Consider adding a pre-commit hook or GitHub secret scanning (repo Settings > Security).

## Summary

| Question | Answer |
|---|---|
| Secrets found in history? | ✅ Yes — signing passwords in 3 commits |
| Files affected | `RELEASE_GUIDE.md`, `PROJECT_REFERENCE.md`, `docs/baseline_upgrade_audit.md` |
| Working tree clean now? | ✅ Yes |
| History rewrite needed? | Only if repo is public or has been shared |
| Recommended minimum action | Rotate credentials immediately |
