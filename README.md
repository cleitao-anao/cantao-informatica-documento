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

## ⚡ Script de Diagnóstico (`script/`)

Script PowerShell usado na bancada. Fica na raiz de um **pen drive (Ventoy)** junto das ferramentas portáteis e da pasta `OS/`, e é iniciado pelo `iniciar.bat`.

> [!IMPORTANT]
> Funciona no **Windows 10/11**. No **WinPE (Strelec) ainda não funciona**. Existe um **app profissional** planejado para substituir o script e resolver isso.

Guia completo (menus, atalhos, estrutura do pen drive, **explicação do `config.json`**, WinPE): **[script/README.md](script/README.md)**.

### Resumo
* **Modos de teste:** Rápido, Completo, Completo + Estresse, Periféricos/Portas, Personalizado e **Teste Final**.
* **Ferramentas automatizadas:** HDDScan, CrystalDiskInfo, HDSentinel, HWiNFO, BatteryInfoView, KeyboardTest, UsbTreeView, Victoria e FurMark. A lista é configurável no `config.json`, sem mexer no código.
* **Prints por teclado:** `F9` (janela em foco), `F8` (tela inteira) e `Alt+F12`/`F12` para seguir. Fechar a janela no `[X]` também avança sozinho. Nenhum print é automático por tempo.
* **Teste Final:** testa periféricos e portas e preenche a coluna **TESTES** do laudo. Salva em uma OS existente (subpasta `teste final`) ou numa OS nova (`{OS} - teste final`).
* **Saídas por OS:** prints, textos de hardware, relatório HTML/PDF e JSONs para importar no laudo.

---

## 🚀 Como Executar

### Laudo Web
Abra **`index.html`** em qualquer navegador moderno (Edge, Chrome, Firefox). Não precisa de instalação nem servidor.

### Script de bancada
No Windows, execute **`script/iniciar.bat`** como **Administrador**, ou:
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "script/diagnostico.ps1"
```
As ferramentas portáteis **não** estão no repositório: coloque cada uma em `script/Ferramentas/<pasta>` conforme o `config.json`.

