# Claude Code Resources

## Knowledge

- [Docs: Security (code.claude.com)](https://code.claude.com/docs/en/security)
  Primaire bron voor permissions, prompt injection, MCP-vertrouwen en werkmap-grens. Use for: les veilig werken.
- [Docs: Choose a permission mode](https://code.claude.com/docs/en/permission-modes)
  Tabel met modes (`default`/Manual, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`) en hoe je wisselt per surface (Shift+Tab, VS Code-indicator, Desktop-selector). Use for: oefening permission modes.
- [Docs: Configure permissions](https://code.claude.com/docs/en/permissions)
  Allow/ask/deny-regels, `/permissions`, `Read(./.env)` deny, workspace trust. Use for: deny-regels voor gevoelige bestanden.
- [Docs: Data usage](https://code.claude.com/docs/en/data-usage)
  Wat naar Anthropic gaat, training (niet bij Team/Enterprise), bewaartermijn 30 dagen, lokale transcripts in `~/.claude/projects/`, `/feedback` stuurt gesprek mee. Use for: uitleg wat er met data gebeurt.
- [Docs: Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp)
  `claude mcp add`, scopes local/project/user, `/mcp`, GitHub-voorbeeld met fine-grained token. Use for: les GitHub MCP.
- [Docs: Skills](https://code.claude.com/docs/en/skills)
  Wat een skill is, locaties, `/skill-naam`, `/skills`, automatisch laden via `description`. Use for: les skills.
- [Docs: Best practices](https://code.claude.com/docs/en/best-practices)
  Explore-plan-code, verificatie geven, `/clear`, `Esc`, `/rewind`, faalpatronen. Use for: werkwijze en verschil met chat.

- Franks interne wiki "Machine setup" (ASZ)
  Installatie Claude Code, mattpocock-skills, GitHub MCP met `GITHUB_PAT` via 1Password en `claude mcp add-json ... -s user`. Use for: les 2 en 3; ASZ-standaard voor setup.
- [mattpocock/skills (GitHub)](https://github.com/mattpocock/skills)
  Bron van de skills-plugin (`grilling`, `code-review`, `pr`, `teach`). Use for: les 3.

## Wisdom (Communities)

- Interne ASZ-groep (nog op te richten): Teams-kanaal waar collega's prompts, skills en incidenten delen. Use for: na de workshop.
- [Anthropic Discord](https://www.anthropic.com/discord)
  Officiële community met Claude Code-kanalen. Use for: vragen die de docs niet beantwoorden.

## Gaps

- Formeel ASZ-beleid voor AI-tools (toegestane data, plan, bewaartermijn). Nu alleen informele afspraken; navragen bij privacy officer / CISO.
- GitHub MCP in de desktop-app voor niet-technische collega's: connectors via claude.ai nog niet onderzocht.
