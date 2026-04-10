# Contributing to anchoring-examples

Thanks for your interest in improving these examples.

## What belongs here

- **Workflow templates** — new stacks (Rust, Go, Java, etc.)
- **Verification scripts** — new languages or platforms
- **Documentation improvements** — clearer instructions, typo fixes
- **Bug fixes** — broken workflows or scripts

## What doesn't belong here

- Changes to the anchor-action itself (see [AnchoringTrust/anchor-action](https://github.com/AnchoringTrust/anchor-action))
- Feature requests for the Umarise API (see [umarise.com/developers](https://umarise.com/developers))

## Adding a new workflow template

1. Create `.github/workflows/anchor-<stack>.yml`
2. Follow the existing pattern: **Test → Build → Anchor**
3. Add a row to the workflow table in `README.md`
4. Keep it minimal — show the anchoring step, not a full CI/CD setup

### Required steps

Every template must include:

```yaml
- name: Anchor to Bitcoin
  uses: AnchoringTrust/anchor-action@v1
  with:
    file: <your-artifact>
  env:
    UMARISE_API_KEY: ${{ secrets.UMARISE_API_KEY }}
