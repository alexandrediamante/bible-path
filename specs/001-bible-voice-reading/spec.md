# Feature Specification: Leitura da Bíblia com vozes

**Feature Branch**: main (alterações locais preservadas)
**Created**: 2026-10-26
**Status**: Ready for planning
**Input**: Leitura sequencial como referência do Bible Path 2.5.6, uma ou mais vozes,
documentação Spec Kit e verificação funcional.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ouvir o capítulo (Priority: P1)
O leitor abre uma passagem e ouve os versículos em ordem.
**Why this priority**: leitura sem som não entrega a função principal.
**Independent Test**: ouvir Gênesis 1, pausar, retomar e parar.
**Acceptance Scenarios**:
1. **Given** capítulo e voz compatível, **When** toca Reproduzir,
   **Then** ouve o texto e vê destaque no versículo em reprodução.
2. **Given** leitura iniciada, **When** pausa ou para,
   **Then** interrompe a fala; eventos antigos não avançam a passagem.
3. **Given** continuação habilitada, **When** termina o capítulo,
   **Then** começa o próximo; navegação manual interrompe a fala.

### User Story 2 - Escolher a voz (Priority: P2)
O leitor escolhe vozes disponíveis e mantém a preferência ao reabrir.
**Why this priority**: atender preferência e idioma com opções reais.
**Independent Test**: alternar duas vozes disponíveis e reabrir a tela.
**Acceptance Scenarios**:
1. **Given** duas vozes no aparelho, **When** escolhe cada uma,
   **Then** a leitura utiliza a seleção.
2. **Given** automático e passagem em português, **When** inicia,
   **Then** prioriza voz de português disponível.
3. **Given** voz salva removida, **When** reabre,
   **Then** utiliza automático e mantém controles funcionais.

### User Story 3 - Ajustar e recuperar (Priority: P2)
O leitor ajusta a velocidade e entende falhas sem perder controle.
**Why this priority**: não confundir avanço visual com som.
**Independent Test**: falhar reprodução, repetir e mudar velocidade.
**Acceptance Scenarios**:
1. **Given** áudio bloqueado, **When** falha,
   **Then** mostra erro e não avança versículo.
2. **Given** leitura pausada ou carregando, **When** muda voz ou velocidade,
   **Then** reinicia o versículo com nova configuração e estado consistente.
3. **Given** passagem longa, **When** reproduz,
   **Then** lê todo o texto sem perder palavras.

### Edge Cases
Vozes carregadas depois; voz salva removida; IDs repetidos; storage bloqueado;
Stop durante solicitação online; resposta antiga após nova seleção; troca de motor;
fim sem início confirmado; erro ao retomar; mudança de tela enquanto carrega.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: Ler o texto real em ordem, sem simular reprodução.
- **FR-002**: Confirmar início antes de mostrar reprodução e destacar versículo.
- **FR-003**: Oferecer reproduzir, pausar, retomar, parar e velocidade.
- **FR-004**: Listar vozes reais mesmo com áudio online configurado.
- **FR-005**: Persistir voz; automático prioriza idioma da passagem.
- **FR-006**: Cancelar leitura anterior ao mudar texto, voz, velocidade ou tela.
- **FR-007**: Ler passagens longas integralmente em trechos adequados.
- **FR-008**: Mostrar erro recuperável sem avançar em falha ou início ausente.
- **FR-009**: Oferecer áudio online apenas nos idiomas realmente suportados.
- **FR-010**: Manter continuação opcional de capítulos e destaque sincronizado.
- **FR-011**: Documentar evidência do APK e verificação reproduzível.

### Key Entities *(include if feature involves data)*
- **Voz**: identidade, nome, idioma e origem.
- **Preferência**: voz escolhida ou automático.
- **Sessão**: passagem, versículo, velocidade e estado.

## Success Criteria *(mandatory)*

### Measurable Outcomes
- **SC-001**: Um capítulo completo mantém ordem sem pular versículos nos testes.
- **SC-002**: Voze disponíveis são selecionáveis; duas podem ser alternadas quando
  o aparelho oferece, com preferência restaurada ao reabrir.
- **SC-003**: Zero eventos antigos alteram leitura após parar/trocar passagem.
- **SC-004**: Falhas não avançam; espera de início termina em até 25 segundos.
- **SC-005**: Som português e controles são confirmados em aparelho físico antes
  de declarar concluída a validação de iPhone.

## Assumptions
Primeiro plano é o escopo; não garantir tela bloqueada. Vozes do aparelho são a
primeira opção, sem novas assinaturas. A quantidade depende do aparelho.
APK é referência comportamental; não copiar voz ou serviço proprietário.
Testes automatizados e validação física são evidências distintas.
