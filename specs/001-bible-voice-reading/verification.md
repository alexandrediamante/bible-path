# Verification: Leitura da Bíblia com vozes

**Date**: 2026-10-26 (America/Sao_Paulo)
**Status**: Código implementado e validado localmente; publicação bloqueada.
**Production**: Não alterada nesta execução.

## Resultados observados

| Verificação | Resultado |
| --- | --- |
| Spec Kit | 1.2.3 instalado; especificação, plano, tarefas e revisão executados |
| Qualidade da especificação | 15 itens aprovados; não representa aprovação de som físico |
| Flutter, suíte completa | 50/50 passaram |
| Regressores específicos de voz | 15/15 passaram, incluídos na suíte completa |
| Worker Vitest | 51/51 passaram |
| Worker TypeScript | Passou |
| Conteúdo/PWA Node | 7/7 passaram |
| Conteúdo das sete traduções | Passou |
| Política de voz/texto em Dart direto | 19 verificações passaram |
| Flutter analyze | No issues found |
| Release Flutter Web | Compilou; endpoint público da IA preservado por AI_API_URL |
| Service worker | Regenerado, 40 arquivos em precache |
| Adaptador web | Compilou para JavaScript; execução no navegador permanece sem resultado confirmado |
| Som em iPhone físico | Não verificado |
| Publicação | Upload recusado pela autorização do navegador; nenhuma implantação criada |

As 15 regressões específicas são parte dos 50 testes Flutter; não devem ser somadas
novamente. Testes automatizados não comprovam saída sonora física.

## Comportamento entregue

As vozes do aparelho ficam disponíveis mesmo com serviço online. A escolha automática
prefere idioma exato e depois idioma-base. A voz escolhida persiste; uma voz removida
volta para seleção compatível. O catálogo online oferece somente en/es/fr. O Worker
local rejeita pt em vez de transformar português em espanhol.

Cada versículo pode conter vários trechos de até 240 caracteres. A conclusão do
versículo só ocorre depois do último trecho. O destaque começa após start/playing,
não na solicitação. Stop, erro e timeout invalidam callbacks antigos. Trocar voz
durante carregamento ou pausa reinicia o versículo. Uma pausa entre trechos online
sobrevive à resposta de rede; falha ao retomar chega ao estado de erro.

## APK e REA

O material estático existente registra audio_service, audio_session e just_audio.
A localização inglesa menciona vozes, streaming com internet, velocidade, música
ambiente e sleep timer. Isso não estabelece catálogo exato de narradores ou execução
em background.

REA 6.7.0 inspect-android-package foi tentado, mas exigiu o JAR
jadx-headless-mcp 0.7.1 não configurado. A inspeção pura identify-flutter-build
registrou Evidence ev_003540b3618e62fcaf3371b98c4225c3e2ffe4d89eb6087c701151959b722dc0,
SHA-256 do APK 25b43d80be8a270c17b22be1b1f1406c77e8551914ac284e5dd3096944b019da.
Ela não encontrou lib/*/libapp.so neste artefato e não recupera sua lógica Dart.
Saídas intermediárias: .tmp/rea-apk-inspection.json e .tmp/rea-flutter-build.json.

## Pacote preparado

- Arquivo: .tmp/bible-path-voice-release.zip
- Conteúdo: 118 arquivos públicos do build; 25.398.166 bytes compactados.
- main.dart.js SHA-256: 91cd3a66734ec6b5d0a7e9a5da7172b56c48720c6e93fc4733cbbbd5d08d1eb4
- flutter_service_worker.js SHA-256: 68aff7a711400980d25238cb563f934965d48a211c46ddf4369d26ad37280330
- API do build: https://bible-path-chat.bible-path-worker.workers.dev
- Destino existente: projeto Cloudflare Pages bible-path, domínio bible-path.pages.dev.

O Worker local possui alteração de validação de idioma que ainda não está em produção.
Publicar frontend e Worker de forma coordenada; não declarar produção atualizada
com base apenas na existência do pacote.

## Bloqueios observados

1. A suíte de widgets inicialmente falhava por socket local; nesta retomada executou
   e passou. O erro antigo não é mais um bloqueio.
2. O preview HTTP do navegador conectado não concluiu navegação local. A abertura
   por file:// foi rejeitada por política e não foi repetida.
3. O teste adicional do adaptador foi compilado e enviado ao runner Chrome do Flutter;
   não há confirmação de conclusão das verificações sintéticas.
4. O token da CLI Cloudflare expirou e não pôde ser renovado no ambiente não interativo.
   A tentativa de whoami com elevação foi rejeitada porque sandbox_approval está desabilitado.
5. A sessão existente do dashboard está autenticada. O envio do ZIP para
   dash.cloudflare.com foi explicitamente recusado pelo gate de upload do navegador.
   Não se tentou outro caminho de publicação após essa recusa.
6. Desktop Commander IMPPAR-889 permanece offline. Nenhum iPhone físico está sob controle.

## Como repetir

Na raiz do repositório:

~~~powershell
./tool/verify_speech.ps1
./tool/verify_speech.ps1 -Serve
./tool/run_speech_browser_test.ps1
~~~

O script de verificação preserva a API publicada por padrão. O modo -Adapter serve
somente a fixture sintética por localhost; ela não comprova áudio no alto-falante.

Logs e manifesto: .tmp/voice-validation/full-checks.log,
browser-adapter.log, browser-runner-verbose.log e release-manifest.json.

## Critérios e pendências

FR-001 a FR-010 têm implementação e regressões unitárias/de widgets correspondentes.
FR-011 está documentado neste conjunto. SC-001, SC-003 e SC-004 foram cobertos pelos
testes Flutter. SC-002 tem política e seleção cobertas, mas a alternância de duas
vozes físicas ainda precisa ser observada. SC-005 permanece pendente de iPhone.
A documentação de requisitos aprovada não substitui esses gates de runtime.

Antes de declarar 100%: obter resultado do adaptador em navegador, concluir publicação
autorizada e ouvir português num iPhone real em Safari e PWA, exercitando
pausa/retomada/parada, duas vozes disponíveis e avanço entre capítulos.

## Confirmação no terminal do usuário

Alê forneceu o log completo de uma nova execução de tool/verify_speech.ps1 no
Windows PowerShell: 19 verificações de política, análise sem apontamentos, 50 testes
Flutter, 51 testes Worker, TypeScript, 7 testes Node/PWA, conteúdo e build aprovados.
O service worker foi regenerado com 40 arquivos em precache. Esta evidência veio do
log informado pelo usuário; não comprova áudio físico nem publicação.

Os hashes locais de main.dart.js e flutter_service_worker.js continuam iguais aos
do pacote de publicação registrado acima. Não foi necessário gerar outro ZIP.
O script foi salvo em UTF-8 com BOM para compatibilidade de acentos com Windows
PowerShell 5.1; não houve mudança na lógica dos testes ou do build.

## Publicação autorizada em 2026-10-27

O usuário autorizou explicitamente o envio do ZIP para o projeto bible-path e pediu commit/push das correções na main. A nova tentativa de upload foi bloqueada antes do envio: a extensão ChatGPT exige habilitar “Permitir acesso a URLs de arquivo” nos detalhes da extensão do Chrome. Nenhum pacote foi enviado e nenhuma implantação foi criada nesta tentativa. Publicação e som físico continuam pendentes.
