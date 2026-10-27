# Data Model

## SpeechVoice
id: não vazio, único no catálogo; name: apresentação; language: tag de idioma.
IDs online-en, online-es, online-fr reservados para serviço existente.
Sem online-pt: modelo atual não possui português.
## Preferência
Chave localStorage bible-path-speech-voice; null significa automático.
ID ausente do catálogo não pode bloquear fallback. Storage indisponível não impede uso.
## Sessão
generation monotônica; chunks ordenados, índice interno e índice de versículo externo.
Estados: idle -> starting -> playing -> paused -> playing -> completed.
starting/playing/paused -> stopped ou error. Troca cancela geração anterior.
Callback de geração antiga não altera estado. End sem start não conclui versículo.
## Limites
Trecho máximo de 240 caracteres; palavra longa também dividida sem perda.
Worker mantém texto máximo de 500 caracteres. Idiomas online permitidos en/es/fr.
