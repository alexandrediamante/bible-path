# Speech interfaces

## SpeechOutput
voices: catálogo real do browser mais alternativas online en/es/fr.
hasVoiceSelection: true no web, inclusive em hospedagem com Worker.
voicesChanged: repassa carregamento do dispositivo.
selectVoice(id|null): persiste preferência; seleção automática por idioma exato/base.
speak(text, locale, rate, onStart, onDone, onError):
cancela leitura anterior; um start por versículo, done após todos os trechos;
erro não emite done; callbacks cancelados não têm efeito.
pause/resume/stop/dispose: pause mantém trecho; resume rejeitado emite erro;
stop invalida callbacks e interrompe ambos os motores.

## POST /v1/tts
JSON {text, locale}; text não vazio <=500 caracteres; locale en/es/fr com variante
opcional. Português retorna 400 invalid_request em vez de enviar ao modelo espanhol.
Resposta 200 audio/wav; erro 400/401/403/429/503 como contrato existente.
Preservar autenticação, CORS, rate limiting e no-store.
O frontend não faz chamada online para voz de aparelho.
