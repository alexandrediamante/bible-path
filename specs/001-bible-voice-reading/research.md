# Research: Leitura por voz
Data: 2026-10-26. Investigação de código e assets; pesquisa delegada conforme speckit-plan.

## Decisões
| Decision | Rationale | Alternatives considered |
| --- | --- | --- |
| Voz compatível do aparelho por padrão | Português real e independência de quota TTS | Forçar MeloTTS espanhol não atende idioma |
| Áudio online opcional en/es/fr | Backend existente oferece esses idiomas | Novo provedor depende de credenciais e não foi necessário |
| Uma geração de cancelamento | Evitar rede antiga e motores sobrepostos | Cancelar apenas UI deixa callbacks ativos |
| Fragmentar dentro do versículo | Preservar destaque e limites | Fragmentar somente texto genérico ignora Bible.segments |
| Início confirmado | UI deve refletir evento de reprodução | Timer não comprova áudio |

## Evidência local
- APK: bible-path-decoded/smali_classes3/io/flutter/plugins/GeneratedPluginRegistrant.smali
  registra audio_service, audio_session e just_audio.
- APK: assets/flutter_assets/assets/languages/en.json contém currently_playing,
  playback_speed, ambient_music, sleep_timer; FAQ descreve streaming com internet.
- Não prova narradores exatos nem operação em background; não encontrado flutter_tts
  por nome. Inspeção comum de shell, não Evidence produzido pelo REA.
- Fonte: SpeechOutput considerava qualquer origem HTTP como serviço, escondendo
  vozes; worker validateTtsInput mapeava pt para es.
- Fonte: eventos nativos sem geração; resume engolia erro; destaque antes de start;
  Bible.segments não passava pelo limite de 500 caracteres do Worker.

## Referências primárias
- https://webaudio.github.io/web-speech-api/#speechsynthesis
- https://webkit.org/blog/6784/new-video-policies-for-ios/
- https://www.w3.org/TR/audio-session/
Audio Session é capability detectável, não garantia de som físico.

## Incógnitas resolvidas e limites
Desenho não depende de catálogo proprietário. Usar vozes que o navegador de fato
expõe. Catálogo e saída sonora do iPhone físico ainda precisam ser observados.
A rede deste terminal falhou com ENOTFOUND; dependências locais serão reutilizadas.
