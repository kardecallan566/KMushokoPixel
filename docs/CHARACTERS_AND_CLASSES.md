# Personagens, classes e especializações

## Modelo extensível

**Classe** define regras compartilhadas de equipamentos, recursos, ataque e posicionamento. **Especialização** define função tática. **Personagem** define arte, IA, elementos e habilidades únicas. O motor de combate não deve conter `if name == "Rudeus"` ou qualquer outra lógica por nome. Novos integrantes são cadastrados por dados, habilidades e sprites.

| Personagem | Classe | Especialização | Uso principal |
| --- | --- | --- | --- |
| Rudeus | Mago | Artilharia / debuff | Explosão de dano em elites e bosses, quebra de defesa |
| Roxy | Maga | Elementalista / controle | Dano em área, molhado, gelo e interrupções |
| Sylphie | Maga | Cura / proteção | Cura por prioridade, escudo e buffs defensivos |
| Eris | Guerreira | Espadachim / duelista | Ataque frontal, interrupção e finalização |

## IA e utilidade permanente

- **Rudeus** prioriza armadura inimiga e alvos de alto valor; recursos e recargas impedem spam.
- **Roxy** controla múltiplos monstros, preparando combos molhado+gelo; não substitui a função de Rudeus.
- **Sylphie** cura abaixo de um limiar, protege antes de telegraphs de chefes e também causa dano leve quando não há emergência.
- **Eris** protege a linha frontal interceptando inimigos e explora adversários debilitados.

Cada herói terá (meta de médio prazo) um ataque básico, duas habilidades ativas, uma passiva e uma ultimate, com feedback visual, cooldown, alvo e prioridades explícitos. O JSON de CP00 define 3 habilidades iniciais e ainda não é uma implementação de combate.

## Sinergias

- `wet` + `ice` -> congelamento ampliado (Roxy).
- `armor_broken` (Rudeus) + espada de Eris -> janela de dano físico.
- Escudo antecipado de Sylphie -> proteção contra golpe anunciado de boss.
- Controle de Roxy + cura de Sylphie -> sobrevivência contra múltiplas ondas.

## Sistema de grupo para futuro

A primeira versão tem 4 heróis fixos, mas o sistema deve suportar **elenco desbloqueável e 4 slots de party**, sem exigir quatro magos ou uma composição única. Especializações podem compartilhar classe sem compartilhar mecânicas. Personagens candidatos para estudo posterior: Ruijerd, Ghislaine, Paul, Zanoba, Cliff e Elinalise; pesquisa de lore e autorização de uso de personagem antes de produção.

Personagens não devem ficar inúteis ao atingir conteúdo mais avançado: cada um mantém pelo menos uma especialidade valiosa em elites/bosses e equipamento escalável.
