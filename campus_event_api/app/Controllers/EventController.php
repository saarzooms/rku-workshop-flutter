<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\EventRepository;
use App\Repositories\RegistrationRepository;

final class EventController
{
    public function index(array $context): void
    {
        $search = $_GET['search'] ?? null;
        $categoryId = isset($_GET['category_id']) && $_GET['category_id'] !== '' ? (int) $_GET['category_id'] : null;
        $user = $context['user'];

        $status = 'published';
        $organizerId = null;
        if ($user !== null && in_array($user['role'], ['organizer', 'admin'], true)) {
            $requestedStatus = $_GET['status'] ?? null;
            if ($requestedStatus !== null && $requestedStatus !== '') {
                $status = $requestedStatus;
            } elseif ($user['role'] === 'organizer' && isset($_GET['mine']) && $_GET['mine'] === '1') {
                $status = 'all';
                $organizerId = (int) $user['id'];
            }
        }

        $events = (new EventRepository())->listEvents($search, $categoryId, $status, $organizerId);
        Response::ok('Events retrieved', ['events' => $events]);
    }

    public function show(array $context): void
    {
        $id = (int) ($context['params']['id'] ?? 0);
        $event = (new EventRepository())->findById($id);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        $isRegistered = false;
        if ($user !== null) {
            $reg = (new RegistrationRepository())->findByEventAndUser($id, (int) $user['id']);
            $isRegistered = $reg !== null && $reg['status'] === 'registered';
        }
        $event['is_registered'] = $isRegistered;

        Response::ok('Event retrieved', ['event' => $event]);
    }

    public function store(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['title', 'description', 'category_id', 'venue', 'start_time', 'end_time', 'max_capacity']);

        $categoryId = (int) ($input['category_id'] ?? 0);
        $maxCapacity = (int) ($input['max_capacity'] ?? 0);
        $repo = new EventRepository();

        if ($categoryId > 0 && !$repo->categoryExists($categoryId)) {
            $errors['category_id'] = 'Category does not exist';
        }
        if ($maxCapacity <= 0) {
            $errors['max_capacity'] = 'Max capacity must be greater than 0';
        }
        if (!empty($input['start_time']) && !empty($input['end_time'])) {
            if (strtotime((string) $input['end_time']) <= strtotime((string) $input['start_time'])) {
                $errors['end_time'] = 'End time must be after start time';
            }
        }
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $eventId = $repo->create([
            'organizer_id' => (int) $context['user']['id'],
            'category_id' => $categoryId,
            'title' => trim((string) $input['title']),
            'description' => trim((string) $input['description']),
            'venue' => trim((string) $input['venue']),
            'start_time' => $input['start_time'],
            'end_time' => $input['end_time'],
            'max_capacity' => $maxCapacity,
            'status' => $input['status'] ?? 'published',
        ]);

        Response::ok('Event created', ['event' => $repo->findById($eventId)], 201);
    }

    public function update(array $context): void
    {
        $id = (int) ($context['params']['id'] ?? 0);
        $repo = new EventRepository();
        $event = $repo->findById($id);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        if ($user['role'] !== 'admin' && (int) $event['organizer_id'] !== (int) $user['id']) {
            Response::error('Forbidden: you can only edit your own events', 403);
        }

        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['title', 'description', 'category_id', 'venue', 'start_time', 'end_time', 'max_capacity']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $repo->update($id, [
            'category_id' => (int) $input['category_id'],
            'title' => trim((string) $input['title']),
            'description' => trim((string) $input['description']),
            'venue' => trim((string) $input['venue']),
            'start_time' => $input['start_time'],
            'end_time' => $input['end_time'],
            'max_capacity' => (int) $input['max_capacity'],
            'status' => $input['status'] ?? $event['status'],
        ]);

        Response::ok('Event updated', ['event' => $repo->findById($id)]);
    }

    public function destroy(array $context): void
    {
        $id = (int) ($context['params']['id'] ?? 0);
        $repo = new EventRepository();
        $event = $repo->findById($id);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        if ($user['role'] !== 'admin' && (int) $event['organizer_id'] !== (int) $user['id']) {
            Response::error('Forbidden: you can only cancel your own events', 403);
        }

        $repo->updateStatus($id, 'cancelled');
        Response::ok('Event cancelled');
    }

    public function categories(array $context): void
    {
        $categories = (new EventRepository())->listCategories();
        Response::ok('Categories retrieved', ['categories' => $categories]);
    }
}
