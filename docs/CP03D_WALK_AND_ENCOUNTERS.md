# CP03D — Corrigir direção e troca de aparência entre quadros

O CP03C intercalava três sprites chibi com um quarto quadro feito em outra
linguagem pixel art. Esse quadro reaparecia no walk loop e trocava rosto,
roupas, proporções e silhueta. Ao mesmo tempo, heróis caminhavam para a
esquerda mas encontravam inimigos à direita.

**Corrigido:** todos os heróis continuam olhando para a esquerda, como no
vídeo. Inimigos surgem do lado esquerdo e são espelhados apenas no corpo;
HP permanece normal. Eris forma a vanguarda e os três magos ficam atrás.
A paralaxe se move na direção oposta. Telegraphs do chefe passam a sinalizar
o lado ocupado pelos heróis.

A caminhada agora usa a sequência [0,1,2,1,0,1,2,1] a partir de três
poses pixeladas compatíveis. A região superior (até 59 px) vem de uma
base única para preservar a identidade da skin, enquanto as pernas/capas
variam. São oito frames mas apenas **três poses de pernas distintas**;
animação autoral mais sofisticada é etapa posterior, não está prometida aqui.

Validação automatizada: `tools/validate_walk_consistency.py` e
`tests/test_party_direction.gd`, junto aos testes anteriores Godot 4.7.2.
