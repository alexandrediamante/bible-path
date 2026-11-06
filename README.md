# Bible Path

Bible Path é um companheiro pessoal de Bíblia, offline-first, construído com Flutter Web. Projetado para ser instalado pelo Safari em "Adicionar à Tela de Início" e usado no iPhone.

É uma implementação independente de clean-room. Não é afiliada nem endossada pela editora do aplicativo Android comercial com nome similar. Não inclui o código-fonte, APIs privadas, credenciais, lógica de assinatura, arte, áudio ou outros ativos proprietários desse aplicativo.

---

## O que o aplicativo faz

### Leitura da Bíblia
- Leitura de versículos e capítulos com navegação por livro e capítulo
- Sete traduções disponíveis (inglês, espanhol, português, francês, alemão, italiano e russo)
- Copiar e compartilhar versículos

### Planos diários
- Plano diário com versículo, devocional, reflexão e oração
- Marcar etapas como concluídas
- Acompanhar sequência (streak) e histórico de planos concluídos

### Estudo
- Planos de estudo com lições diárias
- Acompanhar progresso de conclusão por dia
- Retomar onde parou

### Oração
- Diário de orações pessoal
- Arquivar e restaurar entradas
- Contar entradas registradas

### Favoritos
- Salvar versículos favoritos
- Remover favoritos a qualquer momento

### Chat com IA (Bible AI)
- Faça perguntas sobre a Bíblia e fé
- Contexto de passagens bíblicas selecionadas incluído automaticamente
- Histórico de conversas salvo localmente

### Entrar com Google + Sincronização na nuvem
- Faça login com sua conta do Google
- Seus favoritos, orações, planos, progresso e histórico de chat são salvos na nuvem (Cloudflare D1)
- Acesse os mesmos dados em qualquer dispositivo onde entrar com o mesmo Google
- Sincronização bidirecional: alterações em um aparelho se refletem nos outros

### Configurações
- Modo escuro/claro
- Tamanho do texto
- Idioma da interface (7 idiomas disponíveis)
- Versão da Bíblia preferida
- Lembrete diário com horário personalizado
- Token de acesso do Worker de IA

---

## Como instalar no iPhone

O Bible Path é um **PWA (Progressive Web App)**. Não precisa da App Store, nem do Xcode, nem de conta de desenvolvedor da Apple.

### Passo 1: Abra no Safari

Acesse:

```
https://bible-path.pages.dev
```

### Passo 2: Adicionar à Tela de Início

1. No Safari, toque no botão **Compartilhar** (quadrado com seta para cima)
2. Role para baixo e toque em **"Adicionar à Tela de Início"**
3. Confirme o nome "Bible Path" e toque em **Adicionar**

### Passo 3: Usar o aplicativo

O ícone "Bible Path" aparecerá na sua tela de início. Toque nele para abrir em tela cheia, sem a barra do Safari. Funciona offline após a primeira visita.

---

## Como fazer login e sincronizar

### Entrar com o Google

1. Abra o aplicativo no iPhone
2. Vá em **Perfil** (aba inferior)
3. Toque em **"Entrar com Google"**
4. Escolha sua conta do Google e autorize
5. Após o login, seus dados começam a sincronizar automaticamente

### Sincronizar dados

- Toque no botão **"Sincronizar agora"** na tela de Perfil para forçar uma sincronização manual
- O status da última sincronização é mostrado abaixo do botão
- Seus dados (favoritos, orações, planos, progresso, chat) ficam disponíveis em qualquer dispositivo onde você entrar com a mesma conta do Google

---

## Como desenvolver (para contribuidores)

### Pré-requisitos

- Flutter `3.47.7` com suporte a Web
- Node.js 22 ou mais recente (para service worker e Worker)
- Conta Cloudflare com Workers AI habilitado (para Bible AI)

### Instalação local

```bash
flutter pub get
flutter gen-l10n
```

### Validar código

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

### Build de produção

```bash
flutter build web --release --base-href "/bible-path/" --dart-define="AI_API_URL=https://seu-worker.workers.dev"
node tool/generate_service_worker.mjs build/web
```

O resultado fica em `build/web`.

### Worker de IA (Cloudflare)

O Worker fica em `worker/` e chama o Cloudflare Workers AI.

```bash
npm ci --prefix worker
npm test --prefix worker
npm run typecheck --prefix worker
```

Configure os segredos no Cloudflare Dashboard ou Wrangler antes de implantar:

- `APP_AUTH_TOKEN` (valor aleatório de pelo menos 32 caracteres)
- `GOOGLE_CLIENT_ID` (do Google Cloud Console, OAuth 2.0 Client ID Web)
- `ALLOWED_ORIGIN` = a origem exata do seu Pages (ex: `https://bible-path.pages.dev`)

### Banco de dados D1 (sincronização)

```bash
wrangler d1 create bible-path-db
wrangler d1 execute bible-path-db --file=worker/schema.sql
```

Copie o `database_id` gerado para `worker/wrangler.toml`.

### Deploy no GitHub Pages

O fluxo está em `.github/workflows/deploy.yml`. Ele constrói sob o subcaminho do repositório, executa verificações e faz upload apenas de `build/web`.

Ative GitHub Actions e Pages nas configurações do repositório.

---

## Privacidade e armazenamento

- Dados pessoais ficam armazenados no navegador do dispositivo
- O token de acesso à IA é local e excluído das exportações
- Ao usar o Bible AI, a pergunta, histórico recente de chat, idioma, tradução selecionada e passagens bíblicas locais são processadas pelo Cloudflare Workers AI
- O Safari pode evictar dados do site. Instalar na tela de início e solicitar armazenamento persistente melhoram a durabilidade, mas não garantem. Exporte entradas importantes regularmente

---

## Conteúdo e licenciamento

Textos bíblicos, fontes e ícones são dependências de bloqueio de release. Suas edições exatas, URLs de origem, licenças/bases de domínio público, requisitos de atribuição, datas de aquisição e hashes SHA-256 ficam em `THIRD_PARTY_CONTENT.md` e `assets/bible/translations.json`.

Não publique ativos com origem desconhecida. Não extraia texto bíblico, ícones, traduções ou áudio do APK do Android.

---

## Política de clean-room

Veja [CLEAN_ROOM.md](CLEAN_ROOM.md). O APK local e artefatos decodificados podem ser inspecionados apenas para entender o comportamento observável. Implementação decompilada, cópia proprietária, ativos, endpoints, credenciais, comportamento de pagamento e verificações de licença não são copiados para este projeto.

---

## URLs

- Produção: https://bible-path.pages.dev
- Worker de chat: https://bible-path-chat.bible-path-worker.workers.dev
- Repositório: https://github.com/alexandrediamante/bible-path

---

## Versão

Versão atual: **2026.11.0.0** (mostrada em Início, Configurações > Sobre e no player de leitura em voz alta)