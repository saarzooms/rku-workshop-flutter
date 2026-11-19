<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\Database;
use PDO;

final class RegistrationRepository
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function findByEventAndUser(int $eventId, int $userId): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM event_registrations WHERE event_id = :event_id AND user_id = :user_id LIMIT 1'
        );
        $stmt->execute(['event_id' => $eventId, 'user_id' => $userId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function countActiveForEvent(int $eventId): int
    {
        $stmt = $this->db->prepare(
            "SELECT COUNT(*) FROM event_registrations WHERE event_id = :event_id AND status = 'registered'"
        );
        $stmt->execute(['event_id' => $eventId]);
        return (int) $stmt->fetchColumn();
    }

    public function register(int $eventId, int $userId): int
    {
        $existing = $this->findByEventAndUser($eventId, $userId);
        if ($existing !== null) {
            $stmt = $this->db->prepare(
                "UPDATE event_registrations SET status = 'registered', registered_at = NOW(), cancelled_at = NULL WHERE id = :id"
            );
            $stmt->execute(['id' => $existing['id']]);
            return (int) $existing['id'];
        }

        $stmt = $this->db->prepare(
            "INSERT INTO event_registrations (event_id, user_id, status) VALUES (:event_id, :user_id, 'registered')"
        );
        $stmt->execute(['event_id' => $eventId, 'user_id' => $userId]);
        return (int) $this->db->lastInsertId();
    }

    public function cancel(int $registrationId): bool
    {
        $stmt = $this->db->prepare(
            "UPDATE event_registrations SET status = 'cancelled', cancelled_at = NOW() WHERE id = :id"
        );
        return $stmt->execute(['id' => $registrationId]);
    }

    public function listByUser(int $userId): array
    {
        $stmt = $this->db->prepare(
            "SELECT r.id AS registration_id, r.status AS registration_status, r.registered_at,
                    e.id AS event_id, e.title, e.venue, e.start_time, e.end_time, e.status AS event_status,
                    c.name AS category_name,
                    (SELECT a.marked_at FROM attendance a WHERE a.registration_id = r.id LIMIT 1) AS attendance_marked_at
             FROM event_registrations r
             INNER JOIN events e ON e.id = r.event_id
             INNER JOIN event_categories c ON c.id = e.category_id
             WHERE r.user_id = :user_id
             ORDER BY e.start_time DESC"
        );
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetchAll();
    }

    public function listByEvent(int $eventId): array
    {
        $stmt = $this->db->prepare(
            "SELECT r.id AS registration_id, r.status AS registration_status, r.registered_at,
                    u.id AS user_id, u.full_name, u.email, u.student_id_number, u.department,
                    a.marked_at AS attendance_marked_at, a.status AS attendance_status
             FROM event_registrations r
             INNER JOIN users u ON u.id = r.user_id
             LEFT JOIN attendance a ON a.registration_id = r.id
             WHERE r.event_id = :event_id AND r.status = 'registered'
             ORDER BY u.full_name ASC"
        );
        $stmt->execute(['event_id' => $eventId]);
        return $stmt->fetchAll();
    }
}
