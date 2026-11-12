<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Config\Env;
use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\UserRepository;

final class AuthController
{
    public function register(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['full_name', 'email', 'password']);

        $email = strtolower(trim((string) ($input['email'] ?? '')));
        if ($email !== '' && !Validator::isValidEmail($email)) {
            $errors['email'] = 'Invalid email format';
        }
        $password = (string) ($input['password'] ?? '');
        if ($password !== '' && strlen($password) < 6) {
            $errors['password'] = 'Password must be at least 6 characters';
        }
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $repo = new UserRepository();
        if ($repo->findByEmail($email) !== null) {
            Response::error('Email is already registered', 409, ['email' => 'Email already exists']);
        }

        // Security rule: never trust client-supplied role during public registration
        $userId = $repo->create([
            'full_name' => trim((string) $input['full_name']),
            'email' => $email,
            'password_hash' => password_hash($password, PASSWORD_BCRYPT),
            'role' => 'student',
            'student_id_number' => $input['student_id_number'] ?? null,
            'department' => $input['department'] ?? null,
            'phone' => $input['phone'] ?? null,
        ]);

        $token = bin2hex(random_bytes(32));
        $ttlHours = (int) Env::get('TOKEN_TTL_HOURS', '168');
        $expiresAt = date('Y-m-d H:i:s', time() + ($ttlHours * 3600));
        $repo->createSession($userId, $token, $expiresAt);

        $user = $repo->findById($userId);
        Response::ok('Registration successful', [
            'token' => $token,
            'expires_at' => $expiresAt,
            'user' => $user,
        ], 201);
    }

    public function login(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['email', 'password']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $email = strtolower(trim((string) $input['email']));
        $password = (string) $input['password'];

        $repo = new UserRepository();
        $user = $repo->findByEmail($email);

        if ($user === null || !password_verify($password, $user['password_hash'])) {
            Response::error('Invalid email or password', 401);
        }

        if ((int) $user['is_active'] !== 1) {
            Response::error('Account is deactivated', 403);
        }

        $token = bin2hex(random_bytes(32));
        $ttlHours = (int) Env::get('TOKEN_TTL_HOURS', '168');
        $expiresAt = date('Y-m-d H:i:s', time() + ($ttlHours * 3600));
        $repo->createSession((int) $user['id'], $token, $expiresAt);

        unset($user['password_hash']);
        Response::ok('Login successful', [
            'token' => $token,
            'expires_at' => $expiresAt,
            'user' => $user,
        ]);
    }

    public function logout(array $context): void
    {
        if (!empty($context['token'])) {
            (new UserRepository())->revokeSession($context['token']);
        }
        Response::ok('Logged out successfully');
    }
}
