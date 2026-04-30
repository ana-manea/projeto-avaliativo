<?php

if (!defined('AVALIA_SYSTEM')) {
    die('Acesso negado');
}

// Carrega variáveis locais de .env sem versionar credenciais.
$envFile = dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env';
if (is_file($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
            continue;
        }
        [$key, $value] = explode('=', $line, 2);
        $key = trim($key);
        $value = trim(trim($value), '"\'');
        if ($key !== '' && getenv($key) === false) {
            putenv($key . '=' . $value);
            $_ENV[$key] = $value;
        }
    }
}

define('APP_ENV', $_ENV['APP_ENV'] ?? getenv('APP_ENV') ?: 'local');

if (APP_ENV === 'local') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

define('ROOT_PATH', dirname(__DIR__) . DIRECTORY_SEPARATOR);
define('APP_PATH', ROOT_PATH . 'app' . DIRECTORY_SEPARATOR);
define('CONFIG_PATH', ROOT_PATH . 'config' . DIRECTORY_SEPARATOR);
define('CORE_PATH', ROOT_PATH . 'core' . DIRECTORY_SEPARATOR);
define('ROUTES_PATH', ROOT_PATH . 'routes' . DIRECTORY_SEPARATOR);
define('PUBLIC_PATH', ROOT_PATH . 'public' . DIRECTORY_SEPARATOR);
define('STORAGE_PATH', ROOT_PATH . 'storage' . DIRECTORY_SEPARATOR);
define('VIEWS_PATH', APP_PATH . 'Views' . DIRECTORY_SEPARATOR);

define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'banco_avalia');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_CHARSET', 'utf8mb4');

define('SITE_NAME', 'Avalia');
define('SITE_DESCRIPTION', 'Sistema Web de Avaliações');

// URL base dinâmica.
$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
$basePath = rtrim(str_replace('\\', '/', dirname($scriptName)), '/');

if ($basePath === '/public') {
    $basePath = '';
} elseif (str_ends_with($basePath, '/public')) {
    $basePath = substr($basePath, 0, -7);
}

if ($basePath === '/' || $basePath === '.') {
    $basePath = '';
}

define('APP_BASE_PATH', $basePath);
define('SITE_URL', getenv('RAILWAY_PUBLIC_DOMAIN')
    ? 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN')
    : $scheme . '://' . $host . APP_BASE_PATH
);
define('SITE_VERSION', '1.0.0');
define('SESSION_NAME', 'avalia_session');
define('SESSION_LIFETIME', 3600);

define('NIVEL_ALUNO', 'aluno');
define('NIVEL_PROFESSOR', 'professor');
define('NIVEL_MODERADOR', 'moderador');
define('NIVEL_ADMIN', 'admin');

define('NIVEIS_ACESSO', [
    NIVEL_ALUNO => 'Aluno',
    NIVEL_PROFESSOR => 'Professor',
    NIVEL_MODERADOR => 'Moderador',
    NIVEL_ADMIN => 'Administrador',
]);

define('TEMAS', [
    'claro' => 'Modo Claro',
    'escuro' => 'Modo Escuro',
    'daltonico' => 'Modo Daltônico',
    'alto_contraste' => 'Alto Contraste',
]);

define('AVATAR_CORES', [
    'roxo'     => '#9333ea',
    'azul'     => '#2563eb',
    'verde'    => '#16a34a',
    'vermelho' => '#dc2626',
    'laranja'  => '#ea580c',
    'rosa'     => '#db2777',
    'ciano'    => '#0891b2',
    'amarelo'  => '#ca8a04',
    'cinza'    => '#4b5563',
    'indigo'   => '#4f46e5',
    'teal'     => '#0d9488',
    'lime'     => '#65a30d',
]);

define('AVATAR_COR_PADRAO', '#9333ea');
define('ENABLE_VLIBRAS', true);

date_default_timezone_set('America/Sao_Paulo');

function redirect(string $url): void
{
    if (!str_starts_with($url, 'http')) {
        $url = rtrim(SITE_URL, '/') . '/' . ltrim($url, '/');
    }

    header("Location: {$url}");
    exit;
}

function e(?string $string): string
{
    return htmlspecialchars($string ?? '', ENT_QUOTES, 'UTF-8');
}

function formatarData(?string $data, string $formato = 'd/m/Y'): string
{
    if (empty($data)) {
        return '';
    }

    return date($formato, strtotime($data));
}

function gerarMatricula(string $nivel, ?int $ano = null): string
{
    $ano = $ano ?? (int) date('Y');

    $prefixos = [
        NIVEL_ALUNO => 'ALU',
        NIVEL_PROFESSOR => 'PRO',
        NIVEL_MODERADOR => 'MOD',
        NIVEL_ADMIN => 'ADM',
    ];

    $prefixo = $prefixos[$nivel] ?? 'USR';
    $numero = str_pad((string) random_int(1, 9999), 4, '0', STR_PAD_LEFT);

    return $prefixo . $ano . $numero;
}

function avatarIniciais(string $nome): string
{
    $partes = preg_split('/\s+/', trim($nome));

    if (!$partes || empty($partes[0])) {
        return 'U';
    }

    $primeira = mb_strtoupper(mb_substr($partes[0], 0, 1));
    $ultima = count($partes) > 1 ? mb_strtoupper(mb_substr(end($partes), 0, 1)) : '';

    return $primeira . $ultima;
}

function gerarCorAvatar(string $nome): string
{
    $cores = array_values(AVATAR_CORES);

    if (empty(trim($nome))) {
        return AVATAR_COR_PADRAO;
    }

    $hash = crc32(mb_strtolower(trim($nome)));

    return $cores[$hash % count($cores)];
}

function isAjax(): bool
{
    return !empty($_SERVER['HTTP_X_REQUESTED_WITH'])
        && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest';
}

function jsonResponse(mixed $data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}
