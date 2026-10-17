# CP03C — Reboot visual guiado pelo Reel

**Estado:** primeiro passe implementado, aguardando avaliação visual no Godot 4.7.2 (Windows).

## Problemas identificados no CP03

1. Personagens 48×60 muito genéricos e sem semelhança suficiente com o Reel; passos simulados por 1px -> moonwalk.
2. Heróis do vídeo caminham **olhando para a esquerda**, mas o cenário anterior se deslocava para a esquerda; durante o combate, inimigos à direita e heróis ainda olhando para a esquerda.
3. HUD com retângulos enormes e barra inferior cobrindo cenário.
4. Monstros eram recortes retangulares com visual sem coerência com personagens.
5. Pipeline `generate_assets.py` poderia restaurar a arte antiga e passar CI porque a testagem visual dependia de screenshots artificiais.

## Trabalho implementado

- 4 heróis 72×100, 20 frames: idle 4, walk 8 (4 poses-fonte repetidas), cast 6, hit 2.
- `Hero.facing_right` controla flip apenas no combate; viagem para esquerda -> paralaxe para direita.
- Grade inteira de pixels: 384×216 @ 3x / 480×120 @ 2x; a troca de tamanho não altera GameSession.
- Atualização da HUD: faixa superior de 19/12px, cards de 25px e rodapé de 13/11px, sem grande mensagem central.
- Seis monstros novos desenhados proceduralmente em pixel art com uma paleta coerente, sem esticar sprites.
- Uma camada de flora reproduzível (flores, ervas, pedras) para as Planícies Verdes.
- Sistema de VFX mantém mágicas atuais e aceita efeitos `fire`, `air`, `arrow` para habilidades futuras.
- Teste de instalação limpa e de arquivo fonte; CI no Godot 4.7.2.

## Atenção jurídica

**Os sprites-fonte temporários foram reconstruídos diretamente de quadros do Reel fornecido pelo usuário.** Não são assets originais/licenciados. Servem apenas para validar silhueta, vestuário, paleta, posição e ritmo durante a pré-produção. Antes de distribuição, solicitar direitos/licenças ou substituir por sprites próprios de produção, respeitando também os direitos de Mushoku Tensei.

## Critérios de aceite (ainda requerem validação humana)

- Comparar o jogo *em execução* com o vídeo, não aprovar com base em imagem conceitual.
- Verificar se os oito frames da caminhada no Windows não apresentam oscilação de sprite ou recortes de fundo.
- Validar Sylphie e Roxy no modo compacto, olhos/rosto/capa na mesma altura relativa do Reel.
- Confirmar que combate mostra heróis olhando para a direita e inimigos para a esquerda, sem moonwalk.
- Confirmar legibilidade dos cards de HP e aviso do Lobo Alfa em ambos os modos.
- Polir contornos e recortar manualmente resíduos do fundo do Reel ainda visíveis nos sprites temporários.

**Não é arte final.** Este checkpoint estabelece a base verificável para o trabalho manual de sprites de produção.
