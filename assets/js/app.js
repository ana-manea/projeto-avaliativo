/**
 * SISTEMA AVALIA - JavaScript Principal MVC
 */
(function () {
    'use strict';

    function qs(selector, scope) { return (scope || document).querySelector(selector); }
    function qsa(selector, scope) { return Array.from((scope || document).querySelectorAll(selector)); }

    var temaSalvo = localStorage.getItem('avalia_tema') || localStorage.getItem('avalia_tema_preview');
    if (temaSalvo) document.documentElement.setAttribute('data-tema', temaSalvo);

    window.toggleDropdown = function (id) {
        var dropdown = document.getElementById(id);
        if (dropdown) {
            dropdown.classList.toggle('active');
            dropdown.classList.toggle('open');
        }
    };

    window.alterarTema = function (tema) {
        document.documentElement.setAttribute('data-tema', tema);
        localStorage.setItem('avalia_tema', tema);
        localStorage.setItem('avalia_tema_preview', tema);

        qsa('.tema-btn').forEach(function (btn) { btn.classList.remove('active'); });
        var btnAtivo = qs('.tema-btn-' + tema);
        if (btnAtivo) btnAtivo.classList.add('active');

        var formData = new FormData();
        formData.append('alterar_tema', '1');
        formData.append('tema', tema);

        fetch(window.location.href, {
            method: 'POST',
            body: formData,
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }).catch(function () {});
    };

    function initDropdowns(scope) {
        qsa('[data-dropdown]', scope).forEach(function (dropdown) {
            var toggle = qs('[data-dropdown-toggle]', dropdown);
            if (!toggle || toggle.dataset.dropdownBound === '1') return;
            toggle.dataset.dropdownBound = '1';
            toggle.addEventListener('click', function (event) {
                event.stopPropagation();
                qsa('[data-dropdown].open, [data-dropdown].active').forEach(function (item) {
                    if (item !== dropdown) {
                        item.classList.remove('open', 'active');
                        var itemToggle = qs('[data-dropdown-toggle]', item);
                        if (itemToggle) itemToggle.setAttribute('aria-expanded', 'false');
                    }
                });
                var isOpen = !dropdown.classList.contains('open');
                dropdown.classList.toggle('open', isOpen);
                dropdown.classList.toggle('active', isOpen);
                toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            });
        });
    }

    document.addEventListener('click', function () {
        qsa('[data-dropdown].open, [data-dropdown].active').forEach(function (dropdown) {
            dropdown.classList.remove('open', 'active');
            var toggle = qs('[data-dropdown-toggle]', dropdown);
            if (toggle) toggle.setAttribute('aria-expanded', 'false');
        });
    });

    function getModal() { return qs('#app-modal'); }

    window.openModal = function (modalId) {
        var modal = modalId ? document.getElementById(modalId) : getModal();
        if (!modal) return;
        modal.classList.add('active', 'open');
        modal.setAttribute('aria-hidden', 'false');
        document.body.classList.add('modal-open');
    };

    window.closeModal = function (modalId) {
        var modal = modalId ? document.getElementById(modalId) : getModal();
        if (!modal) return;
        modal.classList.remove('active', 'open');
        modal.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('modal-open');
        if (modal.id === 'app-modal') {
            var body = qs('#app-modal-body');
            var title = qs('#app-modal-title');
            if (body) body.innerHTML = '';
            if (title) title.textContent = '';
        }
    };

    async function openRemoteModal(button) {
        var url = button.getAttribute('data-modal-url');
        if (!url) return;
        var modal = getModal();
        var body = qs('#app-modal-body');
        var title = qs('#app-modal-title');
        var dialog = qs('#app-modal .modal');
        if (!modal || !body || !title) {
            window.location.href = url;
            return;
        }
        title.textContent = button.getAttribute('data-modal-title') || button.textContent.trim();
        body.innerHTML = '<div class="loading"><div class="loading-spinner"></div><p class="loading-text">Carregando...</p></div>';
        if (dialog) dialog.classList.toggle('modal-lg', button.getAttribute('data-modal-size') === 'lg');
        window.openModal('app-modal');
        try {
            var response = await fetch(url, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                credentials: 'same-origin'
            });
            if (!response.ok) throw new Error('HTTP ' + response.status);
            body.innerHTML = await response.text();
            initFormEnhancements(body);
            initAvaliacaoCriar(body);
            var firstField = qs('input, select, textarea, button', body);
            if (firstField) setTimeout(function () { firstField.focus(); }, 50);
        } catch (error) {
            body.innerHTML = '<div class="alert alert-error">Não foi possível carregar o formulário. <a href="' + url + '">Abrir página</a></div>';
        }
    }

    function initRemoteModals() {
        document.addEventListener('click', function (event) {
            var button = event.target.closest('[data-modal-url]');
            if (!button) return;
            event.preventDefault();
            openRemoteModal(button);
        });
        document.addEventListener('click', function (event) {
            if (event.target.matches('[data-modal-close]') || event.target.classList.contains('modal-overlay')) {
                window.closeModal(event.target.closest('.modal-overlay')?.id || 'app-modal');
            }
        });
    }

    function initFormEnhancements(scope) {
        scope = scope || document;
        qsa('input[maxlength="1"]', scope).forEach(function (input) {
            if (input.dataset.upperBound === '1') return;
            input.dataset.upperBound = '1';
            input.addEventListener('input', function () { input.value = input.value.toUpperCase(); });
        });
        qsa('form[data-confirm]', scope).forEach(function (form) {
            if (form.dataset.confirmBound === '1') return;
            form.dataset.confirmBound = '1';
            form.addEventListener('submit', function (event) {
                var message = form.dataset.confirm || 'Confirmar ação?';
                if (!confirm(message)) event.preventDefault();
            });
        });
        qsa('[data-modal-cancel]', scope).forEach(function (btn) {
            if (btn.dataset.cancelBound === '1') return;
            btn.dataset.cancelBound = '1';
            btn.addEventListener('click', function (event) {
                event.preventDefault();
                window.closeModal('app-modal');
            });
        });
    }

    // ===== Wizard genérico =====
    window.currentStep = 1;
    window.totalSteps = 3;
    window.initWizard = function (steps) {
        window.totalSteps = steps || 3;
        window.currentStep = 1;
        updateWizardUI(document);
    };
    window.nextStep = function () {
        if (window.currentStep < window.totalSteps && validateCurrentStep(document)) {
            window.currentStep++;
            updateWizardUI(document);
        }
    };
    window.prevStep = function () {
        if (window.currentStep > 1) {
            window.currentStep--;
            updateWizardUI(document);
        }
    };
    function updateWizardUI(scope) {
        scope = scope || document;
        qsa('.wizard-step', scope).forEach(function (el, index) {
            el.classList.remove('active', 'completed');
            if (index + 1 === window.currentStep) el.classList.add('active');
            else if (index + 1 < window.currentStep) el.classList.add('completed');
        });
        qsa('.step-content', scope).forEach(function (el, index) {
            el.style.display = (index + 1 === window.currentStep) ? 'block' : 'none';
        });
        var prevBtn = qs('.btn-prev', scope);
        var nextBtn = qs('.btn-next', scope);
        var submitBtn = qs('.btn-submit', scope);
        if (prevBtn) prevBtn.style.display = window.currentStep > 1 ? 'inline-flex' : 'none';
        if (nextBtn && submitBtn) {
            nextBtn.style.display = window.currentStep < window.totalSteps ? 'inline-flex' : 'none';
            submitBtn.style.display = window.currentStep === window.totalSteps ? 'inline-flex' : 'none';
        }
    }
    function validateCurrentStep(scope) {
        scope = scope || document;
        var contents = qsa('.step-content', scope);
        var currentContent = contents[window.currentStep - 1];
        if (!currentContent) return true;
        var valid = true;
        qsa('[required]', currentContent).forEach(function (field) {
            if (!String(field.value || '').trim()) {
                field.classList.add('error', 'campo-obrigatorio-vazio');
                valid = false;
            } else {
                field.classList.remove('error', 'campo-obrigatorio-vazio');
            }
        });
        return valid;
    }

    window.filterAvaliacoes = function (filtro) {
        qsa('.filter-btn').forEach(function (btn) { btn.classList.remove('active'); });
        if (window.event && window.event.target) window.event.target.classList.add('active');
        qsa('.avaliacoes-section').forEach(function (section) {
            var status = section.dataset.status;
            section.style.display = (filtro === 'todas' || status === filtro) ? 'block' : 'none';
        });
    };

    // ===== Criação de Avaliação =====
    var letrasGlobais = ['A', 'B', 'C', 'D', 'E'];
    var dragSrcQuestaoItem = null;
    var dragSrcRow = null;
    var dragSrcQuestao = null;

    window.addQuestao = function () {
        var form = qs('#formAvaliacao');
        var container = qs('#questoesContainer');
        if (!container) return;
        var count = parseInt(container.dataset.questaoCount || '0', 10) + 1;
        container.dataset.questaoCount = String(count);
        var numAlternativas = parseInt(qs('#numAlternativasSelect')?.value || '5', 10);
        var div = document.createElement('div');
        div.className = 'questao-item';
        div.id = 'questao-item-' + count;
        div.dataset.questaoNum = String(count);
        div.draggable = true;
        div.addEventListener('dragstart', onQuestaoDragStart);
        div.addEventListener('dragover', onQuestaoDragOver);
        div.addEventListener('drop', onQuestaoDrop);
        div.addEventListener('dragend', onQuestaoDragEnd);
        div.innerHTML = buildQuestaoHTML(count, numAlternativas);
        container.appendChild(div);
        distribuirPontosIguais(form || document);
    };

    window.removeQuestao = function (num) {
        var el = qs('#questao-item-' + num) || qs('#questao-' + num);
        if (el) el.remove();
        renumerarQuestoes();
    };

    function buildAltRow(questaoNum, letra, index) {
        return '' +
            '<div class="alt-row" draggable="true" data-questao="' + questaoNum + '" data-index="' + index + '">' +
                '<span class="drag-handle" title="Arrastar para reordenar">&#x2807;</span>' +
                '<span class="alt-letra-badge">' + letra + '</span>' +
                '<input type="text" class="form-control alt-input" placeholder="Alternativa ' + letra + '" data-validar-alternativa>' +
                '<input type="radio" class="alt-radio" name="questoes[' + questaoNum + '][correta_idx]" value="' + index + '" title="Marcar como correta">' +
            '</div>';
    }

    function buildQuestaoHTML(num, numAlternativas) {
        var altsHTML = '';
        for (var i = 0; i < numAlternativas; i++) altsHTML += buildAltRow(num, letrasGlobais[i], i);
        return '' +
            '<div class="questao-header-row">' +
                '<span class="questao-drag-handle" title="Arrastar para reordenar">&#x2807;</span>' +
                '<span class="questao-num-badge">' + num + '</span>' +
                '<input type="text" name="questoes[' + num + '][titulo]" class="form-control questao-titulo-input" placeholder="Título da questão (opcional)">' +
                '<select name="questoes[' + num + '][tipo]" class="form-control questao-tipo-select" data-toggle-tipo-questao="' + num + '">' +
                    '<option value="multipla_escolha">Múltipla Escolha</option>' +
                    '<option value="dissertativa">Dissertativa</option>' +
                '</select>' +
                '<input type="number" name="questoes[' + num + '][pontos]" id="pontos-' + num + '" class="form-control pontos-input" placeholder="Pts" step="0.01" min="0" data-pontos-input="' + num + '">' +
                '<button type="button" class="btn btn-sm btn-danger" data-remove-questao="' + num + '">X</button>' +
            '</div>' +
            '<div class="form-group">' +
                '<textarea name="questoes[' + num + '][enunciado]" class="form-control enunciado-input" rows="2" placeholder="Enunciado da questão *" required data-validar-campo></textarea>' +
                '<span class="aviso-campo">Campo obrigatório</span>' +
            '</div>' +
            '<div class="alternativas-wrapper" id="alts-' + num + '" data-questao="' + num + '">' + altsHTML + '</div>' +
            '<div class="form-group gabarito-wrapper" id="gabarito-dissertativa-' + num + '" style="display:none;">' +
                '<p class="text-muted" style="font-size:0.82rem;margin:0;">📝 Questão dissertativa — o professor corrigirá manualmente após a avaliação.</p>' +
            '</div>';
    }

    function onQuestaoDragStart(e) {
        if (!e.target.closest('.questao-drag-handle')) { e.preventDefault(); return; }
        dragSrcQuestaoItem = e.currentTarget;
        e.dataTransfer.effectAllowed = 'move';
        setTimeout(function () { if (dragSrcQuestaoItem) dragSrcQuestaoItem.style.opacity = '0.4'; }, 0);
    }
    function onQuestaoDragOver(e) {
        if (!dragSrcQuestaoItem) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        if (e.currentTarget !== dragSrcQuestaoItem) e.currentTarget.classList.add('drag-over');
    }
    function onQuestaoDragEnd() {
        if (dragSrcQuestaoItem) dragSrcQuestaoItem.style.opacity = '1';
        qsa('.questao-item').forEach(function (el) { el.classList.remove('drag-over'); });
        dragSrcQuestaoItem = null;
    }
    function onQuestaoDrop(e) {
        e.preventDefault();
        e.stopPropagation();
        var targetItem = e.currentTarget;
        if (!dragSrcQuestaoItem || dragSrcQuestaoItem === targetItem) return;
        var container = qs('#questoesContainer');
        var items = qsa('.questao-item', container);
        var srcIdx = items.indexOf(dragSrcQuestaoItem);
        var tgtIdx = items.indexOf(targetItem);
        if (srcIdx < tgtIdx) container.insertBefore(dragSrcQuestaoItem, targetItem.nextSibling);
        else container.insertBefore(dragSrcQuestaoItem, targetItem);
        renumerarQuestoes();
    }
    function renumerarQuestoes() {
        qsa('.questao-item').forEach(function (item, i) {
            var badge = qs('.questao-num-badge', item);
            if (badge) badge.textContent = i + 1;
        });
        distribuirPontosIguais(qs('#formAvaliacao') || document);
    }

    function onAltDragStart(e) {
        dragSrcRow = e.currentTarget;
        dragSrcQuestao = dragSrcRow.dataset.questao;
        e.dataTransfer.effectAllowed = 'move';
        setTimeout(function () { if (dragSrcRow) dragSrcRow.style.opacity = '0.4'; }, 0);
    }
    function onAltDragOver(e) {
        e.preventDefault();
        var row = e.currentTarget;
        if (row !== dragSrcRow && row.dataset.questao === dragSrcQuestao) row.classList.add('drag-over');
    }
    function onAltDragEnd() {
        if (dragSrcRow) dragSrcRow.style.opacity = '1';
        qsa('.alt-row').forEach(function (r) { r.classList.remove('drag-over'); });
        dragSrcRow = null;
        dragSrcQuestao = null;
    }
    function onAltDrop(e) {
        e.preventDefault();
        e.stopPropagation();
        var targetRow = e.currentTarget;
        if (!dragSrcRow || dragSrcRow === targetRow || dragSrcRow.dataset.questao !== targetRow.dataset.questao) return;
        var questaoNum = targetRow.dataset.questao;
        var wrapper = qs('#alts-' + questaoNum);
        var rows = qsa('.alt-row', wrapper);
        var checkedRow = qs('.alt-radio:checked', wrapper)?.closest('.alt-row') || null;
        var srcIdx = rows.indexOf(dragSrcRow);
        var tgtIdx = rows.indexOf(targetRow);
        if (srcIdx < tgtIdx) wrapper.insertBefore(dragSrcRow, targetRow.nextSibling);
        else wrapper.insertBefore(dragSrcRow, targetRow);
        relabelAlternativas(questaoNum, checkedRow);
    }
    function relabelAlternativas(questaoNum, checkedRow) {
        var wrapper = qs('#alts-' + questaoNum);
        qsa('.alt-row', wrapper).forEach(function (row, i) {
            var letra = letrasGlobais[i];
            row.dataset.index = String(i);
            var badge = qs('.alt-letra-badge', row);
            if (badge) badge.textContent = letra;
            var input = qs('.alt-input', row);
            if (input) input.placeholder = 'Alternativa ' + letra;
            var radio = qs('.alt-radio', row);
            if (radio) {
                radio.value = String(i);
                radio.checked = checkedRow === row;
            }
        });
    }

    function toggleTipoQuestao(select, num) {
        var altsWrapper = qs('#alts-' + num);
        var gabDissert = qs('#gabarito-dissertativa-' + num);
        if (!altsWrapper || !gabDissert) return;
        if (select.value === 'dissertativa') {
            altsWrapper.style.display = 'none';
            gabDissert.style.display = 'block';
        } else {
            altsWrapper.style.display = 'block';
            gabDissert.style.display = 'none';
        }
    }
    function validarCampo(input) {
        if (!String(input.value || '').trim()) input.classList.add('campo-obrigatorio-vazio');
        else input.classList.remove('campo-obrigatorio-vazio');
    }
    function getPontosInputs(scope) { return qsa('.pontos-input', scope || document); }
    function distribuirPontosIguais(scope) {
        var inputs = getPontosInputs(scope);
        if (!inputs.length) return;
        var val = Math.round((10 / inputs.length) * 100) / 100;
        var soma = 0;
        inputs.forEach(function (inp, i) {
            if (i < inputs.length - 1) { inp.value = String(val); soma += val; }
            else inp.value = String(Math.round((10 - soma) * 100) / 100);
        });
        atualizarSomaPontos(scope);
    }
    function redistribuirPontos(numAlterado, scope) {
        var inputs = getPontosInputs(scope);
        if (inputs.length < 2) { atualizarSomaPontos(scope); return; }
        var inputAlterado = qs('#pontos-' + numAlterado, scope || document);
        if (!inputAlterado) return;
        var valorAlterado = parseFloat(inputAlterado.value) || 0;
        var valorClamped = Math.min(10, Math.max(0, valorAlterado));
        if (valorAlterado !== valorClamped) inputAlterado.value = String(valorClamped);
        var restante = Math.round((10 - valorClamped) * 100) / 100;
        var outros = inputs.filter(function (inp) { return inp !== inputAlterado; });
        var valOther = Math.round((restante / outros.length) * 100) / 100;
        var somaOutros = 0;
        outros.forEach(function (inp, i) {
            if (i < outros.length - 1) { inp.value = String(valOther); somaOutros += valOther; }
            else inp.value = String(Math.round((restante - somaOutros) * 100) / 100);
        });
        atualizarSomaPontos(scope);
    }
    function atualizarSomaPontos(scope) {
        var inputs = getPontosInputs(scope);
        var soma = inputs.reduce(function (acc, inp) { return acc + (parseFloat(inp.value) || 0); }, 0);
        var el = qs('#soma-pontos', scope || document);
        if (el) {
            var arred = Math.round(soma * 100) / 100;
            el.textContent = 'Soma: ' + arred + ' / 10';
            el.style.color = Math.abs(soma - 10) < 0.01 ? '#059669' : '#dc2626';
        }
    }

    function serializarQuestoes(form) {
        var invalido = false;
        form.querySelectorAll('input[data-serial]').forEach(function (el) { el.remove(); });
        var questaoItems = qsa('.questao-item', form);
        questaoItems.forEach(function (item, qIdx) {
            var qNum = qIdx + 1;
            function hidden(name, value) {
                var h = document.createElement('input');
                h.type = 'hidden'; h.dataset.serial = '1'; h.name = name; h.value = value || '';
                form.appendChild(h);
            }
            var enunciado = qs('.enunciado-input', item);
            if (enunciado) {
                if (!enunciado.value.trim()) { enunciado.classList.add('campo-obrigatorio-vazio'); invalido = true; }
                hidden('questoes[' + qNum + '][enunciado]', enunciado.value);
            }
            var titulo = qs('.questao-titulo-input', item);
            if (titulo) hidden('questoes[' + qNum + '][titulo]', titulo.value);
            var tipo = qs('.questao-tipo-select', item);
            if (tipo) hidden('questoes[' + qNum + '][tipo]', tipo.value);
            var pontos = qs('.pontos-input', item);
            if (pontos) hidden('questoes[' + qNum + '][pontos]', pontos.value);
            var wrapper = qs('.alternativas-wrapper', item);
            if (wrapper && wrapper.style.display !== 'none') {
                var checkedIdx = null;
                qsa('.alt-row', wrapper).forEach(function (row, aIdx) {
                    var input = qs('.alt-input', row);
                    var radio = qs('.alt-radio', row);
                    if (input) {
                        if (!input.value.trim()) { input.classList.add('campo-obrigatorio-vazio'); invalido = true; }
                        hidden('questoes[' + qNum + '][alternativas][' + aIdx + ']', input.value);
                    }
                    if (radio && radio.checked) checkedIdx = aIdx;
                });
                if (checkedIdx !== null) hidden('questoes[' + qNum + '][correta_idx]', String(checkedIdx));
            }
        });
        return !invalido;
    }

    function initAvaliacaoCriar(scope) {
        scope = scope || document;
        var form = qs('#formAvaliacao', scope);
        if (!form || form.dataset.boundAvaliacao === '1') return;
        form.dataset.boundAvaliacao = '1';
        window.currentStep = 1;
        window.totalSteps = 3;
        updateWizardUI(scope);

        var altSelect = qs('#numAlternativasSelect', form);
        if (altSelect) altSelect.addEventListener('change', function () {});

        function atualizarProfessorObrigatorio() {
            var semProfessor = qs('[data-sem-professor]', form);
            var professorSelect = qs('[data-professor-select]', form);
            if (!semProfessor || !professorSelect) return;
            if (semProfessor.checked) {
                professorSelect.value = '';
                professorSelect.disabled = true;
                professorSelect.required = false;
                professorSelect.classList.remove('campo-obrigatorio-vazio');
            } else {
                professorSelect.disabled = false;
                professorSelect.required = true;
            }
        }
        atualizarProfessorObrigatorio();

        qsa('.btn-next', form).forEach(function (btn) {
            btn.addEventListener('click', function () {
                if (window.currentStep === 1) {
                    var ok = true;
                    ['titulo', 'turma_id', 'disciplina_id', 'data_aplicacao'].forEach(function (id) {
                        var el = qs('#' + id, form);
                        if (el && !String(el.value || '').trim()) { el.classList.add('campo-obrigatorio-vazio'); ok = false; }
                        else if (el) el.classList.remove('campo-obrigatorio-vazio');
                    });
                    var professorSelect = qs('[data-professor-select]', form);
                    var semProfessor = qs('[data-sem-professor]', form);
                    if (professorSelect && !(semProfessor && semProfessor.checked) && !String(professorSelect.value || '').trim()) {
                        professorSelect.classList.add('campo-obrigatorio-vazio');
                        ok = false;
                    } else if (professorSelect) {
                        professorSelect.classList.remove('campo-obrigatorio-vazio');
                    }
                    var dataEl = qs('#data_aplicacao', form);
                    if (dataEl && dataEl.value) {
                        var hoje = new Date(); hoje.setHours(0,0,0,0);
                        var dataSel = new Date(dataEl.value + 'T00:00:00');
                        if (dataSel < hoje) { dataEl.classList.add('campo-obrigatorio-vazio'); ok = false; }
                        else dataEl.classList.remove('campo-obrigatorio-vazio');
                    }
                    if (!ok) { alert('Preencha os campos obrigatórios corretamente.'); return; }
                }
                if (window.currentStep === 2) {
                    var nq = parseInt(qs('#numQuestoes', form)?.value || '0', 10);
                    if (nq < 1) { alert('Informe o número de questões.'); return; }
                    var container = qs('#questoesContainer', form);
                    if (container) { container.innerHTML = ''; container.dataset.questaoCount = '0'; }
                    for (var i = 0; i < nq; i++) window.addQuestao();
                    distribuirPontosIguais(form);
                }
                if (window.currentStep < window.totalSteps) {
                    window.currentStep++;
                    updateWizardUI(scope);
                }
            });
        });
        qsa('.btn-prev', form).forEach(function (btn) {
            btn.addEventListener('click', function () {
                if (window.currentStep > 1) { window.currentStep--; updateWizardUI(scope); }
            });
        });
        form.addEventListener('click', function (event) {
            var add = event.target.closest('[data-add-questao]');
            if (add) { event.preventDefault(); window.addQuestao(); return; }
            var rem = event.target.closest('[data-remove-questao]');
            if (rem) { event.preventDefault(); window.removeQuestao(rem.dataset.removeQuestao); return; }
            var skip = event.target.closest('[data-skip-questoes]');
            if (skip) {
                event.preventDefault();
                if (confirm('Deseja pular a definição das questões? Você poderá adicioná-las depois.')) {
                    var cont = qs('#questoesContainer', form);
                    if (cont) cont.innerHTML = '';
                    var h = document.createElement('input'); h.type = 'hidden'; h.name = 'skip_questoes'; h.value = '1';
                    form.appendChild(h);
                    form.submit();
                }
            }
        });
        form.addEventListener('change', function (event) {
            if (event.target.closest('[data-sem-professor]')) atualizarProfessorObrigatorio();
            var tipo = event.target.closest('[data-toggle-tipo-questao]');
            if (tipo) toggleTipoQuestao(tipo, tipo.dataset.toggleTipoQuestao);
        });
        form.addEventListener('input', function (event) {
            var pontos = event.target.closest('[data-pontos-input]');
            if (pontos) { redistribuirPontos(pontos.dataset.pontosInput, form); return; }
            if (event.target.matches('[data-validar-campo], [data-validar-alternativa]')) validarCampo(event.target);
        });
        form.addEventListener('dragstart', function (event) {
            var row = event.target.closest('.alt-row');
            if (row) onAltDragStart(event);
        });
        form.addEventListener('dragover', function (event) {
            var row = event.target.closest('.alt-row');
            if (row) onAltDragOver(event);
        });
        form.addEventListener('drop', function (event) {
            var row = event.target.closest('.alt-row');
            if (row) onAltDrop(event);
        });
        form.addEventListener('dragend', function (event) {
            if (event.target.closest('.alt-row')) onAltDragEnd(event);
        });
        form.addEventListener('submit', function (event) {
            atualizarProfessorObrigatorio();
            var dataEl = qs('#data_aplicacao', form);
            var professorSelect = qs('[data-professor-select]', form);
            var semProfessor = qs('[data-sem-professor]', form);
            if (dataEl && !String(dataEl.value || '').trim()) {
                event.preventDefault();
                dataEl.classList.add('campo-obrigatorio-vazio');
                alert('Informe a data da prova.');
                return;
            }
            if (professorSelect && !(semProfessor && semProfessor.checked) && !String(professorSelect.value || '').trim()) {
                event.preventDefault();
                professorSelect.classList.add('campo-obrigatorio-vazio');
                alert('Selecione um professor ou marque a opção sem professor.');
                return;
            }
            var ok = serializarQuestoes(form);
            if (!ok) {
                event.preventDefault();
                var primeiro = qs('.campo-obrigatorio-vazio', form);
                if (primeiro) primeiro.scrollIntoView({ behavior: 'smooth', block: 'center' });
                alert('Preencha todos os campos obrigatórios das questões.');
            }
        });
    }

    window.initAvaliacaoCriar = initAvaliacaoCriar;

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            window.closeModal('app-modal');
            qsa('[data-dropdown].open, [data-dropdown].active').forEach(function (dropdown) { dropdown.classList.remove('open', 'active'); });
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        initDropdowns(document);
        initRemoteModals();
        initFormEnhancements(document);
        initAvaliacaoCriar(document);
    });
})();

// ===== Login: feedback visual enquanto valida o usuário =====
document.addEventListener('DOMContentLoaded', function () {
    var loginForm = document.querySelector('[data-login-form]');
    if (!loginForm || loginForm.dataset.loaderBound === '1') return;
    loginForm.dataset.loaderBound = '1';
    loginForm.addEventListener('submit', function () {
        var page = document.querySelector('.login-page');
        var text = document.querySelector('#loginStatusText');
        var btn = document.querySelector('[data-login-submit]');
        if (page) page.classList.add('validating');
        if (text) text.textContent = 'Validando usuário...';
        if (btn) btn.setAttribute('disabled', 'disabled');
    });
});

// ===== Preview de impressão da prova/gabarito em pop-up =====
(function () {
    function ensurePrintModal() {
        var modal = document.getElementById('print-preview-modal');
        if (modal) return modal;

        modal = document.createElement('div');
        modal.id = 'print-preview-modal';
        modal.className = 'modal-overlay print-preview-overlay';
        modal.setAttribute('aria-hidden', 'true');
        modal.innerHTML = '' +
            '<div class="modal print-preview-modal" role="dialog" aria-modal="true">' +
                '<div class="modal-header print-preview-header">' +
                    '<div>' +
                        '<h2 class="modal-title" id="print-preview-title">Preview de impressão</h2>' +
                        '<p class="text-muted print-preview-subtitle">Confira o layout antes de imprimir ou salvar em PDF.</p>' +
                    '</div>' +
                    '<button type="button" class="modal-close" data-print-close aria-label="Fechar">&times;</button>' +
                '</div>' +
                '<div class="print-preview-toolbar">' +
                    '<button type="button" class="btn btn-secondary btn-sm active" data-print-kind="prova">Prova</button>' +
                    '<button type="button" class="btn btn-secondary btn-sm" data-print-kind="gabarito">Gabarito separado</button>' +
                    '<button type="button" class="btn btn-primary btn-sm" data-print-action="print">Imprimir / Salvar PDF</button>' +
                '</div>' +
                '<div class="print-preview-frame-wrap">' +
                    '<iframe class="print-preview-frame" title="Preview da prova"></iframe>' +
                '</div>' +
            '</div>';
        document.body.appendChild(modal);
        return modal;
    }

    function buildPreviewUrl(baseUrl, tipo) {
        var sep = baseUrl.indexOf('?') >= 0 ? '&' : '?';
        return baseUrl + sep + 'preview=1&tipo=' + encodeURIComponent(tipo || 'prova');
    }

    function setActiveKind(modal, kind) {
        modal.querySelectorAll('[data-print-kind]').forEach(function (btn) {
            btn.classList.toggle('active', btn.getAttribute('data-print-kind') === kind);
        });
    }

    function loadPreview(modal, baseUrl, kind) {
        var iframe = modal.querySelector('.print-preview-frame');
        if (!iframe) return;
        iframe.src = buildPreviewUrl(baseUrl, kind);
        setActiveKind(modal, kind);
        modal.dataset.printKind = kind;
        modal.dataset.printBaseUrl = baseUrl;
    }

    document.addEventListener('click', function (event) {
        var trigger = event.target.closest('[data-print-preview-url]');
        if (trigger) {
            event.preventDefault();
            var modal = ensurePrintModal();
            var title = modal.querySelector('#print-preview-title');
            if (title) title.textContent = 'Preview: ' + (trigger.getAttribute('data-print-title') || 'Avaliação');
            modal.classList.add('active', 'open');
            modal.setAttribute('aria-hidden', 'false');
            document.body.classList.add('modal-open');
            loadPreview(modal, trigger.getAttribute('data-print-preview-url'), 'prova');
            return;
        }

        var close = event.target.closest('[data-print-close]');
        if (close || event.target.id === 'print-preview-modal') {
            var current = document.getElementById('print-preview-modal');
            if (current) {
                current.classList.remove('active', 'open');
                current.setAttribute('aria-hidden', 'true');
                var iframe = current.querySelector('.print-preview-frame');
                if (iframe) iframe.removeAttribute('src');
                document.body.classList.remove('modal-open');
            }
            return;
        }

        var kindBtn = event.target.closest('[data-print-kind]');
        if (kindBtn) {
            var modalKind = document.getElementById('print-preview-modal');
            if (modalKind && modalKind.dataset.printBaseUrl) {
                loadPreview(modalKind, modalKind.dataset.printBaseUrl, kindBtn.getAttribute('data-print-kind'));
            }
            return;
        }

        var printBtn = event.target.closest('[data-print-action="print"]');
        if (printBtn) {
            var modalPrint = document.getElementById('print-preview-modal');
            var frame = modalPrint ? modalPrint.querySelector('.print-preview-frame') : null;
            if (frame && frame.contentWindow) {
                frame.contentWindow.focus();
                frame.contentWindow.print();
            }
        }
    });
})();

// Avatar: preview de cor/imagem em tempo real, inclusive em formulários carregados por modal.
(function () {
    function initAvatarPreview(scope) {
        scope = scope || document;
        var colorInputs = scope.querySelectorAll('[data-avatar-color-input]');
        var imageInputs = scope.querySelectorAll('[data-avatar-image-input]');

        colorInputs.forEach(function (input) {
            var targetSelector = input.getAttribute('data-avatar-target') || '#avatarPreview';
            var preview = scope.querySelector(targetSelector) || document.querySelector(targetSelector);
            if (!preview) return;
            input.addEventListener('input', function () {
                preview.style.backgroundColor = input.value || '#9333ea';
            });
        });

        imageInputs.forEach(function (input) {
            var targetSelector = input.getAttribute('data-avatar-target') || '#avatarPreview';
            var preview = scope.querySelector(targetSelector) || document.querySelector(targetSelector);
            if (!preview) return;
            input.addEventListener('change', function () {
                var file = input.files && input.files[0];
                if (!file) return;
                if (!file.type || !file.type.startsWith('image/')) {
                    alert('Selecione apenas arquivos de imagem.');
                    input.value = '';
                    return;
                }
                var reader = new FileReader();
                reader.onload = function (event) {
                    preview.innerHTML = '<img src="' + event.target.result + '" alt="Preview do avatar">';
                };
                reader.readAsDataURL(file);
            });
        });
    }
    document.addEventListener('DOMContentLoaded', function () { initAvatarPreview(document); });
    document.addEventListener('modal:loaded', function (event) { initAvatarPreview(event.detail && event.detail.container ? event.detail.container : document); });
    window.initAvatarPreview = initAvatarPreview;
})();