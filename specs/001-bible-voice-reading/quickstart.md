# Quickstart validation

## Prerequisites
Flutter local em ../../.flutter-sdk; pacotes existentes; Node e worker/node_modules.
Voz compatível instalada no navegador. iPhone deve testar Safari e PWA separadamente.

## Commands (PowerShell, repository root)
~~~powershell
& ..\.flutter-sdk\bin\flutter.bat analyze --no-pub
& ..\.flutter-sdk\bin\flutter.bat test --no-pub --concurrency=1
npm --prefix worker test
npm --prefix worker run typecheck
& ..\.flutter-sdk\bin\flutter.bat build web --release --no-pub --base-href /
python tool/serve_preview.py --help
~~~

## Scenarios
1. Abrir Bíblia/Gênesis 1 e Reproduzir. Ouvir português; só destacar após início.
2. Pausar, retomar, parar; trocar voz e velocidade carregando e pausado.
3. Habilitar próximo capítulo; ouvir fim do capítulo e início do seguinte.
4. Trocar manualmente capítulo: parar e ignorar eventos atrasados.
5. Alternar duas vozes disponíveis; recarregar e conferir preferência.
6. Sem rede: voz local pode funcionar se instalada; online mostra erro sem avanço.
7. iPhone: um toque para iniciar; confirmar som físico com volume normal,
   botão silencioso nas duas posições, Safari e instalada.
8. Não aprovar SC-005 com emulação Chromium nem só transição de AudioSession.

Registrar comandos, resultados e bloqueios em verification.md.
