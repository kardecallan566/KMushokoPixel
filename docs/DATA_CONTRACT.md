# Contrato de dados — pré-produção v1

## `characters.json`

- `schema_version`: inteiro = 1.
- `party_walk_order`: os IDs de heróis, sem duplicatas.
- `characters[]`: id estável; nome; `class` (mage / warrior); `specialization` única no quarteto; `combat_position`; `element_tags`; `ai_priority`; `skills`; `art_status`.
- A lista de `skills` documenta intenções, não regras de combate implementadas. O gameplay deverá referenciá-las em registros de habilidades.
- Personagens novos poderão repetir classes e especializações quando o balanceamento permitir; o validador atual exige apenas que os quatro iniciais sejam distintos.

## `stages.json`

- `schema_version`: inteiro = 1.
- `region_id`: `green_plains`.
- `stages[]`: 1 a 10 em ordem; `kind` = `normal`, `elite` ou `boss`; `enemies` é uma lista de IDs.
- Fase 5 elite, fase 10 boss; este arquivo é somente o recorte inicial. Expandir por região na próxima fase de implementação.

## Próximos arquivos planejados

`data/enemies.json`, `data/skills.json`, `data/items.json`, `data/loot_tables.json`, `data/biomes.json`, schemas e migrações versionados.

Validar com `python tools/validate_data.py`, depois conectar à `ContentRegistry` do Godot. Não usar nomes de personagens em condicionais dentro do motor de combate.
