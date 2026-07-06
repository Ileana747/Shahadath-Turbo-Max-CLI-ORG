# Shahadath Turbo Max CLI

> Personal-use CLI. Fast. Blunt. Built for speed, not for corporate feelings.

---

## Install

One-liner (Linux / macOS / Termux / Android / Windows):

```bash
curl -fsSL https://shahadath-serve.onrender.com/install.sh | bash
```

Or on Windows (PowerShell):

```powershell
irm https://shahadath-serve.onrender.com/install.sh | iex
```

Verify:

```bash
shahadath --version
```

---

## Commands

```bash
shahadath <url>              # Download in normal mode (free)
shahadath turbo <url>        # Download in turbo mode (8 connections, linked)
shahadath max <url>          # Download in MAX mode (16 connections, linked)
shahadath ai "<prompt>"     # Ask the AI assistant
shahadath link               # Link your Telegram account
shahadath unlink             # Unlink your account
shahadath cookie create      # Create a cookies file
shahadath clean              # Clean cache (keeps verification)
shahadath clean everything   # Clean absolutely everything
shahadath update             # Check for updates
shahadath status             # Show current status
shahadath config             # Show/edit config
shahadath help               # Show help
shahadath version            # Show version
```

---

## Modes

| Mode   | Connections | Linking  | Resolutions                     |
|--------|-------------|----------|---------------------------------|
| normal | 1           | free     | 480p / 720p / 1080p             |
| turbo  | 8           | linked   | 480p / 720p / 1080p / 1440p / 2160p |
| max    | 16          | linked   | 480p / 720p / 1080p / 1440p / 2160p |

## Formats

- `mp4` — video
- `mp3` — audio only

---

## Linking

1. Talk to [@Shahadath_CLI_bot](https://t.me/Shahadath_CLI_bot) on Telegram.
2. Send `/start` to get your linking code.
3. Run `shahadath link <your-code>` on your machine.

For the family tier (50 AI messages/day), use `/family <token>` in the bot to get an `imsudo` code.

---

## Update

```bash
shahadath update
```

Or re-run the install command.

---

## Personal Use Only

This CLI is for personal use only. Misuse is on you.
