const id = new URLSearchParams(location.search).get('id');
const cpfCnpjInput = document.getElementById('cpf_cnpj');

bindCpfCnpjInput(cpfCnpjInput);

async function load() {
    const lookups = await api('lookups');
    form.escola_id.innerHTML = '<option value="">Selecione</option>' + 
        lookups.escolas.map(e => `<option value="${e.id}">${esc(e.nome)}</option>`).join('');
    
    form.turma_id.innerHTML = '<option value="">Selecione</option>' +
        lookups.turmas.map(t => `<option value="${t.id}">${esc(t.escola ? t.escola + ' - ' + t.nome : t.nome)}</option>`).join('');
    
    if (id) {
        title.textContent = 'EDITAR USUÁRIO';
        const response = await api('usuarios/' + id);
        Object.entries(response.item).forEach(([key, value]) => {
            if (form[key]) form[key].value = value ?? '';
        });
        form.senha.required = false;
    } else {
        form.senha.required = true;
    }
}

form.addEventListener('submit', async event => {
    event.preventDefault();
    
    if (!validateForm(form)) return;
    
    const data = formData(form);
    
    try {
        if (data.cpf_cnpj) {
            await exigirDocumentoApi(data.cpf_cnpj, data.nivel === 'aluno' ? 'cpf' : '');
        }
    } catch (error) {
        setFieldError(cpfCnpjInput, error.message);
        return flash(error.message, 'error');
    }
    
    data.cpf_cnpj = maskCpfCnpjValue(data.cpf_cnpj);
    
    if (!id && (!data.senha || data.senha.length < 6)) {
        setFieldError(form.senha, 'Senha mínima de 6 caracteres.');
        return flash('Senha mínima de 6 caracteres.', 'error');
    }
    
    if (id && data.senha && data.senha.length < 6) {
        setFieldError(form.senha, 'Senha mínima de 6 caracteres.');
        return flash('Senha mínima de 6 caracteres.', 'error');
    }
    
    const userId = data.id || id;
    delete data.id;
    
    try {
        await api(userId ? 'usuarios/' + userId : 'usuarios', {
            method: userId ? 'PUT' : 'POST',
            body: data,
        });
        location.href = 'usuarios.html';
    } catch (error) {
        flash(error.message, 'error');
    }
});

requireAdmin().then(load);
