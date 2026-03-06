# anchoring-examples

Every artifact in this repository is anchored to Bitcoin.

Verify any `.proof` file at [verify-anchoring.org](https://verify-anchoring.org).

---

## How it works

On every push to `main`, the workflow:

1. Creates a build artifact
2. Anchors it to Bitcoin via [`anchor-action`](https://github.com/AnchoringTrust/anchor-action)
3. Uploads the `.proof` file as a build artifact

The proof is independently verifiable. No account, no vendor, no trust required.

## Try it yourself

1. Fork this repo
2. Add `UMARISE_API_KEY` to your repo secrets (Settings → Secrets → Actions)
3. Push a commit
4. Check the Actions tab — download the `.proof` artifact
5. Verify at [verify-anchoring.org](https://verify-anchoring.org)

Get an API key at [umarise.com/developers](https://umarise.com/developers).

## Links

- [Umarise — Anchoring Infrastructure](https://umarise.com)
- [GitHub Action](https://github.com/marketplace/actions/umarise-anchor)
- [CLI](https://www.npmjs.com/package/@umarise/cli)
- [Independent Verifier](https://verify-anchoring.org)
- [Anchoring Specification](https://anchoring-spec.org)

## License

Unlicense (Public Domain)
