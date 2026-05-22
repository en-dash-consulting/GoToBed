# Security Policy

## Supported versions

The latest release receives security fixes. Please update to the newest version
(via **Check for Updates…** in the menu) before reporting.

## Reporting a vulnerability

Please report security issues **privately** — do not open a public issue.

Use GitHub's private vulnerability reporting:
**[Report a vulnerability](https://github.com/en-dash-consulting/GoToBed/security/advisories/new)**
(Security → Advisories → Report a vulnerability).

We aim to acknowledge reports within a few days and will coordinate a fix and
disclosure with you.

## Scope notes

GoToBed is a **fully offline** menu-bar app: it has no network entitlement,
makes no network connections, and stores all data locally. This substantially
limits remote attack surface — the most relevant areas are local data handling
(`Application Support/GoToBed/state.json`) and the signed/notarized release
artifacts.
