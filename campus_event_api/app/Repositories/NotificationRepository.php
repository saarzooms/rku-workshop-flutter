<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\Database;
use PDO;

final class NotificationRepository
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function saveDeviceToken(int $userId, string $fcmToken, string $platform = 'android'): void
    {
        $stmt = $this->db->prepare(
            'INSERT INTO device_tokens (user_id, fcm_token, platform, last_seen_at)
             VALUES (:user_id, :fcm_token, :platform, NOW())
             ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), platform = VALUES(platform), last_seen_at = NOW()'
        );
        $stmt->execute([
            'user_id' => $userId,
            'fcm_token' => $fcmToken,
            'platform' => $platform,
        ]);
    }

    public function getTokensForEventRegistrants(int $eventId): array
    {
        $stmt = $this->db->prepare(
            "SELECT DISTINCT dt.fcm_token
             FROM device_tokens dt
             INNER JOIN event_registrations r ON r.user_id = dt.user_id
             WHERE r.event_id = :event_id AND r.status = 'registered'"
        );
        $stmt->execute(['event_id' => $eventId]);
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    public function logNotification(?int $eventId, int $senderId, string $title, string $body, int $recipientCount): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO notifications (event_id, sender_id, title, body, recipient_count)
             VALUES (:event_id, :sender_id, :title, :body, :recipient_count)'
        );
        $stmt->execute([
            'event_id' => $eventId,
            'sender_id' => $senderId,
            'title' => $title,
            'body' => $body,
            'recipient_count' => $recipientCount,
        ]);
        return (int) $this->db->lastInsertId();
    }
}
