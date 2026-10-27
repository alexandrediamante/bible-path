# Tasks: Leitura da Bíblia com vozes
**Input**: spec.md, plan.md, research.md, data-model.md, contracts/speech.md.
**Tests**: solicitados pelo usuário. Executar regressões antes/depois.

## Phase 1: Setup
- [x] T001 Registrar princípios em .specify/memory/constitution.md.
- [x] T002 Documentar desenho e evidência em specs/001-bible-voice-reading/plan.md.

## Phase 2: Foundational
- [x] T003 Criar seleção por idioma e fragmentação com limite de 240 caracteres em lib/core/platform/speech_voice.dart.

## Phase 3: US1 - Ouvir capítulo
**Goal**: leitura real em sequência. **Independent test**: Gênesis 1 com pause/stop.
- [x] T004 [US1] Cobrir início e fim sem início em test/read_aloud_player_test.dart.
- [x] T005 [US1] Unificar geração e execução de trechos em lib/core/platform/speech_output_web.dart.
- [x] T006 [US1] Sincronizar destaque e conclusão em lib/shared/widgets/read_aloud_player.dart.
- [x] T007 [US1] Validar avanço de capítulo em test/bible_speech_test.dart.

## Phase 4: US2 - Selecionar voz
**Goal**: opções reais persistidas. **Independent test**: alternar duas vozes.
- [x] T008 [US2] Cobrir idioma exato/base e preferência removida em test/speech_voice_test.dart.
- [x] T009 [US2] Expor dispositivo e online en/es/fr em lib/core/platform/speech_output_web.dart.
- [x] T010 [US2] Rejeitar português online no Worker e cobrir contrato em worker/test/index.test.ts.

## Phase 5: US3 - Ajustar e recuperar
**Goal**: falhas sem avanço. **Independent test**: trocar carregando/pausado e falhar resume.
- [x] T011 [US3] Cobrir troca durante loading/pausa e cancelamento em test/read_aloud_player_test.dart.
- [x] T012 [US3] Propagar falhas de resume e tratar trechos longos em lib/core/platform/speech_output_web.dart.
- [x] T013 [US3] Corrigir avisos de idiomas e conexão em lib/l10n/app_*.arb.

## Phase 6: Validation
- [x] T014 Executar análise, suítes e release e registrar em specs/001-bible-voice-reading/verification.md.
- [ ] T015 Validar adaptador JS compilado e preview em navegador; registrar em specs/001-bible-voice-reading/verification.md.
- [ ] T016 Confirmar saída física no iPhone e produção em specs/001-bible-voice-reading/verification.md.

## Dependencies & Execution
Setup -> Foundational -> US1 -> US2 -> US3 -> Validation.
US1 é MVP. US2 pode testar política separadamente; US3 pode testar falhas isoladas.
Testes de política e Worker podem rodar em paralelo (arquivos distintos); mudanças no
adaptador/player são sequenciais. Não há tarefa de nova assinatura, chave ou cobrança.


## Phase 7: Convergence
- [ ] T017 Concluir execução do adaptador em tool/run_speech_browser_test.ps1 e registrar em verification.md por FR-004/SC-002 (partial).
- [ ] T018 Publicar .tmp/bible-path-voice-release.zip e Worker local; envio autorizado em 2026-10-27, aguardando permissão de arquivos da extensão Chrome, verificando hashes em verification.md por T016/plan etapa 8 (partial).
- [ ] T019 Confirmar som e controles em iPhone físico e registrar em verification.md por SC-005 (partial).
