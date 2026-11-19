<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\Database;
use PDO;

final class UserRepository
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function findByEmail(string $email): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function findById(int $id): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT id, full_name, email, role, student_id_number, department, phone, is_active, created_at, updated_at
             FROM users WHERE id = :id LIMIT 1'
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(array $data): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO users (full_name, email, password_hash, role, student_id_number, department, phone)
             VALUES (:full_name, :email, :password_hash, :role, :student_id_number, :department, :phone)'
        );
        $stmt->execute([
            'full_name' => $data['full_name'],
            'email' => $data['email'],
            'password_hash' => $data['password_hash'],
            'role' => $data['role'] ?? 'student',
            'student_id_number' => $data['student_id_number'] ?? null,
            'department' => $data['department'] ?? null,
            'phone' => $data['phone'] ?? null,
        ]);
        return (int) $this->db->lastInsertId();
    }

    public function updateProfile(int $userId, array $data): bool
    {
        $stmt = $this->db->prepare(
            'UPDATE users SET full_name = :full_name, student_id_number = :student_id_number,
             department = :department, phone = :phone WHERE id = :id'
        );
        return $stmt->execute([
            'full_name' => $data['full_name'],
            'student_id_number' => $data['student_id_number'] ?? null,
            'department' => $data['department'] ?? null,
            'phone' => $data['phone'] ?? null,
            'id' => $userId,
        ]);
    }

    public function createSession(int $userId, string $plainToken, string $expiresAt): void
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare(
            'INSERT INTO user_sessions (user_id, token_hash, expires_at) VALUES (:user_id, :token_hash, :expires_at)'
        );
        $stmt->execute([
            'user_id' => $userId,
            'token_hash' => $hash,
            'expires_at' => $expiresAt,
        ]);
    }

    public function findBySessionToken(string $plainToken): ?array
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare(
            'SELECT u.id, u.full_name, u.email, u.role, u.student_id_number, u.department, u.phone, u.is_active
             FROM user_sessions s
             INNER JOIN users u ON u.id = s.user_id
             WHERE s.token_hash = :token_hash
               AND s.is_revoked = 0
               AND s.expires_at > NOW()
             LIMIT 1'
        );
        $stmt->execute(['token_hash' => $hash]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function revokeSession(string $plainToken): void
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare('UPDATE user_sessions SET is_revoked = 1 WHERE token_hash = :token_hash');
        $stmt->execute(['token_hash' => $hash]);
    }

    public function listUsers(?string $role = null): array
    {
        $sql = 'SELECT id, full_name, email, role, student_id_number, department, phone, is_active, created_at FROM users';
        $params = [];
        if ($role !== null && $role !== '') {
            $sql .= ' WHERE role = :role';
            $params['role'] = $role;
        }
        $sql .= ' ORDER BY created_at DESC';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public function setActiveStatus(int $userId, int $isActive): bool
    {
        $stmt = $this->db->prepare('UPDATE users SET is_active = :is_active WHERE id = :id');
        return $stmt->execute(['is_active' => $isActive, 'id' => $userId]);
    }
}
