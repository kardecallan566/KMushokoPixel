# KMushokoPixel

RPG idle 2D de exploração lateral em **Godot 4.x**, com janela compacta de desktop e modo expandido para gerenciamento. Projeto fan-made em pré-produção, inspirado em *Mushoku Tensei*, no vídeo de referência compartilhado pelo criador (direção visual) e em *Task Bar Hero* (progressão e desktop companion).

**Primeiro quarteto:** Rudeus (mago de artilharia), Sylphie (maga de suporte), Roxy (maga elementalista) e Eris (guerreira). Mesmo pertencendo à classe mago, Rudeus, Sylphie e Roxy têm funções, lógica de IA e habilidades distintas.

## Comece aqui

- [Game Design Document](docs/GDD.md): loop, fases, bosses, equipamentos, economia, modo híbrido e arquitetura.
- [Art Bible](docs/ART_BIBLE.md): fidelidade ao Reel, paleta, escala, animações e aprovação.
- [Classes e personagens](docs/CHARACTERS_AND_CLASSES.md): papéis, habilidades e expansão futura.
- [Roadmap](docs/ROADMAP.md): checkpoints e critérios de aceite.
- [Contrato de dados](docs/DATA_CONTRACT.md): esquemas versionados e próximos passos.
- `data/characters.json`: elenco inicial.
- `data/stages.json`: fases 1–10 e primeiro boss.

## Verificação

```sh
python tools/validate_data.py
```

**Estado:** somente planejamento e dados; ainda não há cena Godot jogável nem sprites definitivos aprovados. A arte de protótipos anteriores não será usada como definitiva.

## Direitos e licenciamento

Os personagens de *Mushoku Tensei* pertencem aos respectivos titulares. O Reel é referência artística, não uma licença de redistribuição de sprites, trilha ou cenas. Produzir novos assets autorais e verificar permissões antes de publicar/comercializar.
