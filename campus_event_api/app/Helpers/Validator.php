<?php

declare(strict_types=1);

namespace App\Helpers;

final class Validator
{
    public static function requireFields(array $input, array $fields): array
    {
        $errors = [];
        foreach ($fields as $field) {
            if (!isset($input[$field]) || trim((string) $input[$field]) === '') {
                $errors[$field] = ucfirst(str_replace('_', ' ', $field)) . ' is required';
            }
        }
        return $errors;
    }

    public static function isValidEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }
}
