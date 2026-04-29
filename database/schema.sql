-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 29/04/2026 às 11:10
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `avalia_db`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `alternativas`
--

CREATE TABLE `alternativas` (
  `id` int(10) UNSIGNED NOT NULL,
  `questao_id` int(10) UNSIGNED NOT NULL,
  `letra` char(1) NOT NULL,
  `texto` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `alternativas`
--

INSERT INTO `alternativas` (`id`, `questao_id`, `letra`, `texto`) VALUES
(1, 1, 'A', 'a'),
(2, 1, 'B', 'b'),
(3, 1, 'C', 'c'),
(4, 1, 'D', 'd'),
(5, 1, 'E', 'e');

-- --------------------------------------------------------

--
-- Estrutura para tabela `alunos`
--

CREATE TABLE `alunos` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `nome_completo` varchar(120) NOT NULL,
  `data_nascimento` date DEFAULT NULL,
  `matricula` varchar(30) NOT NULL,
  `cpf` varchar(14) DEFAULT NULL,
  `email` varchar(120) DEFAULT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `nome_responsavel` varchar(120) DEFAULT NULL,
  `ano_letivo` year(4) NOT NULL,
  `rg` varchar(20) DEFAULT NULL,
  `email_responsavel` varchar(120) DEFAULT NULL,
  `telefone_responsavel` varchar(20) DEFAULT NULL,
  `escola_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `alunos`
--

INSERT INTO `alunos` (`id`, `usuario_id`, `nome_completo`, `data_nascimento`, `matricula`, `cpf`, `email`, `celular`, `nome_responsavel`, `ano_letivo`, `rg`, `email_responsavel`, `telefone_responsavel`, `escola_id`) VALUES
(1, 3, 'Aluno Padrão', '2009-07-13', 'ALU20260001', '333.333.333-33', 'aluno@email.com', '11999990003', 'Responsável do Aluno', '2026', '33.333.333-3', 'responsavel@email.com', '11999990005', 1),
(3, 5, 'Email Teste', NULL, 'ALU20262889', '11111111111111', 'teste.swg.avalia@gmail.com', '111111111111111', NULL, '2026', NULL, NULL, NULL, 1),
(4, 9, 'Ana Clara Silva', '2011-02-10', 'SEED-A001', '200.000.000-01', 'aluno.a1@seed.com', '(11) 91000-0001', 'Responsável Ana Clara', '2026', '20.000.001-1', 'resp.a1@seed.com', '(11) 92000-0001', 2),
(5, 10, 'Bruno Martins Lima', '2011-04-18', 'SEED-A002', '200.000.000-02', 'aluno.a2@seed.com', '(11) 91000-0002', 'Responsável Bruno Martins', '2026', '20.000.002-2', 'resp.a2@seed.com', '(11) 92000-0002', 2),
(6, 11, 'Camila Souza Rocha', '2011-08-25', 'SEED-A003', '200.000.000-03', 'aluno.a3@seed.com', '(11) 91000-0003', 'Responsável Camila Souza', '2026', '20.000.003-3', 'resp.a3@seed.com', '(11) 92000-0003', 2),
(7, 12, 'Diego Pereira Alves', '2011-01-12', 'SEED-B001', '200.000.000-04', 'aluno.b1@seed.com', '(11) 91000-0004', 'Responsável Diego Pereira', '2026', '20.000.004-4', 'resp.b1@seed.com', '(11) 92000-0004', 2),
(8, 13, 'Eduarda Costa Nunes', '2011-05-03', 'SEED-B002', '200.000.000-05', 'aluno.b2@seed.com', '(11) 91000-0005', 'Responsável Eduarda Costa', '2026', '20.000.005-5', 'resp.b2@seed.com', '(11) 92000-0005', 2),
(9, 14, 'Felipe Gomes Ribeiro', '2011-06-14', 'SEED-B003', '200.000.000-06', 'aluno.b3@seed.com', '(11) 91000-0006', 'Responsável Felipe Gomes', '2026', '20.000.006-6', 'resp.b3@seed.com', '(11) 92000-0006', 2),
(10, 15, 'Gabriela Mendes Freitas', '2011-09-29', 'SEED-B004', '200.000.000-07', 'aluno.b4@seed.com', '(11) 91000-0007', 'Responsável Gabriela Mendes', '2026', '20.000.007-7', 'resp.b4@seed.com', '(11) 92000-0007', 2),
(11, 16, 'Henrique Barbosa Melo', '2011-03-19', 'SEED-C001', '200.000.000-08', 'aluno.c1@seed.com', '(11) 91000-0008', 'Responsável Henrique Barbosa', '2026', '20.000.008-8', 'resp.c1@seed.com', '(11) 92000-0008', 3),
(12, 17, 'Isabela Cardoso Vieira', '2011-07-07', 'SEED-C002', '200.000.000-09', 'aluno.c2@seed.com', '(11) 91000-0009', 'Responsável Isabela Cardoso', '2026', '20.000.009-9', 'resp.c2@seed.com', '(11) 92000-0009', 3),
(13, 18, 'João Pedro Almeida', '2011-10-21', 'SEED-C003', '200.000.000-10', 'aluno.c3@seed.com', '(11) 91000-0010', 'Responsável João Pedro', '2026', '20.000.010-0', 'resp.c3@seed.com', '(11) 92000-0010', 3);

-- --------------------------------------------------------

--
-- Estrutura para tabela `avaliacoes`
--

CREATE TABLE `avaliacoes` (
  `id` int(10) UNSIGNED NOT NULL,
  `titulo` varchar(160) NOT NULL,
  `turma_id` int(10) UNSIGNED NOT NULL,
  `disciplina_id` int(10) UNSIGNED DEFAULT NULL,
  `professor_id` int(10) UNSIGNED DEFAULT NULL,
  `data_prova` date DEFAULT NULL,
  `peso` decimal(5,2) NOT NULL DEFAULT 1.00,
  `numero_questoes` smallint(6) NOT NULL DEFAULT 20,
  `alternativas_por_questao` tinyint(4) NOT NULL DEFAULT 5,
  `observacoes` text DEFAULT NULL,
  `status` enum('pendente','em_andamento','correcao_pendente','concluida') NOT NULL DEFAULT 'pendente',
  `criada_em` datetime NOT NULL DEFAULT current_timestamp(),
  `criado_por_usuario_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `avaliacoes`
--

INSERT INTO `avaliacoes` (`id`, `titulo`, `turma_id`, `disciplina_id`, `professor_id`, `data_prova`, `peso`, `numero_questoes`, `alternativas_por_questao`, `observacoes`, `status`, `criada_em`, `criado_por_usuario_id`) VALUES
(1, 'Teste Email', 1, 9, 1, '2026-04-29', 1.00, 1, 5, NULL, 'pendente', '2026-04-28 16:56:26', 1),
(2, 'Teste de notificação no email', 1, 9, NULL, '2026-04-30', 1.00, 1, 5, NULL, 'concluida', '2026-04-29 03:08:47', 1),
(3, 'Prova Teste 3', 1, 9, 1, '2026-04-29', 1.00, 1, 5, NULL, 'pendente', '2026-04-29 03:42:48', 1),
(4, 'Seed - Matemática A1', 2, 1, 3, '2026-04-01', 1.00, 10, 5, 'Dados seed para gráfico', 'concluida', '2026-04-29 04:06:14', 6),
(5, 'Seed - História A2', 2, 4, 4, '2026-04-05', 1.00, 10, 5, 'Dados seed para gráfico', 'concluida', '2026-04-29 04:06:14', 7),
(6, 'Seed - Matemática B1', 3, 1, 3, '2026-04-03', 1.00, 10, 5, 'Dados seed para gráfico', 'concluida', '2026-04-29 04:06:14', 6),
(7, 'Seed - Geografia B2', 3, 5, 4, '2026-04-08', 1.00, 10, 5, 'Dados seed para gráfico', 'concluida', '2026-04-29 04:06:14', 7),
(8, 'Seed - Ciências C1', 4, 3, 5, '2026-04-10', 1.00, 10, 5, 'Dados seed para gráfico', 'concluida', '2026-04-29 04:06:14', 8);

-- --------------------------------------------------------

--
-- Estrutura para tabela `disciplinas`
--

CREATE TABLE `disciplinas` (
  `id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(80) NOT NULL,
  `codigo` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `disciplinas`
--

INSERT INTO `disciplinas` (`id`, `nome`, `codigo`) VALUES
(1, 'Matemática', 'MAT'),
(2, 'Língua Portuguesa', 'POR'),
(3, 'Ciências', 'CIE'),
(4, 'História', 'HIS'),
(5, 'Geografia', 'GEO'),
(6, 'Inglês', 'ING'),
(7, 'Educação Física', 'EDF'),
(8, 'Artes', 'ART'),
(9, 'Geral', 'GERAL');

-- --------------------------------------------------------

--
-- Estrutura para tabela `disciplina_professor_turma`
--

CREATE TABLE `disciplina_professor_turma` (
  `id` int(10) UNSIGNED NOT NULL,
  `disciplina_id` int(10) UNSIGNED NOT NULL,
  `professor_id` int(10) UNSIGNED NOT NULL,
  `turma_id` int(10) UNSIGNED NOT NULL,
  `ano_letivo` year(4) NOT NULL DEFAULT year(curdate()),
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `disciplina_professor_turma`
--

INSERT INTO `disciplina_professor_turma` (`id`, `disciplina_id`, `professor_id`, `turma_id`, `ano_letivo`, `ativo`, `criado_em`) VALUES
(9, 1, 1, 1, '2026', 1, '2026-04-28 16:45:43'),
(10, 9, 1, 1, '2026', 1, '2026-04-28 16:45:43'),
(12, 1, 3, 2, '2026', 1, '2026-04-29 04:06:13'),
(13, 4, 4, 2, '2026', 1, '2026-04-29 04:06:13'),
(14, 1, 3, 3, '2026', 1, '2026-04-29 04:06:13'),
(15, 5, 4, 3, '2026', 1, '2026-04-29 04:06:13'),
(16, 3, 5, 4, '2026', 1, '2026-04-29 04:06:13');

-- --------------------------------------------------------

--
-- Estrutura para tabela `escolas`
--

CREATE TABLE `escolas` (
  `id` int(11) NOT NULL,
  `nome` varchar(255) NOT NULL,
  `cnpj` varchar(18) DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  `endereco` text DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `escolas`
--

INSERT INTO `escolas` (`id`, `nome`, `cnpj`, `ativo`, `endereco`, `telefone`, `email`, `created_at`, `updated_at`) VALUES
(1, 'Escola Teste', '11.111.111/1111-11', 1, 'Rua Tal, 12, Cidadela - XX', '11111111111', 'escola@email.com', '2026-04-28 19:37:04', '2026-04-28 19:37:04'),
(2, 'Escola Central Seed', '10.000.000/0001-10', 1, 'Rua Central, 100', '(11) 3000-1000', 'central.seed@email.com', '2026-04-29 07:06:13', '2026-04-29 07:06:13'),
(3, 'Escola Secundária Seed', '20.000.000/0001-20', 1, 'Rua Secundária, 200', '(11) 3000-2000', 'secundaria.seed@email.com', '2026-04-29 07:06:13', '2026-04-29 07:06:13');

-- --------------------------------------------------------

--
-- Estrutura para tabela `log_atividades`
--

CREATE TABLE `log_atividades` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `acao` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `log_atividades`
--

INSERT INTO `log_atividades` (`id`, `usuario_id`, `acao`, `descricao`, `ip`, `criado_em`) VALUES
(1, 1, 'login', 'Usuário realizou login', '::1', '2026-04-28 19:46:26'),
(2, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 05:12:24'),
(3, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 05:12:31'),
(4, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 06:06:18'),
(5, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 06:06:31'),
(6, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 06:43:24'),
(7, 2, 'login', 'Usuário realizou login', '::1', '2026-04-29 06:43:30'),
(8, 2, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:04:06'),
(9, 3, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:04:13'),
(10, 3, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:04:17'),
(11, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:04:23'),
(12, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:04:34'),
(13, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:04:44'),
(14, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:05:10'),
(15, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:05:19'),
(16, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:07:44'),
(17, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:07:51'),
(18, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:14:09'),
(19, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:14:17'),
(20, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:15:02'),
(21, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:15:06'),
(22, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:15:30'),
(23, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:15:36'),
(24, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:46:06'),
(25, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:46:11'),
(26, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:49:55'),
(27, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:50:01'),
(28, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 07:57:52'),
(29, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 07:57:57'),
(30, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:02:23'),
(31, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:02:30'),
(32, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:07:24'),
(33, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:07:32'),
(34, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:09:55'),
(35, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:10:03'),
(36, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:17:42'),
(37, 4, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:17:51'),
(38, 4, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:18:54'),
(39, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:19:00'),
(40, 1, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:24:30'),
(41, 19, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:24:37'),
(42, 19, 'logout', 'Usuário realizou logout', '::1', '2026-04-29 08:30:43'),
(43, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 08:45:24'),
(44, 1, 'login', 'Usuário realizou login', '::1', '2026-04-29 09:03:15');

-- --------------------------------------------------------

--
-- Estrutura para tabela `moderador_escola`
--

CREATE TABLE `moderador_escola` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `escola_id` int(11) NOT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `moderador_escola`
--

INSERT INTO `moderador_escola` (`id`, `usuario_id`, `escola_id`, `criado_em`) VALUES
(8, 4, 2, '2026-04-29 04:15:22'),
(9, 19, 3, '2026-04-29 05:24:17');

-- --------------------------------------------------------

--
-- Estrutura para tabela `notificacoes_email`
--

CREATE TABLE `notificacoes_email` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `avaliacao_id` int(11) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `assunto` varchar(255) NOT NULL,
  `mensagem` text NOT NULL,
  `tipo` varchar(50) NOT NULL DEFAULT 'geral',
  `status` varchar(20) NOT NULL DEFAULT 'pendente',
  `tentativas` int(11) NOT NULL DEFAULT 0,
  `erro` text DEFAULT NULL,
  `agendado_para` datetime DEFAULT NULL,
  `enviado_em` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `notificacoes_email`
--

INSERT INTO `notificacoes_email` (`id`, `usuario_id`, `avaliacao_id`, `email`, `assunto`, `mensagem`, `tipo`, `status`, `tentativas`, `erro`, `agendado_para`, `enviado_em`, `created_at`) VALUES
(1, 3, 1, 'responsavel@email.com', 'Avaliação começará em breve: Teste Email', '<p>Olá, Aluno Padrão.</p><p>A avaliação começará em breve. Prepare-se para acessar o Sistema Avalia no horário informado.</p><p><strong>Atividade:</strong> Teste Email<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_em_breve_manual', 'enviada', 0, NULL, '2026-04-29 03:41:21', '2026-04-29 03:41:27', '2026-04-29 06:41:21'),
(2, 5, 1, 'teste.swg.avalia@gmail.com', 'Avaliação começará em breve: Teste Email', '<p>Olá, Email Teste.</p><p>A avaliação começará em breve. Prepare-se para acessar o Sistema Avalia no horário informado.</p><p><strong>Atividade:</strong> Teste Email<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_em_breve_manual', 'enviada', 0, NULL, '2026-04-29 03:41:21', '2026-04-29 03:41:33', '2026-04-29 06:41:21'),
(3, 3, 3, 'responsavel@email.com', 'Nova avaliação criada: Prova Teste 3', '<p>Olá, Aluno Padrão.</p><p>Uma nova avaliação foi criada no Avalia.</p><p><strong>Atividade:</strong> Prova Teste 3<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_criada', 'enviada', 0, NULL, '2026-04-29 03:42:48', '2026-04-29 03:42:53', '2026-04-29 06:42:48'),
(4, 5, 3, 'teste.swg.avalia@gmail.com', 'Nova avaliação criada: Prova Teste 3', '<p>Olá, Email Teste.</p><p>Uma nova avaliação foi criada no Avalia.</p><p><strong>Atividade:</strong> Prova Teste 3<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_criada', 'enviada', 0, NULL, '2026-04-29 03:42:48', '2026-04-29 03:42:58', '2026-04-29 06:42:48'),
(5, 3, 3, 'responsavel@email.com', 'Avaliação começará em breve: Prova Teste 3', '<p>Olá, Aluno Padrão.</p><p>A avaliação começará em breve. Prepare-se para acessar o Sistema Avalia no horário informado.</p><p><strong>Atividade:</strong> Prova Teste 3<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_em_breve_manual', 'enviada', 0, NULL, '2026-04-29 03:44:21', '2026-04-29 03:44:27', '2026-04-29 06:44:21'),
(6, 5, 3, 'teste.swg.avalia@gmail.com', 'Avaliação começará em breve: Prova Teste 3', '<p>Olá, Email Teste.</p><p>A avaliação começará em breve. Prepare-se para acessar o Sistema Avalia no horário informado.</p><p><strong>Atividade:</strong> Prova Teste 3<br><strong>Turma:</strong> Turma A<br><strong>Disciplina:</strong> Geral<br><strong>Data da prova:</strong> 29/04/2026 08:00</p>', 'avaliacao_em_breve_manual', 'enviada', 0, NULL, '2026-04-29 03:44:21', '2026-04-29 03:44:32', '2026-04-29 06:44:21');

-- --------------------------------------------------------

--
-- Estrutura para tabela `professores`
--

CREATE TABLE `professores` (
  `id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `cpf` varchar(14) DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `celular` varchar(20) DEFAULT NULL,
  `instituicao` varchar(120) DEFAULT NULL,
  `cargo` varchar(60) DEFAULT 'professor'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `professores`
--

INSERT INTO `professores` (`id`, `usuario_id`, `cpf`, `data_nascimento`, `celular`, `instituicao`, `cargo`) VALUES
(1, 2, '222.222.222-22', '1985-04-15', '11999990002', 'Escola Teste', 'Professor'),
(3, 6, '100.000.000-01', '1984-03-15', '(11) 90000-0001', 'Escola Central Seed', 'Professor'),
(4, 7, '100.000.000-02', '1988-07-22', '(11) 90000-0002', 'Escola Central Seed', 'Professor'),
(5, 8, '100.000.000-03', '1981-11-09', '(11) 90000-0003', 'Escola Secundária Seed', 'Professor');

-- --------------------------------------------------------

--
-- Estrutura para tabela `questoes`
--

CREATE TABLE `questoes` (
  `id` int(10) UNSIGNED NOT NULL,
  `avaliacao_id` int(10) UNSIGNED NOT NULL,
  `numero` smallint(6) NOT NULL,
  `titulo` varchar(160) DEFAULT NULL,
  `enunciado` text DEFAULT NULL,
  `gabarito` char(1) DEFAULT NULL,
  `pontos` decimal(6,3) NOT NULL DEFAULT 1.000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `questoes`
--

INSERT INTO `questoes` (`id`, `avaliacao_id`, `numero`, `titulo`, `enunciado`, `gabarito`, `pontos`) VALUES
(1, 2, 1, NULL, 'Alternativa', 'A', 5.000),
(2, 2, 2, NULL, 'Dissertativa', NULL, 5.000),
(3, 3, 1, NULL, 'Questão 1', NULL, 5.000),
(4, 3, 2, NULL, 'Questão 2', NULL, 5.000);

-- --------------------------------------------------------

--
-- Estrutura para tabela `respostas`
--

CREATE TABLE `respostas` (
  `id` int(10) UNSIGNED NOT NULL,
  `avaliacao_id` int(10) UNSIGNED NOT NULL,
  `aluno_id` int(10) UNSIGNED NOT NULL,
  `questao_id` int(10) UNSIGNED NOT NULL,
  `resposta` char(1) DEFAULT NULL,
  `correta` tinyint(1) DEFAULT NULL,
  `corrigida` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `resultados`
--

CREATE TABLE `resultados` (
  `id` int(10) UNSIGNED NOT NULL,
  `avaliacao_id` int(10) UNSIGNED NOT NULL,
  `aluno_id` int(10) UNSIGNED NOT NULL,
  `acertos` smallint(6) DEFAULT NULL,
  `total_questoes` smallint(6) DEFAULT NULL,
  `nota` decimal(5,2) DEFAULT NULL,
  `media_turma` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `resultados`
--

INSERT INTO `resultados` (`id`, `avaliacao_id`, `aluno_id`, `acertos`, `total_questoes`, `nota`, `media_turma`) VALUES
(1, 4, 4, 8, 10, 8.20, 8.23),
(2, 4, 5, 7, 10, 7.40, 8.23),
(3, 4, 6, 9, 10, 9.10, 8.23),
(4, 5, 4, 6, 10, 6.80, 7.33),
(5, 5, 5, 8, 10, 8.00, 7.33),
(6, 5, 6, 7, 10, 7.20, 7.33),
(7, 6, 7, 6, 10, 6.40, 6.93),
(8, 6, 8, 7, 10, 7.10, 6.93),
(9, 6, 9, 8, 10, 8.30, 6.93),
(10, 6, 10, 5, 10, 5.90, 6.93),
(11, 7, 7, 7, 10, 7.30, 7.88),
(12, 7, 8, 9, 10, 9.00, 7.88),
(13, 7, 9, 8, 10, 8.50, 7.88),
(14, 7, 10, 6, 10, 6.70, 7.88),
(15, 8, 11, 9, 10, 9.20, 8.30),
(16, 8, 12, 8, 10, 8.10, 8.30),
(17, 8, 13, 7, 10, 7.60, 8.30);

-- --------------------------------------------------------

--
-- Estrutura para tabela `tipos_usuario`
--

CREATE TABLE `tipos_usuario` (
  `id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `tipos_usuario`
--

INSERT INTO `tipos_usuario` (`id`, `nome`) VALUES
(1, 'admin'),
(3, 'aluno'),
(4, 'moderador'),
(2, 'professor');

-- --------------------------------------------------------

--
-- Estrutura para tabela `turmas`
--

CREATE TABLE `turmas` (
  `id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(80) NOT NULL,
  `serie_ano` varchar(40) DEFAULT NULL,
  `turno` varchar(20) DEFAULT NULL,
  `ano_letivo` year(4) NOT NULL,
  `capacidade_maxima` smallint(6) DEFAULT NULL,
  `professor_id` int(10) UNSIGNED DEFAULT NULL,
  `sala` varchar(30) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `escola_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `turmas`
--

INSERT INTO `turmas` (`id`, `nome`, `serie_ano`, `turno`, `ano_letivo`, `capacidade_maxima`, `professor_id`, `sala`, `ativo`, `escola_id`) VALUES
(1, 'Turma A', '9º Ano - Fundamental', 'Manhã', '2026', 35, 1, 'Sala 01', 1, 1),
(2, 'Turma A - Seed', '9º Ano - Fundamental', 'Manhã', '2026', 35, 3, 'Sala A01', 1, 2),
(3, 'Turma B - Seed', '9º Ano - Fundamental', 'Tarde', '2026', 35, 4, 'Sala B01', 1, 2),
(4, 'Turma C - Seed', '9º Ano - Fundamental', 'Manhã', '2026', 35, 5, 'Sala C01', 1, 3);

-- --------------------------------------------------------

--
-- Estrutura para tabela `turmas_alunos`
--

CREATE TABLE `turmas_alunos` (
  `turma_id` int(10) UNSIGNED NOT NULL,
  `aluno_id` int(10) UNSIGNED NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `turmas_alunos`
--

INSERT INTO `turmas_alunos` (`turma_id`, `aluno_id`, `ativo`) VALUES
(1, 1, 1),
(1, 3, 1),
(2, 4, 1),
(2, 5, 1),
(2, 6, 1),
(3, 7, 1),
(3, 8, 1),
(3, 9, 1),
(3, 10, 1),
(4, 11, 1),
(4, 12, 1),
(4, 13, 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(10) UNSIGNED NOT NULL,
  `nome_completo` varchar(120) NOT NULL,
  `usuario` varchar(60) NOT NULL,
  `cpf_cnpj` varchar(14) DEFAULT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `tipo_id` int(10) UNSIGNED NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `tema` varchar(20) DEFAULT 'claro',
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `email` varchar(120) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `cpf` varchar(14) DEFAULT NULL,
  `avatar_imagem` varchar(255) DEFAULT NULL,
  `avatar_cor` varchar(20) DEFAULT '#9333ea',
  `vlibras_ativo` tinyint(1) NOT NULL DEFAULT 1,
  `alto_contraste` tinyint(1) NOT NULL DEFAULT 0,
  `font_size` varchar(20) NOT NULL DEFAULT 'normal'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome_completo`, `usuario`, `cpf_cnpj`, `senha_hash`, `tipo_id`, `avatar`, `ativo`, `tema`, `criado_em`, `email`, `telefone`, `cpf`, `avatar_imagem`, `avatar_cor`, `vlibras_ativo`, `alto_contraste`, `font_size`) VALUES
(1, 'Administrador', 'admin', NULL, '$2y$10$Uzmvrn4jU8NmzdqQTQ253OQhPhd7XnJc.fsoY7PiEqmv5mebxnoYG', 1, NULL, 1, 'claro', '2026-04-28 16:45:43', 'admin@email.com', '11999990001', '111.111.111-11', NULL, '#9333ea', 1, 0, 'normal'),
(2, 'Professor Padrão', 'professor', NULL, '$2y$10$QSm5wHu/rHWv.qGEydwq1e61Ok0tkqc9BF7Y/5F0mwgI52qhyeWTa', 2, NULL, 1, 'claro', '2026-04-28 16:45:43', 'professor@email.com', '11999990002', '222.222.222-22', NULL, '#2563eb', 1, 0, 'normal'),
(3, 'Aluno Padrão', 'aluno', NULL, '$2y$10$JyU469glkQbUgLd9AL7Yn.X7Tmsk1iDoniunEN9zbZeQfcS..JibS', 3, NULL, 1, 'claro', '2026-04-28 16:45:43', 'aluno@email.com', '11999990003', '333.333.333-33', NULL, '#16a34a', 1, 0, 'normal'),
(4, 'Moderador Padrão', 'moderador', NULL, '$2y$10$..Xzu/JPuGTBG.mC/bEVX.IoXaDVZJ.iuc7ky7o9ouYloDF1lhqvW', 4, NULL, 1, 'claro', '2026-04-28 16:45:43', 'moderador@email.com', '11999990004', '444.444.444-44', NULL, '#dc2626', 1, 0, 'normal'),
(5, 'Email Teste', 'testeApp', NULL, '$2y$10$opyONWzK6CAHkxhhZcfubeBSAKdXc9cTNUIN3PqYDEiG.xDpT/2R.', 3, NULL, 1, 'claro', '2026-04-28 16:47:39', 'teste.swg.avalia@gmail.com', '111111111111111', '11111111111111', NULL, '#9333ea', 1, 0, 'normal'),
(6, 'João Henrique Professor', 'prof.joao', NULL, '$2y$12$GCC6n68Y8i1UvfhFoBMgmehEJxUDdljeJdb.DLqScnFLns6fgC8VC', 2, NULL, 1, 'claro', '2026-04-29 04:06:13', 'prof.joao@seed.com', '(11) 90000-0001', '100.000.000-01', NULL, '#2563eb', 1, 0, 'normal'),
(7, 'Maria Eduarda Professora', 'prof.maria', NULL, '$2y$12$GCC6n68Y8i1UvfhFoBMgmehEJxUDdljeJdb.DLqScnFLns6fgC8VC', 2, NULL, 1, 'claro', '2026-04-29 04:06:13', 'prof.maria@seed.com', '(11) 90000-0002', '100.000.000-02', NULL, '#16a34a', 1, 0, 'normal'),
(8, 'Carlos Alberto Professor', 'prof.carlos', NULL, '$2y$12$GCC6n68Y8i1UvfhFoBMgmehEJxUDdljeJdb.DLqScnFLns6fgC8VC', 2, NULL, 1, 'claro', '2026-04-29 04:06:13', 'prof.carlos@seed.com', '(11) 90000-0003', '100.000.000-03', NULL, '#9333ea', 1, 0, 'normal'),
(9, 'Ana Clara Silva', 'aluno.a1', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.a1@seed.com', '(11) 91000-0001', '200.000.000-01', NULL, '#16a34a', 1, 0, 'normal'),
(10, 'Bruno Martins Lima', 'aluno.a2', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.a2@seed.com', '(11) 91000-0002', '200.000.000-02', NULL, '#16a34a', 1, 0, 'normal'),
(11, 'Camila Souza Rocha', 'aluno.a3', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.a3@seed.com', '(11) 91000-0003', '200.000.000-03', NULL, '#16a34a', 1, 0, 'normal'),
(12, 'Diego Pereira Alves', 'aluno.b1', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.b1@seed.com', '(11) 91000-0004', '200.000.000-04', NULL, '#0891b2', 1, 0, 'normal'),
(13, 'Eduarda Costa Nunes', 'aluno.b2', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.b2@seed.com', '(11) 91000-0005', '200.000.000-05', NULL, '#0891b2', 1, 0, 'normal'),
(14, 'Felipe Gomes Ribeiro', 'aluno.b3', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.b3@seed.com', '(11) 91000-0006', '200.000.000-06', NULL, '#0891b2', 1, 0, 'normal'),
(15, 'Gabriela Mendes Freitas', 'aluno.b4', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.b4@seed.com', '(11) 91000-0007', '200.000.000-07', NULL, '#0891b2', 1, 0, 'normal'),
(16, 'Henrique Barbosa Melo', 'aluno.c1', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.c1@seed.com', '(11) 91000-0008', '200.000.000-08', NULL, '#ea580c', 1, 0, 'normal'),
(17, 'Isabela Cardoso Vieira', 'aluno.c2', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.c2@seed.com', '(11) 91000-0009', '200.000.000-09', NULL, '#ea580c', 1, 0, 'normal'),
(18, 'João Pedro Almeida', 'aluno.c3', NULL, '$2y$12$4MzGtaRaD0WLo4PYt4ce9usb7hgcb2RPRhABh2NtfC1ECBus9v5RW', 3, NULL, 1, 'claro', '2026-04-29 04:06:13', 'aluno.c3@seed.com', '(11) 91000-0010', '200.000.000-10', NULL, '#ea580c', 1, 0, 'normal'),
(19, 'Moderador Teste 2', 'moderador2', NULL, '$2y$10$kpQuc6I/erYzMzkvCZJFKuGhpr1t.DM3M6oijH2Mf5WmtPFe1tcXq', 4, NULL, 1, 'claro', '2026-04-29 05:24:17', 'moderador2@email.com', '11111111111111', '11111111111111', NULL, '#9333ea', 1, 0, 'normal');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `alternativas`
--
ALTER TABLE `alternativas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_alt_q` (`questao_id`);

--
-- Índices de tabela `alunos`
--
ALTER TABLE `alunos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario_id` (`usuario_id`),
  ADD UNIQUE KEY `matricula` (`matricula`),
  ADD KEY `fk_aluno_escola` (`escola_id`);

--
-- Índices de tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_av_turma` (`turma_id`),
  ADD KEY `fk_av_disc` (`disciplina_id`),
  ADD KEY `fk_av_prof` (`professor_id`);

--
-- Índices de tabela `disciplinas`
--
ALTER TABLE `disciplinas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nome` (`nome`);

--
-- Índices de tabela `disciplina_professor_turma`
--
ALTER TABLE `disciplina_professor_turma`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_disc_prof_turma` (`disciplina_id`,`professor_id`,`turma_id`,`ano_letivo`),
  ADD KEY `fk_dpt_disciplina` (`disciplina_id`),
  ADD KEY `fk_dpt_professor` (`professor_id`),
  ADD KEY `fk_dpt_turma` (`turma_id`);

--
-- Índices de tabela `escolas`
--
ALTER TABLE `escolas`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `log_atividades`
--
ALTER TABLE `log_atividades`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `moderador_escola`
--
ALTER TABLE `moderador_escola`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_mod_escola` (`usuario_id`,`escola_id`),
  ADD KEY `fk_me_escola` (`escola_id`);

--
-- Índices de tabela `notificacoes_email`
--
ALTER TABLE `notificacoes_email`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notif_email_status` (`status`,`agendado_para`),
  ADD KEY `idx_notif_email_avaliacao` (`avaliacao_id`,`tipo`);

--
-- Índices de tabela `professores`
--
ALTER TABLE `professores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario_id` (`usuario_id`);

--
-- Índices de tabela `questoes`
--
ALTER TABLE `questoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_q_av` (`avaliacao_id`);

--
-- Índices de tabela `respostas`
--
ALTER TABLE `respostas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resp` (`avaliacao_id`,`aluno_id`,`questao_id`),
  ADD KEY `fk_r_aluno` (`aluno_id`),
  ADD KEY `fk_r_q` (`questao_id`);

--
-- Índices de tabela `resultados`
--
ALTER TABLE `resultados`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resultado` (`avaliacao_id`,`aluno_id`),
  ADD KEY `fk_res_aluno` (`aluno_id`);

--
-- Índices de tabela `tipos_usuario`
--
ALTER TABLE `tipos_usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nome` (`nome`);

--
-- Índices de tabela `turmas`
--
ALTER TABLE `turmas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_turma_prof` (`professor_id`),
  ADD KEY `fk_turma_escola` (`escola_id`);

--
-- Índices de tabela `turmas_alunos`
--
ALTER TABLE `turmas_alunos`
  ADD PRIMARY KEY (`turma_id`,`aluno_id`),
  ADD KEY `fk_ta_aluno` (`aluno_id`);

--
-- Índices de tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD UNIQUE KEY `cpf_cnpj` (`cpf_cnpj`),
  ADD KEY `fk_usr_tipo` (`tipo_id`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `alternativas`
--
ALTER TABLE `alternativas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `alunos`
--
ALTER TABLE `alunos`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `disciplinas`
--
ALTER TABLE `disciplinas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de tabela `disciplina_professor_turma`
--
ALTER TABLE `disciplina_professor_turma`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de tabela `escolas`
--
ALTER TABLE `escolas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `log_atividades`
--
ALTER TABLE `log_atividades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de tabela `moderador_escola`
--
ALTER TABLE `moderador_escola`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `notificacoes_email`
--
ALTER TABLE `notificacoes_email`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `professores`
--
ALTER TABLE `professores`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `questoes`
--
ALTER TABLE `questoes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `respostas`
--
ALTER TABLE `respostas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `resultados`
--
ALTER TABLE `resultados`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de tabela `tipos_usuario`
--
ALTER TABLE `tipos_usuario`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT de tabela `turmas`
--
ALTER TABLE `turmas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `alternativas`
--
ALTER TABLE `alternativas`
  ADD CONSTRAINT `fk_alt_q` FOREIGN KEY (`questao_id`) REFERENCES `questoes` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `alunos`
--
ALTER TABLE `alunos`
  ADD CONSTRAINT `fk_aluno_usr` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Restrições para tabelas `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD CONSTRAINT `fk_av_disc` FOREIGN KEY (`disciplina_id`) REFERENCES `disciplinas` (`id`),
  ADD CONSTRAINT `fk_av_prof` FOREIGN KEY (`professor_id`) REFERENCES `professores` (`id`),
  ADD CONSTRAINT `fk_av_turma` FOREIGN KEY (`turma_id`) REFERENCES `turmas` (`id`);

--
-- Restrições para tabelas `disciplina_professor_turma`
--
ALTER TABLE `disciplina_professor_turma`
  ADD CONSTRAINT `fk_dpt_disciplina` FOREIGN KEY (`disciplina_id`) REFERENCES `disciplinas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dpt_professor` FOREIGN KEY (`professor_id`) REFERENCES `professores` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dpt_turma` FOREIGN KEY (`turma_id`) REFERENCES `turmas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `moderador_escola`
--
ALTER TABLE `moderador_escola`
  ADD CONSTRAINT `fk_me_escola` FOREIGN KEY (`escola_id`) REFERENCES `escolas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_me_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `professores`
--
ALTER TABLE `professores`
  ADD CONSTRAINT `fk_prof_usr` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Restrições para tabelas `questoes`
--
ALTER TABLE `questoes`
  ADD CONSTRAINT `fk_q_av` FOREIGN KEY (`avaliacao_id`) REFERENCES `avaliacoes` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `respostas`
--
ALTER TABLE `respostas`
  ADD CONSTRAINT `fk_r_aluno` FOREIGN KEY (`aluno_id`) REFERENCES `alunos` (`id`),
  ADD CONSTRAINT `fk_r_av` FOREIGN KEY (`avaliacao_id`) REFERENCES `avaliacoes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_r_q` FOREIGN KEY (`questao_id`) REFERENCES `questoes` (`id`);

--
-- Restrições para tabelas `resultados`
--
ALTER TABLE `resultados`
  ADD CONSTRAINT `fk_res_aluno` FOREIGN KEY (`aluno_id`) REFERENCES `alunos` (`id`),
  ADD CONSTRAINT `fk_res_av` FOREIGN KEY (`avaliacao_id`) REFERENCES `avaliacoes` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `turmas`
--
ALTER TABLE `turmas`
  ADD CONSTRAINT `fk_turma_prof` FOREIGN KEY (`professor_id`) REFERENCES `professores` (`id`);

--
-- Restrições para tabelas `turmas_alunos`
--
ALTER TABLE `turmas_alunos`
  ADD CONSTRAINT `fk_ta_aluno` FOREIGN KEY (`aluno_id`) REFERENCES `alunos` (`id`),
  ADD CONSTRAINT `fk_ta_turma` FOREIGN KEY (`turma_id`) REFERENCES `turmas` (`id`);

--
-- Restrições para tabelas `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usr_tipo` FOREIGN KEY (`tipo_id`) REFERENCES `tipos_usuario` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
