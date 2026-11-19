<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Config\Env;
use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\AttendanceRepository;
use App\Repositories\EventRepository;
use App\Repositories\RegistrationRepository;

final class AttendanceController
{
    public function generateQr(array $context): void
    {
        $eventId = (int) ($context['params']['id'] ?? 0);
        $event = (new EventRepository())->findById($eventId);
        if ($event === null) {
            Response::error('Event not found', 404);
        }

        $user = $context['user'];
        if ($user['role'] !== 'admin' && (int) $event['organizer_id'] !== (int) $user['id']) {
            Response::error('Forbidden: only the event organizer can generate attendance QR codes', 403);
        }
        if ($event['status'] !== 'published') {
            Response::error('Attendance QR can only be generated for published events', 400);
        }

        $input = Response::readJsonBody();
        $defaultTtl = (int) Env::get('QR_TOKEN_DEFAULT_TTL_MINUTES', '15');
        $ttlMinutes = max(1, min(120, (int) ($input['ttl_minutes'] ?? $defaultTtl)));
        $expiresAt = date('Y-m-d H:i:s', time() + ($ttlMinutes * 60));

        $plainToken = 'CAMPUS_QR_' . $eventId . '_' . bin2hex(random_bytes(16));
        (new AttendanceRepository())->createQrToken($eventId, (int) $user['id'], $plainToken, $expiresAt);

        Response::ok('QR token generated', [
            'event_id' => $eventId,
            'qr_token' => $plainToken,
            'expires_at' => $expiresAt,
            'ttl_minutes' => $ttlMinutes,
        ], 201);
    }

    public function verify(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['qr_token']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $plainToken = trim((string) $input['qr_token']);
        $attRepo = new AttendanceRepository();
        $qrRecord = $attRepo->findValidQrToken($plainToken);

        if ($qrRecord === null || (int) $qrRecord['is_revoked'] === 1) {
            Response::error('Invalid attendance QR code', 400);
        }
        if (strtotime($qrRecord['expires_at']) < time()) {
            Response::error('Attendance QR code has expired', 400);
        }

        $eventId = (int) $qrRecord['event_id'];
        $userId = (int) $context['user']['id'];

        $event = (new EventRepository())->findById($eventId);
        if ($event === null || $event['status'] !== 'published') {
            Response::error('Event is not active for attendance', 400);
        }

        $registration = (new RegistrationRepository())->findByEventAndUser($eventId, $userId);
        if ($registration === null || $registration['status'] !== 'registered') {
            Response::error('You must be registered for this event to mark attendance', 403);
        }

        if ($attRepo->findByRegistrationId((int) $registration['id']) !== null) {
            Response::error('Attendance already recorded for this event', 409);
        }

        $attendanceId = $attRepo->recordAttendance(
            (int) $registration['id'],
            $eventId,
            $userId,
            (int) $qrRecord['id'],
            'present'
        );

        Response::ok('Attendance recorded successfully', [
            'attendance_id' => $attendanceId,
            'event_id' => $eventId,
            'event_title' => $event['title'],
            'status' => 'present',
        ], 201);
    }

    public function eventReport(array $context): void
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

        $rows = (new AttendanceRepository())->getEventReport($eventId);
        $totalRegistered = count($rows);
        $totalPresent = 0;
        foreach ($rows as $row) {
            if ($row['attendance_status'] !== null) {
                $totalPresent++;
            }
        }

        Response::ok('Attendance report retrieved', [
            'summary' => [
                'event_id' => $eventId,
                'event_title' => $event['title'],
                'total_registered' => $totalRegistered,
                'total_present' => $totalPresent,
                'attendance_rate' => $totalRegistered > 0 ? round(($totalPresent / $totalRegistered) * 100, 1) : 0.0,
            ],
            'attendees' => $rows,
        ]);
    }

    public function myAttendance(array $context): void
    {
        $rows = (new AttendanceRepository())->listByUser((int) $context['user']['id']);
        Response::ok('My attendance retrieved', ['attendance' => $rows]);
    }
}
