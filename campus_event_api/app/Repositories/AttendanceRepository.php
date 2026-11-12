<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\Database;
use PDO;

final class AttendanceRepository
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function createQrToken(int $eventId, int $generatedBy, string $plainToken, string $expiresAt): int
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare(
            'INSERT INTO attendance_qr_tokens (event_id, generated_by, token_hash, expires_at)
             VALUES (:event_id, :generated_by, :token_hash, :expires_at)'
        );
        $stmt->execute([
            'event_id' => $eventId,
            'generated_by' => $generatedBy,
            'token_hash' => $hash,
            'expires_at' => $expiresAt,
        ]);
        return (int) $this->db->lastInsertId();
    }

    public function findValidQrToken(string $plainToken): ?array
    {
        $hash = hash('sha256', $plainToken);
        $stmt = $this->db->prepare(
            'SELECT * FROM attendance_qr_tokens WHERE token_hash = :token_hash LIMIT 1'
        );
        $stmt->execute(['token_hash' => $hash]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function findByRegistrationId(int $registrationId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM attendance WHERE registration_id = :registration_id LIMIT 1');
        $stmt->execute(['registration_id' => $registrationId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function recordAttendance(int $registrationId, int $eventId, int $userId, int $qrTokenId, string $status = 'present'): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO attendance (registration_id, event_id, user_id, qr_token_id, status)
             VALUES (:registration_id, :event_id, :user_id, :qr_token_id, :status)'
        );
        $stmt->execute([
            'registration_id' => $registrationId,
            'event_id' => $eventId,
            'user_id' => $userId,
            'qr_token_id' => $qrTokenId,
            'status' => $status,
        ]);
        return (int) $this->db->lastInsertId();
    }

    public function getEventReport(int $eventId): array
    {
        $stmt = $this->db->prepare(
            "SELECT u.id AS user_id, u.full_name, u.email, u.student_id_number, u.department,
                    a.status AS attendance_status, a.marked_at
             FROM event_registrations r
             INNER JOIN users u ON u.id = r.user_id
             LEFT JOIN attendance a ON a.registration_id = r.id
             WHERE r.event_id = :event_id AND r.status = 'registered'
             ORDER BY a.marked_at DESC, u.full_name ASC"
        );
        $stmt->execute(['event_id' => $eventId]);
        return $stmt->fetchAll();
    }

    public function listByUser(int $userId): array
    {
        $stmt = $this->db->prepare(
            'SELECT a.id, a.status, a.marked_at, e.id AS event_id, e.title, e.venue, e.start_time
             FROM attendance a
             INNER JOIN events e ON e.id = a.event_id
             WHERE a.user_id = :user_id
             ORDER BY a.marked_at DESC'
        );
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetchAll();
    }
}
