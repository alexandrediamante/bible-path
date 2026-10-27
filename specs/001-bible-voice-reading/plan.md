# Implementation Plan: Leitura da Bíblia com vozes

**Branch**: main (feature 001-bible-voice-reading) | **Date**: 2026-10-26
**Spec**: [spec.md](spec.md)
**Input**: specs/001-bible-voice-reading/spec.md

## Summary
Restaurar seleção das vozes reais do aparelho, priorizar idioma da passagem e manter
áudio online opcional com idioma honesto. Cancelar motores anteriores, dividir
versículos longos internamente e derivar destaque e progresso de eventos reais.

## Technical Context
**Language/Version**: Dart do Flutter instalado (CI fixa 3.47.7); TypeScript.
**Primary Dependencies**: Flutter, dart:html, Web Speech, HTMLAudioElement, http,
Cloudflare Workers AI MeloTTS já integrado.
**Storage**: localStorage existente bible-path-speech-voice, sem migração destrutiva.
**Testing**: flutter_test, Vitest, testes de browser Dart compilados para JS.
**Target Platform**: navegadores desktop e PWA Safari iPhone.
**Project Type**: Flutter Web e Worker TypeScript.
**Performance Goals**: apenas uma leitura ativa; espera de início <=25s;
trechos <=240 caracteres sem perdas; requisições online <=500 caracteres.
**Constraints**: terminal sem DNS externo; preservar patches locais; sem novas
credenciais/assinaturas; backend atual não suporta português nativo.
**Scale/Scope**: três histórias, player compartilhado e endpoint TTS existente.

## Constitution Check
Antes/depois do desenho: I eventos reais; II APK só referência; III regressões e
build; IV idiomas honestos; V patches e segredos preservados. PASS no desenho.
A verificação física é gate de entrega de iPhone, não inferência a partir de mocks.

## Project Structure
### Documentation (this feature)
spec.md, plan.md, research.md, data-model.md, contracts/speech.md, quickstart.md,
tasks.md e verification.md nesta pasta; qualidade em checklists/requirements.md.
### Source Code (repository root)
- lib/core/platform/speech_voice.dart: seleção automática e fragmentação testáveis.
- lib/core/platform/speech_output_web.dart: inventário, escolha do motor e lifecycle.
- lib/shared/widgets/read_aloud_player.dart: estado, progresso e troca de voz.
- lib/l10n/app_*.arb: orientação correta nos sete idiomas.
- worker/src/index.ts: rejeitar português no modelo espanhol.
- test/: regressões de estado, seleção e capítulos.
- tool/: verificação do adaptador web compilado e preview.
**Structure Decision**: ampliar os componentes existentes sem novo serviço.

## Etapas detalhadas
1. Registrar estado original e investigar evidência estática do APK. Não reinstalar
   emulador sem necessidade; material existente basta para mapear controles,
   mas não prova catálogo de narradores. Tentar REA local disponível.
2. Testar seleção automática por idioma, persistência, eventos antigos, texto longo,
   erro e troca de voz durante carregamento/pausa.
3. Unificar inventário: vozes do aparelho sempre visíveis, vozes online identificadas
   como tal. ID salvo inválido volta a automático. Atualizar por voiceschanged.
4. No automático usar primeiro idioma exato, depois idioma-base. Sem voz compatível,
   usar online apenas en/es/fr; português não será disfarçado como espanhol.
5. Ao falar, invalidar a geração anterior e cancelar os dois motores. Fragmentar
   internamente preservando conclusão de versículo. Manter referência da utterance.
   Entrar em playback para mídia; reutilizar elemento desbloqueado pelo toque.
6. Exibir início e destaque somente após start/playing. Ignorar end sem start.
   Propagar rejeição de resume, permitir Stop durante rede e troca durante loading.
7. Traduzir avisos; validar Worker, Dart, UI móvel e release. Abrir preview no
   navegador conectado se acessível; registrar limites de aparelho/rede.
8. Reconciliar tarefas e critérios com speckit-converge; qualquer falta física
   permanece pendente com procedimento, sem declarar 100% por simulação.

## Complexity Tracking
Nenhuma violação de constituição planejada. Compatibilidade preservada para controles
existentes; a remoção da falsa voz portuguesa online é uma correção intencional.
