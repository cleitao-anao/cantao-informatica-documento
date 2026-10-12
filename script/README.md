# 🛠️ Script de Diagnóstico - Cantão Informática

Script PowerShell que automatiza os testes de bancada: abre as ferramentas de diagnóstico uma a uma, tira prints das janelas, coleta dados de hardware, testa periféricos e gera um relatório (HTML/PDF) e arquivos `.json` prontos para **importar no laudo web** (`index.html`).

> [!IMPORTANT]
> **Situação atual:** o script funciona no **Windows 10/11**. No **WinPE (Strelec)** ele **ainda não funciona de forma confiável**. Há tratamento parcial para o PE no código, mas ele não está validado. Veja [WinPE e planos futuros](#-winpe-e-planos-futuros).

---

## 📋 Índice

1. [Como eu uso (pen drive)](#-como-eu-uso-pen-drive)
2. [Como iniciar](#-como-iniciar)
3. [Menu principal](#-menu-principal)
4. [Teste Final](#-teste-final)
5. [Atalhos durante os testes](#️-atalhos-durante-os-testes)
6. [Arquivos gerados](#-arquivos-gerados-por-os)
7. [config.json explicado](#️-configjson-explicado)
8. [WinPE e planos futuros](#-winpe-e-planos-futuros)
9. [Problemas comuns](#-problemas-comuns)

---

## 💾 Como eu uso (pen drive)

O script fica na **raiz de um pen drive com Ventoy** (aqui `D:`), junto das ferramentas e das OS. Tudo é **portátil**: os caminhos do `config.json` são relativos à pasta do script, então a letra do drive pode mudar sem problema.

```text
Ventoy (D:)
├── config.json          ← configuração (explicada abaixo)
├── iniciar.bat          ← duplo clique para começar (como administrador)
├── diagnostico.ps1      ← o script principal
├── Diagnostico.exe      ← versão antiga em C# (anterior ao script atual)
├── Ferramentas/         ← programas portáteis de teste
│   ├── CrystalDiskInfo9_9_2/
│   ├── HDDScan/
│   ├── hdsentinel_pro_portable/
│   ├── hwi_854/
│   ├── batteryinfoview-x64/
│   ├── KeyboardTestUtility/
│   ├── UsbTreeView_x64/
│   ├── Victoria537/
│   ├── FurMark_win64/
│   └── Musica/          ← coloque aqui um .mp3/.wav/.wma para o teste de áudio
├── OS/                  ← saída: uma pasta por Ordem de Serviço
│   ├── 12344/
│   ├── 12645/
│   │   ├── Documentos/
│   │   └── Textos/
│   └── teste/
├── isos/  ventoy/  Instalacao de Sistema/   ← parte do pen drive (Ventoy/ISOs), não do script
└── HarmonyBackup/
```

> [!NOTE]
> No repositório, as pastas de `Ferramentas/` e `OS/` ficam vazias (só `.gitkeep`). Os programas portáteis **não** estão versionados; baixe cada um e coloque na pasta correspondente (os nomes das pastas estão no `config.json`).

---

## 🚀 Como iniciar

1. Plugue o pen drive no PC do cliente (Windows normal).
2. Dê duplo clique em **`iniciar.bat`**. Ele chama o PowerShell com `-ExecutionPolicy Bypass` e `-NoProfile`.
3. Rode **como administrador** (clique direito → *Executar como administrador*). Sem admin, o script avisa e alguns programas (HWiNFO, HDDScan, Victoria) não funcionam 100%.

Ou direto pelo terminal:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "diagnostico.ps1"
```

Depois de escolher o modo, o script pergunta: **número da OS**, **nome do cliente**, **técnico** (Enter aceita o padrão do `config.json`) e **equipamento** (Enter aceita o modelo detectado).

---

## 📋 Menu principal

O menu tem 2 páginas (`[P]` próxima, `[V]` voltar). Quais programas entram em cada opção vem do [`config.json`](#️-configjson-explicado).

### Página 1 – Modos de teste

| Opção | Nome | O que roda | Tempo |
|---|---|---|---|
| `[1]` | **Rápido** | Programas marcados como rápidos (`modoRapido`) | ~3 min |
| `[2]` | **Completo** | Todos os programas, **exceto** os de estresse | ~15 min |
| `[3]` | **Completo + Estresse** | Todos acima + FurMark (GPU) | ~25 min |
| `[4]` | **Periféricos / Portas** | Programas marcados `perifericos` (KeyboardTest, UsbTreeView) + câmera, microfone e som | ~5 min |
| `[5]` | **Personalizado** | Você marca/desmarca cada programa (começa com tudo marcado, menos estresse) | – |
| `[6]` | **Teste Final** | Igual ao `[4]`, mas gera o JSON da coluna **TESTES** do laudo | ~5 min |
| `[0]` | alterna **Periféricos** | `OFFLINE` (apps + Windows) → `ONLINE` (sites) → `DESLIGADO` | – |

### Página 2 – Utilitários

| Opção | Nome | O que faz |
|---|---|---|
| `[1]` | **Criar / Regenerar Relatório** | Escolhe uma OS existente e recria o relatório HTML/PDF, incluindo fotos externas que você colocou na pasta (`.png .jpg .jpeg .bmp .webp`) |

---

## ✅ Teste Final

A opção `[6]` é o teste de periféricos e portas **pós-reparo**. Ela preenche a coluna **TESTES** do laudo e marca o checklist, **sem mexer na coluna TÉCNICO**.

Ao escolher, o script pergunta **onde salvar**:

| Escolha | Resultado |
|---|---|
| `[1]` **OS existente** | Lista as pastas de `OS/`; você escolhe e tudo vai para `OS/<OS escolhida>/teste final/` |
| `[2]` **OS nova** | Pede o número e cria `OS/<número> - teste final/` |

Tudo (fotos, `Textos/`, `Documentos/`, relatório e JSON) fica dentro dessa pasta.

O arquivo `<OS> - TESTES_FINAL - <cliente>.json` é importado em **Importar** no laudo. Importar só esse JSON atualiza a coluna Testes e o checklist; o restante do laudo é preservado.

---

## ⌨️ Atalhos durante os testes

Cada programa abre, é maximizado e fica em foco. Você usa o programa normalmente e usa estas teclas (valem **globalmente**, mesmo com outro app em foco):

| Tecla | Ação |
|---|---|
| **`F9`** | Print só da **janela em foco** |
| **`F8`** | Print da **tela inteira** |
| **`Alt + F12`** | Segue para o próximo programa (fecha o atual) |
| **`F12`** | Idem, mas **só no KeyboardTest** (ele bloqueia o `Alt+F12`) |
| **Fechar no `[X]`** | O script percebe que o programa fechou e **segue sozinho** |

Observações:

- **Nenhuma foto é automática por tempo.** Só tira print quando você aperta F9/F8 (veja o modo `auto` abaixo).
- Se você der `Alt+F12` sem ter tirado nenhuma foto, o script **pergunta se quer mesmo pular**.
- As teclas são lidas por um **hook de teclado próprio**, que conta eventos de tecla pressionada. Isso é necessário porque o KeyboardTest captura o teclado e esconde as teclas dos métodos comuns.
- Segurar a tecla conta **um** print só.

### Modos de cada programa (`modo` no config)

| Modo | Comportamento |
|---|---|
| `auto` | Abre, maximiza, **tira 1 print sozinho** e fecha (CrystalDiskInfo, HDSentinel, BatteryInfoView) |
| `manual` | Abre e espera você: F9/F8 para prints, fechar ou `Alt+F12` para seguir (HWiNFO, KeyboardTest, UsbTreeView, Victoria, FurMark) |
| `fundo` | Como `manual`, mas ao seguir o programa **continua rodando minimizado** (HDDScan, para o teste de leitura). No fim o script volta nele para a foto final |

---

## 📊 Arquivos gerados por OS

```text
OS/<número>/
├── <programa>_1.png, <programa>_2.png ...   ← prints com faixa de data/hora/OS/PC
├── Textos/
│   ├── systeminfo.txt        ← specs do sistema (no PE: hardware_pe.txt)
│   ├── ram.txt               ← módulos de memória
│   ├── ambiente.txt          ← o que existe/falta no ambiente (útil para depurar o PE)
│   └── log_execucao.txt      ← log completo da execução (mande este em caso de erro)
└── Documentos/
    ├── bateria.html                         ← relatório de bateria do Windows
    ├── <OS> - RELATORIO - <cliente>.html    ← relatório com todos os prints
    ├── <OS> - RELATORIO - <cliente>.pdf     ← gerado via Microsoft Edge
    ├── <OS> - RELATORIO - <cliente>.json    ← importar no laudo (coluna TÉCNICO + parecer)
    └── <OS> - TESTES_FINAL - <cliente>.json ← só no Teste Final (coluna TESTES + checklist)
```

---

## ⚙️ config.json explicado

É o **único arquivo que você precisa editar** para mudar quais programas existem, onde estão e como se comportam. Fica ao lado do `diagnostico.ps1`. Se o JSON estiver inválido (vírgula ou aspas faltando), o script mostra o erro e não inicia.

### Estrutura geral

```json
{
  "tecnico": "joao",
  "pastas": { "ferramentas": "...", "os": "...", "musica": "..." },
  "modoRapido": [ "01_HDDScan", "..." ],
  "programas": [ { ... }, { ... } ]
}
```

### `tecnico`

Nome padrão do técnico. Aparece como sugestão em `Tecnico [joao]:` e basta dar Enter para aceitar. Se você digitar **outro nome**, o script **grava como novo padrão** no `config.json`.

### `pastas`

| Campo | Significado | Padrão |
|---|---|---|
| `ferramentas` | Onde ficam as pastas dos programas | `Ferramentas` |
| `os` | Onde as pastas de OS são criadas | `OS` |
| `musica` | Pasta com o áudio do teste de som | `Ferramentas\\Musica` |

Regras de caminho (valem para `pastas` e para `pasta` de cada programa):

- **Relativo** → relativo à pasta do script (`"Ferramentas"`). É o que mantém o pen drive portátil.
- **Absoluto** → usado como está (`"C:\\Tools"`, `"\\\\servidor\\ferramentas"`).
- **Variáveis de ambiente** funcionam (`"%USERPROFILE%\\Tools"`).
- Em JSON, a barra invertida precisa ser **dupla**: `\\`.

### `modoRapido`

Lista com os nomes dos programas que entram na opção **`[1] Rápido`**. Aceita com ou sem o prefixo numérico (`"05_BatteryInfoView"` ou `"BatteryInfoView"`).

> Se a lista existir e não estiver vazia, ela **tem prioridade** sobre o campo `rapido` de cada programa. Se estiver vazia/ausente, vale o `rapido` de cada programa.

### `programas` (um objeto por ferramenta)

```json
{ "nome": "06_KeyboardTest", "pasta": "KeyboardTestUtility", "exe": "KeyboardTest64.exe|KeyboardTest*.exe",
  "modo": "manual", "maximizar": true, "espera": 4, "desc": "Teste de teclado",
  "rapido": false, "estresse": false, "perifericos": true, "soF12": true }
```

| Campo | Tipo | O que faz |
|---|---|---|
| `nome` | texto | Identifica o programa e **dá nome aos prints** (`06_KeyboardTest_1.png`). O prefixo numérico (`06_`) define a **ordem** e é escondido no menu |
| `pasta` | texto | Pasta do programa (relativa a `pastas.ferramentas`, ou absoluta) |
| `exe` | texto | Executável. Aceita **vários padrões separados por `\|`** (usa o primeiro que existir) e **curingas** (`Victoria*.exe`), útil quando a versão muda |
| `modo` | `auto` / `manual` / `fundo` | Veja a [tabela de modos](#modos-de-cada-programa-modo-no-config) |
| `maximizar` | true/false | Maximiza a janela ao abrir |
| `espera` | segundos | Tempo para o programa terminar de abrir antes de interagir/printar. Aumente em PC lento |
| `desc` | texto | Descrição mostrada no menu |
| `rapido` | true/false | Entra na opção `[1] Rápido` (só vale se `modoRapido` estiver vazio) |
| `estresse` | true/false | É teste pesado: **fora** da opção `[2]`, **dentro** da `[3]`. No WinPE é removido automaticamente (precisa de driver de vídeo) |
| `perifericos` | true/false | Entra nas opções `[4]` e `[6]`. Também é **removido** se o modo de periféricos estiver `DESLIGADO` |
| `soF12` | true/false | Para avançar com **`F12` sozinho** (em vez de `Alt+F12`). Use em programas que bloqueiam o Alt+F12, como o KeyboardTest |

### Como adicionar uma ferramenta nova

1. Coloque a ferramenta portátil em `Ferramentas/<NomeDaPasta>/`.
2. Acrescente um objeto em `programas` (copie um existente e ajuste `nome`, `pasta`, `exe`).
3. Escolha o `modo` e marque `rapido`/`estresse`/`perifericos` conforme a opção do menu em que ela deve aparecer.
4. Salve e rode o script. Não precisa mexer no `.ps1`.

---

## 🧭 WinPE e planos futuros

### Situação do WinPE

O script **ainda não funciona no WinPE**. O que já existe no código para o PE (detectado pela chave `HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT`):

- Erros não críticos vão para o log em vez de poluir a tela.
- `estresse` (FurMark) é removido automaticamente.
- Em vez do `systeminfo`/`powercfg`, usa o WMI (`hardware_pe.txt`).
- Menu avisa que câmera, microfone e som não funcionam no PE.
- `Textos/ambiente.txt` registra quais cmdlets/programas existem, para depurar.

**Por que é difícil:** o PowerShell no WinPE costuma vir sem vários cmdlets e sem o compilador .NET (`csc.exe`), de que o script depende para compilar as funções de janela, teclado e HUD (`Add-Type`). Sem isso, nem inicia.

> Se for testar no PE, rode e envie o `Textos/ambiente.txt` e o `log_execucao.txt` para ver exatamente o que falta.

### Próximo passo: app profissional

A ideia é substituir o script por um **aplicativo próprio**, compilado, que dispense o PowerShell e o `Add-Type`. O que isso resolve:

- **Funcionar no WinPE**, sem depender de compilador nem de cmdlets.
- Executável único, mais rápido para abrir e sem `iniciar.bat`.
- Interface gráfica no lugar do menu de texto.
- Capturas e teclas globais nativas e mais confiáveis.

O que deve ser **reaproveitado do script** (continua valendo como especificação):

- O formato do `config.json` (programas, modos, flags).
- A estrutura de pastas da OS (`Textos/`, `Documentos/`, prints na raiz, `teste final/`).
- Os formatos dos JSON de saída, compatíveis com a importação do laudo web.
- O fluxo de teclas (`F9`, `F8`, `Alt+F12`/`F12`, fechar no `[X]`).

---

## 🩺 Problemas comuns

| Sintoma | Causa provável / solução |
|---|---|
| `config.json invalido` ao abrir | Vírgula ou aspas faltando, ou `\` simples em vez de `\\`. Valide o JSON |
| `Nao encontrei X em <pasta>` | A ferramenta não está na pasta definida em `pasta`/`exe`. Confira o nome da pasta e do executável |
| Programa abre mas o print sai do terminal | Aumente o `espera` desse programa; o script só fotografa a janela que pertence ao app |
| Programa lento não é fotografado no `auto` | O script avisa `PC lento...` e passa a modo manual; aperte F9 |
| Print não sai ao apertar F9 | Confira se o foco está no programa (ou clique nele); se o hook falhar, o script usa o método antigo de leitura de teclas |
| `Rode como administrador` | Execute o `iniciar.bat` como administrador |
| Nada funciona no PE | Esperado por enquanto. Veja [WinPE e planos futuros](#-winpe-e-planos-futuros) |
