# Checkpoint 02 — Primeiro ciclo jogável, pixel art 8-bit

## O que entra
- Caminhada pelo mesmo cenário do Reel (sprites e paralaxe do CP01A preservados).
- 6 folhas de sprites originais de monstros (slime, javali, lobo, cogumelo, javali elite e Lobo Alfa), quatro quadros por criatura; pixels nítidos sem filtros suaves.
- Regiões: planícies verdes, fases 1–10 com elite em 5 e boss em 10. Transições automáticas entre exploração, combate, vitória e farm.
- Quatro funções de RPG: Rudeus (dano/debuff), Roxy (molhado/gelo/controle), Sylphie (cura/escudo) e Eris (dano físico/combo). 12 habilidades de dados, cooldowns, prioridades situacionais.
- Barras de HP, status dos heróis, aviso de ataque do chefe, efeitos de impacto, ganho de XP e ouro.
- Evolução da equipe gastando ouro (U), farm (F), pausa (Espaço), salvar (S), modo compacto/expandido (Tab), fixar janela (T), HUD (H).
- Simulação de combate em passos fixos de 100 ms independentes da taxa de quadros e modo de apresentação.
- Save versionado simples em `user://kmushoko_progress_v1.json` com gravação temporária e troca de arquivo. Salva avanço, ouro, nível, XP e modo farm; não salva luta intermediária.

## Controles
| Ação | Tecla |
| --- | --- |
| Janela compacta/expandida | TAB |
| Pausa | Espaço |
| Aprimorar equipe | U (custo em ouro no HUD) |
| Habilitar ou desabilitar farm | F |
| Salvar | S |
| Mostrar/ocultar HUD | H |
| Alternar janela sempre no topo | T |
| Retornar ao expandido a partir do compacto | Esc |

## Validação
- `python tools/validate_data.py`
- `python tools/validate_assets.py`
- `python tools/validate_combat_data.py`
- `python tools/generate_monsters.py` e `git diff --exit-code -- assets/enemies`
- `godot --headless --editor --path . --quit`
- `godot --headless --path . --script res://tests/test_game_session.gd`
- `godot --headless --path . --quit-after 120`

## Limitações intencionais
Ainda é uma **vertical slice**: sem áudio, inventário, crafting, drops individuais, multiplayer ou progressão offline. O combate é automático e a IA usa pesos simples; balanceamento precisará de playtest no Windows. A arte chibi ainda é um primeiro passe, e novos monstros devem respeitar a mesma espessura de contorno/iluminação do Reel. Não subir artes ripadas do vídeo.

## Próximas melhorias
CP02B: telegraph desenhado no chão, efeitos em sprites 8-bit, hitstop leve, animações reais de ataque e barra de especial. CP03: bosses com padrões e arena dedicados, drops de equipamentos, baús e progressão regional mais profunda. Planejar a importação futura de novos personagens por registros em vez de condicionais por nome.