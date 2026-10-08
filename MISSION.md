# Mission: Claude Code workshop voor ASZ-collega's

## Why
Frank wil collega's van ASZ (data engineers, BI-analisten en niet-technische collega's) in één workshop van ongeveer een uur leren werken met Claude Code. Na de workshop gebruiken zij het zelfstandig en veilig, in een ziekenhuisomgeving waar patiëntgegevens onder AVG, WGBO en NEN 7510 vallen.

## Success looks like
- Een collega legt in eigen woorden uit wat Claude Code anders doet dan een ChatGPT-chat: het leest bestanden, voert commando's uit en wijzigt bestanden.
- Een collega herkent een permission prompt, kiest bewust tussen toestaan en weigeren, en wisselt van permission mode.
- Een collega noemt de ASZ-regels voor data: geen patiëntgegevens in prompts, geen echte data in repo's.
- Een data engineer of BI-analist verbindt de GitHub MCP-server met een eigen fine-grained token en controleert de verbinding met `/mcp`. Niet-technische collega's zien hoe het werkt.
- Een collega installeert de mattpocock-skills, vindt skills met `/skills` en gebruikt `/grilling`, `/code-review` en `/pr` om een query van vraag tot pull request te brengen, zonder dat Claude de database raakt.

## Constraints
- Workshop van ongeveer een uur, geleid door Frank. Lessen dienen als hand-out en oefenmateriaal.
- Gemengde groep: data engineers (CLI of VS Code), BI-analisten en niet-technische collega's (desktop-app, Code-tab).
- Lessen in het Nederlands; namen van tools, commando's en knoppen blijven Engels.
- ASZ heeft alleen informele afspraken over AI-tools. Lessen stellen veilige standaarden voor en markeren open punten.
- Alleen synthetische voorbeelddata.

## Out of scope
- Zelf skills schrijven.
- Hooks, subagents, plugins bouwen, CI-automatisering met `claude -p`.
- Diepgaande prompt engineering.
