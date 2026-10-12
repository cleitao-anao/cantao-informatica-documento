# Cantão Informática - Sistema de Laudo & Diagnóstico Técnico

Sistema integrado desenvolvido para padronizar, registrar e agilizar o fluxo de trabalho diário na **Cantão Informática**. O ecossistema é composto por:

1. **Laudo Técnico Digital (Web/Front-end):** Interface interativa para preenchimento de entrada, diagnóstico do técnico e conferência/testes com suporte a exportação/importação JSON e impressão perfeita em 1 página A4.
2. **Suite de Automação de Diagnóstico (`script/`):** Script avançado em PowerShell para testes de hardware, captura de telas (screenshots), testes de periféricos e geração automática de laudos e JSON integráveis.

---

## 🔄 O Fluxo de Trabalho (Workflow da Loja)

A tabela do sistema espelha as etapas reais de atendimento na assistência:

1. **Entrada:** Preenchimento inicial no balcão. Registra o estado físico do equipamento (PC, Notebook ou TV), marcas de uso, peças presentes, se liga, etc.
2. **Técnico (Parecer Técnico):** Área do técnico para registrar peças defeituosas, testes efetuados, orçamentos, observações internas e parecer formal com barra de formatação (negrito, itálico, listas).
3. **Testes Finais:** Preenchido após o reparo na bancada. Garante que todos os componentes (rede, Wi-Fi, áudio, webcam, portas USB, teclado, bateria) foram validados antes da entrega.
4. **Checklist do Atendente (☑):** Caixas de validação para a equipe de balcão conferir cada item indicado pelo técnico, assegurando dupla checagem de qualidade.

---

## 💻 Funcionalidades do Sistema Web (`index.html`)

* **Tipos de Equipamento:** Alternância instantânea entre `PC`, `Notebook` e `TV`, exibindo apenas os componentes pertinentes.
* **Preenchimento em Lote:** Botões de preenchimento rápido ("Todos Funcionando", "Limpar", etc.).
* **Navegação Estilo Planilha:** Suporte completo a atalhos de teclado (`Tab`, `Ctrl + Setas`, `Alt + Setas`) para transitar entre células sem o mouse.
* **Persistência Local Automática:** Todos os dados são salvos em tempo real no `localStorage` do navegador para evitar perda de dados.
* **Importação & Exportação JSON:** Salve laudos completos em arquivos `.json` e importe-os a qualquer momento.
  * Suporte a JSON de **Diagnóstico Técnico** (preenche coluna Técnico e parecer).
  * Suporte a JSON de **Teste Final** (preenche a coluna Testes e marca os checkboxes).
* **Editor com Barra de Formatação:** Formatação rica no parecer técnico e observações de defeitos.
* **Assinatura do Atendente & Técnico:** Campos dedicados e persistentes para assinaturas de conferência.
* **Dark Mode & Impressão A4:** Tema escuro para operação diária e formatação automática em preto/branco comprimida para **exatamente 1 página A4** na impressão/PDF.

---

## ⚡ Suite de Automação de Diagnóstico (`script/`)

Localizada na pasta `script/`, é a ferramenta técnica utilizada na bancada de manutenção e em ambientes WinPE / Strelec.

Para detalhes completos de uso, opções de menu, atalhos e configuração das ferramentas, consulte o [README do Script](script/README.md).

### Resumo das capacidades do script:
* **Diagnóstico Rápido e Completo:** Automatiza abertura e testes de ferramentas como CrystalDiskInfo, HDDScan, HDSentinel, HWiNFO, BatteryInfoView, KeyboardTest, UsbTreeView, Victoria e FurMark.
* **Captura Inteligente via Hook de Baixo Nível:** Captura fotos de janelas (`F9`) ou tela cheia (`F8`) sem travamentos e com identificação automática de foco.
* **Avanço Automático:** Fecha programas e avança automaticamente ao fechar no `[X]` ou via `Alt+F12` / `F12`.
* **Teste Final Dedicado:** Permite testar periféricos vinculando a uma OS existente (criando subpasta `teste final`) ou criando uma nova OS (`{OS} - teste final`), gerando o arquivo JSON compatível com a coluna de Testes.
* **Relatório Unificado (HTML & PDF):** Compila todos os dados de hardware, prints e status em um relatório visual completo com exportação automática via Microsoft Edge.

---

## 🚀 Como Executar

### 1. Sistema de Laudo Web
Abra o arquivo **`index.html`** com qualquer navegador moderno (Edge, Chrome, Firefox). Não requer instalação ou servidores locais.

### 2. Automação de Bancada
No Windows ou WinPE, execute como Administrador o atalho **`script/iniciar.bat`** ou:
```powershell
powershell -ExecutionPolicy Bypass -File "script/diagnostico.ps1"
```
