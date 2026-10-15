# KMushokoPixel — Art Bible v0.2

## Regra inegociável

O **vídeo enviado pelo criador** define a linguagem artística; não usar artes de outros RPGs como substituto. Não há monstros no vídeo, então monstros e chefes devem ser DESENHADOS no mesmo vocabulário visual, sem alegar que foram extraídos do Reel. Os sprites do protótipo ManaTrail anterior NÃO estão aprovados. Preservar a aparência dos personagens mostrados no vídeo: silhuetas, acessórios, paleta, postura e dinâmica de caminhada. Produzir assets originais sem copiar ou extrair imagens de terceiros para distribuição.

## Observações da referência

- Vídeo vertical, aproximadamente 8 segundos; quartetos em movimento lateral com pixels definidos e cenário colorido.
- Ordem de caminhada: **Rudeus, Sylphie, Roxy, Eris**.
- Personagens chibi, perfil lateral/3/4, cabeças relativamente grandes, braços/pernas legíveis, cabelo e roupas com movimento.
- Contornos escuros, volumes por grupos de pixels e poucos tons por material; sem smoothing de textura em tempo de execução.
- Camadas do mapa: céu, nuvens, montanhas azuladas, floresta, flores, chão e vegetação frontal; deslocamento por paralaxe.
- Alguns trechos do vídeo aparentam suavização, mas a direção de arte do jogo prioriza o visual **pixelado nítido**.

## Paleta amostrada do vídeo (aproximada; não substituir observação lado a lado)

| Material | Cor |
| --- | --- |
| Céu | `#1F92FD` |
| Nuvens | `#EBF3F7` |
| Sombra clara | `#B0D9FB` |
| Montanhas | `#1678B3` |
| Grama iluminada | `#8DC248` |
| Grama secundária | `#6CAD39` |
| Vegetação escura | `#0B5C51` |
| Vegetação frontal | `#02354A` |
| Contorno | `#100A13` |

**Importante:** paleta-base de cenário, não paleta completa dos quatro heróis. Não inventar tons definitivos antes de conferir os quadros do vídeo.

## Fichas de fidelidade visual

- **Rudeus:** cabelo cobre/alaranjado conforme o Reel (não verde), traje aventureiro em tons azul/verde, cajado, silhueta legível como mago.
- **Sylphie:** cabelo claro/acinzentado como o vídeo, roupa leve com detalhes esverdeados, movimento delicado.
- **Roxy:** cabelo azul, chapéu pontudo azul escuro, cajado, capa; silhueta não deve confundir com a de Rudeus.
- **Eris:** cabelo vermelho longo, espada, roupa clara e detalhes escuros; passo mais enérgico de espadachim.

Não extrapolar uma cor a partir de um quadro comprimido; confirmar com vários frames, principalmente nas partes animadas.

## Pipeline da arte

1. Salvar **referências locais para revisão apenas** (não distribuí-las como assets do jogo).
2. Produzir primeiro um **Rudeus piloto** em pixel art, fundo transparente, incluindo idle e walk.
3. Aprovar comparação A/B com o Reel em **escala real do modo compacto**.
4. Fixar resolução-base, espessura de contorno, ponto de apoio dos pés, iluminação, saturação e timing (walk sugerido 6–8 frames, idle 4–6).
5. Replicar pipeline para Sylphie, Roxy e Eris sem mudar proporções e escala.
6. Produzir slime piloto e um monstro de tamanho médio seguindo exatamente a mesma estética.
7. Fazer um boss grande com mesma lógica de luz/contorno, telegraph legível e 2 ataques distintos.

## Gate de aceitação

- Os 4 reconhecíveis **sem rótulos**, inclusive na janela compacta.
- No Reel, a formação e o balanço de cabelo/roupa dão personalidade; reproduzir isso em jogo.
- Pés alinhados; escala e anatomia coerentes; sombras de contato.
- `CanvasItem.texture_filter = NEAREST` ou configuração equivalente; sem blur inesperado.
- Comparação A/B documentada e aprovação do criador ANTES de implementar conteúdo em massa.
- Sprite de combate preserva identidade visual do sprite caminhando.
