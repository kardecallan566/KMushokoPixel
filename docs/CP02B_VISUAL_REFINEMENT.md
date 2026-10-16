# CP02B — Recuperação e padronização da pixel art

Este checkpoint corrige **defeitos técnicos da representação visual** antes de implementar novas fases. Não altera balanceamento, save, classes ou a progressão de 10 estágios.

## Diagnóstico confirmado no CP02

- Sprite sheet 48×60 era ampliada com `preview_scale` fracionário (`1.30` e `1.35`), produzindo pixels de largura desigual e tremidos com movimento.
- Monstros também recebiam zoom fracionário (`0.7`, `0.95`, `1.3`), mudando de tamanho ao alternar janelas.
- O sprite do Lobo Alfa ocupava apenas parte vertical da própria célula e parecia flutuar.
- Efeito de ataque anterior era um deslocamento senoide não alinhado a pixels e um círculo genérico igual para todas as classes.
- HUD estava desenhada no `Main`, abaixo de sprites e do primeiro plano por ordem de desenho, permitindo folhas cobrirem barras e botões.
- Janela compacta ainda renderizava cartões de status sobre os pés dos personagens.

## Alterações

1. **Grade nativa inteira**: 384×216 a 3× no expandido (1152×648) e 480×120 a 2× no compacto (960×240). Sem zoom fracionário nos sprites, sem coordenadas subpixel na animação.
2. **Âncoras consistentes**: apoio de pé fixo a y=54 no herói; monstros reposicionados na própria sprite sheet com deslocamento compartilhado por animação.
3. **HUD separado em `scripts/hud.gd`**: elemento visual com `z_index=20`, acima de personagens e vegetação. Janela compacta com faixa superior de 14px e rodapé de 18px; barras de vida compactas no rodapé; sem cartões sobre os personagens.
4. **Efeitos específicos**: seis quadros de pixel art para cada um dos quatro integrantes — magia azul/terra do Rudeus, sigilo verde da Sylphie, gelo de Roxy e arco de espada da Eris.
5. **Polimento de roupas e acessórios**: detalhes discretos nos sprites originais, sem mudar as cores-base ou a ordem da equipe vista no Reel.
6. **Reprodutibilidade**: geração determinística em Python/Pillow e teste visual que garante resolução, margem, ancoragem, animação e nearest-neighbor.

## Referência de arte e limite de aprovação

O vídeo enviado continua sendo a referência. As quatro identidades e o cenário são os mesmos; a reforma corrige pixels quebrados, mas **não equivale ainda a declarar fidelidade artística perfeita ao vídeo**. A próxima rodada, após testar no Windows, deve revisar proporção de cabeças, roupas, armas, movimento e iluminação em comparação com frames individuais. A imagem `PREVIEW_CP02B_VISUAL.png` é uma **composição estática feita com os sprites reais**, e não uma captura do Godot.

## Checagens

```sh
python tools/generate_assets.py
python tools/generate_monsters.py
python tools/generate_effects.py
python tools/validate_visual_pipeline.py
python tools/validate_combat_data.py
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/test_game_session.gd
godot --headless --path . --quit-after 120
```

Validação manual necessária em Windows: alternar TAB durante combate, verificar recortes em resolução 100% e escalas de DPI diferentes, teste com boss e janela compacta em monitores variados.
