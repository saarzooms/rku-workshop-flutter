<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\Database;
use PDO;

final class EventRepository
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function listEvents(?string $search = null, ?int $categoryId = null, ?string $status = 'published', ?int $organizerId = null): array
    {
        $sql = "SELECT e.*, c.name AS category_name, u.full_name AS organizer_name,
                (SELECT COUNT(*) FROM event_registrations r WHERE r.event_id = e.id AND r.status = 'registered') AS registered_count
                FROM events e
                INNER JOIN event_categories c ON c.id = e.category_id
                INNER JOIN users u ON u.id = e.organizer_id
                WHERE 1=1";
        $params = [];

        if ($status !== null && $status !== '' && $status !== 'all') {
            $sql .= ' AND e.status = :status';
            $params['status'] = $status;
        }
        if ($categoryId !== null && $categoryId > 0) {
            $sql .= ' AND e.category_id = :category_id';
            $params['category_id'] = $categoryId;
        }
        if ($organizerId !== null && $organizerId > 0) {
            $sql .= ' AND e.organizer_id = :organizer_id';
            $params['organizer_id'] = $organizerId;
        }
        if ($search !== null && trim($search) !== '') {
            $sql .= ' AND (e.title LIKE :search_title OR e.description LIKE :search_desc OR e.venue LIKE :search_venue)';
            $like = '%' . trim($search) . '%';
            $params['search_title'] = $like;
            $params['search_desc'] = $like;
            $params['search_venue'] = $like;
        }

        $sql .= ' ORDER BY e.start_time ASC';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public function findById(int $id): ?array
    {
        $stmt = $this->db->prepare(
            "SELECT e.*, c.name AS category_name, u.full_name AS organizer_name,
             (SELECT COUNT(*) FROM event_registrations r WHERE r.event_id = e.id AND r.status = 'registered') AS registered_count
             FROM events e
             INNER JOIN event_categories c ON c.id = e.category_id
             INNER JOIN users u ON u.id = e.organizer_id
             WHERE e.id = :id LIMIT 1"
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(array $data): int
    {
        $stmt = $this->db->prepare(
            'INSERT INTO events (organizer_id, category_id, title, description, venue, start_time, end_time, max_capacity, status)
             VALUES (:organizer_id, :category_id, :title, :description, :venue, :start_time, :end_time, :max_capacity, :status)'
        );
        $stmt->execute([
            'organizer_id' => $data['organizer_id'],
            'category_id' => $data['category_id'],
            'title' => $data['title'],
            'description' => $data['description'],
            'venue' => $data['venue'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'max_capacity' => $data['max_capacity'],
            'status' => $data['status'] ?? 'published',
        ]);
        return (int) $this->db->lastInsertId();
    }

    public function update(int $id, array $data): bool
    {
        $stmt = $this->db->prepare(
            'UPDATE events SET category_id = :category_id, title = :title, description = :description,
             venue = :venue, start_time = :start_time, end_time = :end_time, max_capacity = :max_capacity,
             status = :status WHERE id = :id'
        );
        return $stmt->execute([
            'category_id' => $data['category_id'],
            'title' => $data['title'],
            'description' => $data['description'],
            'venue' => $data['venue'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'max_capacity' => $data['max_capacity'],
            'status' => $data['status'],
            'id' => $id,
        ]);
    }

    public function updateStatus(int $id, string $status): bool
    {
        $stmt = $this->db->prepare('UPDATE events SET status = :status WHERE id = :id');
        return $stmt->execute(['status' => $status, 'id' => $id]);
    }

    public function listCategories(): array
    {
        return $this->db->query('SELECT id, name, description FROM event_categories ORDER BY name ASC')->fetchAll();
    }

    public function createCategory(string $name, ?string $description): int
    {
        $stmt = $this->db->prepare('INSERT INTO event_categories (name, description) VALUES (:name, :description)');
        $stmt->execute(['name' => $name, 'description' => $description]);
        return (int) $this->db->lastInsertId();
    }

    public function categoryExists(int $categoryId): bool
    {
        $stmt = $this->db->prepare('SELECT 1 FROM event_categories WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $categoryId]);
        return (bool) $stmt->fetchColumn();
    }
}
