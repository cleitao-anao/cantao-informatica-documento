# ===== DIAGNOSTICO COM PRINTS (v3) =====
# Modo "auto"   : abre, maximiza, tira 1 print da janela e fecha.
# Modo "fundo"  : como manual, mas ao dar Alt+F12 o programa fica RODANDO minimizado
#                 (ex.: teste do HDDScan). No fim de tudo o script volta nele pra foto.
# Modo "manual" : abre, maximiza, e voce usa o programa. Teclas globais:
#                 F9  = print so da janela em foco
#                 F8  = print da tela inteira
#                 Alt+F12 = continuar (fecha o programa e vai pro proximo)
# Exe aceita varios nomes separados por "|" (usa o primeiro que existir).

$TeclaJanela = 0x78   # F9
$TeclaTela   = 0x77   # F8
$TeclaProx   = 0x7B   # F12 (usado junto com Alt)
$LimiteBateria = 80   # saude da bateria abaixo disso: o script sugere "N"

$Ferr = Join-Path $PSScriptRoot "Ferramentas"
$TodosProgramas = @(
    [pscustomobject]@{ Nome = "01_HDDScan";         Pasta = "HDDScan";                 Exe = "HDDScan.exe";                          Modo = "fundo";  Maximizar = $true; Espera = 6;  Desc = "Leitura do disco";              Rapido = $true;  Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "02_CrystalDiskInfo"; Pasta = "CrystalDiskInfo9_9_2";    Exe = "DiskInfo64.exe";                       Modo = "auto";   Maximizar = $true; Espera = 8;  Desc = "Saude dos discos";              Rapido = $true;  Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "03_HDSentinel";      Pasta = "hdsentinel_pro_portable"; Exe = "HDSentinel.exe|HDSentinel*.exe";       Modo = "auto";   Maximizar = $true; Espera = 12; Desc = "Saude e desempenho do disco";   Rapido = $false; Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "04_HWiNFO";          Pasta = "hwi_854";                 Exe = "HWiNFO64.exe";                         Modo = "manual"; Maximizar = $true; Espera = 15; Desc = "Informacoes de hardware";       Rapido = $true;  Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "05_BatteryInfoView"; Pasta = "batteryinfoview-x64";     Exe = "BatteryInfoView.exe";                  Modo = "auto";   Maximizar = $true; Espera = 5;  Desc = "Saude da bateria";              Rapido = $false; Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "06_KeyboardTest";    Pasta = "KeyboardTestUtility";     Exe = "KeyboardTest64.exe|KeyboardTest*.exe"; Modo = "manual"; Maximizar = $true; Espera = 4;  Desc = "Teste de teclado";              Rapido = $false; Estresse = $false; Perifericos = $true;  SoF12 = $true  }
    [pscustomobject]@{ Nome = "07_UsbTreeView";     Pasta = "UsbTreeView_x64";         Exe = "UsbTreeView.exe|UsbTreeView*.exe";     Modo = "manual"; Maximizar = $true; Espera = 4;  Desc = "Portas e dispositivos USB";     Rapido = $false; Estresse = $false; Perifericos = $true;  SoF12 = $false }
    [pscustomobject]@{ Nome = "08_Victoria";        Pasta = "Victoria537";             Exe = "Victoria*.exe";                        Modo = "manual"; Maximizar = $true; Espera = 6;  Desc = "Diagnostico avancado de disco"; Rapido = $false; Estresse = $false; Perifericos = $false; SoF12 = $false }
    [pscustomobject]@{ Nome = "09_FurMark";         Pasta = "FurMark_win64";           Exe = "FurMark_GUI.exe";                      Modo = "manual"; Maximizar = $true; Espera = 8;  Desc = "Estresse da GPU";               Rapido = $false; Estresse = $true;  Perifericos = $false; SoF12 = $false }
)

# ===== AMBIENTE: Windows normal ou WinPE (Strelec) =====
$isPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
# No WinPE varios cmdlets/DLLs nao existem: erros nao criticos vao para o log (erros.log) em vez de poluir a tela
if ($isPE) { $ErrorActionPreference = "SilentlyContinue" }

$srcW = @'
using System;
using System.Runtime.InteropServices;
public struct RECT { public int L, T, R, B; }
public class W {
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int k);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int s);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern int GetWindowTextLength(IntPtr h);
    public delegate bool EnumProc(IntPtr h, IntPtr l);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
    public static System.Collections.Generic.List<IntPtr> JanelasDoProcesso(uint pid) {
        var r = new System.Collections.Generic.List<IntPtr>();
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            uint p; GetWindowThreadProcessId(h, out p);
            if (p == pid && IsWindowVisible(h) && GetWindowTextLength(h) > 0) r.Add(h);
            return true;
        }, IntPtr.Zero);
        return r;
    }
}

'@
try { Add-Type -TypeDefinition $srcW -ErrorAction Stop }
catch {
    Write-Host ""
    Write-Host "  [ERRO] Nao consegui compilar as funcoes de janela (Add-Type)." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    if ($isPE) { Write-Host "  No WinPE isso acontece quando falta o compilador .NET (csc.exe). Use o Diagnostico.exe (C#) compilado no Windows normal." -ForegroundColor Yellow }
    Read-Host "  Enter para sair"; exit
}

$srcHud = @'
public class HUD {
    static System.Windows.Forms.Form f;
    static System.Windows.Forms.Label l;
    public static void Show(string initialText) {
        System.Threading.Thread t = new System.Threading.Thread(() => {
            f = new System.Windows.Forms.Form();
            f.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            f.TopMost = true;
            f.ShowInTaskbar = false;
            f.BackColor = System.Drawing.Color.Black;
            f.Opacity = 0.85;
            f.Width = 600; f.Height = 35;
            f.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            f.Location = new System.Drawing.Point(System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width / 2 - 300, 0);
            l = new System.Windows.Forms.Label();
            l.ForeColor = System.Drawing.Color.Lime;
            l.Font = new System.Drawing.Font("Segoe UI", 11, System.Drawing.FontStyle.Bold);
            l.Dock = System.Windows.Forms.DockStyle.Fill;
            l.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            l.Text = initialText;
            f.Controls.Add(l);
            System.Windows.Forms.Application.Run(f);
        });
        t.SetApartmentState(System.Threading.ApartmentState.STA);
        t.Start();
    }
    public static void SetText(string text) {
        if (f != null && l != null && f.IsHandleCreated) {
            try { f.BeginInvoke(new Action(() => { l.Text = text; })); } catch {}
        }
    }
    public static void Close() {
        if (f != null && f.IsHandleCreated) {
            try { f.BeginInvoke(new Action(() => { f.Close(); })); } catch {}
        }
    }
}

'@
try { Add-Type -ReferencedAssemblies "System.Windows.Forms", "System.Drawing" -TypeDefinition $srcHud -ErrorAction Stop }
catch {
    # sem o aviso na tela o resto funciona: cria uma versao "vazia" para o script nao quebrar
    Add-Type -TypeDefinition 'public class HUD { public static void Show(string t){} public static void SetText(string t){} public static void Close(){} }'
}
try { Add-Type -AssemblyName System.Windows.Forms, System.Drawing -ErrorAction Stop }
catch { Write-Host "  [ERRO] System.Windows.Forms/System.Drawing indisponiveis: $($_.Exception.Message)" -ForegroundColor Red; Read-Host "  Enter para sair"; exit }
[W]::SetProcessDPIAware() | Out-Null

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Testes de camera/microfone/som: 0 = offline | 1 = online | 2 = desligado
$script:ModoPerifericos = 0

# ===== MENU DE SELECAO =====
function Linha-Menu($texto, $cor = "White") {
    $v = [char]0x2551
    $w = 60
    Write-Host "  $v" -ForegroundColor Cyan -NoNewline
    $pad = $w - $texto.Length
    Write-Host "$texto$(' ' * [Math]::Max(0, $pad))" -ForegroundColor $cor -NoNewline
    Write-Host "$v" -ForegroundColor Cyan
}

# programas de cada opcao do menu (a lista mostrada vem daqui, nunca fica desatualizada)
function Lista-Opcao($n) {
    if ($n -eq 1) { return @($TodosProgramas | Where-Object { $_.Rapido }) }
    if ($n -eq 2) { return @($TodosProgramas | Where-Object { -not $_.Estresse }) }
    if ($n -eq 4) { return @($TodosProgramas | Where-Object { $_.Perifericos }) }
    return @($TodosProgramas)
}

# quebra os nomes em linhas curtas para caber na caixa do menu
function Linhas-Nomes($lista) {
    $nomes = @($lista | ForEach-Object { $_.Nome -replace '^\d+_', '' })
    $linhas = @()
    $atual = ""
    foreach ($n in $nomes) {
        if ($atual -eq "") { $nova = $n } else { $nova = "$atual, $n" }
        if ($nova.Length -gt 48) { $linhas += ($atual + ","); $atual = $n } else { $atual = $nova }
    }
    if ($atual) { $linhas += $atual }
    return $linhas
}

function Mostrar-Menu {
    $e = [char]0x2550; $v = [char]0x2551
    $w = 60; $bar = "$e" * $w

    Clear-Host
    Write-Host ""
    Write-Host "  $([char]0x2554)$bar$([char]0x2557)" -ForegroundColor Cyan

    # titulo centralizado
    $t1 = "DIAGNOSTICO TECNICO"
    $t2 = "Cantao Informatica"
    foreach ($t in @($t1, $t2)) {
        $pl = [math]::Floor(($w - $t.Length) / 2)
        $pr = $w - $pl - $t.Length
        Write-Host "  $v$(' ' * $pl)" -ForegroundColor Cyan -NoNewline
        if ($t -eq $t1) { Write-Host $t -ForegroundColor White -NoNewline }
        else            { Write-Host $t -ForegroundColor DarkCyan -NoNewline }
        Write-Host "$(' ' * $pr)$v" -ForegroundColor Cyan
    }

    Write-Host "  $([char]0x2560)$bar$([char]0x2563)" -ForegroundColor Cyan
    if ($isPE) { Linha-Menu "  WinPE (Strelec) detectado: itens do Windows serao pulados" "Yellow" }
    Linha-Menu ""

    function Linha-Opcao($num, $nome, $corNome, $tempo) {
        $pad = 60 - 2 - 3 - 2 - $nome.Length - $tempo.Length - 2
        Write-Host "  $v  " -ForegroundColor Cyan -NoNewline
        Write-Host "[$num]" -ForegroundColor Yellow -NoNewline
        Write-Host "  $nome" -ForegroundColor $corNome -NoNewline
        Write-Host "$(' ' * [Math]::Max(1, $pad))$tempo" -ForegroundColor DarkGray -NoNewline
        Write-Host "  $v" -ForegroundColor Cyan
    }

    # Opcao 1 - Rapido
    Linha-Opcao 1 "Rapido" "Green" "~3 min"
    foreach ($l in (Linhas-Nomes (Lista-Opcao 1))) { Linha-Menu "       $l" "DarkGray" }
    Linha-Menu ""

    # Opcao 2 - Completo
    Linha-Opcao 2 "Completo" "White" "~15 min"
    foreach ($l in (Linhas-Nomes (Lista-Opcao 2))) { Linha-Menu "       $l" "DarkGray" }
    Linha-Menu ""

    # Opcao 3 - Completo + Estresse
    Linha-Opcao 3 "Completo + Estresse" "Red" "~25 min"
    Linha-Menu "       Todos acima + FurMark (GPU)" "DarkGray"
    Linha-Menu ""

    # Opcao 4 - Perifericos / Portas
    Linha-Opcao 4 "Perifericos / Portas" "DarkCyan" "~5 min"
    foreach ($l in (Linhas-Nomes (Lista-Opcao 4))) { Linha-Menu "       $l" "DarkGray" }
    if ($isPE) { Linha-Menu "       (camera, microfone e som nao funcionam no WinPE)" "DarkGray" }
    else       { Linha-Menu "       + Camera, microfone e som" "DarkGray" }
    Linha-Menu ""

    # Opcao 5 - Personalizado
    Linha-Opcao 5 "Personalizado" "Magenta" ""
    Linha-Menu "       Escolha os programas manualmente" "DarkGray"
    Linha-Menu ""

    $txtModo = "OFFLINE (apps + Windows)"
    $corModo = "Green"
    if ($script:ModoPerifericos -eq 1) { $txtModo = "ONLINE (sites)"; $corModo = "Yellow" }
    elseif ($script:ModoPerifericos -eq 2) { $txtModo = "DESLIGADO"; $corModo = "Red" }
    Linha-Menu "  Perifericos: $txtModo  [0] alterna" $corModo
    Linha-Menu ""

    Write-Host "  $([char]0x255A)$bar$([char]0x255D)" -ForegroundColor Cyan
    Write-Host ""
}

function Mostrar-Personalizado($sel) {
    $e = [char]0x2550; $v = [char]0x2551
    $w = 60; $bar = "$e" * $w

    Clear-Host
    Write-Host ""
    Write-Host "  $([char]0x2554)$bar$([char]0x2557)" -ForegroundColor Cyan

    $t = "SELECAO DE PROGRAMAS"
    $pl = [math]::Floor(($w - $t.Length) / 2)
    $pr = $w - $pl - $t.Length
    Write-Host "  $v$(' ' * $pl)" -ForegroundColor Cyan -NoNewline
    Write-Host $t -ForegroundColor White -NoNewline
    Write-Host "$(' ' * $pr)$v" -ForegroundColor Cyan

    Write-Host "  $([char]0x2560)$bar$([char]0x2563)" -ForegroundColor Cyan
    Linha-Menu "  Digite o numero para marcar/desmarcar" "DarkGray"
    Linha-Menu "  Enter para confirmar | 0 para voltar" "DarkGray"
    Write-Host "  $([char]0x2560)$bar$([char]0x2563)" -ForegroundColor Cyan
    Linha-Menu ""

    for ($i = 0; $i -lt $TodosProgramas.Count; $i++) {
        $p = $TodosProgramas[$i]
        $marca = if ($sel[$i]) { "X" } else { " " }
        $corMarca = if ($sel[$i]) { "Green" } else { "DarkGray" }
        $corNome  = if ($sel[$i]) { "White" } else { "DarkGray" }
        $nome = ($p.Nome -replace '^\d+_', '')
        $desc = $p.Desc

        Write-Host "  $v  " -ForegroundColor Cyan -NoNewline
        Write-Host "[$marca]" -ForegroundColor $corMarca -NoNewline
        Write-Host "  " -NoNewline
        Write-Host "$($i+1). " -ForegroundColor Yellow -NoNewline
        $txtNome = $nome.PadRight(18)
        Write-Host $txtNome -ForegroundColor $corNome -NoNewline
        $restante = $w - 12 - $txtNome.Length - $desc.Length
        Write-Host $desc -ForegroundColor DarkGray -NoNewline
        Write-Host "$(' ' * [Math]::Max(0, $restante))$v" -ForegroundColor Cyan
    }

    Linha-Menu ""
    Write-Host "  $([char]0x255A)$bar$([char]0x255D)" -ForegroundColor Cyan
    Write-Host ""
}

function Escolher-Menu {
    while ($true) {
        Mostrar-Menu
        $r = Read-Host "  Escolha [1-5] ou [0] para alternar online/offline"
        switch ($r) {
            "0" { $script:ModoPerifericos = ($script:ModoPerifericos + 1) % 3 }
            "1" { return (Lista-Opcao 1) }
            "2" { return (Lista-Opcao 2) }
            "3" { return (Lista-Opcao 3) }
            "4" { return (Lista-Opcao 4) }
            "5" {
                # Personalizado: comeca com tudo marcado exceto o que e estresse
                $sel = @(1..$TodosProgramas.Count | ForEach-Object { $false })
                for ($i = 0; $i -lt $TodosProgramas.Count; $i++) {
                    $sel[$i] = -not $TodosProgramas[$i].Estresse
                }
                while ($true) {
                    Mostrar-Personalizado $sel
                    $pick = Read-Host "  Opcao"
                    if ($pick -eq "" -or $pick -eq "c" -or $pick -eq "C") {
                        $resultado = @()
                        for ($i = 0; $i -lt $TodosProgramas.Count; $i++) {
                            if ($sel[$i]) { $resultado += $TodosProgramas[$i] }
                        }
                        if ($resultado.Count -eq 0) {
                            Write-Host "  [!] Selecione ao menos um programa." -ForegroundColor Yellow
                            Start-Sleep 1
                            continue
                        }
                        return $resultado
                    }
                    if ($pick -eq "0") { break }  # volta ao menu principal
                    $n = 0
                    if ([int]::TryParse($pick, [ref]$n) -and $n -ge 1 -and $n -le $TodosProgramas.Count) {
                        $sel[$n - 1] = -not $sel[$n - 1]
                    }
                }
            }
            default {
                Write-Host "  [!] Digite de 1 a 5 (ou 0)" -ForegroundColor Yellow
                Start-Sleep 1
            }
        }
    }
}

$Programas = @(Escolher-Menu)
if ($isPE) {
    $semGpu = @($Programas | Where-Object { $_.Estresse })
    if ($semGpu.Count -gt 0) {
        Write-Host "`n  [!] WinPE: removido do teste (precisa de driver de video): $(($semGpu | ForEach-Object { $_.Nome -replace '^\d+_', '' }) -join ', ')" -ForegroundColor Yellow
        $Programas = @($Programas | Where-Object { -not $_.Estresse })
        Start-Sleep 2
    }
}
if ($script:ModoPerifericos -eq 2) {
    $Programas = @($Programas | Where-Object { -not $_.Perifericos })
}

# exibe resumo da selecao
Clear-Host
$nomesModo = ($Programas | ForEach-Object { $_.Nome -replace '^\d+_', '' }) -join ", "
Write-Host ""
Write-Host "  Modo selecionado: " -ForegroundColor Cyan -NoNewline
Write-Host $nomesModo -ForegroundColor White
Write-Host ""
if (-not $admin -and -not $isPE) { Write-Host "  [!] Rode como administrador para os programas funcionarem 100%." -ForegroundColor Yellow; Write-Host "" }

$os  = Read-Host "Numero da OS"
$cliente = Read-Host "Nome do cliente"
$arqTec  = Join-Path $PSScriptRoot "tecnico.txt"
$tecPad  = ""
if (Test-Path $arqTec) { $tecPad = (Get-Content $arqTec -TotalCount 1) }
$msgTec  = "Tecnico"
if ($tecPad) { $msgTec = "Tecnico [$tecPad]" }
$tecnico = Read-Host $msgTec
if (-not $tecnico) { $tecnico = $tecPad } else { Set-Content $arqTec $tecnico }
$modeloPad = (Get-CimInstance Win32_ComputerSystem).Model
$equip   = Read-Host "Equipamento [$modeloPad]"
if (-not $equip) { $equip = $modeloPad }
$dir = Join-Path $PSScriptRoot "OS\$os"
New-Item -ItemType Directory -Force $dir | Out-Null
# fotos ficam na raiz da OS; textos e documentos em subpastas
$dirTxt = Join-Path $dir "Textos";      New-Item -ItemType Directory -Force $dirTxt | Out-Null
$dirDoc = Join-Path $dir "Documentos";  New-Item -ItemType Directory -Force $dirDoc | Out-Null
$script:n = 0

# log completo da execucao (use para me mandar quando algo der errado)
try { Start-Transcript -Path "$dirTxt\log_execucao.txt" -Append | Out-Null } catch {}

# o que existe neste ambiente (ajuda a entender o que falta no WinPE)
function Registrar-Ambiente {
    $l = @()
    $l += "WinPE: $isPE"
    $l += "PowerShell: $($PSVersionTable.PSVersion)  CLR: $($PSVersionTable.CLRVersion)"
    $l += "Admin: $admin"
    $l += "csc.exe (compilador .NET): " + (Test-Path "$env:windir\Microsoft.NET\Framework64\v4.0.30319\csc.exe")
    $l += "dwmapi.dll: " + (Test-Path "$env:windir\System32\dwmapi.dll")
    foreach ($c in 'Get-CimInstance','Get-CimAssociatedInstance','Get-NetAdapter','Get-PnpDevice','Get-PhysicalDisk','Get-WinEvent','Get-Clipboard','Test-Connection','Start-Transcript','ConvertTo-Json') {
        $l += "cmdlet $c : " + [bool](Get-Command $c -ErrorAction SilentlyContinue)
    }
    foreach ($e in 'systeminfo.exe','powercfg.exe','netsh.exe','explorer.exe','msedge.exe') {
        $l += "programa $e : " + [bool](Get-Command $e -ErrorAction SilentlyContinue)
    }
    try { $l | Set-Content "$dirTxt\ambiente.txt" -Encoding UTF8 } catch {}
}
Registrar-Ambiente

function Tecla($k) { ([W]::GetAsyncKeyState($k) -band 0x8000) -ne 0 }
function Prox($p = $null) {
    # programas com SoF12 (ex.: KeyboardTest, que bloqueia o Alt+F12) avancam so com F12
    if ($p -and $p.SoF12) { return [bool](Tecla $TeclaProx) }
    return [bool]((Tecla 0x12) -and (Tecla $TeclaProx))   # Alt + F12
}
function Soltar($k) { while (Tecla $k) { Start-Sleep -Milliseconds 50 } }

# processos do terminal (este script e quem o hospeda) - nunca fotografar
$script:pidsTerm = @()
$cur = $PID
for ($i = 0; $i -lt 6 -and $cur; $i++) {
    $nomeProc = (Get-Process -Id $cur -ErrorAction SilentlyContinue).ProcessName
    if (-not $nomeProc -or $nomeProc -eq "explorer") { break }
    $script:pidsTerm += $cur
    $cur = (Get-CimInstance Win32_Process -Filter "ProcessId=$cur" -ErrorAction SilentlyContinue).ParentProcessId
}
$script:cache = @{}
$script:appPid = 0
$script:appPasta = ""

function Pid-Janela($h) { $x = [uint32]0; [W]::GetWindowThreadProcessId($h, [ref]$x) | Out-Null; [int]$x }
function Eh-Terminal($h) {
    if ($h -eq [IntPtr]::Zero) { return $true }
    return ($script:pidsTerm -contains (Pid-Janela $h))
}
function Pertence-App($h) {
    if ($h -eq [IntPtr]::Zero -or (Eh-Terminal $h)) { return $false }
    $id = Pid-Janela $h
    if ($id -eq $script:appPid) { return $true }
    if (-not $script:cache.ContainsKey($id)) {
        $ok = $false
        try {
            $path = (Get-Process -Id $id -ErrorAction Stop).Path
            if ($path) { $ok = $path.StartsWith($script:appPasta, [StringComparison]::OrdinalIgnoreCase) }
        } catch {}
        $script:cache[$id] = $ok
    }
    return $script:cache[$id]
}

function Salvar-Imagem($src, $nome) {
    $script:n++
    $banda = 30
    $texto = "OS $os  |  $(Get-Date -f 'dd/MM/yyyy HH:mm:ss')  |  $env:COMPUTERNAME"
    $out = New-Object Drawing.Bitmap $src.Width, ($src.Height + $banda)
    $g = [Drawing.Graphics]::FromImage($out)
    $g.DrawImage($src, 0, 0, $src.Width, $src.Height)
    $g.FillRectangle([Drawing.Brushes]::Black, 0, $src.Height, $src.Width, $banda)
    $fonte = New-Object Drawing.Font "Arial", 11, ([Drawing.FontStyle]::Bold)
    $g.DrawString($texto, $fonte, [Drawing.Brushes]::Yellow, 6, $src.Height + 6)
    $arq = "$dir\$($nome)_$($script:n).png"
    $out.Save($arq, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $out.Dispose(); $src.Dispose()
    try { [Console]::Beep(1000, 150) } catch {}
    Write-Host "    foto salva: $arq" -ForegroundColor Green
    $script:fotoTirada = $true
}

function Foto-Janela($h, $nome) {
    $r = New-Object RECT
    # 9 = limites reais da janela (sem a sombra invisivel do Windows 10/11)
    $okDwm = $false
    try { $okDwm = ([W]::DwmGetWindowAttribute($h, 9, [ref]$r, 16) -eq 0) } catch {}   # no WinPE o DWM nao existe: usa GetWindowRect
    if (-not $okDwm) { [W]::GetWindowRect($h, [ref]$r) | Out-Null }
    $w = $r.R - $r.L; $alt = $r.B - $r.T
    if ($w -le 0 -or $alt -le 0) { Write-Host "    [!] janela invalida" -ForegroundColor Yellow; return }
    $bmp = New-Object Drawing.Bitmap $w, $alt
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.L, $r.T, 0, 0, (New-Object Drawing.Size $w, $alt))
    $g.Dispose()
    Salvar-Imagem $bmp $nome
}

function Foto-Tela($nome) {
    $b = [Windows.Forms.SystemInformation]::VirtualScreen
    $bmp = New-Object Drawing.Bitmap $b.Width, $b.Height
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($b.Location, [Drawing.Point]::Empty, $b.Size)
    $g.Dispose()
    Salvar-Imagem $bmp $nome
}

$script:emFundo = @()

function Preparar-App($p, $proc) {
    $script:cache = @{}
    $script:appPasta = (Join-Path $Ferr $p.Pasta)
    $script:appPid = $proc.Id
}

# Fica ouvindo as teclas: F9 foto da janela, F8 tela inteira, Alt+F12 sai do laco
function Loop-Foto($p, $proc) {
    $ultima = [IntPtr]::Zero
    while ($true) {
        $fg = [W]::GetForegroundWindow()
        if (Pertence-App $fg) { $ultima = $fg }

        if (Tecla $TeclaJanela) {
            $alvo = $fg
            if (-not (Pertence-App $fg)) {
                # foco esta no terminal/outro lugar: volta para a ultima janela do programa
                if ($ultima -ne [IntPtr]::Zero -and [W]::IsWindow($ultima)) { $alvo = $ultima }
                else { $proc.Refresh(); $alvo = $proc.MainWindowHandle }
                [W]::SetForegroundWindow($alvo) | Out-Null
                Start-Sleep -Milliseconds 600
            }
            if ($alvo -eq [IntPtr]::Zero -or (Eh-Terminal $alvo)) {
                Write-Host "    [!] nao achei a janela do programa" -ForegroundColor Yellow
            } else { Foto-Janela $alvo $p.Nome }
            Soltar $TeclaJanela
        }
        elseif (Tecla $TeclaTela) {
            Foto-Tela $p.Nome
            Soltar $TeclaTela
        }
        elseif (Prox $p) {
            Soltar $TeclaProx
            if (-not $script:fotoTirada) {
                $f = New-Object Windows.Forms.Form
                $f.TopMost = $true
                $resp = [Windows.Forms.MessageBox]::Show($f, "Nenhuma foto foi tirada!`n`nDeseja realmente pular e ir para o proximo?", "Atencao", 4, 48)
                $f.Dispose()
                if ($resp -ne 'Yes') { continue }
            }
            break
        }
        Start-Sleep -Milliseconds 80
    }
}

function Testar($p) {
    # Exe pode ter varios padroes separados por "|": usa o primeiro que existir
    $exe = $null
    foreach ($pat in ($p.Exe -split '\|')) {
        $exe = Get-ChildItem (Join-Path $Ferr $p.Pasta) -Recurse -Filter $pat -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($exe) { break }
    }
    if (-not $exe) { Write-Host "[!] Nao encontrei $($p.Exe) em $($p.Pasta)" -ForegroundColor Yellow; return }

    Write-Host "`n[+] $($p.Nome)  (modo $($p.Modo))" -ForegroundColor Cyan
    $script:n = 0
    $proc = Start-Process $exe.FullName -WorkingDirectory $exe.DirectoryName -PassThru
    Preparar-App $p $proc
    Start-Sleep $p.Espera
    for ($i = 0; $i -lt 20 -and $proc.MainWindowHandle -eq [IntPtr]::Zero; $i++) { Start-Sleep -Milliseconds 500; $proc.Refresh() }
    $proc.Refresh()
    $h = $proc.MainWindowHandle
    if ($h -ne [IntPtr]::Zero) {
        [W]::SetForegroundWindow($h) | Out-Null
        if ($p.Maximizar) { [W]::ShowWindow($h, 3) | Out-Null }
    }
    Start-Sleep -Milliseconds 800

    $script:fotoTirada = $false
    $isAuto = ($p.Modo -eq "auto")

    if ($isAuto) {
        [HUD]::SetText("$($p.Nome) - Print automatico")
        $fgAtual = [W]::GetForegroundWindow()
        if ($h -ne [IntPtr]::Zero -and -not (Eh-Terminal $h)) { 
            Foto-Janela $h $p.Nome 
        } elseif (-not (Eh-Terminal $fgAtual)) {
            Foto-Tela $p.Nome
        } else {
            Write-Host "    [!] PC lento ou programa demorou para abrir. Tire a foto manualmente." -ForegroundColor Yellow
            $isAuto = $false
        }
    }
    
    if (-not $isAuto) {
        if ($p.Modo -eq "fundo") {
            Write-Host "    Inicie o teste no programa (use so testes de LEITURA)." -ForegroundColor Gray
            Write-Host "    F9 = foto | Alt+F12 = deixar rodando em segundo plano e seguir" -ForegroundColor Gray
            [HUD]::SetText("$($p.Nome) (Fundo) -> F9 Foto | Alt+F12 Pular")
            Loop-Foto $p $proc
            # guarda as janelas e minimiza; o programa continua rodando
            $janelas = @([W]::JanelasDoProcesso([uint32]$proc.Id))
            foreach ($jn in $janelas) { [W]::ShowWindow($jn, 6) | Out-Null }
            $script:emFundo += [pscustomobject]@{ P = $p; Proc = $proc; Janelas = $janelas; N = $script:n }
            Write-Host "    [segundo plano] $($p.Nome) continua rodando (minimizado)" -ForegroundColor Green
            return
        } else {
            $teclaCont = "Alt+F12"
            if ($p.SoF12) { $teclaCont = "F12" }
            Write-Host "    Use o programa. F9 = foto da janela | F8 = tela inteira | $teclaCont = continuar" -ForegroundColor Gray
            [HUD]::SetText("$($p.Nome) -> F9 Foto | $teclaCont Pular")
            Loop-Foto $p $proc
        }
    }
    try { if (-not $proc.HasExited) { Stop-Process $proc -Force -ErrorAction SilentlyContinue } } catch {}
}

# No final: volta nos programas que ficaram rodando, para tirar foto
function Voltar-Fundo {
    foreach ($e in $script:emFundo) {
        $saiu = $false
        try { $saiu = $e.Proc.HasExited } catch { $saiu = $true }
        if ($saiu) { Write-Host "[!] $($e.P.Nome) foi fechado antes do fim" -ForegroundColor Yellow; continue }

        Write-Host "`n[<] Voltando ao $($e.P.Nome)..." -ForegroundColor Cyan
        $script:n = $e.N
        Preparar-App $e.P $e.Proc
        foreach ($jn in $e.Janelas) { [W]::ShowWindow($jn, 9) | Out-Null }
        $e.Proc.Refresh()
        $hm = $e.Proc.MainWindowHandle
        if ($hm -ne [IntPtr]::Zero) {
            [W]::ShowWindow($hm, 3) | Out-Null
            [W]::SetForegroundWindow($hm) | Out-Null
        }
        Start-Sleep -Milliseconds 800
        Write-Host "    Espere o teste terminar. F9 = foto | F8 = tela inteira | Alt+F12 = finalizar e fechar" -ForegroundColor Gray
        Loop-Foto $e.P $e.Proc
        try { Stop-Process $e.Proc -Force -ErrorAction SilentlyContinue } catch {}
    }
    $script:emFundo = @()
}

# Relatorios em texto (backup dos prints)
Write-Host "Gerando relatorios de texto..."
if ($isPE) {
    # WinPE nao tem systeminfo nem relatorio de bateria: grava o que o WMI informar
    try { Get-CimInstance Win32_ComputerSystem, Win32_BIOS, Win32_Processor | Format-List * | Out-File "$dirTxt\hardware_pe.txt" } catch {}
} else {
    systeminfo > "$dirTxt\systeminfo.txt"
    powercfg /batteryreport /output "$dirDoc\bateria.html" | Out-Null
}
try { Get-CimInstance Win32_PhysicalMemory | Select Manufacturer, Capacity, Speed | Out-File "$dirTxt\ram.txt" } catch {}

[HUD]::Show("Iniciando diagnostico...")
foreach ($p in $Programas) { Testar $p }

# Testes de perifericos (teclado e USB passam pelos apps KeyboardTest / UsbTreeView)
$usouTeclado = @($Programas | Where-Object { $_.Nome -like "*KeyboardTest*" }).Count -gt 0
if ($script:ModoPerifericos -eq 2) {
    Write-Host "`n[!] Teste de perifericos ignorado pelo usuario (Modo Desligado)." -ForegroundColor Yellow
}
elseif ($script:ModoPerifericos -eq 1) {
    # modo online: sites (precisa de internet)
    if (-not $usouTeclado) { Start-Process "https://www.testarteclado.com.br/" }
    Start-Process "https://testarmicrofone.com.br/"
    Start-Process "https://testarsom.com.br/"
    Start-Process "https://testarcamera.com.br/"
    Write-Host "`nTestes online abertos. Use F9 para fotografar a janela em foco (a tecla continua valendo)." -ForegroundColor Gray
} else {
    # modo offline: apps de perifericos (se ainda nao rodaram pela selecao do menu) + ferramentas do Windows
    foreach ($per in @($TodosProgramas | Where-Object { $_.Perifericos })) {
        $jaRodou = @($Programas | Where-Object { $_.Nome -eq $per.Nome }).Count -gt 0
        if (-not $jaRodou) { Testar $per }
    }
    if ($isPE) {
        Write-Host "`n[WinPE] Camera, microfone e som ignorados (o WinPE nao tem esses servicos). Teclado e USB passam pelos apps." -ForegroundColor Yellow
    } else {
    Start-Process "microsoft.windows.camera:"                      # webcam (nao tire fotos/videos: o app salva em Imagens\Rolo da Camera)
    Write-Host "`nCamera do Windows aberta (so visualize, nao capture). F9 fotografa a janela em foco." -ForegroundColor Gray

    # traz o terminal de volta para o foco (a camera abre por cima)
    function Foco-Terminal-Local {
        foreach ($id in $script:pidsTerm) {
            $hw = (Get-Process -Id $id -ErrorAction SilentlyContinue).MainWindowHandle
            if ($hw -ne $null -and $hw -ne [IntPtr]::Zero) { [W]::ShowWindow($hw, 9) | Out-Null; [W]::SetForegroundWindow($hw) | Out-Null; break }
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }

    # --- Teste de microfone: grava 5s NA MEMORIA e toca de volta (nada e salvo em disco) ---
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Threading;
public class Mic {
    [StructLayout(LayoutKind.Sequential)] public struct WFX { public ushort Tag, Ch; public uint Rate, AvgBytes; public ushort Align, Bits, Cb; }
    [StructLayout(LayoutKind.Sequential)] public struct HDR { public IntPtr Data; public uint Len, Rec; public IntPtr User; public uint Flags, Loops; public IntPtr Next, Res; }
    [DllImport("winmm.dll")] static extern int waveInOpen(out IntPtr h, uint dev, ref WFX f, IntPtr cb, IntPtr inst, uint fl);
    [DllImport("winmm.dll")] static extern int waveInPrepareHeader(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveInAddBuffer(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveInStart(IntPtr h);
    [DllImport("winmm.dll")] static extern int waveInStop(IntPtr h);
    [DllImport("winmm.dll")] static extern int waveInReset(IntPtr h);
    [DllImport("winmm.dll")] static extern int waveInUnprepareHeader(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveInClose(IntPtr h);
    [DllImport("winmm.dll")] static extern int waveOutOpen(out IntPtr h, uint dev, ref WFX f, IntPtr cb, IntPtr inst, uint fl);
    [DllImport("winmm.dll")] static extern int waveOutPrepareHeader(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveOutWrite(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveOutReset(IntPtr h);
    [DllImport("winmm.dll")] static extern int waveOutUnprepareHeader(IntPtr h, IntPtr hdr, int sz);
    [DllImport("winmm.dll")] static extern int waveOutClose(IntPtr h);
    // retorna o pico captado (0-100); -1 = sem microfone; -2 = sem saida de audio
    public static int GravarEOuvir(int seg) {
        WFX f = new WFX(); f.Tag = 1; f.Ch = 1; f.Rate = 44100; f.Bits = 16; f.Align = 2; f.AvgBytes = 88200; f.Cb = 0;
        int len = (int)f.AvgBytes * seg;
        int sz = Marshal.SizeOf(typeof(HDR));
        IntPtr buf = Marshal.AllocHGlobal(len);
        IntPtr hdr = Marshal.AllocHGlobal(sz);
        try {
            for (int i = 0; i < len; i++) Marshal.WriteByte(buf, i, 0);
            HDR h = new HDR(); h.Data = buf; h.Len = (uint)len;
            Marshal.StructureToPtr(h, hdr, false);
            IntPtr wi;
            if (waveInOpen(out wi, 0xFFFFFFFF, ref f, IntPtr.Zero, IntPtr.Zero, 0) != 0) return -1;
            waveInPrepareHeader(wi, hdr, sz); waveInAddBuffer(wi, hdr, sz); waveInStart(wi);
            Thread.Sleep(seg * 1000 + 200);
            waveInStop(wi); waveInReset(wi); waveInUnprepareHeader(wi, hdr, sz); waveInClose(wi);
            int peak = 0;
            for (int i = 0; i < len - 1; i += 2) { int s = Math.Abs((int)Marshal.ReadInt16(buf, i)); if (s > peak) peak = s; }
            HDR h2 = new HDR(); h2.Data = buf; h2.Len = (uint)len;
            Marshal.StructureToPtr(h2, hdr, false);
            IntPtr wo;
            if (waveOutOpen(out wo, 0xFFFFFFFF, ref f, IntPtr.Zero, IntPtr.Zero, 0) != 0) return -2;
            waveOutPrepareHeader(wo, hdr, sz); waveOutWrite(wo, hdr, sz);
            while ((((HDR)Marshal.PtrToStructure(hdr, typeof(HDR))).Flags & 1) == 0) Thread.Sleep(50);
            waveOutReset(wo); waveOutUnprepareHeader(wo, hdr, sz); waveOutClose(wo);
            return peak * 100 / 32768;
        } finally { Marshal.FreeHGlobal(buf); Marshal.FreeHGlobal(hdr); }
    }
}
'@

    Foco-Terminal-Local
    Write-Host "`n=== TESTE DE MICROFONE ===" -ForegroundColor Cyan
    Write-Host "Vai gravar 5 segundos (na memoria, nada fica salvo) e tocar de volta. Use fone ou deixe o volume baixo." -ForegroundColor Gray
    do {
        Read-Host "  Enter para gravar (fale perto do microfone)" | Out-Null
        Write-Host "  Gravando 5s... FALE AGORA" -ForegroundColor Yellow
        $pico = [Mic]::GravarEOuvir(5)
        if ($pico -eq -1)     { Write-Host "  [!] Nenhum microfone encontrado/habilitado." -ForegroundColor Red }
        elseif ($pico -eq -2) { Write-Host "  [!] Sem saida de audio para tocar de volta." -ForegroundColor Red }
        elseif ($pico -lt 3)  { Write-Host "  Reproduzido. Nivel captado: $pico% (muito baixo/mudo - possivel defeito ou mutado)" -ForegroundColor Yellow }
        else                  { Write-Host "  Reproduzido. Nivel captado: $pico%" -ForegroundColor Green }
        $de = Read-Host "  Gravar de novo? [S/N]"
    } while ($de -match '^[sS]')

    # --- Teste de audio: toca o mp3 da pasta Ferramentas\Musica (somente leitura, sem rastros) ---
    $pastaMusica = Join-Path $Ferr "Musica"
    $mp3 = Get-ChildItem $pastaMusica -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in ".mp3", ".wav", ".wma" } | Select-Object -First 1
    Write-Host "`n=== TESTE DE AUDIO ===" -ForegroundColor Cyan
    if ($mp3) { try {
        Add-Type -AssemblyName presentationCore -ErrorAction Stop
        $mp = New-Object System.Windows.Media.MediaPlayer
        $mp.Open([Uri]$mp3.FullName)
        $mp.Play()
        Write-Host "  Tocando: $($mp3.Name)  (confira os dois lados/alto-falantes)" -ForegroundColor Gray
        Read-Host "  Enter para parar a musica" | Out-Null
        $mp.Stop(); $mp.Close()
    } catch { Write-Host "  [!] Nao consegui tocar o audio: $($_.Exception.Message)" -ForegroundColor Yellow } } else {
        Write-Host "  [!] Nenhum mp3 em $pastaMusica" -ForegroundColor Yellow
    }
    Write-Host "`nF9 fotografa a janela em foco (ex.: a Camera)." -ForegroundColor Gray
    }
}

if ($script:ModoPerifericos -ne 2 -and -not ($isPE -and $script:ModoPerifericos -eq 0)) {
    if ($script:emFundo.Count -gt 0) { Write-Host "(programas em segundo plano continuam rodando)" -ForegroundColor Gray }
    Write-Host "Aperte Alt+F12 quando terminar."
    [HUD]::SetText("Perifericos -> F9 Foto | Alt+F12 Terminar")
    $script:n = 0
    while (-not (Prox)) {
        if (Tecla $TeclaJanela) {
            $fg = [W]::GetForegroundWindow()
            if (Eh-Terminal $fg) {
                Write-Host "    [!] o foco esta no terminal. Clique na janela do app e aperte F9." -ForegroundColor Yellow
            } else { Foto-Janela $fg "10_Testes_Perifericos" }
            Soltar $TeclaJanela
        }
        Start-Sleep -Milliseconds 80
    }
    Soltar $TeclaProx
    Start-Sleep -Milliseconds 300
    # fecha a Camera do Windows para nao deixar nada aberto
    Get-Process -Name "WindowsCamera" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Voltar-Fundo
[HUD]::Close()

# ===== RESUMO FINAL + PERGUNTAS =====
function HEnc($t) { return [System.Net.WebUtility]::HtmlEncode([string]$t) }

function Focar-Terminal {
    foreach ($id in $script:pidsTerm) {
        $h = (Get-Process -Id $id -ErrorAction SilentlyContinue).MainWindowHandle
        if ($h -ne $null -and $h -ne [IntPtr]::Zero) {
            [W]::ShowWindow($h, 9) | Out-Null
            [W]::SetForegroundWindow($h) | Out-Null
            break
        }
    }
    $Host.UI.RawUI.FlushInputBuffer()
}

# $sug = resposta sugerida (SIM/NAO/...) aceita com Enter; $motivo = por que sugeriu
function Perguntar($texto, $sug = "", $motivo = "") {
    $dica = "[S]im [N]ao [T]=nao testado [A]=nao se aplica"
    if ($sug) {
        $letra = @{ "SIM" = "S"; "NAO" = "N"; "NAO TESTADO" = "T"; "NAO SE APLICA" = "A" }[$sug]
        $dica += "  | Enter = $letra"
        if ($motivo) { Write-Host "    sugestao: $letra ($motivo)" -ForegroundColor DarkYellow }
    }
    while ($true) {
        $r = (Read-Host "$texto  $dica").Trim().ToLower()
        if ($r -eq "" -and $sug) { return $sug }
        if ($r -eq "s" -or $r -eq "sim") { return "SIM" }
        if ($r -eq "n" -or $r -eq "nao") { return "NAO" }
        if ($r -eq "t") { return "NAO TESTADO" }
        if ($r -eq "a") { return "NAO SE APLICA" }
        Write-Host "  Responda S, N, T ou A" -ForegroundColor Yellow
    }
}

# Saude dos discos: le o relatorio do CrystalDiskInfo (/CopyExit)
function Saude-Discos {
    $lista = @()
    $ci = Get-ChildItem (Join-Path $Ferr "CrystalDiskInfo9_9_2") -Recurse -Filter "DiskInfo64.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $ci) { return $lista }
    $txt = Join-Path $ci.DirectoryName "DiskInfo.txt"
    Remove-Item $txt -ErrorAction SilentlyContinue
    Start-Process $ci.FullName -ArgumentList "/CopyExit" -WorkingDirectory $ci.DirectoryName -Wait
    if (Test-Path $txt) {
        Copy-Item $txt "$dirTxt\crystaldiskinfo.txt" -Force
        $linhas = Get-Content $txt
    } else {
        $linhas = @()
        if (Get-Command Get-Clipboard -ErrorAction SilentlyContinue) { $linhas = (Get-Clipboard -Raw) -split "`r?`n" }   # plano B: area de transferencia
        $linhas | Set-Content "$dirTxt\crystaldiskinfo.txt" -Encoding UTF8
    }
    $modelo = ""
    foreach ($l in $linhas) {
        if ($l -match '^\s*\(\d+\)\s+(.+?)\s*:\s*') { $modelo = $matches[1].Trim() }
        elseif ($l -match '^\s*(Health Status|Estado de Sa.de)\s*:\s*(.+)$') {
            $val = $matches[2].Trim()
            $pct = ""
            if ($val -match '\((\d+(?:[.,]\d+)?)\s*%\)') { $pct = $matches[1] + " %" }
            $lista += [pscustomobject]@{ Modelo = $modelo; Estado = $val; Pct = $pct }
        }
    }
    return $lista
}

# Saude da bateria: salva o texto do BatteryInfoView e calcula a % (capacidade atual / projeto)
function Saude-Bateria {
    $res = [pscustomobject]@{ Tem = $false; Pct = ""; PctNum = 0; Detalhe = "" }
    $bi = Get-ChildItem (Join-Path $Ferr "batteryinfoview-x64") -Recurse -Filter "BatteryInfoView.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($bi) { Start-Process $bi.FullName -ArgumentList "/stext `"$dirTxt\bateriainfo.txt`"" -WorkingDirectory $bi.DirectoryName -Wait -WindowStyle Hidden }
    try {
        $proj  = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity
        $cheia = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity
        if ($proj -gt 0 -and $cheia -gt 0) {
            $res.Tem = $true
            $res.PctNum = [int][math]::Min(100, [math]::Round(100 * $cheia / $proj, 0))
            $res.Pct = "$([math]::Round(100 * $cheia / $proj, 1)) %"
            $res.Detalhe = "capacidade atual $cheia mWh de $proj mWh (projeto)"
        }
    } catch {}
    return $res
}

function Tipo-Disco($modelo) {
    $d = $null
    if ($fis.Count -gt 0) {
        $d = $fis | Where-Object { $_.FriendlyName -and $modelo -and ($_.FriendlyName -like "*$modelo*" -or $modelo -like "*$($_.FriendlyName)*") } | Select-Object -First 1
    }
    if ($d) {
        if ($d.BusType -eq "USB")   { return "USB" }
        if ($d.BusType -eq "NVMe")  { return "NVMe" }
        if ($d.MediaType -eq "HDD") { return "HD" }
        if ($d.MediaType -eq "SSD") { return "SSD" }
        return ""
    }
    # plano B (WinPE sem o modulo Storage): Win32_DiskDrive
    $w = $discosWmi | Where-Object { $_.Model -and $modelo -and ($_.Model -like "*$modelo*" -or $modelo -like "*$($_.Model)*") } | Select-Object -First 1
    if ($w) {
        if ($w.InterfaceType -eq "USB" -or [string]$w.MediaType -match "Removable|External") { return "USB" }
        if ($w.Model -match "NVMe" -or $w.PNPDeviceID -match "NVME") { return "NVMe" }
        if ($w.Model -match "SSD") { return "SSD" }
    }
    return ""
}

# modelo do disco onde este script esta (o pendrive Ventoy): nunca entra na lista de armazenamento
function Modelo-Disco-Do-Script {
    try {
        $drv = Split-Path $PSScriptRoot -Qualifier
        if (-not $drv) { return "" }
        $ld   = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$drv'"
        $part = Get-CimAssociatedInstance -InputObject $ld -ResultClassName Win32_DiskPartition
        $disk = Get-CimAssociatedInstance -InputObject $part -ResultClassName Win32_DiskDrive | Select-Object -First 1
        return [string]$disk.Model
    } catch { return "" }
}

# Informacoes que o Windows ja sabe (detecao de dispositivo/driver, nao teste funcional)
function Coletar-Sistema {
    $o = [ordered]@{}

    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $o["CpuNome"] = $cpu.Name
    $cpuOpt = ""
    if     ($cpu.Name -match 'Ryzen\s*([3579])') { $cpuOpt = "AMD Ryzen $($matches[1])" }
    elseif ($cpu.Name -match 'Core.*?i([3579])') { $cpuOpt = "Core i$($matches[1])" }
    elseif ($cpu.Name -match 'Celeron')          { $cpuOpt = "Intel Celeron" }
    elseif ($cpu.Name -match 'Pentium')          { $cpuOpt = "Intel Pentium" }
    $o["CpuOpt"] = $cpuOpt

    $ramGB = [int][math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
    $o["RamGB"] = $ramGB
    $ramOpt = ""
    if (@(2,4,6,8,10,12,16,32,64) -contains $ramGB) { $ramOpt = "${ramGB}GB" }
    $o["RamOpt"] = $ramOpt

    # tela principal
    $tela = [Windows.Forms.Screen]::PrimaryScreen.Bounds
    $o["Res"] = "$($tela.Width)x$($tela.Height)"
    $resOpt = ""
    if     ($tela.Width -ge 3840) { $resOpt = "4K (UHD)" }
    elseif ($tela.Width -ge 2560) { $resOpt = "2K (QHD)" }
    elseif ($tela.Width -ge 1920) { $resOpt = "FULL HD" }
    elseif ($tela.Width -ge 1280) { $resOpt = "HD" }
    $o["ResOpt"] = $resOpt

    $vc = @(Get-CimInstance Win32_VideoController)
    $hz = ($vc | Where-Object { $_.CurrentRefreshRate } | Measure-Object CurrentRefreshRate -Maximum).Maximum
    $hzOpt = ""
    if ($hz) { foreach ($c in 60,75,120,144,165,240) { if ([math]::Abs($c - $hz) -le 2) { $hzOpt = "${c}Hz" } } }
    $o["Hz"] = $hz
    $o["HzOpt"] = $hzOpt

    $o["Gpus"] = (($vc | ForEach-Object { $_.Name }) -join " + ")
    $o["GpuDedicadaOk"]  = [bool]($vc | Where-Object { $_.Name -match 'NVIDIA|GeForce|Radeon RX|Radeon Pro|Intel\(R\) Arc' -and $_.Status -eq 'OK' })
    $o["VideoIntegrado"] = [bool]($vc | Where-Object { $_.Name -match 'UHD|Iris|Intel\(R\) HD|Radeon\(TM\) Graphics|Radeon Graphics|Vega' })
    if ($isPE) {
        # no WinPE o video e basico (resolucao/Hz/placa nao representam o equipamento): nao preenche esses campos
        $o["ResOpt"] = ""; $o["HzOpt"] = ""; $o["VideoIntegrado"] = $false; $o["GpuDedicadaOk"] = $false
    }

    # rede e bluetooth (ignora adaptadores USB, que podem ser do tecnico)
    # no WinPE nao ha drivers/modulos de rede: nao avalia (ausencia no PE nao significa defeito)
    $o["WifiOk"] = $false; $o["LanOk"] = $false; $o["BluetoothOk"] = $false
    if (-not $isPE) {
        if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) {
            $ads  = @(Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -notmatch 'USB' })
            $okSt = @('Up', 'Disconnected')
            $o["WifiOk"] = [bool]($ads | Where-Object { ($_.PhysicalMediaType -match '802\.11' -or $_.InterfaceDescription -match 'Wi-?Fi|Wireless|802\.11') -and ($okSt -contains [string]$_.Status) })
            $o["LanOk"]  = [bool]($ads | Where-Object { ([string]$_.PhysicalMediaType -eq '802.3') -and $_.InterfaceDescription -notmatch 'Wi-?Fi|Wireless|Bluetooth' -and ($okSt -contains [string]$_.Status) })
        }
        if (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue) {
            $o["BluetoothOk"] = [bool](Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'OK' -and $_.InstanceId -match '^(USB|PCI)\\' })
        }
    }

    $isWinPE = $isPE
    
    # ativacao do Windows e chave (Idea 2)
    if ($isWinPE) {
        $o["WindowsAtivado"] = $null
    } else {
        $lic = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($lic) { $o["WindowsAtivado"] = [bool]($lic.LicenseStatus -eq 1) } else { $o["WindowsAtivado"] = $null }
    }
    $o["WinKey"] = "Nao encontrada na BIOS"
    try {
        $wmiKey = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_OEMSoftwareLicensingTable -ErrorAction SilentlyContinue
        if ($wmiKey.OA3xOriginalProductKey) { $o["WinKey"] = $wmiKey.OA3xOriginalProductKey }
    } catch {}

    # Eventos Ocultos (Idea 1)
    if ($isWinPE) {
        $o["EventosCriticos"] = "Nao avaliado (Modo WinPE)"
    } else {
        $eventos = @()
        try {
            $data = (Get-Date).AddDays(-7)
            $log = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$data; ID=@(41, 6008, 7, 11, 153)} -ErrorAction SilentlyContinue
            foreach ($e in $log) {
                $etipo = if ($e.Id -in 7,11,153) { "Erro de Disco" } else { "Desligamento Inesperado" }
                $eventos += "$etipo em $($e.TimeCreated.ToString('dd/MM HH:mm'))"
            }
        } catch {}
        if ($eventos.Count -eq 0) { $eventos = @("Nenhum erro critico recente") }
        $o["EventosCriticos"] = ($eventos | Select-Object -Unique) -join " | "
    }

    # Teste Rapido de Rede (Idea 3)
    $netStatus = "Offline"
    if ($isPE) {
        $netStatus = "Nao avaliado (WinPE)"
    } else {
        $ping = Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($ping) {
            $netStatus = "Online (Ping OK)"
            $wifi = netsh wlan show interfaces | Select-String "Sinal|Signal" -ErrorAction SilentlyContinue
            if ($wifi) { $netStatus += " | Wi-Fi: $($wifi.ToString().Split(':')[1].Trim())" }
        }
    }
    $o["TesteRede"] = $netStatus

    # notebook ou pc (tipo do chassi)
    $ch = @((Get-CimInstance Win32_SystemEnclosure).ChassisTypes)
    $o["Notebook"] = [bool]($ch | Where-Object { @(8,9,10,11,12,14,18,21,30,31,32) -contains $_ })
    $o["IsWinPE"] = $isWinPE

    return [pscustomobject]$o
}

Focar-Terminal
Write-Host "`n===== RESUMO FINAL =====" -ForegroundColor Cyan

# ---- discos ----
$discos = @(Saude-Discos)
$fis = @()
if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { $fis = @(Get-PhysicalDisk -ErrorAction SilentlyContinue) }
$discosWmi = @(Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue)
$modeloPendrive = Modelo-Disco-Do-Script
$discosJson = @()
foreach ($d in $discos) {
    $tipo = Tipo-Disco $d.Modelo
    if ($tipo -eq "USB") { continue }   # ignora o pendrive
    if ($modeloPendrive -and ($modeloPendrive -like "*$($d.Modelo)*" -or $d.Modelo -like "*$modeloPendrive*")) { continue }   # disco do Ventoy
    $discosJson += [pscustomobject]@{ Modelo = $d.Modelo; Estado = $d.Estado; Pct = $d.Pct; Tipo = $tipo }
}
Write-Host "`nArmazenamento (CrystalDiskInfo):"
$discoTxt = @()
if ($discosJson.Count -eq 0) {
    Write-Host "  nao consegui ler - confira o print do CrystalDiskInfo" -ForegroundColor Yellow
    $discoTxt += "nao lido (ver print)"
} else {
    foreach ($d in $discosJson) {
        Write-Host "  $($d.Modelo): $($d.Estado)"
        $discoTxt += "$($d.Modelo) = $($d.Estado)"
    }
}

# ---- bateria ----
$bat = Saude-Bateria
Write-Host "`nBateria (BatteryInfoView):"
if ($bat.Tem) { Write-Host "  Saude: $($bat.Pct)  ($($bat.Detalhe))" }
else { Write-Host "  nenhuma bateria detectada" }

# ---- sistema ----
Write-Host "`nColetando informacoes do sistema..."
$sist = Coletar-Sistema
$modo = "pc"
if ($sist.Notebook -or $bat.Tem) { $modo = "notebook" }
$txtAtiv = "nao identificado"
if ($sist.WindowsAtivado -eq $true) { $txtAtiv = "ativado" } elseif ($sist.WindowsAtivado -eq $false) { $txtAtiv = "NAO ativado" }
if ($sist.IsWinPE) { $txtAtiv = "ignorado (WinPE)" }
Write-Host "  Tipo: $modo | CPU: $($sist.CpuNome) | RAM: $($sist.RamGB) GB"
Write-Host "  Tela: $($sist.Res) @ $($sist.Hz) Hz | Video: $($sist.Gpus)"
Write-Host "  Wi-Fi: $($sist.WifiOk) | LAN: $($sist.LanOk) | Bluetooth: $($sist.BluetoothOk) | Windows: $txtAtiv"

# ---- sugestoes de resposta (Enter aceita) ----
$sugArm = ""; $motArm = ""
if ($discosJson.Count -gt 0) {
    $ruim = @($discosJson | Where-Object { $_.Estado -match 'Caution|Cuidado|Bad|Ruim' })
    $bom  = @($discosJson | Where-Object { $_.Estado -match 'Good|Sa.d' })
    if ($ruim.Count -gt 0) { $sugArm = "NAO"; $motArm = "$($ruim[0].Modelo) = $($ruim[0].Estado)" }
    elseif ($bom.Count -eq $discosJson.Count) { $sugArm = "SIM"; $motArm = "todos os discos saudaveis" }
}
$sugBat = ""; $motBat = ""
if ($bat.Tem) {
    if ($bat.PctNum -ge $LimiteBateria) { $sugBat = "SIM"; $motBat = "saude $($bat.PctNum)% (limite $LimiteBateria%)" }
    else                                { $sugBat = "NAO"; $motBat = "saude $($bat.PctNum)% (limite $LimiteBateria%)" }
}

Write-Host ""
$perg = [ordered]@{}
if ($script:ModoPerifericos -eq 2) {
    $perg["TECLADO_OK"]        = "NAO TESTADO"
    $perg["MICROFONE_OK"]      = "NAO TESTADO"
    $perg["AUDIO_OK"]          = "NAO TESTADO"
    $perg["WEBCAM_OK"]         = "NAO TESTADO"
} elseif ($isPE) {
    Write-Host "  (WinPE) microfone, audio e webcam ficam como Nao Testado" -ForegroundColor Yellow
    $perg["TECLADO_OK"]        = Perguntar "O teclado estava bom?"
    $perg["MICROFONE_OK"]      = "NAO TESTADO"
    $perg["AUDIO_OK"]          = "NAO TESTADO"
    $perg["WEBCAM_OK"]         = "NAO TESTADO"
} else {
    $perg["TECLADO_OK"]        = Perguntar "O teclado estava bom?"
    $perg["MICROFONE_OK"]      = Perguntar "O microfone esta funcionando?"
    $perg["AUDIO_OK"]          = Perguntar "O audio esta funcionando?"
    $perg["WEBCAM_OK"]         = Perguntar "A webcam esta funcionando?"
}
$perg["ARMAZENAMENTO_OK"]  = Perguntar "Os armazenamentos estao bons?" $sugArm $motArm
if ($bat.Tem) { $perg["BATERIA_OK"] = Perguntar "A bateria esta boa?" $sugBat $motBat } else { $perg["BATERIA_OK"] = "NAO SE APLICA" }

# ---- TXT (formato CHAVE: valor) ----
$sis  = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$r = [ordered]@{}
$r["OS"]                    = $os
$r["DATA"]                  = Get-Date -f "dd/MM/yyyy HH:mm"
$r["CLIENTE"]               = $cliente
$r["TECNICO"]               = $tecnico
$r["COMPUTADOR"]            = $env:COMPUTERNAME
$r["FABRICANTE"]            = $sis.Manufacturer
$r["MODELO"]                = $sis.Model
$r["SERIAL"]                = $bios.SerialNumber
$r["TIPO"]                  = $modo
$r["PROCESSADOR"]           = $sist.CpuNome
$r["MEMORIA_GB"]            = $sist.RamGB
$r["TELA"]                  = "$($sist.Res) @ $($sist.Hz) Hz"
$r["VIDEO"]                 = $sist.Gpus
$r["WIFI_DETECTADO"]        = $sist.WifiOk
$r["LAN_DETECTADO"]         = $sist.LanOk
$r["BLUETOOTH_DETECTADO"]   = $sist.BluetoothOk
$r["WINDOWS"]               = $txtAtiv
$r["CHAVE_WINDOWS"]         = $sist.WinKey
$r["REDE_STATUS"]           = $sist.TesteRede
$r["EVENTOS_CRITICOS"]      = $sist.EventosCriticos
foreach ($k in $perg.Keys) { $r[$k] = $perg[$k] }
$r["ARMAZENAMENTO_SAUDE"]   = ($discoTxt -join " ; ")
$r["BATERIA_SAUDE"]         = if ($bat.Tem) { "$($bat.Pct) - $($bat.Detalhe)" } else { "sem bateria" }

$arq = "$dirTxt\resumo_OS_$os.txt"
$r.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" } | Set-Content $arq -Encoding UTF8
Write-Host "`nResumo salvo em: $arq" -ForegroundColor Green

# ===== PARECER TECNICO PRE-ESCRITO (HTML; acentos como entidades) =====
function Montar-Parecer {
    $itens = @()
    $prob = $false
    $rot = @{ "TECLADO_OK" = "teclado"; "MICROFONE_OK" = "microfone"; "AUDIO_OK" = "&aacute;udio"; "WEBCAM_OK" = "webcam"; "ARMAZENAMENTO_OK" = "armazenamento"; "BATERIA_OK" = "bateria" }

    if ($perg["TECLADO_OK"] -eq "NAO")   { $prob = $true; $itens += "<li><b>Teclado:</b> apresenta defeito, sendo necess&aacute;ria a troca.</li>" }
    if ($perg["MICROFONE_OK"] -eq "NAO") { $prob = $true; $itens += "<li><b>Microfone:</b> n&atilde;o funcionou corretamente nos testes realizados.</li>" }
    if ($perg["AUDIO_OK"] -eq "NAO")     { $prob = $true; $itens += "<li><b>&Aacute;udio:</b> apresentou falha nos testes realizados.</li>" }
    if ($perg["WEBCAM_OK"] -eq "NAO")    { $prob = $true; $itens += "<li><b>Webcam:</b> n&atilde;o funcionou corretamente nos testes realizados.</li>" }

    if ($bat.Tem) {
        if ($perg["BATERIA_OK"] -eq "NAO") {
            $prob = $true
            $itens += "<li><b>Bateria:</b> com $($bat.PctNum)% da capacidade original ($(HEnc $bat.Detalhe)), recomenda-se a troca.</li>"
        } elseif ($perg["BATERIA_OK"] -eq "SIM") {
            $itens += "<li><b>Bateria:</b> em bom estado, com $($bat.PctNum)% da capacidade original.</li>"
        }
    }

    foreach ($d in $discosJson) {
        $t = ""
        if ($d.Tipo) { $t = " ($(HEnc $d.Tipo))" }
        $linha = "<li><b>Armazenamento</b> $(HEnc $d.Modelo)$($t): estado $(HEnc $d.Estado)"
        if ($d.Pct) {
            $pn = (($d.Pct -replace '[^\d,\.]', '') -split '[,\.]')[0]
            $linha += ", sa&uacute;de de $pn%"
        }
        $linha += "."
        if ($perg["ARMAZENAMENTO_OK"] -eq "NAO") {
            $prob = $true
            $linha += " Recomenda-se a substitui&ccedil;&atilde;o e o backup dos dados."
        }
        $itens += $linha + "</li>"
    }

    if ($sist.WindowsAtivado -eq $false) { $prob = $true; $itens += "<li><b>Windows:</b> n&atilde;o ativado.</li>" }
    
    if ($sist.EventosCriticos -ne "Nenhum erro critico recente" -and $sist.EventosCriticos -notmatch "WinPE") {
        $prob = $true
        $itens += "<li><b>Alertas do Sistema:</b> foram registrados eventos de erro cr&iacute;tico ($($sist.EventosCriticos)). Recomenda-se investigar a causa raiz.</li>"
    }

    $nt = @()
    foreach ($k in $perg.Keys) { if ($perg[$k] -eq "NAO TESTADO") { $nt += $rot[$k] } }
    if ($nt.Count -gt 0) { $itens += "<li><b>N&atilde;o testado:</b> $($nt -join ', ').</li>" }

    if (-not $prob) { $itens += "<li>Nenhum defeito encontrado nos itens testados.</li>" }
    return "<p>Ap&oacute;s an&aacute;lise t&eacute;cnica em bancada, seguem os resultados:</p><ul>" + ($itens -join "") + "</ul>"
}

# ===== JSON NO FORMATO DO PROJETO (importar em "Importar" da pagina) =====
function Estado-Pagina($v) {
    if ($v -eq "SIM")           { return "Funcionando" }
    if ($v -eq "NAO")           { return "Com defeito" }
    if ($v -eq "NAO TESTADO")   { return "N$([char]0xE3)o Testado" }
    if ($v -eq "NAO SE APLICA") { return "N$([char]0xE3)o Se Aplica" }
    return "Selecione"
}

# Tudo vai na coluna TECNICO da pagina (2a coluna de cada linha)
$j = [ordered]@{}
$j["campo_1"]               = $cliente
$j["campo_2"]               = $equip
$j["campo_os"]              = $os
$j["campo_tecnico_tecnico"] = $tecnico
$j["campo_102"] = Estado-Pagina ($perg["TECLADO_OK"])
$j["campo_116"] = Estado-Pagina ($perg["MICROFONE_OK"])
$j["campo_120"] = Estado-Pagina ($perg["AUDIO_OK"])
$j["campo_112"] = Estado-Pagina ($perg["WEBCAM_OK"])

# detectados automaticamente
if ($sist.CpuOpt)  { $j["campo_34"] = $sist.CpuOpt }
if ($sist.RamOpt)  { $j["campo_43"] = $sist.RamOpt }
if ($sist.VideoIntegrado) { $j["campo_35"] = "Com v$([char]0xED)deo integrado" }
if ($sist.ResOpt)  { $j["campo_56"] = $sist.ResOpt }
if ($sist.HzOpt)   { $j["campo_60"] = $sist.HzOpt }
if ($sist.GpuDedicadaOk) { $j["campo_132"] = "Funcionando" }
if ($sist.WifiOk)        { $j["campo_93"]  = "Funcionando" }
if ($sist.LanOk)         { $j["campo_89"]  = "Funcionando" }
if ($sist.BluetoothOk)   { $j["campo_97"]  = "Funcionando" }
if (-not $isPE) { $j["campo_128"] = "Funcionando" }   # o Windows iniciou e rodou o diagnostico (no WinPE nao diz nada sobre o SO do cliente)

if ($bat.Tem) {
    $j["campo_9"]  = Estado-Pagina ($perg["BATERIA_OK"])
    $j["campo_10"] = "$($bat.PctNum)"
}

$stArm = Estado-Pagina ($perg["ARMAZENAMENTO_OK"])
if ($discosJson.Count -eq 0) { $j["campo_138"] = $stArm }
$i = 0
foreach ($d in $discosJson) {
    $i++
    if ($i -eq 1) { $kSt = "campo_138"; $kTp = "campo_139"; $kSa = "campo_140" }
    else          { $kSt = "campo_arm${i}_4"; $kTp = "campo_arm${i}_5"; $kSa = "campo_arm${i}_6" }
    $j[$kSt] = $stArm
    if ($d.Tipo) { $j[$kTp] = $d.Tipo }
    if ($d.Pct)  { $j[$kSa] = (($d.Pct -replace '[^\d,\.]', '') -split '[,\.]')[0] }
}

$j["PARECERTECNICOField"] = Montar-Parecer
$j["_modo"] = $modo          # "notebook" ou "pc" (a pagina usa se tiver o ajuste no importarJSON)
if ($discosJson.Count -gt 1) { $j["_armazenamentoCount"] = $discosJson.Count - 1 }
$j["defeitosObs"] = @{}

$nomeJson = ("$os - RELATORIO - $cliente.json") -replace '[\\/:*?"<>|]', '_'
$arqJson  = Join-Path $dirDoc $nomeJson
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($arqJson, ($j | ConvertTo-Json -Depth 5), $utf8)
Write-Host "JSON para a pagina salvo em: $arqJson" -ForegroundColor Green

# ===== RELATORIO UNICO COM TODOS OS PRINTS (HTML autocontido + PDF se tiver Edge) =====
function Linha-Info($rot, $val) { return "<tr><th>$rot</th><td>$val</td></tr>" }

function Gerar-Relatorio {
    $css = @'
body{font-family:Arial,Helvetica,sans-serif;margin:24px;color:#111}
h1{margin:0 0 4px}
h2{margin:28px 0 8px;border-bottom:2px solid #333;padding-bottom:4px}
table{border-collapse:collapse;width:100%;margin:8px 0}
td,th{border:1px solid #999;padding:6px 8px;text-align:left;font-size:14px}
th{background:#eee;width:30%}
.ok{color:#0a7a2f;font-weight:bold}.bad{color:#c62828;font-weight:bold}.nt{color:#b26a00;font-weight:bold}
figure{margin:14px 0;page-break-inside:avoid}
figure img{max-width:100%;border:1px solid #888}
figcaption{font-size:12px;color:#555;margin-top:2px}
.sub{color:#555;font-size:13px}
@media print{body{margin:10mm}}
'@
    $h = New-Object System.Collections.Generic.List[string]
    $h.Add("<!DOCTYPE html><html lang='pt-BR'><head><meta charset='UTF-8'><title>Relatorio OS $(HEnc $os)</title><style>$css</style></head><body>")
    $h.Add("<h1>Relat&oacute;rio de Diagn&oacute;stico</h1>")
    $h.Add("<div class='sub'>OS $(HEnc $os) &mdash; gerado em $(Get-Date -f 'dd/MM/yyyy HH:mm')</div>")

    $h.Add("<h2>Equipamento</h2><table>")
    $h.Add((Linha-Info "OS" (HEnc $os)))
    $h.Add((Linha-Info "Cliente" (HEnc $cliente)))
    $h.Add((Linha-Info "Equipamento" (HEnc $equip)))
    $h.Add((Linha-Info "Fabricante / Modelo" (HEnc "$($sis.Manufacturer) $($sis.Model)")))
    $h.Add((Linha-Info "N&ordm; de s&eacute;rie" (HEnc $bios.SerialNumber)))
    $h.Add((Linha-Info "T&eacute;cnico" (HEnc $tecnico)))
    $h.Add((Linha-Info "Processador" (HEnc $sist.CpuNome)))
    $h.Add((Linha-Info "Mem&oacute;ria" (HEnc "$($sist.RamGB) GB")))
    $h.Add((Linha-Info "Tela" (HEnc "$($sist.Res) @ $($sist.Hz) Hz")))
    $h.Add((Linha-Info "V&iacute;deo" (HEnc $sist.Gpus)))
    $wtxt = "N&atilde;o identificado"
    if ($sist.WindowsAtivado -eq $true) { $wtxt = "Ativado" } elseif ($sist.WindowsAtivado -eq $false) { $wtxt = "N&atilde;o ativado" }
    $h.Add((Linha-Info "Windows" $wtxt))
    $h.Add("</table>")

    $h.Add("<h2>Resultados</h2><table>")
    $nomesTab = [ordered]@{ "TECLADO_OK" = "Teclado"; "MICROFONE_OK" = "Microfone"; "AUDIO_OK" = "&Aacute;udio"; "WEBCAM_OK" = "Webcam"; "ARMAZENAMENTO_OK" = "Armazenamento"; "BATERIA_OK" = "Bateria" }
    foreach ($k in $nomesTab.Keys) {
        $v = $perg[$k]
        $cls = "nt"; $tx = "N&atilde;o testado"
        if ($v -eq "SIM")           { $cls = "ok";  $tx = "Funcionando" }
        elseif ($v -eq "NAO")       { $cls = "bad"; $tx = "Com defeito" }
        elseif ($v -eq "NAO SE APLICA") { $cls = "nt"; $tx = "N&atilde;o se aplica" }
        $h.Add((Linha-Info $nomesTab[$k] "<span class='$cls'>$tx</span>"))
    }
    $h.Add("</table>")

    $h.Add("<h2>Sa&uacute;de de armazenamento e bateria</h2><table>")
    if ($discosJson.Count -eq 0) { $h.Add((Linha-Info "Armazenamento" "n&atilde;o lido (ver prints)")) }
    foreach ($d in $discosJson) {
        $txd = HEnc "$($d.Estado) $($d.Tipo)"
        if ($d.Pct) { $txd = $txd + " &mdash; " + (HEnc $d.Pct) }
        $h.Add((Linha-Info (HEnc $d.Modelo) $txd))
    }
    if ($bat.Tem) { $h.Add((Linha-Info "Bateria" (HEnc "$($bat.Pct) - $($bat.Detalhe)"))) }
    $h.Add("</table>")

    $pngs = @(Get-ChildItem $dir -Filter *.png | Sort-Object { $_.BaseName -replace '_\d+$', '' }, { [int]($_.BaseName -replace '^.*_', '') })
    if ($pngs.Count -gt 0) { $h.Add("<h2>Capturas de tela</h2>") }
    $grupo = ""
    foreach ($f in $pngs) {
        $g = $f.BaseName -replace '_\d+$', ''
        if ($g -ne $grupo) {
            $grupo = $g
            $h.Add("<h3>" + (HEnc (($g -replace '^\d+_', '') -replace '_', ' ')) + "</h3>")
        }
        $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f.FullName))
        $h.Add("<figure><img src='data:image/png;base64,$b64'><figcaption>$(HEnc $f.BaseName)</figcaption></figure>")
    }
    $h.Add("</body></html>")

    $arqHtml = Join-Path $dirDoc "relatorio_OS_$($os -replace '[\\/:*?""<>|\s]', '_').html"
    [System.IO.File]::WriteAllText($arqHtml, ($h -join "`n"), $utf8)
    Write-Host "Relatorio HTML salvo em: $arqHtml" -ForegroundColor Green

    # PDF (melhor esforco, usa o Edge que ja vem no Windows)
    $edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($edge) {
        $arqPdf = [IO.Path]::ChangeExtension($arqHtml, ".pdf")
        $uri = ([System.Uri]$arqHtml).AbsoluteUri
        try {
            Start-Process $edge -ArgumentList "--headless", "--disable-gpu", "--no-pdf-header-footer", "--print-to-pdf=`"$arqPdf`"", $uri -Wait -WindowStyle Hidden
            if (Test-Path $arqPdf) {
                Write-Host "Relatorio PDF salvo em:  $arqPdf" -ForegroundColor Green
                Remove-Item $arqHtml -Force -ErrorAction SilentlyContinue
            }
        } catch {}
    }
}
Gerar-Relatorio

# erros nao criticos (principalmente no WinPE) ficam registrados
try {
    if ($Error.Count -gt 0) {
        $Error | ForEach-Object { "[{0}] {1}`r`n    em: {2}" -f $_.CategoryInfo.Category, $_.Exception.Message, $_.InvocationInfo.PositionMessage } |
            Set-Content "$dirTxt\erros.log" -Encoding UTF8
        Write-Host "$($Error.Count) aviso(s)/erro(s) registrado(s) em: $dirTxt\erros.log" -ForegroundColor Yellow
    }
} catch {}
try { Stop-Transcript | Out-Null } catch {}

if ($isPE) {
    Write-Host "Resultados em: $dir" -ForegroundColor Green
    if (Get-Command explorer.exe -ErrorAction SilentlyContinue) { try { Start-Process explorer.exe "`"$dir`"" } catch {} }
} else {
    Invoke-Item $dir
}
