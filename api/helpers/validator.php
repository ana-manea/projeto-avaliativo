<?php
/**
 * Validações de documentos e integração com a API Invertexto.
 * Mantém fallback local para CPF/CNPJ e usa a API quando INVERTEXTO_TOKEN existir no .env.
 */

function onlyDigits($value): string
{
    return preg_replace('/\D+/', '', (string) $value);
}

function cpfValido($value): bool
{
    $cpf = onlyDigits($value);

    if (strlen($cpf) !== 11 || preg_match('/^(\d)\1{10}$/', $cpf)) {
        return false;
    }

    $sum = 0;
    for ($i = 0; $i < 9; $i++) {
        $sum += (int) $cpf[$i] * (10 - $i);
    }

    $digit = ($sum * 10) % 11;
    if ($digit === 10) {
        $digit = 0;
    }

    if ($digit !== (int) $cpf[9]) {
        return false;
    }

    $sum = 0;
    for ($i = 0; $i < 10; $i++) {
        $sum += (int) $cpf[$i] * (11 - $i);
    }

    $digit = ($sum * 10) % 11;
    if ($digit === 10) {
        $digit = 0;
    }

    return $digit === (int) $cpf[10];
}

function cnpjValido($value): bool
{
    $cnpj = onlyDigits($value);

    if (strlen($cnpj) !== 14 || preg_match('/^(\d)\1{13}$/', $cnpj)) {
        return false;
    }

    $calculate = static function (string $base, array $weights): int {
        $sum = 0;
        for ($i = 0; $i < strlen($base); $i++) {
            $sum += (int) $base[$i] * $weights[$i];
        }

        $mod = $sum % 11;
        return $mod < 2 ? 0 : 11 - $mod;
    };

    $digit1 = $calculate(substr($cnpj, 0, 12), [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    $digit2 = $calculate(substr($cnpj, 0, 12) . $digit1, [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);

    return $digit1 === (int) $cnpj[12] && $digit2 === (int) $cnpj[13];
}

function cpfCnpjValido($value): bool
{
    $digits = onlyDigits($value);

    if ($digits === '') {
        return true;
    }

    return (strlen($digits) === 11 && cpfValido($digits))
        || (strlen($digits) === 14 && cnpjValido($digits));
}

function invertextoToken(): string
{
    return getenv('INVERTEXTO_TOKEN') ?: ($_ENV['INVERTEXTO_TOKEN'] ?? '');
}

function validarDocumentoInvertexto($value, string $type = ''): array
{
    $doc = onlyDigits($value);

    if ($doc === '') {
        return ['ok' => true, 'api' => false, 'message' => 'Documento vazio.'];
    }

    if (!(strlen($doc) === 11 || strlen($doc) === 14)) {
        return ['ok' => false, 'api' => false, 'message' => 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos.'];
    }

    if (strlen($doc) === 11 && !cpfValido($doc)) {
        return ['ok' => false, 'api' => false, 'message' => 'CPF inválido pelos dígitos verificadores.'];
    }

    if (strlen($doc) === 14 && !cnpjValido($doc)) {
        return ['ok' => false, 'api' => false, 'message' => 'CNPJ inválido pelos dígitos verificadores.'];
    }

    $token = invertextoToken();
    if ($token === '') {
        return [
            'ok' => true,
            'api' => false,
            'message' => 'Validação local aprovada. Configure INVERTEXTO_TOKEN no .env para validar também pela API Invertexto.'
        ];
    }

    $query = http_build_query([
        'token' => $token,
        'value' => $doc,
    ] + ($type ? ['type' => $type] : []));

    $url = 'https://api.invertexto.com/v1/validator?' . $query;
    $context = stream_context_create([
        'http' => [
            'method' => 'GET',
            'timeout' => 10,
            'ignore_errors' => true,
            'header' => "User-Agent: Avalia/1.0\r\nAccept: application/json\r\n",
        ],
    ]);

    $raw = @file_get_contents($url, false, $context);
    if ($raw === false || $raw === '') {
        return ['ok' => false, 'api' => true, 'message' => 'Não foi possível consultar a API Invertexto. Verifique a conexão ou tente novamente.'];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        return ['ok' => false, 'api' => true, 'message' => 'Resposta inválida da API Invertexto.'];
    }

    $valid = $data['valid'] ?? $data['valido'] ?? $data['is_valid'] ?? null;
    if ($valid === null && isset($data['success'])) {
        $valid = $data['success'];
    }

    if ($valid === true || $valid === 1 || $valid === 'true' || $valid === '1') {
        return ['ok' => true, 'api' => true, 'message' => 'Documento validado pela API Invertexto.', 'data' => $data];
    }

    return ['ok' => false, 'api' => true, 'message' => 'CPF/CNPJ inválido segundo a API Invertexto.', 'data' => $data];
}
