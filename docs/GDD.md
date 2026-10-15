# KMushokoPixel — Game Design Document v1.0

> **Estado:** pré-produção, 14/10/2026. Engine proposta: Godot 4.x. Plataforma inicial: Windows. **Referência artística prioritária:** Reel fornecido pelo criador. **Referência de loop/desktop:** *TBH: Task Bar Hero*.

## Visão

RPG idle 2D lateral de quatro aventureiros. Em modo compacto, uma pequena janela fica próxima à barra de tarefas mostrando a equipe caminhando, enfrentando monstros e recolhendo loot. Em modo expandido, o jogador gerencia equipe, equipamentos, habilidades e estratégias. Alterar o tamanho da janela não pode reiniciar combate, fase ou cooldown.

### Pilares

1. O jogo deve ficar **tão charmoso visualmente quanto a referência do Reel**; arte piloto precisa de comparação e aprovação.
2. Cada integrante deve ter funções próprias, incluindo os três magos.
3. Progressão automática significativa com fases, elites, chefes, materiais, níveis e builds.
4. Um único estado lógico compartilhado entre os dois modos de janela.
5. Conteúdo novo por dados, não por scripts específicos para cada personagem/monstro.

## A jornada: exploração → encontro → combate → recompensa → melhoria

- Caminhada lateral contínua com cenário em paralaxe e quatro personagens no mesmo enquadramento.
- Ao encontrar inimigos, transição curta para formação de combate; IA executa habilidades conforme contexto.
- Vitória avança fase e concede XP/ouro/loot. Derrota retorna a farm de estágio já vencido sem apagar conquistas.
- Chefes têm ataques sinalizados e são vencíveis no compacto por IA bem configurada; expandido permite otimizar presets e observar efeitos maiores.

## Estrutura das fases

- Cada região contém **30 fases**; boss a cada 10, elite nas fases 5, 15 e 25.
- Estágio 10: Lobo Alfa, invoca lobos e investe.
- Estágio 20: Guardião da Floresta, raízes/espinhos.
- Estágio 30: Golem Ancestral, duas etapas e recompensa regional.
- Primeira **vertical slice = 10 fases**, com slime, javali, lobo, cogumelo e boss 10.
- Regiões futuras: **Floresta Encantada** (31–60), **Ruínas e Montanhas** (61–90).
- Recompensas garantidas de primeira vitória em bosses + tabela de drop repetível. Monstros e bosses devem ser desenhados com mesma linguagem da Art Bible.

## Quarteto e classes

- Rudeus: `mage / burst_controller`. Magias de pedra/terra, explosão direcionada, quebra de armadura.
- Roxy: `mage / elemental_controller`. Água/gelo, controle de grupos e debuffs.
- Sylphie: `mage / healer_support`. Cura, escudos e vento defensivo.
- Eris: `warrior / frontline_duelist`. Combos de espada, investida e interrupções.

Ao invés de codificar `if hero_name == ...`, cada herói referencia habilidades e preferências em dados. Quatro slots de equipe, permitindo desbloquear outros personagens no futuro. A formação da caminhada segue o Reel; a formação de combate pode ser configurada.

### Combate

- Simulação determinística por ticks ou delta controlado; FPS e tamanho da janela não alteram recompensa nem dano.
- HP, mana, alcance, cooldown, alvo, prioridades de IA e telegraph de boss.
- Estados iniciais: `wet`, `freeze`, `shield`, `weakened`, `heal_over_time`.
- Sinergias: molhado+gelo, defesa quebrada+combo físico, proteção antes de golpe do boss.
- Chefes não são sacos de HP: silhueta própria, introdução, 2+ ataques distintos, janela de reação e feedback de derrota.
- O jogador pode configurar prioridades e presets, mas microgerenciamento não deve ser obrigatório para concluir fases comuns.

## Economia e loot

- Moedas base: ouro, essências arcanas e materiais regionais. Sem monetização na primeira versão.
- Equipamento: arma, vestimenta e dois acessórios.
- Raridades: comum, incomum, raro, épico e lendário. Afixos de gameplay (dano, cooldown, duração de efeito), não apenas números maiores.
- Cada personagem terá nível, atributos, equipamentos, habilidades e árvore de melhorias planejada.
- Farm repetível de fases já conquistadas; bosses não avançam automaticamente via simulação offline.

## Modos de apresentação

**Compacto:** pequena janela sem bordas, opcional `always_on_top`, UI mínima (fase, HP compacto, pausa, expandir, notificações discretas), sem receber foco indevidamente e com controle de posição. Janela posicionada perto da taskbar; não literalmente integrada à barra do Windows.

**Expandido:** viewport amplo + equipe, inventário, habilidades, informações do estágio, controles de farm e builds. Uma mesma `GameSession` permanece ativa durante a transição. Salvar preferências de janela e providenciar boas dimensões para monitores 1080p e notebooks.

## Persistência e idle

- Arquivo versionado com gravação atômica/backup e recuperação em caso de corrupção.
- Pausa real; save em transições e intervalos.
- No modo compacto, simulação normal quando o programa está aberto.
- Ao reabrir, recompensa offline limitada inicialmente a 8 horas via estimativa de farm, sujeita a balanceamento. Nunca dar primeira vitória de boss offline. Controlar retrocesso/manipulação grosseira de relógio.

## Estrutura técnica prevista em Godot

```text
project.godot
assets/art/{characters,enemies,bosses,biomes,ui}/
assets/audio/{music,sfx}/
scenes/{world,actors,combat,ui}/
scripts/autoload/{game_session,save_service,content_registry}.gd
scripts/systems/{stage_director,combat_resolver,reward_service,offline_progress,window_mode_controller}.gd
scripts/actors/
data/
tests/
docs/
```

- **GameSession:** estado único em memória: equipe, progresso, luta atual e modo; UI nunca é fonte de verdade.
- **ContentRegistry:** desserialização e validação de heróis, habilidades, inimigos, fases, loot.
- **StageDirector:** sequência de exploração/encontro/vitória/derrota e transições.
- **CombatResolver:** dano, cooldown, IA e status por regra determinística, independente da renderização.
- **RewardService:** loot e XP com RNG de seed testável, impedindo recompensa duplicada.
- **WindowModeController:** modifica tamanho/bordas/viewport sem recriar a sessão.
- **SaveService:** salvar/carregar com versões e backup.
- Eventos/sinais: `stage_started`, `actor_damaged`, `skill_cast`, `loot_awarded`, `boss_started`, `mode_changed`.

## Testes obrigatórios

1. Repetir a mudança compacto↔expandido durante um ataque: sem reiniciar luta ou duplicar ouro.
2. Mesma seed + inputs = combate e loot equivalentes em FPS diferentes.
3. O progresso sobrevive a reinicialização e a save incompleto.
4. Chefes são solucionáveis por IA mesmo no compacto.
5. Conteúdo novo entra por definição de dados.
6. Parar de jogar offline não desbloqueia boss.
7. Os 4 heróis são reconhecíveis na resolução compacta.

## Critérios de vertical slice

Um bioma polido e fiel ao vídeo, quatro heróis reconhecíveis, 4 monstros, 10 fases (elite 5, boss 10), combate automático com sinergias, XP/loot simples, save e alternância de janela. Não produzir 90 fases, monetização, multiplayer ou gacha antes desse teste completo.

## Direitos

Projeto fan-made com personagens protegidos de *Mushoku Tensei*. Não usar assets ripados de vídeo/anime/terceiros; direitos de personagens e visual não são presumidos. Planejar autorização/licença ou substituição por personagens originais antes de distribuição pública/comercial.
