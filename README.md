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

As consultas passam pela rota PHP `api/index.php?path=integracoes/...`, evitando dependência direta do JavaScript com serviços externos. Se uma API externa estiver indisponível, o cadastro manual continua funcionando.


## Como executar localmente

1. Clone o repositório:
`git clone https://github.com/ana-manea/projeto-avaliativo.git`

2. Importe o banco de dados:
`Localizado no caminho: database\schema.sql`

3. Configure o `.env` com as informações do banco de dados:
`MYSQLHOST=localhost
MYSQLDATABASE=avalia_db
MYSQLUSER=root
MYSQLPASSWORD=
`

4. Abra o arquivo `public\index.html` no navegador.


## Autoras

- Ana Carolina Manea Bueno - [@ana-manea](https://github.com/ana-manea)
- Giovana Gonçalves Pádua - [@giovana-padua](https://github.com/giovana-padua)
