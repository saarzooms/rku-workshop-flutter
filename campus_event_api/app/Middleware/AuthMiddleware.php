<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Helpers\Response;
use App\Repositories\UserRepository;

final class AuthMiddleware
{
    public static function extractBearerToken(): ?string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
        if ($header === '' && function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }
        if (preg_match('/Bearer\s+(.+)$/i', $header, $matches)) {
            return trim($matches[1]);
        }
        return null;
    }

    public static function optional(): callable
    {
        return function (array $context): array {
            $token = self::extractBearerToken();
            if ($token !== null) {
                $user = (new UserRepository())->findBySessionToken($token);
                if ($user !== null && (int) $user['is_active'] === 1) {
                    $context['user'] = $user;
                    $context['token'] = $token;
                }
            }
            return $context;
        };
    }

    public static function requireAuth(array $allowedRoles = []): callable
    {
        return function (array $context) use ($allowedRoles): array {
            $token = self::extractBearerToken();
            if ($token === null) {
                Response::error('Authentication required', 401);
            }

            $user = (new UserRepository())->findBySessionToken($token);
            if ($user === null) {
                Response::error('Invalid or expired session token', 401);
            }

            if ((int) $user['is_active'] !== 1) {
                Response::error('Account is deactivated', 403);
            }

            if ($allowedRoles !== [] && !in_array($user['role'], $allowedRoles, true)) {
                Response::error('Forbidden: insufficient permissions', 403);
            }

            $context['user'] = $user;
            $context['token'] = $token;
            return $context;
        };
    }
}
