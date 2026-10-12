# 🛠️ Automação de Diagnóstico Técnico - Cantão Informática

Script PowerShell avançado desenvolvido para automação completa de testes de bancada, coleta de especificações de hardware, geração de laudos visuais com prints e integração direta com o sistema de laudo web da Cantão Informática.

Suporta **Windows 10/11** e ambientes portáteis **WinPE (ex.: Sergei Strelec)**.

---

## 📂 Estrutura de Pastas

```text
script/
├── Ferramentas/            # Executáveis e ferramentas portáteis de teste
│   ├── CrystalDiskInfo9_9_2/
│   ├── HDDScan/
│   ├── hdsentinel_pro_portable/
│   ├── hwi_854/
│   ├── batteryinfoview-x64/
│   ├── KeyboardTestUtility/
│   ├── UsbTreeView_x64/
│   ├── Victoria537/
│   ├── FurMark_win64/
│   └── Musica/            # Áudios (mp3/wav) para teste de som
├── OS/                     # Diretório de saída dos testes por Ordem de Serviço
├── config.json             # Configuração das ferramentas, tempos de espera e modos
├── diagnostico.ps1         # Script principal de automação
├── iniciar.bat             # Atalho para execução rápida em lote
└── README.md               # Esta documentação
```

---

## 🚀 Como Iniciar

1. Abra a pasta `script/` e execute como **Administrador** o arquivo **`iniciar.bat`**.
2. Ou via terminal PowerShell:
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "diagnostico.ps1"
   ```

---

## 📋 Menus e Modos de Operação

O menu principal possui suporte a paginação (`[P]` próxima página e `[V]` voltar):

### Página 1: Modos de Teste
* **`[1] Modo Rápido`**: Executa os testes rápidos essenciais (HDDScan em fundo, CrystalDiskInfo, BatteryInfoView e HWiNFO).
* **`[2] Modo Completo`**: Executa todas as ferramentas cadastradas em sequência.
* **`[3] Modo Básico`**: Diagnóstico sem testes de estresse (ignora GPU/FurMark).
* **`[4] Modo Estresse`**: Roda testes de estresse térmico e estabilidade (FurMark e discos).
* **`[5] Modo Personalizado`**: Menu interativo com caixas de marcação `[X]` para selecionar individualmente as ferramentas desejadas.
* **`[6] Teste Final (Coluna TESTES)`**: Modo pós-reparo com testes de periféricos (teclado, USBs, áudio, microfone, webcam, etc.), gerando o arquivo JSON para importar diretamente na coluna **TESTES** do laudo.
* **`[0] Alternar Periféricos`**: Alterna entre modos de periféricos (*Offline com apps*, *Online via navegador* ou *Desligado*).

### Página 2: Utilitários
* **`[1] Criar / Regenerar Relatório de OS Existente`**: Permite selecionar uma OS já executada para compilar um novo relatório HTML/PDF com suporte a importação de fotos externas (`.png`, `.jpg`, `.jpeg`, `.bmp`, `.webp`).

---

## 🎯 Teste Final: Fluxo Especial de Pastas

Ao selecionar o modo **`[6] Teste Final`**, o script oferece duas formas de armazenamento:

1. **`[1] Escolher uma OS existente`**:
   * Lista as OS já presentes na pasta `OS/`.
   * Cria automaticamente a subpasta **`teste final`** dentro da pasta da OS escolhida (ex.: `OS/1234/teste final/`).
   * Mantém todo o histórico e laudo original intactos, agrupando o teste final na mesma OS.
2. **`[2] Criar uma OS nova`**:
   * Solicita o número da OS e cria uma pasta independente com sufixo (ex.: `OS/1234 - teste final/`).

---

## ⌨️ Atalhos de Teclado Durante os Testes

O script utiliza um hook de teclado de baixo nível em C# nativo (`WH_KEYBOARD_LL`), garantindo captura mesmo quando aplicativos como o KeyboardTest estão em foco exclusivo:

* **`F9`**: Tira print apenas da **janela do programa em foco**.
* **`F8`**: Tira print da **tela inteira** (todos os monitores).
* **`Alt + F12`** *(ou apenas **`F12`** no KeyboardTest)*: Pula para o próximo programa.
* **Fechar a janela no `[X]`**: O script detecta automaticamente quando o processo foi encerrado e avança para a próxima ferramenta instantaneamente.

---

## 📊 Arquivos e Relatórios Gerados

Ao término dos testes em cada OS, a pasta de destino contém:

* **Prints:** Arquivos `.png` salvos na raiz da OS com carimbo contendo data, hora, número da OS e nome do computador.
* **Pasta `Textos/`:**
  * `hardware_pe.txt` / `systeminfo.txt`: Especificações completas do processador, placa-mãe e BIOS.
  * `ram.txt`: Fabricante, frequência e capacidade dos módulos de memória.
  * `ambiente.txt` & `log_execucao.txt`: Logs técnicos do ambiente e execução.
* **Pasta `Documentos/`:**
  * `<OS> - RELATORIO - <Cliente>.html`: Relatório unificado com galeria de prints e especificações.
  * `<OS> - RELATORIO - <Cliente>.pdf`: Relatório exportado automaticamente em PDF via Microsoft Edge Headless.
  * `<OS> - RELATORIO - <Cliente>.json`: Arquivo pronto para importação na coluna **Técnico** e **Parecer Técnico** do laudo web.
  * `<OS> - TESTES_FINAL - <Cliente>.json`: Arquivo gerado no modo Teste Final, compatível com a coluna **Testes** e os checkboxes do laudo web.
