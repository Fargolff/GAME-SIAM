# Staging Config Notes

Godot client config lives in:

`C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle\scripts\config\environment.gd`

## Environments

- `dev`: local/dev Supabase placeholder
- `staging`: closed-test Supabase placeholder
- `prod`: production Supabase placeholder

Before real closed testing, replace:

- Supabase project URL
- Supabase anon key
- Feedback form URL

Set the active environment through project setting:

`application/config/gamesiam_environment`

Default is `dev`.

## Safety Rules

- Never ship staging/prod keys in a public repository without reviewing exposure risk.
- Do not enable paid gacha until Google purchase validation is live.
- Do not use local save as source of truth for premium currency.
