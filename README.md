# Avalia

Sistema web de gerenciamento de atividades e avaliações para escolas com o objetivo de proporcionar apoio educacional para professores ao avaliar o desempenho dos seus alunos em atividades avaliativas.

Versão final simplificada para **um único perfil: Administrador**.

A interface continua em **HTML, CSS e JavaScript puro**. O PHP fica concentrado na pasta `api/`, usado como API para banco de dados, autenticação, e notificações.


## Funcionalidades

- Dashboard administrativo geral.
- Gerenciamento de usuários: aluno, professor, moderador e admin.
- Agrupamento de alunos por escola e turma.
- Cadastro, edição, ativação/desativação e exclusão lógica de usuários.
- Validação de CPF/CNPJ.
- Senha mínima de 6 caracteres.
- Gerenciamento de escolas.
- Gerenciamento de turmas e visualização dos alunos da turma.
- Gerenciamento de disciplinas.
- Gerenciamento de avaliações.
- Visualização da avaliação com status, professor, escola, questões e resultados.
- Ações de avaliação: atualizar status, enviar notificação e excluir.
- Perfil do administrador: dados, senha, tema, avatar, fonte, alto contraste e VLibras.
- Integração com VLibras.
- Processamento da fila `notificacoes_email`.


## Tecnologias usadas

- HTML5 e CSS3
- JavaScript
- PHP
- **ViaCEP**: usado no cadastro de escolas para preencher endereço pelo CEP.
- **BrasilAPI CNPJ**: usado no cadastro de escolas para preencher dados da instituição pelo CNPJ.
- **VLibras**: acessibilidade em Libras, controlada nas preferências do perfil.
- **Validator**: usado no cadastro de usuários para validar o CPF.

## Validação CPF/CNPJ com API Invertexto

O sistema valida CPF/CNPJ em duas etapas:

- Validação local por dígitos verificadores no JavaScript e no PHP;
- Validação opcional pela API Invertexto quando `INVERTEXTO_TOKEN` estiver configurado no arquivo `.env`.

A API usada é `GET https://api.invertexto.com/v1/validator`, com os parâmetros `token`, `value` e opcionalmente `type` (`cpf` ou `cnpj`). A documentação da Invertexto informa que o endpoint retorna se o documento é válido ou inválido e que o plano gratuito possui limite mensal de requisições.

Configure no `.env`:

```env
INVERTEXTO_TOKEN=seu_token_aqui
```

Sem token, o sistema continua bloqueando documentos matematicamente inválidos pela validação local.

As consultas passam pela rota PHP `api/index.php?path=integracoes/...`, evitando dependência direta do JavaScript com serviços externos. Se uma API externa estiver indisponível, o cadastro manual continua funcionando.


## Como executar localmente

1. Clone o repositório:
`git clone https://github.com/ana-manea/projeto-avaliativo.git`

2. Importe o banco de dados:
`Localizado no caminho: database\banco_avalia.sql`

3. Configure o `.env` com as informações do banco de dados e API:
`
DB_HOST=localhost
DB_NAME=banco_avalia
DB_USER=root
DB_PASS=
`


4. Acesse:
`projeto-avaliativo/install.php`

5. Confirme host, usuário e senha do MySQL.

6. Clique em **Criar/carregar banco_avalia**.

O instalador carrega automaticamente o arquivo:
```txt 
database/banco_avalia.sql
```

7. Abra o arquivo `public\index.html` no navegador.


## Autoras

- Ana Carolina Manea Bueno - [@ana-manea](https://github.com/ana-manea)
- Giovana Gonçalves Pádua - [@giovana-padua](https://github.com/giovana-padua)
