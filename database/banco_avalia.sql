-- Banco Avalia 
-- Nome do banco: banco_avalia
-- Usuário padrão:
-- admin / admin123

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- Criação do db e limpeza de quaisquer dados que estejam nele e possam interferir.
CREATE DATABASE IF NOT EXISTS `banco_avalia` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `banco_avalia`;

DROP TABLE IF EXISTS `respostas`;
DROP TABLE IF EXISTS `resultados`;
DROP TABLE IF EXISTS `alternativas`;
DROP TABLE IF EXISTS `questoes`;
DROP TABLE IF EXISTS `avaliacoes`;
DROP TABLE IF EXISTS `disciplina_professor_turma`;
DROP TABLE IF EXISTS `turmas_alunos`;
DROP TABLE IF EXISTS `moderador_escola`;
DROP TABLE IF EXISTS `log_atividades`;
DROP TABLE IF EXISTS `alunos`;
DROP TABLE IF EXISTS `professores`;
DROP TABLE IF EXISTS `turmas`;
DROP TABLE IF EXISTS `disciplinas`;
DROP TABLE IF EXISTS `escolas`;
DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `tipos_usuario`;

--------------------------------------------------------
--
-- Estrutura para tabela `alternativas`
--
CREATE TABLE `alternativas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `questao_id` int unsigned NOT NULL,
  `letra` char(1) NOT NULL,
  `texto` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_alternativas_questao` (`questao_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `alternativas`
--
INSERT INTO `alternativas` (`id`, `questao_id`, `letra`, `texto`) VALUES
(1, 1, 'A', '3'),
(2, 1, 'B', '4'),
(3, 1, 'C', '5'),
(4, 1, 'D', '6'),
(5, 1, 'E', '7');

--------------------------------------------------------
--
-- Estrutura para tabela `alunos`
--
CREATE TABLE `alunos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `nome_completo` varchar(160) NOT NULL,
  `data_nascimento` date DEFAULT NULL,
  `matricula` varchar(30) NOT NULL,
  `cpf` varchar(18) DEFAULT NULL,
  `email` varchar(160) DEFAULT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `nome_responsavel` varchar(160) DEFAULT NULL,
  `ano_letivo` year NOT NULL DEFAULT 2026,
  `rg` varchar(30) DEFAULT NULL,
  `email_responsavel` varchar(160) DEFAULT NULL,
  `telefone_responsavel` varchar(20) DEFAULT NULL,
  `escola_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_alunos_usuario` (`usuario_id`),
  UNIQUE KEY `uk_alunos_matricula` (`matricula`),
  KEY `idx_alunos_escola` (`escola_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `alunos`
--
INSERT INTO `alunos` (`id`, `usuario_id`, `nome_completo`, `data_nascimento`, `matricula`, `cpf`, `email`, `celular`, `nome_responsavel`, `ano_letivo`, `rg`, `email_responsavel`, `telefone_responsavel`, `escola_id`) 
VALUES
(1, 4, 'Aluno Padrão', '2011-04-15', 'ALU20260001', '123.456.789-09', 'aluno@avalia.local', '(11) 90000-0004', 'Responsável Padrão', 2026, '12.345.678-9', 'responsavel@avalia.local', '(11) 90000-0005', 1);

--------------------------------------------------------
--
-- Estrutura para tabela `avaliacoes`
--
CREATE TABLE `avaliacoes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(160) NOT NULL,
  `turma_id` int unsigned NOT NULL,
  `disciplina_id` int unsigned DEFAULT NULL,
  `professor_id` int unsigned DEFAULT NULL,
  `data_prova` date DEFAULT NULL,
  `peso` decimal(5,2) NOT NULL DEFAULT 1.00,
  `numero_questoes` smallint NOT NULL DEFAULT 0,
  `alternativas_por_questao` tinyint NOT NULL DEFAULT 5,
  `observacoes` text DEFAULT NULL,
  `status` enum('pendente','em_andamento','correcao_pendente','concluida') NOT NULL DEFAULT 'pendente',
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criada_em` datetime NOT NULL DEFAULT current_timestamp(),
  `criado_por_usuario_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_avaliacoes_turma` (`turma_id`),
  KEY `idx_avaliacoes_disciplina` (`disciplina_id`),
  KEY `idx_avaliacoes_professor` (`professor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `avaliacoes`
--
INSERT INTO `avaliacoes` (`id`, `titulo`, `turma_id`, `disciplina_id`, `professor_id`, `data_prova`, `peso`, `numero_questoes`, `alternativas_por_questao`, `observacoes`, `status`, `ativo`, `criado_por_usuario_id`) 
VALUES
(1, 'Avaliação Diagnóstica Padrão', 1, 1, 1, '2026-04-30', 1.00, 1, 5, 'Avaliação inicial cadastrada no seed do sistema.', 'pendente', 1, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `disciplinas`
--
CREATE TABLE `disciplinas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `codigo` varchar(20) DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_disciplinas_nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `disciplinas`
--
INSERT INTO `disciplinas` (`id`, `nome`, `codigo`, `descricao`, `ativo`) 
VALUES
(1, 'Matemática', 'MAT', 'Disciplina padrão de Matemática', 1),
(2, 'Língua Portuguesa', 'POR', 'Disciplina padrão de Língua Portuguesa', 1),
(3, 'Ciências', 'CIE', 'Disciplina padrão de Ciências', 1),
(4, 'História', 'HIS', 'Disciplina padrão de História', 1),
(5, 'Geografia', 'GEO', 'Disciplina padrão de Geografia', 1);

--------------------------------------------------------
--
-- Estrutura para tabela `disciplina_professor_turma`
--
CREATE TABLE `disciplina_professor_turma` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `disciplina_id` int unsigned NOT NULL,
  `professor_id` int unsigned NOT NULL,
  `turma_id` int unsigned NOT NULL,
  `ano_letivo` year NOT NULL DEFAULT 2026,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dpt_disciplina` (`disciplina_id`),
  KEY `idx_dpt_professor` (`professor_id`),
  KEY `idx_dpt_turma` (`turma_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `disciplina_professor_turma`
--
INSERT INTO `disciplina_professor_turma` (`id`, `disciplina_id`, `professor_id`, `turma_id`, `ano_letivo`, `ativo`) 
VALUES
(1, 1, 1, 1, 2026, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `escolas`
--
CREATE TABLE `escolas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `cnpj` varchar(18) DEFAULT NULL,
  `endereco` text DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `escolas`
--
INSERT INTO `escolas` (`id`, `nome`, `cnpj`, `endereco`, `telefone`, `email`, `ativo`) 
VALUES
(1, 'Escola Padrão Avalia', '11.222.333/0001-81', 'Rua das Avaliações, 100 - Centro - São Paulo/SP', '(11) 3000-0000', 'contato@escolapadrao.com', 1);

--------------------------------------------------------
--
-- Estrutura para tabela `log_atividades`
--
CREATE TABLE `log_atividades` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned DEFAULT NULL,
  `acao` varchar(120) NOT NULL,
  `entidade` varchar(80) DEFAULT NULL,
  `entidade_id` int unsigned DEFAULT NULL,
  `detalhes` text DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_log_usuario` (`usuario_id`),
  KEY `idx_log_entidade` (`entidade`,`entidade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--------------------------------------------------------
--
-- Estrutura para tabela `moderador_escola`
--
CREATE TABLE `moderador_escola` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `escola_id` int unsigned NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_moderador_usuario` (`usuario_id`),
  KEY `idx_moderador_escola` (`escola_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `moderador_escola`
--
INSERT INTO `moderador_escola` (`id`, `usuario_id`, `escola_id`, `ativo`) 
VALUES
(1, 2, 1, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `professores`
--
CREATE TABLE `professores` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `cpf` varchar(18) DEFAULT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `instituicao` varchar(180) DEFAULT NULL,
  `cargo` varchar(80) DEFAULT NULL,
  `area_formacao` varchar(120) DEFAULT NULL,
  `registro_profissional` varchar(60) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_professores_usuario` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `professores`
--
INSERT INTO `professores` (`id`, `usuario_id`, `cpf`, `celular`, `instituicao`, `cargo`, `area_formacao`, `registro_profissional`, `ativo`) 
VALUES
(1, 3, '111.444.777-35', '(11) 90000-0003', 'Escola Padrão Avalia', 'Professor', 'Matemática', 'PROF-2026-001', 1);

--------------------------------------------------------
--
-- Estrutura para tabela `questoes`
--
CREATE TABLE `questoes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `avaliacao_id` int unsigned NOT NULL,
  `numero` int NOT NULL,
  `enunciado` text DEFAULT NULL,
  `tipo` varchar(20) NOT NULL DEFAULT 'objetiva',
  `gabarito` char(1) DEFAULT NULL,
  `valor` decimal(5,2) DEFAULT 1.00,
  PRIMARY KEY (`id`),
  KEY `idx_questoes_avaliacao` (`avaliacao_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `questoes`
--
INSERT INTO `questoes` (`id`, `avaliacao_id`, `numero`, `enunciado`, `tipo`, `gabarito`, `valor`) 
VALUES
(1, 1, 1, 'Quanto é 2 + 2?', 'objetiva', 'B', 10.00);

--------------------------------------------------------
--
-- Estrutura para tabela `respostas`
--
CREATE TABLE `respostas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `avaliacao_id` int unsigned NOT NULL,
  `aluno_id` int unsigned NOT NULL,
  `questao_id` int unsigned NOT NULL,
  `resposta` char(1) DEFAULT NULL,
  `correta` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_respostas_aluno` (`aluno_id`),
  KEY `idx_respostas_avaliacao` (`avaliacao_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--------------------------------------------------------
--
-- Estrutura para tabela `resultados`
--
CREATE TABLE `resultados` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `avaliacao_id` int unsigned NOT NULL,
  `aluno_id` int unsigned NOT NULL,
  `nota` decimal(5,2) DEFAULT NULL,
  `acertos` int DEFAULT 0,
  `total_questoes` int DEFAULT 0,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_resultados_avaliacao` (`avaliacao_id`),
  KEY `idx_resultados_aluno` (`aluno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `resultados`
--
INSERT INTO `resultados` (`id`, `avaliacao_id`, `aluno_id`, `nota`, `acertos`, `total_questoes`) VALUES
(1, 1, 1, 10.00, 1, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `tipos_usuario`
--
CREATE TABLE `tipos_usuario` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(40) NOT NULL,
  `descricao` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tipos_usuario_nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `tipos_usuario`
--
INSERT INTO `tipos_usuario` (`id`, `nome`, `descricao`) VALUES
(1, 'admin', 'Administrador do sistema'),
(2, 'professor', 'Professor'),
(3, 'aluno', 'Aluno'),
(4, 'moderador', 'Moderador escolar');

--------------------------------------------------------
--
-- Estrutura para tabela `turmas`
--
CREATE TABLE `turmas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `serie_ano` varchar(40) DEFAULT NULL,
  `turno` varchar(30) DEFAULT NULL,
  `ano_letivo` year NOT NULL DEFAULT 2026,
  `capacidade_maxima` int DEFAULT NULL,
  `professor_id` int unsigned DEFAULT NULL,
  `sala` varchar(40) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `escola_id` int unsigned DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_turmas_escola` (`escola_id`),
  KEY `idx_turmas_professor` (`professor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `turmas`
--
INSERT INTO `turmas` (`id`, `nome`, `serie_ano`, `turno`, `ano_letivo`, `capacidade_maxima`, `professor_id`, `sala`, `ativo`, `escola_id`) 
VALUES
(1, 'Turma Padrão 6º Ano A', '6º Ano', 'Manhã', 2026, 35, 1, 'Sala 01', 1, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `turmas_alunos`
--
CREATE TABLE `turmas_alunos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `turma_id` int unsigned NOT NULL,
  `aluno_id` int unsigned NOT NULL,
  `ano_letivo` year NOT NULL DEFAULT 2026,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_turma_aluno` (`turma_id`,`aluno_id`,`ano_letivo`),
  KEY `idx_turmas_alunos_aluno` (`aluno_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `turmas_alunos`
--
INSERT INTO `turmas_alunos` (`id`, `turma_id`, `aluno_id`, `ano_letivo`, `ativo`) 
VALUES
(1, 1, 1, 2026, 1);

--------------------------------------------------------
--
-- Estrutura para tabela `usuarios`
--
CREATE TABLE `usuarios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome_completo` varchar(160) NOT NULL,
  `usuario` varchar(60) NOT NULL,
  `email` varchar(160) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `cpf` varchar(18) DEFAULT NULL,
  `cpf_cnpj` varchar(18) DEFAULT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `tipo_id` int unsigned NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `tema` varchar(30) NOT NULL DEFAULT 'claro',
  `avatar_cor` varchar(20) NOT NULL DEFAULT '#9333ea',
  `avatar_imagem` varchar(255) DEFAULT NULL,
  `vlibras_ativo` tinyint(1) NOT NULL DEFAULT 1,
  `alto_contraste` tinyint(1) NOT NULL DEFAULT 0,
  `font_size` varchar(20) NOT NULL DEFAULT 'normal',
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_usuarios_usuario` (`usuario`),
  KEY `idx_usuarios_tipo` (`tipo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Fornecendo dados para a tabela `usuarios`
--
INSERT INTO `usuarios` (`id`, `nome_completo`, `usuario`, `email`, `telefone`, `cpf`, `cpf_cnpj`, `senha_hash`, `tipo_id`, `ativo`, `tema`, `avatar_cor`, `vlibras_ativo`, `alto_contraste`, `font_size`) 
VALUES
(1, 'Administrador Padrão', 'admin', 'admin@avalia.local', '(11) 90000-0001', '529.982.247-25', '529.982.247-25', '$2y$12$5vrfkZc7QBibE8PQpqD7tuATKXLu4DoWWw2A1fS8hLWJzVJb/ULqi', 1, 1, 'claro', '#9333ea', 1, 0, 'normal'),
(2, 'Moderador Padrão', 'moderador', 'moderador@avalia.local', '(11) 90000-0002', '153.509.460-56', '153.509.460-56', '$2y$12$CUz.Ep/m7dvenUE.1YgI0un1syINmaFtbfqDZ.hE7KWhCBtPyaUKO', 4, 1, 'claro', '#2563eb', 1, 0, 'normal'),
(3, 'Professor Padrão', 'professor', 'professor@avalia.local', '(11) 90000-0003', '111.444.777-35', '111.444.777-35', '$2y$12$OFvTJkvKVNkA8hfW.zN7mOLiX1tlkmtb23O2UMyAYrA6ICwnVInk6', 2, 1, 'claro', '#16a34a', 1, 0, 'normal'),
(4, 'Aluno Padrão', 'aluno', 'aluno@avalia.local', '(11) 90000-0004', '123.456.789-09', '123.456.789-09', '$2y$12$Q/oZ3HTvnLsjIkO.ilu2ZuhuH7iFMMUgcZgVyrP0jMXBQqCjntbva', 3, 1, 'claro', '#ea580c', 1, 0, 'normal');
