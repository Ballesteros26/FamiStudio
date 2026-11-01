# Parallel pull requests

- last updated: 2026-05-25

---

In order to update Dn-help in sync with your primary pull request on the parent repository Dn-FamiTracker's, you must make a parallel pull request on Dn-help.

1. Create a separate PR on Dn-help that has your corresponding changes.
2. **Do not push the subrepo head updates.**
3. When both your pull requests are ready, let the PR messages reference each other:
	- Dn-FamiTracker:
		- ``This pull request corresponds to Dn-Programming-Core-Management/Dn-help#`<PR number>`. Please merge Dn-help's PR before this one.``
	- Dn-help:
		- ``This pull request corresponds to Dn-Programming-Core-Management/Dn-FamiTracker#`<PR number>`.``

## Merging the PRs

1. Merge Dn-help's PR to its `main`
2. On Dn-FamiTracker's PR, push a commit that updates the subrepo head to point to the latest commit of Dn-help's `main` branch.
3. Merge Dn-FamiTracker's PR to its `main`.
