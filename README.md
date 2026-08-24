# LIMTESTE

PROMPT COMPLETO PARA LOVABLE

Título do Projeto:
💼 LimSist-2.0 – Sistema de Gestão de Microcrédito e Poupanças

🧩 Descrição Geral

Crie um sistema SaaS robusto, completo e responsivo para gestão de microcrédito e poupanças, inspirado no aplicativo limmicrobanco.lovable.app
, mas muito mais completo, profissional e automatizado.

O sistema deve funcionar online e offline (IndexedDB), permitindo sincronização automática de dados com o backend (Supabase) quando a internet estiver disponível.

A interface deve ser moderna, limpa e intuitiva, nas cores azul-claro e branco, com ícones claros e cards informativos.
Deve incluir notificações em tempo real, gráficos financeiros, e exportação de relatórios em PDF e Excel.

🏠 Página de Login / Cadastro

Título: LimSist – Sistema de Microcrédito
Campos e Layout:

E-mail

Senha

Botões: Entrar | Cadastrar

Frase inferior: “Sistema de Gestão para Microcrédito — Seguro • Confiável • Offline”

Design simples, centralizado, responsivo, com logotipo no topo.

📊 Página Principal (Painel de Controle)
Cards de Indicadores:

Total Emprestado: soma de todos os créditos ativos.

Capital Desembolsado: valor total já emprestado.

Recebimentos: total recebido.

Clientes Ativos: número de clientes com empréstimos vigentes.

Taxa de Inadimplência: % de empréstimos em atraso.

Empréstimos Ativos: total de contratos vigentes.

Total da Carteira: valor a receber (total - pago).

Gráficos:

Gráfico de barras: volume de empréstimos e recebimentos mensais.

Gráfico de pizza: distribuição da carteira por tipo de empréstimo.

Gráfico de linha: evolução da inadimplência.

💰 Simulador de Crédito
Campos:

Dados do Cliente

Nome Completo

Dados do Empréstimo

Valor do Empréstimo (MZN)

Período (1 a 12 meses)

Taxa de Juros (% ao mês)

Tipo de Juros: Simples ou Composto

Botão: “Simular Empréstimo”
→ Gera um quadro de simulação automática, mostrando:

Juros mensais e totais

Valor total a pagar

Parcela mensal

Gráfico do saldo devedor

Função Extra: opção de gerar PDF do resultado com logotipo da empresa.

👥 Clientes
Campos:

Nome Completo *

Telefone *

Email

NUIT

Data de Nascimento

Gênero

Província

Distrito/Cidade

Bairro

Rua

Funcionalidades:

Pesquisar clientes

Editar / Excluir / Bloquear

Exportar lista (Excel/PDF)

Histórico de crédito e pagamentos do cliente

💵 Empréstimos
Formulário de Novo Empréstimo:

Cliente * (busca por nome)

Valor (MZN) *

Taxa de Juros (% a.a.)

Duração (meses)

Tipo de Juros (Simples ou Composto)

Modalidade de Desembolso *

Tipo de Garantia

Data de Desembolso

Observações

Funcionalidades:

Listar todos os empréstimos com filtro por status (ativo, pago, em atraso).

Calcular automaticamente juros de mora configuráveis (% ao dia).

Mostrar histórico de pagamentos.

Exportar contrato de crédito (modelo simples, sem quadros coloridos).

Enviar contrato por WhatsApp.

💎 Gestão de Poupanças

Crie um módulo para gestão de grupos de poupança rotativa:

Funcionalidades:

Criar grupo: nome, local, presidente, secretariado.

Adicionar membros com: nome, telefone, valor poupado.

Cada membro possui:

Valor poupado acumulado

Valor de empréstimo já recebido

Valor pago / em atraso / produção gerada

Cálculo automático:

Total Geral = (Valor Poupado + AT - Dívida + Bónus + Outros1 + Outros2)


Exibição:

Saldo individual e total do grupo

Histórico de contribuições

Empréstimos internos do grupo

Geração de relatórios em PDF

📑 Relatórios
Tipos de Relatórios:

Financeiros (Diário, Mensal, BM)

Total emprestado, recebido e em carteira

Exportar PDF/Excel

Análise de Clientes

Ativos, novos e inativos

Perfis de risco

Análise de Risco

Percentual de atrasos

Carteira vencida

Histórico Diário

Registo de operações, entradas e saídas

📂 Gestão de Arquivos
Seções:

Documentos Obrigatórios: BI, Declaração de Residência

Comprovativo de Rendimento

Fotos da Garantia (até 4 fotos)

Detalhes da Garantia (descrição, valor, condições)

Upload: formatos JPG, PNG, PDF (máx. 10MB)

Indicador de status de envio (enviado / pendente)

💸 Gestão de Despesas
Campos:

Categoria

Descrição

Valor

Data

Funcionalidades:

Relatório detalhado com filtros (diário, mensal, anual)

Exportar CSV

Mostrar:

Total de Despesas

Juros Produzidos

Lucro Líquido (Juros – Despesas)

Maior Categoria

Tendência percentual

⚙️ Configurações do Sistema

Seções:

Geral: Nome do sistema, idioma, tema.

Capital: valor base da instituição.

Usuários: adicionar, editar, permissões.

Notificações: alertas automáticos de atraso, pagamento, vencimento.

Segurança: controle de sessão, autenticação 2FA.

Integrações: WhatsApp, Email, API de Pagamentos.

Informações da Empresa:

Nome, NUIT, Endereço, Telefone, Email

Upload de Logotipo (PNG, JPG, SVG)

Aplicar em todos os documentos gerados

🧑‍💼 Administração

Funções de controle de acesso e comunicação interna.

Módulos:

Usuários: listar, ativar, bloquear, definir função (SuperAdmin, Admin, Gestor).

Notificações: enviar alertas e comunicados aos utilizadores.

Relatórios de Acesso: visualizar logins, horários e IPs.

Estrutura Hierárquica:

Super Administrador: controla administradores, define tempo de uso, bloqueia contas.

Administrador: controla gestores e suas carteiras.

Gestor: apenas acessa e gerencia seus próprios clientes e empréstimos.

💾 Requisitos Técnicos

Backend: Supabase (com políticas RLS de segurança)

Banco local: IndexedDB (modo offline completo)

Exportações: PDF e Excel (automático)

APIs: WhatsApp, Email, Pagamentos

Autenticação: Supabase Auth

Interface: React + TailwindCSS (responsivo e limpo)

🧭 Extras

Tema escuro opcional

Relógio e data no topo do dashboard

Mensagem de boas-vindas personalizada

Indicador de sincronização offline/online

Backup automático de dados locais

🔧 Resumo de Estrutura do Menu Lateral

Painel

Simulador

Clientes

Empréstimos

Poupanças

Relatórios

Arquivos

Despesas

Configurações

Administração

This project was built with [Lovable](https://lovable.dev).

**Live app**: https://limmicrocreditoteste.lovable.app

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/c522bb4f-12f2-447d-9ad7-8581e0874be6).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
