# Cantão Informática - Fluxo de Diagnóstico Técnico

Este projeto é um sistema de laudo e documento interativo desenvolvido para padronizar e agilizar o fluxo de trabalho diário na **Cantão Informática**. Ele acompanha o equipamento do cliente desde a recepção até a entrega final, garantindo que nenhuma etapa ou teste seja esquecido.

## 🔄 O Fluxo de Trabalho (Workflow)

A tabela do sistema é dividida em colunas que representam os estágios reais do serviço na loja:

1. **Entrada:** Preenchimento inicial feito no balcão. Registra o estado exato em que o equipamento (PC, Notebook ou TV) chegou à loja (condições da carcaça, peças presentes, se liga, etc).
2. **Técnico (Parecer):** Espaço dedicado ao técnico responsável para registrar o diagnóstico, defeitos encontrados, peças a trocar e observações vitais que serão passadas ao cliente.
3. **Testes Finais:** Preenchido após a aprovação do cliente e a execução do serviço (produção). Garante que todos os componentes (áudio, rede, vídeo, placa) foram testados sob estresse e estão funcionando antes da entrega.
4. **Check do Atendente (Caixas de Seleção):** As caixas de *checkbox* (☑) laterais servem para a equipe de atendimento (ou balcão) validar se tudo que o técnico indicou foi conferido, garantindo dupla checagem para manter o padrão de qualidade.

## ✨ Principais Funcionalidades

* **Modos de Equipamento:** Alternância rápida entre `PC`, `Notebook` e `TV` no topo da tela, exibindo apenas as peças que fazem sentido para aquele aparelho.
* **Preenchimento Rápido em Lote:** Botões no topo para preencher colunas inteiras com "Funcionando", "Com defeito" ou "Vazio" com apenas um clique.
* **Navegação Rápida (Estilo Excel):** É possível navegar velozmente pela tabela inteira usando o teclado. Use `Tab` para descer rapidamente na mesma coluna, ou `Ctrl + Setas` / `Alt + Setas` para pular de campo em campo sem precisar usar o mouse.
* **Salvamento Automático:** Nenhum dado é perdido. Tudo que é digitado fica salvo localmente no navegador (`localStorage`) em tempo real.
* **Backup de Laudos (JSON):** Botões de "Exportar" e "Importar" permitem salvar o laudo atual do cliente como um arquivo `.json` na máquina e abri-lo meses depois, caso o cliente retorne.
* **Dark Mode (Modo Escuro):** Botão de troca de tema no topo da tela, proporcionando conforto visual para quem preenche os dados o dia todo.
* **Impressão Inteligente (PDF):** Ao clicar em "Imprimir", o sistema remove as cores do dark mode, esconde botões, apaga caixas de texto que foram deixadas em branco e compacta a tabela para caber com elegância em **exatamente 1 página A4**.

## 🛠️ Como Executar

O projeto foi construído com tecnologias front-end puras, focando em ser leve e rápido.
Para usar, basta dar um duplo clique no arquivo **`index.html`** para abri-lo no Chrome, Edge ou qualquer navegador moderno. Nenhuma instalação ou servidor de internet é necessário.
