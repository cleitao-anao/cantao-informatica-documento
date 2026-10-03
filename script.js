// =====================================================================
// DADOS
// =====================================================================

// Opções de cada select (data-opt). A primeira opção de cada lista é o
// "vazio" do campo (Selecione, Modelo, Capacidade, Tipo, Vídeo integrado).
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

  'opt15': ['Selecione', 'Simples', 'Completo'],
  'opt16': ['Selecione', 'Funcionando', 'Com defeito', 'Corrompido', 'Não Inicializa', 'Não Testado', 'Não Se Aplica'],
  'opt17': ['Tipo', 'SSD', 'NVMe', 'HD', 'NGFF(M2)'],
  'opt18': ['Selecione', 'Necessário', 'Realizada', 'Não necessária', 'Não realizada'],

  'opt19': ['Vídeo integrado', 'Com vídeo integrado', 'Sem vídeo integrado']
};

// Valores que indicam problema em selects de display
const valoresDisplayProblema = [
  'sem iluminação', 'oscilando', 'aberta', 'em curto',
  'mau contato', 'rompido', 'tela escura com imagem',
  'sem imagem total', 'listras / artefatos', 'imagem piscando',
  'sem imagem', 'imagem com defeito'
];

// Valores padrão de defeito
const valoresDeDefeito = ['com defeito', 'corrompido', 'não inicializa'];

// Valores pintados de verde
const valoresOk = ['funcionando', 'imagem normal'];

// Índice da célula de cada coluna dentro da linha (0 é o nome do item)
const COLUNAS = [1, 2];
const NOMES_COLUNAS = { 1: 'Técnico', 2: 'Testes' };

// Valor usado pelo botão Vazio no preenchimento rápido
const VALOR_VAZIO = 'Selecione';

let armazenamentoCount = 0;

// Observações dos defeitos (persistidas no localStorage)
let defeitosObs = JSON.parse(localStorage.getItem('defeitosObs') || '{}');


// =====================================================================
// UTILITÁRIOS
// =====================================================================

function nomeDoItem(linha) {
  return linha?.querySelector('td')?.innerText.trim();
}

function linhaVisivel(tr) {
  return tr.style.display !== 'none';
}

// A primeira opção de todo select é o "vazio"
function selectVazio(select) {
  return select.selectedIndex <= 0;
}

function ehValorDeDefeito(valor) {
  const v = valor.toLowerCase();
  return valoresDeDefeito.includes(v) || valoresDisplayProblema.includes(v);
}

function temObs(item) {
  return Boolean(item && defeitosObs[item] && defeitosObs[item].trim() !== '');
}

function escaparHtml(texto) {
  return String(texto)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Data de hoje no formato brasileiro (dd/mm/aaaa)
function dataDeHoje() {
  const hoje = new Date();
  const doisDigitos = n => String(n).padStart(2, '0');
  return `${doisDigitos(hoje.getDate())}/${doisDigitos(hoje.getMonth() + 1)}/${hoje.getFullYear()}`;
}

// Coloca as barras enquanto digita: 03102026 -> 03/10/2026
function mascararData(campo) {
  const digitos = campo.value.replace(/\D/g, '').slice(0, 8);
  campo.value = [digitos.slice(0, 2), digitos.slice(2, 4), digitos.slice(4)].filter(Boolean).join('/');
}

// Confere se dd/mm/aaaa é uma data que existe (ex.: 31/02/2026 não existe)
function dataValida(texto) {
  const partes = texto.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
  if (!partes) return false;
  const [dia, mes, ano] = partes.slice(1).map(Number);
  const data = new Date(ano, mes - 1, dia);
  return data.getFullYear() === ano && data.getMonth() === mes - 1 && data.getDate() === dia;
}

// Mostra o aviso de data inválida (campo vazio não é marcado enquanto se digita)
function conferirData() {
  const campo = document.getElementById('dataField');
  const invalida = campo.value !== '' && !dataValida(campo.value);
  campo.classList.toggle('invalido', invalida);
  document.getElementById('dataErro').hidden = !invalida;
  return !invalida;
}

// Laudo sem data (novo, antigo ou vindo do diagnostico.ps1) recebe a data de hoje.
// Datas salvas no formato antigo (aaaa-mm-dd) são convertidas.
function preencherDataSeVazia() {
  const campo = document.getElementById('dataField');
  const iso = campo.value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (iso) campo.value = `${iso[3]}/${iso[2]}/${iso[1]}`;
  if (!campo.value) campo.value = dataDeHoje();
  salvar();
}

// Remove caracteres que não podem ir em nome de arquivo
function nomeDeArquivoSeguro(texto, padrao) {
  return (texto || '').trim().replace(/[\\/:*?"<>|]/g, '_') || padrao;
}

function injetarOpcoes(raiz) {
  raiz.querySelectorAll('select[data-opt]').forEach(select => {
    const items = optionsData[select.getAttribute('data-opt')];
    if (!items) return;
    select.innerHTML = '';
    items.forEach(item => {
      const option = document.createElement('option');
      option.textContent = item;
      select.appendChild(option);
    });
  });
}


// =====================================================================
// CAMPOS: ler, escrever, salvar e carregar
// =====================================================================

function idDoCampo(el) {
  return el.getAttribute('data-id') || el.id;
}

function ehCampoDeValor(el) {
  return el.tagName === 'SELECT' || el.tagName === 'INPUT' || el.tagName === 'TEXTAREA';
}

function lerCampo(el) {
  if (el.type === 'checkbox') return el.checked;
  if (ehCampoDeValor(el)) return el.value;
  return el.innerHTML;
}

function escreverCampo(el, valor) {
  if (el.type === 'checkbox') {
    el.checked = valor === true || valor === 'true';
  } else if (ehCampoDeValor(el)) {
    el.value = valor || '';
    if (el.tagName === 'SELECT') {
      // Valor salvo que não existe mais no menu volta para a primeira opção
      if (el.selectedIndex === -1) el.selectedIndex = 0;
      el.dataset.anterior = el.value;
    }
  } else {
    el.innerHTML = valor || '';
  }
}

function coletarDados() {
  const dados = {};
  document.querySelectorAll('.save').forEach(el => {
    const id = idDoCampo(el);
    if (id) dados[id] = lerCampo(el);
  });
  dados._armazenamentoCount = armazenamentoCount;
  return dados;
}

// Quantas linhas extras de armazenamento o laudo tem (null = não informado)
function quantidadeDeArmazenamentos(dados) {
  if (dados._armazenamentoCount !== undefined) {
    return parseInt(dados._armazenamentoCount, 10) || 0;
  }
  // JSONs exportados por versões antigas não guardavam a quantidade:
  // deduz pelos campos campo_arm2_*, campo_arm3_*... (a linha N é a extra N - 1)
  const numeros = Object.keys(dados)
    .map(chave => chave.match(/^campo_arm(\d+)_/))
    .filter(Boolean)
    .map(m => parseInt(m[1], 10));
  return numeros.length > 0 ? Math.max(...numeros) - 1 : null;
}

// Usado ao abrir a página (dados do localStorage) e ao importar um JSON
function aplicarDados(dados) {
  const armazenamentos = quantidadeDeArmazenamentos(dados);
  if (armazenamentos !== null) recriarArmazenamentos(armazenamentos);
  document.querySelectorAll('.save').forEach(el => {
    const id = idDoCampo(el);
    if (id && dados[id] !== undefined) escreverCampo(el, dados[id]);
  });
}

function salvar() {
  localStorage.setItem('laudo', JSON.stringify(coletarDados()));
}

function salvarObs() {
  localStorage.setItem('defeitosObs', JSON.stringify(defeitosObs));
}

// Liga o salvamento automático e a atualização da tela em um campo .save
function prepararCampo(el) {
  el.addEventListener('change', salvar);

  if (el.tagName === 'SELECT') {
    prepararSelect(el);
    return;
  }

  el.addEventListener('input', () => {
    salvar();
    atualizarResumo();
  });
}

// Ao tirar um item de "defeito", avisa antes de apagar a observação dele
function prepararSelect(select) {
  select.dataset.anterior = select.value;
  select.addEventListener('focus', () => {
    select.dataset.anterior = select.value;
  });

  select.addEventListener('change', () => {
    const anterior = select.dataset.anterior;
    const novoValor = select.value;
    const item = nomeDoItem(select.closest('tr'));

    if (!(ehValorDeDefeito(anterior) && !ehValorDeDefeito(novoValor) && temObs(item))) {
      select.dataset.anterior = novoValor;
      atualizarResumo();
      return;
    }

    abrirModal(
      'O item "' + item + '" possui uma observação que será apagada. Deseja continuar?',
      (confirmou) => {
        if (confirmou) {
          delete defeitosObs[item];
          salvarObs();
          select.dataset.anterior = novoValor;
          atualizarResumo();
        } else {
          select.value = anterior;
          salvar();
        }
      }
    );
  });
}


// =====================================================================
// ARMAZENAMENTO (linhas extras de SSD/NVMe/HD)
// =====================================================================

function celulaArmazenamento(n, primeiroCampo) {
  return `
        <td>
          <select class="save" data-opt="opt1" data-id="campo_arm${n}_${primeiroCampo}"></select>
          <hr>
          <select class="save" data-opt="opt17" data-id="campo_arm${n}_${primeiroCampo + 1}"></select>
          <hr>
          <input type="text" class="save saude" placeholder="Saúde (%)" data-id="campo_arm${n}_${primeiroCampo + 2}">
        </td>`;
}

function adicionarArmazenamento() {
  const btnRow = document.querySelector('.armazenamento-btn-row');
  if (!btnRow) return;

  armazenamentoCount++;
  const n = armazenamentoCount + 1;

  const linha = document.createElement('tr');
  linha.setAttribute('data-device', 'pc,notebook');
  linha.classList.add('armazenamento-row', 'armazenamento-extra');
  linha.innerHTML = `
        <td>SSD/NVMe/HD (${n})</td>` + celulaArmazenamento(n, 4) + celulaArmazenamento(n, 7);

  btnRow.parentNode.insertBefore(linha, btnRow);
  injetarOpcoes(linha);
  linha.querySelectorAll('.save').forEach(prepararCampo);

  const modoAtual = localStorage.getItem('modo_equipamento') || 'notebook';
  if (!linha.getAttribute('data-device').split(',').includes(modoAtual)) {
    linha.style.display = 'none';
  }

  document.getElementById('btnRemoverArmazenamento').hidden = false;
  atualizarCoresSelects();
}

function removerArmazenamento() {
  const extras = document.querySelectorAll('.armazenamento-extra');
  if (extras.length > 0) {
    extras[extras.length - 1].remove();
    armazenamentoCount--;
  }
  document.getElementById('btnRemoverArmazenamento').hidden = armazenamentoCount === 0;
  atualizarResumo();
}

function recriarArmazenamentos(quantidade) {
  document.querySelectorAll('.armazenamento-extra').forEach(linha => linha.remove());
  armazenamentoCount = 0;
  document.getElementById('btnRemoverArmazenamento').hidden = true;
  for (let i = 0; i < quantidade; i++) {
    adicionarArmazenamento();
  }
}


// =====================================================================
// RESUMO: defeitos encontrados, cores e pendências
// =====================================================================

// Recalcula tudo o que depende dos valores da tabela
function atualizarResumo() {
  capturarDefeitos();
  atualizarCoresSelects();
  verificarPendencias();
}

function obterInfoExtra(item, linha) {
  // Para SSD/NVMe/HD (e os extras "SSD/NVMe/HD (2)", "(3)"...), busca saúde e tipo
  if (item.startsWith('SSD/NVMe/HD')) {
    let saude = '';
    linha.querySelectorAll('.saude').forEach(inp => {
      if (inp.value.trim() !== '') saude = inp.value.trim();
    });
    let tipo = '';
    linha.querySelectorAll('select[data-opt="opt17"]').forEach(sel => {
      if (!selectVazio(sel)) tipo = sel.value;
    });
    let extra = tipo;
    if (saude) extra += (extra ? ' ' : '') + 'com ' + saude + ' de saúde';
    return extra;
  }

  // Para itens de display, mostra os sintomas específicos selecionados
  const sintomas = [];
  linha.querySelectorAll('.display-check').forEach(sel => {
    if (valoresDisplayProblema.includes(sel.value.toLowerCase())) sintomas.push(sel.value);
  });
  return sintomas.join(', ');
}

function capturarDefeitos() {
  const defeitos = []; // { item, extra }
  const itensAdicionados = [];

  document.querySelectorAll('.save').forEach(el => {
    const valor = ehCampoDeValor(el) ? el.value : el.innerText;
    if (!valor) return;

    const linha = el.closest('tr');
    const item = nomeDoItem(linha);
    if (!item || itensAdicionados.includes(item)) return;

    if (ehValorDeDefeito(valor)) {
      itensAdicionados.push(item);
      defeitos.push({ item, extra: obterInfoExtra(item, linha) });
    } else if (item === 'PREVENTIVA' && valor === 'Necessário' && el.tagName === 'SELECT') {
      // Preventiva: quando "Necessário" é selecionado, aparece na área de problemas
      itensAdicionados.push(item);
      defeitos.push({ item, extra: 'Limpeza preventiva necessária' });
    }
  });

  // Remove OBS de itens que não são mais defeito
  Object.keys(defeitosObs).forEach(item => {
    if (!itensAdicionados.includes(item)) delete defeitosObs[item];
  });
  salvarObs();

  renderizarDefeitos(defeitos);
}

function renderizarDefeitos(defeitos) {
  const campo = document.getElementById('DEFEITOENCONTRADOField');
  if (!campo) return;

  // Sem espaços entre as tags: o campo usa white-space: pre-wrap
  campo.innerHTML = defeitos.map(d =>
    '<div class="defeito-card">' +
      `<div class="defeito-texto">Problema encontrado: <strong>${escaparHtml(d.item)}</strong></div>` +
      (d.extra ? `<div class="defeito-extra">${escaparHtml(d.extra)}</div>` : '') +
      '<div class="defeito-obs-row">' +
        '<strong>OBS:</strong>' +
        `<textarea class="defeito-obs-input" data-item="${escaparHtml(d.item)}" placeholder="Adicionar observação..." oninput="atualizarObs(this)">${escaparHtml(defeitosObs[d.item] || '')}</textarea>` +
      '</div>' +
    '</div>'
  ).join('');
}

function atualizarObs(textarea) {
  defeitosObs[textarea.getAttribute('data-item')] = textarea.value;
  salvarObs();
}

// Pinta cada select da tabela conforme o resultado: ok, defeito ou ainda não preenchido
function atualizarCoresSelects() {
  document.querySelectorAll('.table-responsive tbody select').forEach(sel => {
    const v = sel.value.toLowerCase();
    if (selectVazio(sel)) {
      sel.dataset.status = 'vazio';
    } else if (valoresOk.includes(v)) {
      sel.dataset.status = 'ok';
    } else if (ehValorDeDefeito(v)) {
      sel.dataset.status = 'defeito';
    } else {
      delete sel.dataset.status;
    }
  });
}

// Campos referenciados pelos links do aviso de pendências
let camposPendentes = [];

function irParaPendencia(campo) {
  campo.scrollIntoView({ behavior: 'smooth', block: 'center' });
  campo.focus({ preventScroll: true });
  campo.classList.remove('destaque');
  void campo.offsetWidth; // reinicia a animação se clicar de novo
  campo.classList.add('destaque');
  setTimeout(() => campo.classList.remove('destaque'), 1600);
}

// Avisa quando uma coluna foi começada mas ficou com itens sem selecionar
function verificarPendencias() {
  const pendentes = { 1: [], 2: [] };
  const comecada = { 1: false, 2: false };

  document.querySelectorAll('tbody tr').forEach(tr => {
    const tds = tr.querySelectorAll('td');
    // Linhas de item têm uma célula por coluna; seções e campos largos têm menos
    if (!linhaVisivel(tr) || tds.length !== COLUNAS.length + 1) return;

    COLUNAS.forEach(col => {
      const selects = Array.from(tds[col].querySelectorAll('select'));
      if (selects.some(sel => !selectVazio(sel))) comecada[col] = true;
      const primeiroVazio = selects.find(selectVazio);
      if (primeiroVazio) pendentes[col].push({ item: nomeDoItem(tr), campo: primeiroVazio });
    });
  });

  // Cada item pendente vira um link que leva até o campo que falta
  camposPendentes = [];
  const link = ({ item, campo }) => {
    camposPendentes.push(campo);
    return `<button type="button" class="pendencia-link" data-pendencia="${camposPendentes.length - 1}">${escaparHtml(item)}</button>`;
  };

  const msgs = COLUNAS
    .filter(col => comecada[col] && pendentes[col].length > 0)
    .map(col => `<strong><i class="fa-solid fa-triangle-exclamation"></i> Coluna ${NOMES_COLUNAS[col]} incompleta:</strong> Faltou selecionar em: ${pendentes[col].map(link).join(', ')}`);

  const incompleto = msgs.length > 0;
  const avisoDiv = document.getElementById('avisosPendencia');
  avisoDiv.innerHTML = msgs.join('<br><br>');
  avisoDiv.hidden = !incompleto;
  document.getElementById('appBarAviso').hidden = !incompleto;
  document.getElementById('fab').classList.toggle('com-aviso', incompleto);
}


// =====================================================================
// MODO (PC / Notebook / TV) E TEMA
// =====================================================================

function mudarModo(modo) {
  document.querySelectorAll('.app-bar button').forEach(btn => btn.classList.remove('active'));
  document.getElementById('btn-' + modo)?.classList.add('active');

  document.querySelectorAll('tbody tr[data-device]').forEach(tr => {
    tr.style.display = tr.getAttribute('data-device').split(',').includes(modo) ? '' : 'none';
  });

  localStorage.setItem('modo_equipamento', modo);
}

function toggleDarkMode() {
  const escuro = document.getElementById('themeSwitch').checked;
  document.body.classList.toggle('dark-mode', escuro);
  localStorage.setItem('tema_escuro', String(escuro));
}

function aplicarTemaSalvo() {
  const escuro = localStorage.getItem('tema_escuro') === 'true';
  document.body.classList.toggle('dark-mode', escuro);
  document.getElementById('themeSwitch').checked = escuro;
}


// =====================================================================
// PREENCHIMENTO RÁPIDO (Funcionando / Com defeito / Vazio)
// =====================================================================

// Colunas escolhidas em "Preencher": Todos (0), Técnico (1) ou Testes (2)
function colunasEscolhidas() {
  const escolha = parseInt(document.getElementById('colunaSelect').value, 10);
  return escolha === 0 ? COLUNAS : [escolha];
}

function celulasDaColuna(col) {
  return Array.from(document.querySelectorAll('tbody tr'))
    .filter(linhaVisivel)
    .map(tr => tr.querySelectorAll('td')[col])
    .filter(Boolean);
}

function preencherColunaApp(valorProcurado) {
  const colunas = colunasEscolhidas();
  const selectsAfetados = colunas.flatMap(col =>
    celulasDaColuna(col).flatMap(td => Array.from(td.querySelectorAll('select'))));

  // Itens que deixariam de ser defeito e têm observação escrita
  const itensEmRisco = ehValorDeDefeito(valorProcurado) ? [] : [...new Set(
    selectsAfetados
      .filter(sel => ehValorDeDefeito(sel.value))
      .map(sel => nomeDoItem(sel.closest('tr')))
      .filter(temObs)
  )];

  if (itensEmRisco.length === 0) {
    executarPreenchimento(colunas, valorProcurado);
    return;
  }

  abrirModal(
    'Os seguintes itens têm observações que serão apagadas: ' + itensEmRisco.join(', ') + '. Deseja continuar?',
    (confirmou) => {
      if (!confirmou) return;
      itensEmRisco.forEach(item => delete defeitosObs[item]);
      salvarObs();
      executarPreenchimento(colunas, valorProcurado);
    }
  );
}

function executarPreenchimento(colunas, valorProcurado) {
  const limpar = valorProcurado === VALOR_VAZIO;

  // Vazio em "Todos" também limpa os campos largos, que pertencem às duas colunas (Backup, Parecer)
  if (limpar && colunas.length > 1) {
    document.querySelectorAll('tbody td[colspan] textarea').forEach(campo => {
      campo.value = '';
    });
    document.getElementById('PARECERTECNICOField').innerHTML = '';
  }

  colunas.forEach(col => {
    celulasDaColuna(col).forEach(td => {
      if (limpar) {
        limparCelula(td);
      } else {
        preencherCelula(td, valorProcurado);
      }
    });
  });

  atualizarResumo();
  salvar();
}

function preencherCelula(td, valor) {
  td.querySelectorAll('select').forEach(select => {
    const existe = Array.from(select.options).some(opt => opt.value === valor || opt.text === valor);
    if (existe) select.value = valor;
  });
}

// Volta os selects para a primeira opção e limpa os textos da célula (ex.: Saúde %).
// Células largas (Backup, Sintoma Visual...) só têm os selects resetados.
function limparCelula(td) {
  td.querySelectorAll('select').forEach(select => {
    select.selectedIndex = 0;
  });
  if (!td.hasAttribute('colspan')) {
    td.querySelectorAll('input[type="text"], textarea').forEach(campo => {
      campo.value = '';
    });
  }
}


// =====================================================================
// AÇÕES: novo laudo, imprimir, exportar, importar
// =====================================================================

function novoLaudo() {
  abrirModal('Iniciar um novo laudo? Todos os dados preenchidos na tela serão apagados.', (confirmou) => {
    if (confirmou) {
      localStorage.removeItem('laudo');
      localStorage.removeItem('defeitosObs');
      location.reload();
    }
  });
}

function validarObrigatorios() {
  const falta = [];
  if (!document.getElementById('clienteField').value.trim()) falta.push('CLIENTE');
  if (!document.getElementById('equipamentoField').value.trim()) falta.push('EQUIPAMENTO');
  if (!document.getElementById('osField').value.trim()) falta.push('OS');
  if (!document.getElementById('dataField').value.trim()) falta.push('DATA');

  const temTecnico = Array.from(document.querySelectorAll('.input-tecnico')).some(inp => inp.value.trim());
  if (!temTecnico) falta.push('TÉCNICO (pelo menos um nome)');

  if (falta.length > 0) {
    abrirModal('Os seguintes campos são obrigatórios: ' + falta.join(', '));
    return false;
  }
  if (!conferirData()) {
    abrirModal('A data do laudo não existe. Confira o dia e o mês (formato dd/mm/aaaa).');
    return false;
  }
  return true;
}

// Marca o que não deve sair no papel (selects vazios, OBS e nomes em branco)
function prepararImpressao() {
  document.querySelectorAll('select:not(#colunaSelect)').forEach(sel => {
    sel.toggleAttribute('data-print-hide-text', selectVazio(sel));
  });

  document.querySelectorAll('.defeito-obs-input').forEach(inp => {
    inp.closest('.defeito-obs-row').toggleAttribute('data-print-hide', inp.value.trim() === '');
  });

  document.querySelectorAll('.input-tecnico').forEach(inp => {
    inp.toggleAttribute('data-print-hide', inp.value.trim() === '');
  });
}

function imprimir() {
  if (!validarObrigatorios()) return;
  prepararImpressao();

  const os = nomeDeArquivoSeguro(document.getElementById('osField').value, 'SemOS');
  const cliente = nomeDeArquivoSeguro(document.getElementById('clienteField').value, 'SemCliente');

  // O título vira o nome sugerido do PDF
  const tituloOriginal = document.title;
  document.title = os + ' Diagnóstico Técnico ' + cliente;
  window.print();
  setTimeout(() => {
    document.title = tituloOriginal;
  }, 1000);
}

async function exportarJSON() {
  const dadosJSON = coletarDados();
  dadosJSON.defeitosObs = defeitosObs;
  dadosJSON._modo = localStorage.getItem('modo_equipamento') || 'notebook';

  const os = nomeDeArquivoSeguro(document.getElementById('osField').value, 'OS');
  const cliente = nomeDeArquivoSeguro(document.getElementById('clienteField').value, 'Cliente');
  const nomeArquivo = `${os} - Diagnostico - ${cliente}.json`;
  const conteudoJSON = JSON.stringify(dadosJSON, null, 2);

  try {
    // Tenta usar a API moderna do navegador para abrir a janela "Salvar Como"
    if (window.showSaveFilePicker) {
      const handle = await window.showSaveFilePicker({
        suggestedName: nomeArquivo,
        types: [{
          description: 'Arquivo JSON',
          accept: { 'application/json': ['.json'] },
        }],
      });
      const writable = await handle.createWritable();
      await writable.write(conteudoJSON);
      await writable.close();
    } else {
      // Fallback para navegadores sem a API (ex.: Firefox ou arquivo local sem HTTPS)
      const link = document.createElement('a');
      link.href = 'data:text/json;charset=utf-8,' + encodeURIComponent(conteudoJSON);
      link.download = nomeArquivo;
      document.body.appendChild(link);
      link.click();
      link.remove();
    }
  } catch (err) {
    // Ignora o erro se o usuário apenas clicou em "Cancelar" na janela
    if (err.name !== 'AbortError') {
      console.error('Erro ao salvar:', err);
      alert('Não foi possível salvar o arquivo.');
    }
  }
}

function importarJSON(event) {
  const file = event.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = function (e) {
    try {
      const dadosJSON = JSON.parse(e.target.result);

      if (dadosJSON.defeitosObs) {
        defeitosObs = dadosJSON.defeitosObs;
        salvarObs();
      }

      // _modo vem do Exportar ou do diagnostico.ps1
      if (['pc', 'notebook', 'tv'].includes(dadosJSON._modo)) {
        mudarModo(dadosJSON._modo);
      }

      if (dadosJSON.campo_data === undefined) document.getElementById('dataField').value = '';
      aplicarDados(dadosJSON);
      preencherDataSeVazia();
      atualizarResumo();
      salvar();
      alert('Dados carregados com sucesso!');
    } catch (error) {
      alert('Erro ao ler o arquivo JSON. O arquivo pode estar corrompido.');
      console.error(error);
    }

    // Permite importar o mesmo arquivo de novo
    event.target.value = '';
  };
  reader.readAsText(file);
}


// =====================================================================
// MODAL
// =====================================================================

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


// =====================================================================
// MENU FLUTUANTE
// =====================================================================

function alternarFab(abrir) {
  const fab = document.getElementById('fab');
  const aberto = typeof abrir === 'boolean' ? abrir : !fab.classList.contains('aberto');
  fab.classList.toggle('aberto', aberto);
  document.getElementById('fabBotao').setAttribute('aria-expanded', aberto);
}

// Ações que não são de preenchimento fecham o menu antes de rodar
function fabAcao(acao) {
  alternarFab(false);
  acao();
}

// O menu e a app bar compartilham o mesmo #colunaSelect
function escolherColunaFab(col) {
  document.getElementById('colunaSelect').value = col;
  sincronizarColunaFab();
}

function sincronizarColunaFab() {
  const col = document.getElementById('colunaSelect').value;
  document.querySelectorAll('.fab-colunas button').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.col === col);
  });
}

function configurarFab() {
  document.addEventListener('click', e => {
    const fab = document.getElementById('fab');
    if (fab.classList.contains('aberto') && !fab.contains(e.target)) alternarFab(false);
  });

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') alternarFab(false);
  });
}


// =====================================================================
// NAVEGAÇÃO POR TECLADO (Tab, Alt/Ctrl + setas)
// =====================================================================

function camposFocaveis(celula) {
  return Array.from(celula.querySelectorAll('input:not([type="hidden"]), select, textarea'));
}

function configurarNavegacaoTeclado() {
  document.addEventListener('keydown', function (e) {
    const isTab = e.key === 'Tab';
    const isSeta = ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key);

    // Exigir Tab ou (Alt/Ctrl + Seta)
    if (!isTab && !(isSeta && (e.altKey || e.ctrlKey))) return;

    const atual = document.activeElement;
    // Só navegar se estiver focando em algum campo do laudo
    if (!atual || (!atual.classList.contains('save') && !atual.classList.contains('input-tecnico'))) return;

    const td = atual.closest('td');
    const tr = td ? td.closest('tr') : null;
    if (!td || !tr) return;

    const irmaos = camposFocaveis(td);
    const indexNestaCelula = irmaos.indexOf(atual);
    const colIndex = td.cellIndex;
    let alvo = null;

    function pegarFocavel(linha, pegarUltimo) {
      const celula = linha?.cells[colIndex];
      if (!celula) return null;
      const itens = camposFocaveis(celula);
      if (itens.length === 0) return null;
      return pegarUltimo ? itens[itens.length - 1] : itens[0];
    }

    // Ignora linhas invisíveis ou de cabeçalho
    function proximaLinha(linha, direcao) {
      let atualLinha = linha[direcao];
      while (atualLinha && (atualLinha.style.display === 'none' || atualLinha.querySelector('th'))) {
        atualLinha = atualLinha[direcao];
      }
      return atualLinha;
    }

    function campoNaCelulaVizinha(direcao) {
      let vizinha = td[direcao];
      while (vizinha) {
        const itens = camposFocaveis(vizinha);
        if (itens.length > 0) return itens[Math.min(Math.max(indexNestaCelula, 0), itens.length - 1)];
        vizinha = vizinha[direcao];
      }
      return null;
    }

    // Tab normal se comporta igual ArrowDown. Shift+Tab igual ArrowUp
    const indoParaBaixo = (e.key === 'ArrowDown') || (isTab && !e.shiftKey);
    const indoParaCima = (e.key === 'ArrowUp') || (isTab && e.shiftKey);

    if (indoParaBaixo) {
      // Desce pro próximo item na MESMA célula (ex: combos do SSD) ou pra próxima linha
      alvo = (indexNestaCelula >= 0 && indexNestaCelula < irmaos.length - 1)
        ? irmaos[indexNestaCelula + 1]
        : pegarFocavel(proximaLinha(tr, 'nextElementSibling'), false);
    } else if (indoParaCima) {
      alvo = indexNestaCelula > 0
        ? irmaos[indexNestaCelula - 1]
        : pegarFocavel(proximaLinha(tr, 'previousElementSibling'), true);
    } else if (e.key === 'ArrowRight') {
      alvo = campoNaCelulaVizinha('nextElementSibling');
    } else if (e.key === 'ArrowLeft') {
      alvo = campoNaCelulaVizinha('previousElementSibling');
    }

    // Se achou um alvo, foca nele e previne o comportamento padrão do navegador
    if (alvo) {
      e.preventDefault();
      alvo.focus();
      if (alvo.tagName === 'INPUT' && typeof alvo.select === 'function') {
        alvo.select();
      }
    }
  });
}


// =====================================================================
// INICIALIZAÇÃO
// =====================================================================

window.addEventListener('load', () => {
  injetarOpcoes(document);
  // A máscara roda antes do salvamento automático do campo
  const campoData = document.getElementById('dataField');
  campoData.addEventListener('input', () => {
    mascararData(campoData);
    // Enquanto digita, só some com o aviso; ele volta ao sair do campo se continuar errado
    if (dataValida(campoData.value)) conferirData();
  });
  campoData.addEventListener('blur', conferirData);
  document.querySelectorAll('.save').forEach(prepararCampo);
  configurarNavegacaoTeclado();
  configurarFab();
  sincronizarColunaFab();

  mudarModo(localStorage.getItem('modo_equipamento') || 'notebook');
  aplicarTemaSalvo();

  const dados = JSON.parse(localStorage.getItem('laudo'));
  if (dados) aplicarDados(dados);
  preencherDataSeVazia();

  document.getElementById('avisosPendencia').addEventListener('click', e => {
    const link = e.target.closest('.pendencia-link');
    if (link) irParaPendencia(camposPendentes[link.dataset.pendencia]);
  });

  atualizarResumo();
});
