<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Response;
use App\Helpers\Validator;
use App\Repositories\UserRepository;

final class ProfileController
{
    public function show(array $context): void
    {
        $user = (new UserRepository())->findById((int) $context['user']['id']);
        Response::ok('Profile retrieved', ['user' => $user]);
    }

    public function update(array $context): void
    {
        $input = Response::readJsonBody();
        $errors = Validator::requireFields($input, ['full_name']);
        if ($errors !== []) {
            Response::error('Validation failed', 422, $errors);
        }

        $userId = (int) $context['user']['id'];
        $repo = new UserRepository();
        $repo->updateProfile($userId, [
            'full_name' => trim((string) $input['full_name']),
            'student_id_number' => $input['student_id_number'] ?? null,
            'department' => $input['department'] ?? null,
            'phone' => $input['phone'] ?? null,
        ]);

        Response::ok('Profile updated', ['user' => $repo->findById($userId)]);
    }
}
