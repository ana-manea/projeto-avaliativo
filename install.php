<?php

// O instalador vai servir para fazer a criação do banco de dados e verificar se ocorreu tudo certo. Ele foi projetado para rodar no http://localhost/projeto-avaliativo/install.php

$defaultHost = 'localhost';
$defaultUser = 'root';
$defaultPass = '';
$dbName = 'banco_avalia';
$sqlFile = __DIR__ . '/database/banco_avalia.sql';
$message = '';
$ok = false;

function h($v) { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $host = trim($_POST['host'] ?? $defaultHost);
    $user = trim($_POST['user'] ?? $defaultUser);
    $pass = (string)($_POST['pass'] ?? $defaultPass);

    try {
        if (!is_file($sqlFile)) {
            throw new RuntimeException(('Arquivo SQL não encontrado em database/banco_avalia.sql'));
        }

        $pdo = new PDO("mysql:host={$host};charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);

        $sql = file_get_contents($sqlFile);
        $pdo->exec($sql);

        $env = "APP_ENV=local\n\n" .
            "DB_HOST={$host}\n" .
            "DB_NAME={$dbName}\n" .
            "DB_USER={$user}\n" .
            "DB_PASS={$pass}\n" .
            "\nINVERTEXTO_TOKEN=" . ($_POST["invertexto_token"] ?? "") . "\n";
        file_put_contents(__DIR__ . '/.env', $env);
        
        $ok = true;
        $message = 'Instalação concluída. Banco banco_avalia criado/carregado e .env atualizado.';
    } catch (Throwable $e) {
        $message = 'Erro na instalação: ' . $e->getMessage();
    }
}
?>

<!Doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Instalar Banco de Dados - Avalia</title>
  <style>
    body {
        font-family:Arial,sans-serif;
        background:#f3f4f6;
        margin:0;
        padding:40px;
        color:#111827
    }
    .box {
        max-width:720px;
        margin:auto;
        background:#fff;
        border-radius:16px;
        padding:28px;
        box-shadow:0 10px 30px rgba(0,0,0,.08)
    }
    form {
        padding-right: 30px;
    }
    label {
        display:block;
        font-weight:700;
        margin-top:16px
    }
    input {
        width:100%;
        padding:12px;
        border:1px solid #d1d5db;
        border-radius:10px;
        margin-top:6px;
    }
    button,.btn {
        display:inline-block;
        margin-top:22px;
        background:#7c3aed;
        color:#fff;
        border:0;
        border-radius:10px;
        padding:12px 18px;
        font-weight:700;
        text-decoration:none;
        cursor:pointer
    }
    .msg {
        padding:14px;
        border-radius:10px;
        margin-bottom:16px
    }
    .ok {
        background:#dcfce7;
        color:#166534
    }
    .erro {
        background:#fee2e2;
        color:#991b1b
    }
    .note {
        background:#eef2ff;
        padding:14px;
        border-radius:10px;
        color:#3730a3
    }
    code {
        background:#f3f4f6;
        padding:2px 5px;
        border-radius:6px
    }
  </style>
</head>
<body>
  <main class="box">
    <h1>Instalar Banco de Dados do Projeto Avalia</h1>
    <p class="note">Este instalador cria o banco <code>banco_avalia</code>.</p>
    <?php if ($message): ?><div class="msg <?= $ok ? 'ok' : 'erro' ?>"><?= h($message) ?></div><?php endif; ?>
    <?php if ($ok): ?>
      <p><strong>Logins padrão:</strong></p>
      <ul>
        <li><code>admin</code> / <code>admin123</code></li>
      </ul>
      <a class="btn" href="./">Abrir sistema</a>
    <?php else: ?>
      <form method="post">
        <label>Host do MySQL</label>
        <input name="host" value="<?= h($_POST['host'] ?? $defaultHost) ?>" required>
        <label>Usuário do MySQL</label>
        <input name="user" value="<?= h($_POST['user'] ?? $defaultUser) ?>" required>
        <label>Senha do MySQL</label>
        <input name="pass" type="password" value="<?= h($_POST['pass'] ?? $defaultPass) ?>">
        <label>Token Invertexto (opcional)</label>
        <input name="invertexto_token" value="<?= h($_POST['invertexto_token'] ?? '') ?>" placeholder="Cole aqui o token da API Invertexto">
        <button type="submit">Criar/carregar banco_avalia</button>
      </form>
    <?php endif; ?>
  </main>
</body>
</html>