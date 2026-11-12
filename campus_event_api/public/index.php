<?php

declare(strict_types=1);

use App\Config\Env;
use App\Helpers\Response;

// CORS headers for local development / Flutter web or mobile testing
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$autoload = __DIR__ . '/../vendor/autoload.php';
if (!is_file($autoload)) {
    Response::error('Composer dependencies not installed. Run "composer install".', 500);
}
require_once $autoload;

Env::load(__DIR__ . '/../.env');

set_exception_handler(function (Throwable $e): void {
    $debug = Env::get('APP_DEBUG', 'false') === 'true';
    $logFile = __DIR__ . '/../storage/logs/app.log';
    @file_put_contents($logFile, '[' . date('c') . '] ' . $e->getMessage() . PHP_EOL, FILE_APPEND);

    Response::error(
        $debug ? $e->getMessage() : 'Internal server error',
        500
    );
});

$uriPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$router = require __DIR__ . '/../routes/api.php';
$router->dispatch($_SERVER['REQUEST_METHOD'], $uriPath);
