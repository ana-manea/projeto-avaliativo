const API_BASE = new URL('../api/index.php?path=', window.location.href).toString();

function api(path, options={}){
    const opts={
        headers:{'Content-Type':'application/json','X-Requested-With':'XMLHttpRequest'},
        credentials:'include',...options
    };
    
    if(opts.body && typeof opts.body !== 'string')
        opts.body = JSON.stringify(opts.body);
        return fetch(API_BASE + encodeURI(path), opts).then(async r => {
            const d = await r.json().catch(() => ({
                ok:false,
                error:'Resposta inválida'})
            );

        if(!r.ok || d.ok === false)
            throw new Error(d.error || 'Erro na requisição');
            return d;
    });

}

function esc(v){
    return String(v ?? '').replace(/[&<>'"]/g,ch => ({
        '&':'&amp;',
        '<':'&lt;',
        '>':'&gt;',
        "'":'&#39;',
        '"':'&quot;'
        } 
        [ch]
    ));

}

function onlyDigits(v){
    return String(v || '').replace(/\D/g,'');

}

function initials(n){
    return String(n || 'A').trim().split(/\s+/).slice(0,2).map(p => p[0]?.toUpperCase()).join('') || 'A';

}
function setTheme(t){
    const v = t || localStorage.getItem('avalia_tema') || 'claro';
    document.documentElement.setAttribute('data-tema',v);
    if(t)localStorage.setItem('avalia_tema',v);

} 

setTheme();

function setFontSize(s){
    const v = s || localStorage.getItem('avalia_font_size') || 'normal';
    document.documentElement.setAttribute('data-font-size', v);

    if(s) localStorage.setItem('avalia_font_size', v);

} 

setFontSize();

function isValidCPF(value){
    const cpf = onlyDigits(value);

    if(cpf.length!==11||/^(\d)\1{10}$/.test(cpf))
        return false;

    let sum=0;
    for(let i = 0; i < 9; i++)
        sum += Number(cpf[i]) * (10 - i);

    let d = (sum * 10) % 11;
    if(d === 10)
        d = 0;

    if(d !== Number(cpf[9]))
        return false;
    
    sum=0;
    for(let i = 0; i < 10; i++)
        sum += Number(cpf[i]) * (11 - i);

    d = (sum * 10) % 11;

    if(d === 10)
        d = 0;

    return d === Number(cpf[10]);
}

function isValidCNPJ(value){
    const c = onlyDigits(value);

    if(c.length !== 14 || /^(\d)\1{13}$/.test(c))
        return false;
    
    const calc = (base, w) => {
        const s = base.split('').reduce((a,n,i) => a + Number(n) * w[i], 0);

        const m = s % 11;
        return m < 2 ? 0 : 11 - m;

    };

    const d1 = calc(c.slice(0, 12), [5,4,3,2,9,8,7,6,5,4,3,2]);
    const d2 = calc(c.slice(0, 12) + d1, [6,5,4,3,2,9,8,7,6,5,4,3,2]);
    return d1 === Number(c[12]) && d2 === Number(c[13]);
}

function validateCpfCnpj(v){
    const d = onlyDigits(v);
 
    if(!d) return true;

    return d.length === 11 ? isValidCPF(d) : d.length === 14 ? isValidCNPJ(d) : false;

}

function flash(msg,type='success'){const d=document.createElement('div');
    d.className='alert alert-'+(type==='error'?'error':'success');
    d.textContent=msg;
    document.querySelector('main .container')?.prepend(d);
    setTimeout(()=>d.remove(),4000);

}
function statusBadge(status){const s=String(status||'').toLowerCase();
    const label={concluida:'Concluída',pendente:'Pendente',em_andamento:'Em andamento',correcao_pendente:'Correção pendente',rascunho:'Rascunho',ativo:'Ativo',inativo:'Inativo'}[s]||status||'-';
return `<span class="badge badge-${esc(s)}">${esc(label)}</span>`;
}
async function requireAdmin(){try{const r=await api('me');
    if(!r.user)return location.href='index.html';
    if(String(r.user.nivel).toLowerCase()!=='admin'){await api('auth/logout');
    return location.href='index.html?erro=admin';

}window.currentUser=r.user;
renderHeader(r.user);
applyPreferences(r.user);
return r.user;
}catch(e){location.href='index.html';

}}
function applyPreferences(u){if(u?.tema)setTheme(u.tema);
    if(u?.font_size)setFontSize(u.font_size);
    document.body.classList.toggle('alto-contraste',Number(u?.alto_contraste||0)===1);
    toggleVLibras(true);

}
function renderHeader(user){const el=document.querySelector('[data-app-header]');
    if(!el)return;
    el.innerHTML=`<header class="header app-header"><div class="container"><div class="header-inner"><a class="logo brand" href="dashboard.html"><img src="../assets/img/logo.svg" class="logo-icon" width="48" height="48" alt=""><span class="logo-text">Avalia</span></a><nav class="header-nav"><a href="dashboard.html">Dashboard</a><a href="usuarios.html">Usuários</a><a href="escolas.html">Escolas</a><a href="turmas.html">Turmas</a><a href="disciplinas.html">Disciplinas</a><a href="avaliacoes.html">Avaliações</a></nav><div class="header-actions"><div class="tema-selector"><button class="tema-btn tema-btn-claro" onclick="setTheme('claro')" title="Claro"></button><button class="tema-btn tema-btn-escuro" onclick="setTheme('escuro')" title="Escuro"></button><button class="tema-btn tema-btn-daltonico" onclick="setTheme('daltonico')" title="Daltônico"></button><button class="tema-btn tema-btn-alto_contraste" onclick="setTheme('alto_contraste')" title="Alto contraste"></button></div><div class="avatar-menu-wrap"><button id="avatarMenuBtn" class="user-avatar avatar-user" type="button" style="background:${esc(user.avatar_cor||'#9333ea')}">${user.avatar_imagem?`<img src="${esc(user.avatar_imagem)}" alt="">`:`<span class="avatar-initials">${esc(initials(user.nome))}</span>`}</button><div id="avatarDropdown" class="avatar-dropdown" role="menu"><div class="avatar-dropdown-head"><strong>${esc(user.nome||'Administrador')}</strong><span>Administrador</span></div><a href="perfil.html">Meu Perfil</a><button type="button" onclick="logout()">Sair</button></div></div></div></div></div></header>`;
const b=document.getElementById('avatarMenuBtn'),m=document.getElementById('avatarDropdown');
b?.addEventListener('click',e=>{e.preventDefault();
    e.stopPropagation();
    m.classList.toggle('open');

});
document.addEventListener('click',e=>{if(!e.target.closest('.avatar-menu-wrap'))m?.classList.remove('open');

});
}
function logout(){api('auth/logout').finally(()=>location.href='index.html');

}
function toggleVLibras(enable=true){let root=document.querySelector('[data-vlibras-root]');
    if(!enable){if(root)root.style.display='none';
    return;

}if(!root){root=document.createElement('div');
    root.setAttribute('data-vlibras-root','1');
    root.innerHTML='<div vw class="enabled"><div vw-access-button class="active"></div><div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div></div>';
    document.body.appendChild(root);

}root.style.display='block';
root.style.zIndex='99999';
const startVLibras=()=>{try{if(window.VLibras&&!window.__avaliaVLibrasStarted){new window.VLibras.Widget('https://vlibras.gov.br/app');
    window.__avaliaVLibrasStarted=true;

}}catch(e){console.warn('VLibras não iniciou:',e);

}};
let script=document.getElementById('vlibras-plugin-script');
if(!script){script=document.createElement('script');
    script.id='vlibras-plugin-script';
    script.src='https://vlibras.gov.br/app/vlibras-plugin.js';
    script.async=true;
    script.onload=startVLibras;
    script.onerror=()=>console.warn('Não foi possível carregar o plugin do VLibras. Verifique a conexão com a internet.');
    document.body.appendChild(script);

}else startVLibras();
setTimeout(startVLibras,800);
setTimeout(startVLibras,2000);
}
document.addEventListener('DOMContentLoaded',()=>toggleVLibras(true));

function formData(form){return Object.fromEntries(new FormData(form));

}
function table(headers, rows){return `<div class="table-responsive"><table class="table"><thead><tr>${headers.map(h=>`<th>${h}</th>`).join('')}</tr></thead><tbody>${rows.join('')||`<tr><td colspan="${headers.length}" class="text-center text-muted">Nenhum registro encontrado.</td></tr>`}</tbody></table></div>`;
}
