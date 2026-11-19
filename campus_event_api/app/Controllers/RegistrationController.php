<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Response;
use App\Repositories\EventRepository;
use App\Repositories\RegistrationRepository;

final class RegistrationController
{
    public function register(array $context): void
    {
        $eventId = (int) ($context['params']['id'] ?? 0);
        $userId = (int) $context['user']['id'];

        $event = (new EventRepository())->findById($eventId);
        if ($event === null) {
            Response::error('Event not found', 404);
        }
        if ($event['status'] !== 'published') {
            Response::error('Registration is closed for this event', 400);
        }
        if (strtotime($event['end_time']) < time()) {
            Response::error('Cannot register for an event that has already ended', 400);
        }

        $regRepo = new RegistrationRepository();
        $existing = $regRepo->findByEventAndUser($eventId, $userId);
        if ($existing !== null && $existing['status'] === 'registered') {
            Response::error('You are already registered for this event', 409);
        }

        $currentCount = $regRepo->countActiveForEvent($eventId);
        if ($currentCount >= (int) $event['max_capacity']) {
            Response::error('Event has reached maximum capacity', 409);
        }

        $regId = $regRepo->register($eventId, $userId);
        Response::ok('Registered for event', ['registration_id' => $regId], 201);
    }

    public function cancel(array $context): void
    {
        $eventId = (int) ($context['params']['id'] ?? 0);
        $userId = (int) $context['user']['id'];

        $event = (new EventRepository())->findById($eventId);
        if ($event === null) {
            Response::error('Event not found', 404);
        }
        if (strtotime($event['start_time']) <= time()) {
            Response::error('Cannot cancel registration after the event has started', 400);
        }

        $regRepo = new RegistrationRepository();
        $existing = $regRepo->findByEventAndUser($eventId, $userId);
        if ($existing === null || $existing['status'] !== 'registered') {
            Response::error('Active registration not found', 404);
        }

        $regRepo->cancel((int) $existing['id']);
        Response::ok('Registration cancelled');
    }

    public function myRegistrations(array $context): void
    {
        $userId = (int) $context['user']['id'];
        $rows = (new RegistrationRepository())->listByUser($userId);
        Response::ok('Registrations retrieved', ['registrations' => $rows]);
    }

    public function eventRegistrants(array $context): void
    {
        $eventId = (int) ($context['params']['id'] ?? 0);
        $event = (new EventRepository())->findById($eventId);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        if ($user['role'] !== 'admin' && (int) $event['organizer_id'] !== (int) $user['id']) {
            Response::error('Forbidden', 403);
        }

        $registrants = (new RegistrationRepository())->listByEvent($eventId);
        Response::ok('Registrants retrieved', ['registrants' => $registrants]);
    }
}
