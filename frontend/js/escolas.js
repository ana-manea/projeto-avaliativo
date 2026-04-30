const id = new URLSearchParams(location.search).get('id');
const cepInput = document.getElementById('cep');
const cnpjInput = document.getElementById('cnpj');

bindCpfCnpjInput(cnpjInput, { cnpjOnly: true });
bindCepInput(cepInput);

async function load() {
    if (id) {
        title.textContent = 'EDITAR ESCOLA';
        const response = await api('escolas/' + id);
        Object.entries(response.item).forEach(([key, value]) => {
            if (form[key]) form[key].value = value ?? '';
        });

        if (form.cep) {
            form.cep.value = maskCepValue(form.cep.value);
            form.cep.dataset.cepValid = '';
        }

        validateForm(form);
    }
}

async function validarCepEscola({ preencher = true } = {}) {
    const cepDigits = onlyDigits(cepInput.value);
    cepInput.dataset.cepValid = '';
    cepInput.dataset.cepMessage = '';

    if (!cepDigits) {
        setFieldError(cepInput, 'CEP é obrigatório.');
        return false;
    }

    if (cepDigits.length !== 8) {
        setFieldError(cepInput, 'CEP deve ter 8 dígitos. Ex: 01001-000.');
        return false;
    }

    try {
        const response = await api('integracoes/cep&cep=' + cepDigits);
        
        if (!response.ok || !response.data) {
            cepInput.dataset.cepValid = '0';
            cepInput.dataset.cepMessage = 'CEP não encontrado. Digite um CEP válido.';
            setFieldError(cepInput, cepInput.dataset.cepMessage);
            return false;
        }
        
        cepInput.dataset.cepValid = '1';
        cepInput.value = maskCepValue(cepDigits);
        clearFieldError(cepInput);
        
        if (preencher && response.data.endereco) {
            form.endereco.value = response.data.endereco;
            clearFieldError(form.endereco);
        }
        
        return true;
    } catch (error) {
        cepInput.dataset.cepValid = '0';
        cepInput.dataset.cepMessage = error.message || 'CEP não encontrado. Digite um CEP válido.';
        setFieldError(cepInput, cepInput.dataset.cepMessage);
        
        return false;
    }
}

async function buscarCep() {
    const ok = await validarCepEscola({ preencher: true });
    if (!ok) flash('CEP não encontrado. Digite o CEP correto.', 'error');
}

cepInput.addEventListener('blur', () => {
    if (onlyDigits(cepInput.value).length === 8) {
        validarCepEscola({ preencher: true });
    }
});

async function buscarCnpj() {
    try {
        if (!isValidCNPJ(cnpjInput.value)) {
            setFieldError(cnpjInput, 'CNPJ inválido.');
            return flash('CNPJ inválido.', 'error');
        }
        
        const response = await api('integracoes/cnpj&cnpj=' + onlyDigits(cnpjInput.value));
        ['nome', 'email', 'telefone', 'endereco'].forEach(key => {
            if (response.data[key] && form[key]) form[key].value = response.data[key];
        });
        
        if (response.data.cnpj) form.cnpj.value = response.data.cnpj;
        clearFieldError(cnpjInput);
    } catch (error) {
        setFieldError(cnpjInput, error.message || 'Não foi possível consultar o CNPJ.');
        flash(error.message, 'error');
    }
}

form.addEventListener('submit', async event => {
    event.preventDefault();
    
    if (!validateForm(form)) return;
    
    const cepOk = await validarCepEscola({ preencher: false });
    if (!cepOk) {
        flash('Digite um CEP válido antes de salvar.', 'error');
        return;
    }

    const data = formData(form);
    
    try {
        if (data.cnpj) await exigirDocumentoApi(data.cnpj, 'cnpj');
    } catch (error) {
        setFieldError(cnpjInput, error.message);
        return flash(error.message, 'error');
    }
    
    data.cnpj = maskCnpjValue(data.cnpj);
    data.cep = maskCepValue(data.cep);
    const schoolId = data.id || id;
    delete data.id;
    
    try {
        await api(schoolId ? 'escolas/' + schoolId : 'escolas', {
            method: schoolId ? 'PUT' : 'POST',
            body: data,
        });
        location.href = 'escolas.html';
    } catch (error) {
        flash(error.message, 'error');
    }
});

requireAdmin().then(load);
