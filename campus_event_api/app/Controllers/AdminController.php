<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Config\Database;
use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\EventRepository;
use App\Repositories\UserRepository;

final class AdminController
{
    public function stats(array $context): void
    {
        $db = Database::getConnection();
        $stats = [
            'total_users' => (int) $db->query('SELECT COUNT(*) FROM users')->fetchColumn(),
            'total_students' => (int) $db->query("SELECT COUNT(*) FROM users WHERE role = 'student'")->fetchColumn(),
            'total_organizers' => (int) $db->query("SELECT COUNT(*) FROM users WHERE role = 'organizer'")->fetchColumn(),
            'total_events' => (int) $db->query('SELECT COUNT(*) FROM events')->fetchColumn(),
            'published_events' => (int) $db->query("SELECT COUNT(*) FROM events WHERE status = 'published'")->fetchColumn(),
            'total_registrations' => (int) $db->query("SELECT COUNT(*) FROM event_registrations WHERE status = 'registered'")->fetchColumn(),
            'total_attendance' => (int) $db->query('SELECT COUNT(*) FROM attendance')->fetchColumn(),
        ];

        Response::ok('Admin statistics retrieved', ['stats' => $stats]);
    }

    public function users(array $context): void
    {
        $role = $_GET['role'] ?? null;
        $users = (new UserRepository())->listUsers($role);
        Response::ok('Users retrieved', ['users' => $users]);
    }

    public function toggleUserStatus(array $context): void
    {
        $userId = (int) ($context['params']['id'] ?? 0);
        $input = Response::readJsonBody();
        $isActive = isset($input['is_active']) ? (int) (bool) $input['is_active'] : 1;

        (new UserRepository())->setActiveStatus($userId, $isActive);
        Response::ok('User status updated');
    }

    public function createCategory(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['name']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $id = (new EventRepository())->createCategory(
            trim((string) $input['name']),
            $input['description'] ?? null
        );
        Response::ok('Category created', ['category_id' => $id], 201);
    }

    public function updateEventStatus(array $context): void
    {
        $eventId = (int) ($context['params']['id'] ?? 0);
        $input = Response::readJsonBody();
        $status = (string) ($input['status'] ?? '');
        if (!in_array($status, ['published', 'cancelled', 'pending_approval', 'completed'], true)) {
            Response::error('Invalid event status', 422);
        }

        (new EventRepository())->updateStatus($eventId, $status);
        Response::ok('Event status updated');
    }
}
