<?php

declare(strict_types=1);

namespace App\Helpers;

final class Response
{
    public static function json(bool $success, string $message, mixed $data = null, int $status = 200, ?array $errors = null): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');

        $payload = [
            'success' => $success,
            'message' => $message,
        ];

        if ($success) {
            $payload['data'] = $data;
        } else {
            $payload['errors'] = $errors ?? new \stdClass();
        }

        echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function ok(string $message, mixed $data = null, int $status = 200): never
    {
        self::json(true, $message, $data, $status);
    }

    public static function error(string $message, int $status = 400, ?array $errors = null): never
    {
        self::json(false, $message, null, $status, $errors);
    }

    public static function readJsonBody(): array
    {
        $raw = file_get_contents('php://input');
        if ($raw === false || trim($raw) === '') {
            return [];
        }
        $decoded = json_decode($raw, true);
        if (!is_array($decoded)) {
            self::error('Invalid JSON request body', 400);
        }
        return $decoded;
    }
}
