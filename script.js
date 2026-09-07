    // --- Opções Dinâmicas ---
    const optionsData = {
      'opt1': ['Selecione', 'Funcionando', 'Com defeito', 'Não Testado', 'Não Se Aplica'],
      'opt2': ['Selecione', 'Funcionando', 'Com defeito', 'Não Testado'],
      'opt3': ['Selecione', 'Funcionando', 'Com defeito'],

      'opt4': ['Modelo', 'Intel Celeron', 'Intel Pentium', 'Core i3', 'Core i5', 'Core i7', 'Core i9', 'AMD Ryzen 3', 'AMD Ryzen 5', 'AMD Ryzen 7', 'AMD Ryzen 9'],
      'opt5': ['Capacidade', '2GB', '4GB', '6GB', '8GB', '10GB', '12GB', '16GB', '32GB', '64GB'],

      'opt6': ['Selecione', 'Funcionando', 'Com defeito', 'Sem Imagem', 'Imagem com Defeito', 'Não Testado'],
      'opt7': ['Selecione', 'TN', 'IPS', 'VA', 'OLED'],
      'opt8': ['Selecione', 'HD', 'FULL HD', '2K (QHD)', '4K (UHD)'],
      'opt9': ['Selecione', '60Hz', '75Hz', '120Hz', '144Hz', '165Hz', '240Hz'],
      'opt10': ['Selecione', 'Funcionando', 'Com defeito', 'Sem Iluminação', 'Oscilando', 'Não Testado'],
      'opt11': ['Selecione', 'Funcionando', 'Com defeito', 'Aberta', 'Em Curto', 'Não Testado'],
      'opt12': ['Selecione', 'Funcionando', 'Com defeito', 'Mau Contato', 'Rompido', 'Não Testado'],
      'opt13': ['Selecione', 'Imagem Normal', 'Tela Escura com Imagem', 'Sem Imagem Total', 'Listras / Artefatos', 'Imagem Piscando'],
      // 'opt14': ['Selecione', 'Funcionando', 'Com defeito', 'Não Testado', 'Não Se Aplica'],


      'opt15': ['Selecione', 'Simples', 'Completo'],
      'opt16': ['Selecione', 'Funcionando', 'Com defeito', 'Corrompido', 'Não Inicializa', 'Não Testado', 'Não Se Aplica'],
      'opt17': ['Tipo', 'SSD', 'NVMe', 'HD', 'NGFF(M2)'],
      'opt18': ['Selecione', 'Necessário', 'Realizada', 'Não necessária', 'Não realizada'],

      'opt19': ['Vídeo integrado', 'Com vídeo integrado', 'Sem vídeo integrado']
    };

    let armazenamentoCount = 0;

    function injetarOpcoes() {
      document.querySelectorAll('select[data-opt]').forEach(select => {
        const optKey = select.getAttribute('data-opt');
        const items = optionsData[optKey];
        if (items) {
          select.innerHTML = ''; // Limpa antes de injetar
          items.forEach(item => {
            const option = document.createElement('option');
            option.textContent = item;
            select.appendChild(option);
          });
        }
      });
    }

    function adicionarArmazenamento() {
      armazenamentoCount++;
      const btnRow = document.querySelector('.armazenamento-btn-row');
      if (!btnRow) return;

      const newRow = document.createElement('tr');
      newRow.setAttribute('data-device', 'pc,notebook');
      newRow.classList.add('armazenamento-row', 'armazenamento-extra');

      newRow.innerHTML = `
        <td>SSD/NVMe/HD (${armazenamentoCount + 1})</td>
        <td>
          <select class="save" data-opt="opt1"></select>
          <hr>
          <select class="save" data-opt="opt17"></select>
          <hr>
          <input type="text" class="save" placeholder="Saúde (%)" style="margin-top:5px;">
        </td>
        <td>
          <select class="save" data-opt="opt1"></select>
          <hr>
          <select class="save" data-opt="opt17"></select>
          <hr>
          <input type="text" class="save" placeholder="Saúde (%)" style="margin-top:5px;">
        </td>
        <td>
          <select class="save" data-opt="opt1"></select>
          <hr>
          <select class="save" data-opt="opt17"></select>
          <hr>
          <input type="text" class="save" placeholder="Saúde (%)" style="margin-top:5px;">
        </td>
      `;

      btnRow.parentNode.insertBefore(newRow, btnRow);

      // Injetar opções nos novos selects
      newRow.querySelectorAll('select[data-opt]').forEach(select => {
        const optKey = select.getAttribute('data-opt');
        const items = optionsData[optKey];
        if (items) {
          select.innerHTML = '';
          items.forEach(item => {
            const option = document.createElement('option');
            option.textContent = item;
            select.appendChild(option);
          });
        }
      });

      // Adicionar listeners nos novos selects
      newRow.querySelectorAll('.save').forEach(el => {
        if (el.tagName === 'SELECT') {
          let valorAnterior = el.value;
          el.addEventListener('focus', function() { valorAnterior = this.value; });
          el.addEventListener('change', function() {
            const select = this;
            const novoValor = select.value;
            if (ehValorDeDefeito(valorAnterior) && !ehValorDeDefeito(novoValor)) {
              const linha = select.closest('tr');
              if (linha) {
                const item = linha.querySelector('td')?.innerText.trim();
                if (item && defeitosObs[item] && defeitosObs[item].trim() !== '') {
                  abrirModal(
                    'O item "' + item + '" possui uma observação que será apagada. Deseja continuar?',
                    (confirmou) => {
                      if (confirmou) {
                        delete defeitosObs[item];
                        salvarObs();
                        valorAnterior = novoValor;
                        capturarDefeitos();
                      } else {
                        select.value = valorAnterior;
                      }
                    }
                  );
                  return;
                }
              }
            }
            valorAnterior = novoValor;
            capturarDefeitos();
          });
        } else {
          el.addEventListener('change', capturarDefeitos);
          el.addEventListener('keyup', capturarDefeitos);
        }
      });

      // Mostrar botão remover
      document.getElementById('btnRemoverArmazenamento').style.display = 'inline-block';

      // Aplicar modo atual
      const modoAtual = localStorage.getItem('modo_equipamento') || 'notebook';
      const devices = newRow.getAttribute('data-device');
      if (devices && !devices.includes(modoAtual)) {
        newRow.style.display = 'none';
      }
    }

    function removerArmazenamento() {
      const extras = document.querySelectorAll('.armazenamento-extra');
      if (extras.length > 0) {
        const ultimo = extras[extras.length - 1];
        ultimo.remove();
        armazenamentoCount--;
      }
      if (document.querySelectorAll('.armazenamento-extra').length === 0) {
        document.getElementById('btnRemoverArmazenamento').style.display = 'none';
      }
      capturarDefeitos();
    }
    // ------------------------


    // Armazena OBS dos defeitos (persistido no localStorage)
    let defeitosObs = JSON.parse(localStorage.getItem('defeitosObs') || '{}');

    // Callback do modal
    let _modalCallback = null;

    function abrirModal(msg, callback) {
      document.getElementById('modalMsg').textContent = msg;
      document.getElementById('modalAviso').classList.add('show');
      _modalCallback = callback;
    }

    function fecharModal(confirmou) {
      document.getElementById('modalAviso').classList.remove('show');
      if (_modalCallback) _modalCallback(confirmou);
      _modalCallback = null;
    }

    function salvarObs() {
      localStorage.setItem('defeitosObs', JSON.stringify(defeitosObs));
    }

    // Verifica se algum defeito com OBS está prestes a ser removido
    function temObsEmRisco(selectsAfetados, novoValor) {
      // Se o novo valor ainda é um defeito, não tem risco
      if (ehValorDeDefeito(novoValor)) return [];

      let itensEmRisco = [];
      selectsAfetados.forEach(select => {
        const valorAtual = select.value?.toLowerCase() || '';
        if (!ehValorDeDefeito(valorAtual)) return;
        const linha = select.closest('tr');
        if (!linha) return;
        const item = linha.querySelector('td')?.innerText.trim();
        if (item && defeitosObs[item] && defeitosObs[item].trim() !== '') {
          if (!itensEmRisco.includes(item)) itensEmRisco.push(item);
        }
      });
      return itensEmRisco;
    }

    // Valores que indicam problema em selects de display
    const valoresDisplayProblema = [
      'sem iluminação', 'oscilando', 'aberta', 'em curto',
      'mau contato', 'rompido', 'tela escura com imagem',
      'sem imagem total', 'listras / artefatos', 'imagem piscando',
      'sem imagem', 'imagem com defeito'
    ];

    // Valores padrão de defeito
    const valoresDeDefeito = ['com defeito', 'corrompido', 'não inicializa'];

    function ehValorDeDefeito(valor) {
      const v = valor.toLowerCase();
      return valoresDeDefeito.includes(v) || valoresDisplayProblema.includes(v);
    }

    function obterInfoExtra(item, linha) {
      // Para SSD/NVMe/HD, busca saúde e tipo
      if (item === 'SSD/NVMe/HD') {
        const inputs = linha.querySelectorAll('input[placeholder*="Sa\u00fade"]');
        let saude = '';
        inputs.forEach(inp => {
          if (inp.value && inp.value.trim() !== '') saude = inp.value.trim();
        });
        const tipoSelects = linha.querySelectorAll('select[data-opt="opt17"]');
        let tipo = '';
        tipoSelects.forEach(sel => {
          if (sel.value && sel.value !== 'Tipo') tipo = sel.value;
        });
        let extra = '';
        if (tipo) extra += tipo;
        if (saude) extra += (extra ? ' ' : '') + 'com ' + saude + ' de sa\u00fade';
        return extra;
      }

      // Para itens de display, mostra os sintomas espec\u00edficos selecionados
      const displaySelects = linha.querySelectorAll('.display-check');
      if (displaySelects.length > 0) {
        let sintomas = [];
        displaySelects.forEach(sel => {
          const v = sel.value?.toLowerCase() || '';
          if (valoresDisplayProblema.includes(v)) {
            sintomas.push(sel.value);
          }
        });
        if (sintomas.length > 0) {
          return sintomas.join(', ');
        }
      }

      return '';
    }

    function capturarDefeitos() {
      let defeitos = []; // { item, extra }
      let itensAdicionados = [];

      document.querySelectorAll('.save').forEach((el) => {
        let valor;
        if (el.tagName === 'SELECT' || el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
          valor = el.value;
        } else {
          valor = el.innerText;
        }

        if (valor && ehValorDeDefeito(valor)) {
          let linha = el.closest('tr');
          if (linha) {
            let item = linha.querySelector('td')?.innerText.trim();
            if (item && !itensAdicionados.includes(item)) {
              itensAdicionados.push(item);
              const extra = obterInfoExtra(item, linha);
              defeitos.push({ item, extra });
            }
          }
        }

        // Preventiva: quando "Necessário" é selecionado, aparece na área de problemas
        if (valor && valor === 'Necessário' && el.tagName === 'SELECT') {
          let linha = el.closest('tr');
          if (linha) {
            let item = linha.querySelector('td')?.innerText.trim();
            if (item === 'PREVENTIVA' && !itensAdicionados.includes(item)) {
              itensAdicionados.push(item);
              defeitos.push({ item: 'PREVENTIVA', extra: 'Limpeza preventiva necessária' });
            }
          }
        }
      });

      // Remove OBS de itens que n\u00e3o s\u00e3o mais defeito
      Object.keys(defeitosObs).forEach(key => {
        if (!itensAdicionados.includes(key)) {
          delete defeitosObs[key];
        }
      });
      salvarObs();

      renderizarDefeitos(defeitos);
    }

    function renderizarDefeitos(defeitos) {
      let campo = document.getElementById('DEFEITOENCONTRADOField');
      if (!campo) return;

      let html = '';

      defeitos.forEach(d => {
        const obsVal = defeitosObs[d.item] || '';
        html += '<div class="defeito-card">';
        html += '  <div class="defeito-texto">Problema encontrado: <strong>' + d.item + '</strong></div>';
        if (d.extra) {
          html += '  <div class="defeito-extra">' + d.extra + '</div>';
        }
        html += '  <div class="defeito-obs-row">';
        html += '    <strong>OBS:</strong>';
        html += '    <textarea class="defeito-obs-input" data-item="' + d.item + '" placeholder="Adicionar observa\u00e7\u00e3o..." onchange="atualizarObs(this)" oninput="atualizarObs(this)">' + obsVal.replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</textarea>';
        // html += '    <input class="defeito-obs-input" type="text" value="' + obsVal.replace(/"/g, '&quot;') + '" data-item="' + d.item + '" placeholder="Adicionar observa\u00e7\u00e3o..." onchange="atualizarObs(this)" oninput="atualizarObs(this)">';
        html += '  </div>';
        html += '</div>';
      });

      campo.innerHTML = html;
      verificarPendencias();
    }

    function atualizarObs(input) {
      const item = input.getAttribute('data-item');
      defeitosObs[item] = input.value;
      salvarObs();
    }



    // 💾 SALVAR
    function salvar() {
      let dados = [];

      document.querySelectorAll(".save").forEach((el, i) => {
        if (el.type === 'checkbox') {
          dados[i] = el.checked;
        } else if (el.tagName === "SELECT" || el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
          dados[i] = el.value;
        } else {
          dados[i] = el.innerHTML;
        }
      });

      localStorage.setItem("laudo", JSON.stringify(dados));
    }

    // 🔄 CARREGAR + MONITORAMENTO AUTOMÁTICO
    function padronizarSelects() {
      document.querySelectorAll("select").forEach(select => {

        let temSelecione = false;

        for (let i = 0; i < select.options.length; i++) {
          if (select.options[i].text === "Selecione") {
            temSelecione = true;
            break;
          }
        }

        if (!temSelecione) {
          let option = document.createElement("option");
          option.text = "Selecione";
          option.value = "";

          select.insertBefore(option, select.firstChild);
        }
      });
    }

    function mudarModo(modo) {
      // Atualiza botões
      document.querySelectorAll('.app-bar button').forEach(btn => btn.classList.remove('active'));
      let btn = document.getElementById('btn-' + modo);
      if (btn) btn.classList.add('active');

      // Filtra linhas da tabela
      document.querySelectorAll('tbody tr').forEach(tr => {
        const devices = tr.getAttribute('data-device');
        if (devices) {
          if (devices.includes(modo)) {
            tr.style.display = 'table-row';
          } else {
            tr.style.display = 'none';
          }
        }
      });

      // Salva no localStorage
      localStorage.setItem("modo_equipamento", modo);
    }

    function preencherColunaApp(valorProcurado) {
      const colIndex = parseInt(document.getElementById('colunaSelect').value, 10);

      // Coleta todos os selects afetados
      let selectsAfetados = [];
      const colunas = colIndex === 0 ? [1, 2, 3] : [colIndex];
      colunas.forEach(ci => {
        document.querySelectorAll('tbody tr').forEach(tr => {
          if (tr.style.display !== 'none') {
            const td = tr.querySelectorAll('td')[ci];
            if (td) {
              td.querySelectorAll('select').forEach(sel => selectsAfetados.push(sel));
            }
          }
        });
      });

      const itensEmRisco = temObsEmRisco(selectsAfetados, valorProcurado);
      if (itensEmRisco.length > 0) {
        abrirModal(
          'Os seguintes itens t\u00eam observa\u00e7\u00f5es que ser\u00e3o apagadas: ' + itensEmRisco.join(', ') + '. Deseja continuar?',
          (confirmou) => {
            if (confirmou) {
              itensEmRisco.forEach(item => delete defeitosObs[item]);
              salvarObs();
              executarPreenchimento(colunas, valorProcurado);
            }
          }
        );
      } else {
        executarPreenchimento(colunas, valorProcurado);
      }
    }

    function executarPreenchimento(colunas, valorProcurado) {
      colunas.forEach(colIndex => {
        preencherColuna(colIndex, valorProcurado);
      });
    }

    function preencherColuna(colIndex, valorProcurado) {
      document.querySelectorAll('tbody tr').forEach(tr => {
        if (tr.style.display !== 'none') {
          const td = tr.querySelectorAll('td')[colIndex];
          if (td) {
            td.querySelectorAll('select').forEach(select => {
              if (valorProcurado === 'Selecione') {
                // Para o botão Vazio, sempre volta pro primeiro item que é o padrão (Selecione, Tipo, Modelo, Capacidade)
                select.selectedIndex = 0;
              } else {
                let optionExists = false;
                for (let i = 0; i < select.options.length; i++) {
                  if (select.options[i].value === valorProcurado || select.options[i].text === valorProcurado) {
                    optionExists = true;
                    break;
                  }
                }
                if (optionExists) {
                  select.value = valorProcurado;
                }
              }
            });
          }
        }
      });
      capturarDefeitos();
    }

    
window.onload = function () {
      // Auto-save listeners
      document.querySelectorAll('.save').forEach(el => {
        el.addEventListener('change', salvar);
        if(el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
          el.addEventListener('input', salvar);
        }
      });

      injetarOpcoes(); // Injeta as opções assim que a página carrega

      // Recuperar modo do localStorage ou 'notebook' por padrão
      let modoSalvo = localStorage.getItem("modo_equipamento") || "notebook";
      mudarModo(modoSalvo);

      let dados = JSON.parse(localStorage.getItem("laudo"));

      document.querySelectorAll(".save").forEach((el, i) => {
        if (dados && dados[i] !== undefined) {
          if (el.type === 'checkbox') {
            el.checked = dados[i] === true || dados[i] === "true";
          } else if (el.tagName === "SELECT" || el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
            el.value = dados[i] || "";
          } else {
            el.innerHTML = dados[i] || "";
          }
        }

        // Para selects: verificar se tem OBS em risco ao mudar
        if (el.tagName === "SELECT") {
          let valorAnterior = el.value;
          el.addEventListener("focus", function () {
            valorAnterior = this.value;
          });
          el.addEventListener("change", function () {
            const select = this;
            const novoValor = select.value;

            // Se estava em defeito e agora não está mais
            if (ehValorDeDefeito(valorAnterior) && !ehValorDeDefeito(novoValor)) {
              const linha = select.closest('tr');
              if (linha) {
                const item = linha.querySelector('td')?.innerText.trim();
                if (item && defeitosObs[item] && defeitosObs[item].trim() !== '') {
                  abrirModal(
                    'O item "' + item + '" possui uma observação que será apagada. Deseja continuar?',
                    (confirmou) => {
                      if (confirmou) {
                        delete defeitosObs[item];
                        salvarObs();
                        valorAnterior = novoValor;
                        capturarDefeitos();
                      } else {
                        select.value = valorAnterior;
                      }
                    }
                  );
                  return;
                }
              }
            }
            valorAnterior = novoValor;
            capturarDefeitos();
          });
        } else {
          el.addEventListener("change", capturarDefeitos);
          el.addEventListener("keyup", capturarDefeitos);
        }
      });

      padronizarSelects();
      capturarDefeitos();
    };

    function validarObrigatorios() {
      let falta = [];
      if (!document.getElementById('clienteField').value.trim()) falta.push("CLIENTE");
      if (!document.getElementById('equipamentoField').value.trim()) falta.push("EQUIPAMENTO");
      if (!document.getElementById('osField').value.trim()) falta.push("OS");

      let temTecnico = false;
      document.querySelectorAll('.input-tecnico').forEach(inp => {
        if (inp.value.trim()) temTecnico = true;
      });
      if (!temTecnico) falta.push("TÉCNICO (pelo menos um nome)");

      if (falta.length > 0) {
        abrirModal("Os seguintes campos são obrigatórios: " + falta.join(', '));
        return false;
      }
      return true;
    }

    function verificarPendencias() {
      let pendenciasColunas = [[], [], []]; // 0: Entrada, 1: Técnico, 2: Testes
      let tevePreenchimentoColunas = [false, false, false];

      document.querySelectorAll('tbody tr').forEach(tr => {
        if (tr.style.display !== 'none') {
          const tds = tr.querySelectorAll('td');
          // Linhas normais tem 4 tds
          if (tds.length === 4) {
            const itemNome = tds[0].innerText.trim();
            for (let i = 0; i < 3; i++) {
              const colTd = tds[i + 1];
              if (!colTd) continue;
              const selects = colTd.querySelectorAll('select');
              let temValor = false;
              let temSelecione = false;

              selects.forEach(sel => {
                const v = sel.value;
                const placeholders = ['Selecione', 'Vazio', 'Tipo', 'Modelo', 'Capacidade', 'Vídeo integrado'];
                
                if (v && !placeholders.includes(v) && v !== '') {
                  temValor = true;
                }
                if (placeholders.includes(v)) {
                  temSelecione = true;
                }
              });

              if (temValor) {
                tevePreenchimentoColunas[i] = true;
              }
              if (temSelecione) {
                pendenciasColunas[i].push(itemNome);
              }
            }
          }
        }
      });

      let msgs = [];
      const nomesColunas = ['Entrada', 'Técnico', 'Testes'];
      for (let i = 0; i < 3; i++) {
        if (tevePreenchimentoColunas[i] && pendenciasColunas[i].length > 0) {
          msgs.push(`<strong><i class="fa-solid fa-triangle-exclamation"></i> Coluna ${nomesColunas[i]} incompleta:</strong> Faltou selecionar em: ${pendenciasColunas[i].join(', ')}`);
        }
      }

      const avisoDiv = document.getElementById('avisosPendencia');
      const appBarAviso = document.getElementById('appBarAviso');

      if (msgs.length > 0) {
        avisoDiv.innerHTML = msgs.join('<br><br>');
        avisoDiv.style.display = 'block';
        if (appBarAviso) appBarAviso.style.display = 'inline-block';
      } else {
        avisoDiv.style.display = 'none';
        if (appBarAviso) appBarAviso.style.display = 'none';
      }
    }

    function prepararImpressao() {
      const placeholders = ['Selecione', 'Vazio', 'Tipo', 'Modelo', 'Capacidade'];
      
      document.querySelectorAll('select:not(#colunaSelect)').forEach(sel => {
        if (placeholders.includes(sel.value)) {
          sel.setAttribute('data-print-hide-text', 'true');
        } else {
          sel.removeAttribute('data-print-hide-text');
        }
      });

      document.querySelectorAll('.defeito-obs-input').forEach(inp => {
        if (inp.value.trim() === '') {
          inp.closest('.defeito-obs-row').setAttribute('data-print-hide', 'true');
        } else {
          inp.closest('.defeito-obs-row').removeAttribute('data-print-hide');
        }
      });
    }

    function imprimir() {
      if (!validarObrigatorios()) return;
      prepararImpressao();

      const os = (document.getElementById('osField').value || 'SemOS').trim().replace(/[\\/:*?"<>|]/g, '_');
      const cliente = (document.getElementById('clienteField').value || 'SemCliente').trim().replace(/[\\/:*?"<>|]/g, '_');
      const tituloDesejado = os + ' Diagnóstico Técnico ' + cliente;
      
      const originalTitle = document.title;
      document.title = tituloDesejado;

      window.print();

      setTimeout(() => {
        document.title = originalTitle;
      }, 1000);
    }

    function aplicarMediaPrintDynamic() {
      let printStyle = document.createElement('style');
      printStyle.id = 'temp-print-styles';
      let rules = '';
      
      for (let i = 0; i < document.styleSheets.length; i++) {
        let sheet = document.styleSheets[i];
        try {
          for (let j = 0; j < sheet.cssRules.length; j++) {
            let rule = sheet.cssRules[j];
            if (rule.conditionText === 'print') {
              for (let k = 0; k < rule.cssRules.length; k++) {
                rules += rule.cssRules[k].cssText + '\n';
              }
            }
          }
        } catch (e) { }
      }
      
      printStyle.innerHTML = rules;
      document.head.appendChild(printStyle);
    }

    function removerMediaPrintDynamic() {
      let el = document.getElementById('temp-print-styles');
      if (el) el.remove();
    }

    // --- EXPORTAR / IMPORTAR JSON ---
    async function exportarJSON() {
      let dadosJSON = {};
      document.querySelectorAll(".save").forEach(el => {
        const id = el.getAttribute('data-id');
        if (!id) return;
        
        if (el.type === 'checkbox') {
            dadosJSON[id] = el.checked;
        } else if (el.tagName === "SELECT" || el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
            dadosJSON[id] = el.value;
        } else {
            dadosJSON[id] = el.innerHTML;
        }
      });

      const os = (document.getElementById('osField') ? document.getElementById('osField').value : 'OS').trim() || 'OS';
      const cliente = (document.getElementById('clienteField') ? document.getElementById('clienteField').value : 'Cliente').trim() || 'Cliente';
      const nomeArquivo = `${os} - Diagnostico - ${cliente}.json`;
      const conteudoJSON = JSON.stringify(dadosJSON, null, 2);

      try {
        // Tenta usar a API moderna do navegador para forçar a janela "Salvar Como"
        if (window.showSaveFilePicker) {
          const handle = await window.showSaveFilePicker({
            suggestedName: nomeArquivo,
            types: [{
              description: 'Arquivo JSON',
              accept: {'application/json': ['.json']},
            }],
          });
          const writable = await handle.createWritable();
          await writable.write(conteudoJSON);
          await writable.close();
        } else {
          // Fallback: Se o navegador não suportar a API moderna (ex: Firefox antigo ou rodando localmente sem HTTPS)
          const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(conteudoJSON);
          const btnDownload = document.createElement('a');
          btnDownload.setAttribute("href", dataStr);
          btnDownload.setAttribute("download", nomeArquivo);
          document.body.appendChild(btnDownload);
          btnDownload.click();
          btnDownload.remove();
        }
      } catch (err) {
        // Ignora o erro se o usuário apenas clicou em "Cancelar" na janela
        if (err.name !== 'AbortError') {
          console.error("Erro ao salvar:", err);
          alert("Não foi possível salvar o arquivo.");
        }
      }
    }

    function importarJSON(event) {
      const file = event.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = function(e) {
        try {
          const dadosJSON = JSON.parse(e.target.result);
          
          document.querySelectorAll(".save").forEach(el => {
            const id = el.getAttribute('data-id');
            if (id && dadosJSON[id] !== undefined) {
              if (el.type === 'checkbox') {
                  el.checked = dadosJSON[id];
              } else if (el.tagName === "SELECT" || el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
                  el.value = dadosJSON[id];
              } else {
                  el.innerHTML = dadosJSON[id];
              }
            }
          });
          
          // Trigger change event to update any dependent logic
          document.querySelectorAll(".save").forEach(el => {
            if (el.tagName === "SELECT") {
                el.dispatchEvent(new Event('change'));
            }
          });
          
          salvar(); // Atualiza o localStorage com os novos dados
          alert('Dados carregados com sucesso!');
        } catch (error) {
          alert('Erro ao ler o arquivo JSON. O arquivo pode estar corrompido.');
          console.error(error);
        }
        
        // Reset the file input so the same file can be imported again if needed
        event.target.value = '';
      };
      reader.readAsText(file);
    }
    
