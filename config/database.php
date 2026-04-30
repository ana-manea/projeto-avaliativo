<?php

namespace Core;

use PDO;
use PDOException;
use PDOStatement;
use Exception;

class Database
{
    private static ?self $instance = null;
    private PDO $connection;

    private function __construct()
    {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;

            $this->connection = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        } catch (PDOException $e) {
            if (APP_ENV === 'local') {
                die('Erro de conexão: ' . $e->getMessage());
            }

            die('Erro ao conectar ao banco de dados.');
        }
    }

    public static function getInstance(): self
    {
        return self::$instance ??= new self();
    }

    public function getConnection(): PDO
    {
        return $this->connection;
    }

    public function query(string $sql, array $params = []): PDOStatement
    {
        $stmt = $this->connection->prepare($sql);
        $stmt->execute($params);

        return $stmt;
    }

    public function fetch(string $sql, array $params = []): ?array
    {
        $result = $this->query($sql, $params)->fetch();

        return $result ?: null;
    }

    public function fetchAll(string $sql, array $params = []): array
    {
        return $this->query($sql, $params)->fetchAll();
    }

    public function insert(string $table, array $data): int
    {
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));

        $sql = "INSERT INTO {$table} ({$columns}) VALUES ({$placeholders})";

        $this->query($sql, $data);

        return (int) $this->connection->lastInsertId();
    }

    public function update(string $table, array $data, string $where, array $whereParams = []): bool
    {
        $set = [];

        foreach (array_keys($data) as $column) {
            $set[] = "{$column} = :{$column}";
        }

        $sql = "UPDATE {$table} SET " . implode(', ', $set) . " WHERE {$where}";

        $this->query($sql, array_merge($data, $whereParams));

        return true;
    }

    public function delete(string $table, string $where, array $params = []): bool
    {
        $this->query("DELETE FROM {$table} WHERE {$where}", $params);

        return true;
    }

    public function count(string $table, string $where = '1=1', array $params = []): int
    {
        $result = $this->fetch("SELECT COUNT(*) AS total FROM {$table} WHERE {$where}", $params);

        return (int) ($result['total'] ?? 0);
    }

    public function beginTransaction(): bool
    {
        return $this->connection->beginTransaction();
    }

    public function commit(): bool
    {
        return $this->connection->commit();
    }

    public function rollback(): bool
    {
        return $this->connection->rollBack();
    }

    private function __clone()
    {
    }

    public function __wakeup(): void
    {
        throw new Exception('Não é permitido desserializar o singleton.');
    }
}