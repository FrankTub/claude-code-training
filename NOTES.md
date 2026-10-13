# Notes

- Learner van deze workspace is Frank (docent). Lessen zijn tegelijk hand-out voor collega's.
- Workshop ~1 uur. Vijf lessen: veilig werken (10), context window (8), AGENTS.md en CONTEXT.md (8), skills (14), GitHub MCP (10). Lesblokken ~8-14 min.
- Doelgroep gemengd: data engineers (CLI/VS Code), BI (VS Code of desktop), niet-technisch (desktop Code-tab). Elke les geeft per surface de juiste handeling.
- Taal: Nederlands. Tool-termen, commando's en knoppen in het Engels.
- ASZ-context: ziekenhuis, AVG/WGBO/NEN 7510. Nooit echte patiëntdata in voorbeelden.
- ASZ-afspraken (van Frank, 2026-10-08): geen databaseverbindingen voor Claude. Queryresultaten mogen gedeeld worden, alleen geaggregeerd en niet herleidbaar naar patiënten. Lessen markeren dit als "ASZ-afspraak".
- GitHub: ieder maakt eigen fine-grained PAT (Actions, Contents, Issues, Pull requests R+W), via env var `GITHUB_PAT`, `claude mcp add-json ... -s user`. Bron: Franks wiki-pagina "Machine setup".
- Niet-technische collega's kijken alleen mee bij GitHub MCP.
- Skills: mattpocock-skills (marketplace `mattpocock/skills`). Frank demonstreert live het maken van queries die hij zelf ook in de repo zet.
- Nog onbekend: welk Claude-plan (Team/Enterprise).
- Les 2 (toegevoegd 2026-10-13): context window. Bron: docs context-window en best-practices. Les 3: AGENTS.md en CONTEXT.md (volgorde: veilig werken, context window, AGENTS.md, skills, GitHub MCP). Feiten (docs, 2026-10): Claude Code leest `AGENTS.md` zelf sinds v2.1.277, maar alleen als er geen `CLAUDE.md` of `CLAUDE.local.md` is; anders `@AGENTS.md` importeren. Op Windows geen symlink. mattpocock-skills heeft `CONTEXT.md` hernoemd naar `GLOSSARY.md`.
- Feit om te onthouden: sinds v2.1.283 start CLI/VS Code standaard in `auto` mode. Voor beginners in ziekenhuiscontext Manual of Plan mode aanraden.
