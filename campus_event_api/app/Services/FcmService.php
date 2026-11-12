<?php

declare(strict_types=1);

namespace App\Services;

use App\Config\Env;

final class FcmService
{
    public function sendToTokens(array $tokens, string $title, string $body, array $data = []): array
    {
        if ($tokens === []) {
            return ['sent' => 0, 'failed' => 0, 'configured' => true, 'note' => 'No registered device tokens'];
        }

        $projectId = Env::get('FCM_PROJECT_ID', '');
        $serviceAccountPath = Env::get('FCM_SERVICE_ACCOUNT_PATH', '');

        if ($projectId === '' || $serviceAccountPath === '' || !is_file($serviceAccountPath)) {
            return [
                'sent' => 0,
                'failed' => 0,
                'configured' => false,
                'note' => 'FCM service account not configured; notification logged in database only.',
            ];
        }

        $accessToken = $this->getGoogleAccessToken($serviceAccountPath);
        if ($accessToken === null) {
            return ['sent' => 0, 'failed' => count($tokens), 'configured' => false, 'note' => 'Failed to obtain Google OAuth2 token'];
        }

        $endpoint = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
        $sent = 0;
        $failed = 0;

        foreach ($tokens as $token) {
            $payload = json_encode([
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => array_map('strval', $data),
                ],
            ]);

            $ch = curl_init($endpoint);
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_HTTPHEADER => [
                    'Authorization: Bearer ' . $accessToken,
                    'Content-Type: application/json',
                ],
                CURLOPT_POSTFIELDS => $payload,
                CURLOPT_TIMEOUT => 10,
            ]);
            curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode >= 200 && $httpCode < 300) {
                $sent++;
            } else {
                $failed++;
            }
        }

        return ['sent' => $sent, 'failed' => $failed, 'configured' => true];
    }

    private function getGoogleAccessToken(string $serviceAccountPath): ?string
    {
        $json = json_decode((string) file_get_contents($serviceAccountPath), true);
        if (!is_array($json) || empty($json['client_email']) || empty($json['private_key'])) {
            return null;
        }

        $now = time();
        $header = $this->base64UrlEncode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $claim = $this->base64UrlEncode(json_encode([
            'iss' => $json['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ]));

        $signature = '';
        if (!openssl_sign("{$header}.{$claim}", $signature, $json['private_key'], OPENSSL_ALGO_SHA256)) {
            return null;
        }

        $jwt = "{$header}.{$claim}." . $this->base64UrlEncode($signature);
        $ch = curl_init('https://oauth2.googleapis.com/token');
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_TIMEOUT => 10,
        ]);
        $resp = curl_exec($ch);
        curl_close($ch);

        $decoded = json_decode((string) $resp, true);
        return $decoded['access_token'] ?? null;
    }

    private function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
