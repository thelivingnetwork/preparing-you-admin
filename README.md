# Preparing You · Admin

Admin panel for **[Preparing You](https://preparingyou.netlify.app)** — the gateway app that prepares people for entry into The Living Network.

## Live site

🔗 **https://preparingyou-admin.netlify.app**

Sign in with an admin account (allowlisted in the `prep_admins` table).

## What it does

A single-page admin console for managing the Preparing You service:

- **Users** — view applicants, gateway progress, TLN invite status; delete accounts
- **PCMs** — manage Personal Contact Ministers and their active status
- **Elections** — track PCM election requests and responses
- **Townhalls** — schedule townhalls, manage hosts/moderators, view the lifecycle log
- **Books** — edit the source-book catalog (titles, order, PDF paths, audio overviews)
- **Messages** — monitor user ↔ PCM messaging
- **Paul Logs** — review the Claude-powered "Paul" assistant chat history
- **Admins** — manage the admin allowlist

## Stack

- **Frontend:** Vanilla JS single `index.html`, deployed to Netlify
- **Auth + data:** Supabase (`prep_*` tables; admin access gated on `prep_admins`)
- **Backend:** Node service on Render — [`preparing-you-server.onrender.com`](https://preparing-you-server.onrender.com) (used for privileged operations like full user deletion)

## Repo layout

```
.
├── index.html      # The whole admin panel
├── netlify.toml    # Netlify config (SPA redirect)
├── favicon.png
├── ark-purple.png  # Brand mark
└── sql/            # Database schema / migrations
```
