<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\EventRepository;
use App\Repositories\NotificationRepository;
use App\Services\FcmService;

final class NotificationController
{
    public function saveDeviceToken(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['fcm_token']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $platform = in_array($input['platform'] ?? 'android', ['android', 'ios', 'web'], true)
            ? $input['platform']
            : 'android';

        (new NotificationRepository())->saveDeviceToken(
            (int) $context['user']['id'],
            trim((string) $input['fcm_token']),
            $platform
        );

        Response::ok('Device token registered');
    }

    public function send(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['event_id', 'title', 'body']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $eventId = (int) $input['event_id'];
        $event = (new EventRepository())->findById($eventId);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        if ($user['role'] !== 'admin' && (int) $event['organizer_id'] !== (int) $user['id']) {
            Response::error('Forbidden: only the event organizer can send notifications', 403);
        }

        $notifRepo = new NotificationRepository();
        $tokens = $notifRepo->getTokensForEventRegistrants($eventId);
        $result = (new FcmService())->sendToTokens(
            $tokens,
            trim((string) $input['title']),
            trim((string) $input['body']),
            ['event_id' => (string) $eventId, 'type' => 'event_update']
        );

        $notifRepo->logNotification(
            $eventId,
            (int) $user['id'],
            trim((string) $input['title']),
            trim((string) $input['body']),
            count($tokens)
        );

        Response::ok('Notification processed', array_merge($result, ['recipient_count' => count($tokens)]));
    }
}
