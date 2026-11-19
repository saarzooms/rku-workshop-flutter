-- Campus Event & Attendance Management System
-- MySQL 8.x / MariaDB Schema & Sample Data

CREATE DATABASE IF NOT EXISTS campus_event_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE campus_event_db;

-- 1. Users
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'organizer', 'admin') NOT NULL DEFAULT 'student',
    student_id_number VARCHAR(50) NULL,
    department VARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_role (role)
) ENGINE=InnoDB;

-- 2. Event Categories
CREATE TABLE IF NOT EXISTS event_categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_categories_name (name)
) ENGINE=InnoDB;

-- 3. Events
CREATE TABLE IF NOT EXISTS events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    organizer_id BIGINT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    description TEXT NOT NULL,
    venue VARCHAR(180) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    max_capacity INT UNSIGNED NOT NULL DEFAULT 100,
    status ENUM('draft', 'pending_approval', 'published', 'cancelled', 'completed') NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_events_category FOREIGN KEY (category_id) REFERENCES event_categories(id) ON DELETE RESTRICT,
    INDEX idx_events_status_start (status, start_time),
    INDEX idx_events_category (category_id),
    INDEX idx_events_organizer (organizer_id)
) ENGINE=InnoDB;

-- 4. Event Registrations
CREATE TABLE IF NOT EXISTS event_registrations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('registered', 'cancelled') NOT NULL DEFAULT 'registered',
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reg_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    CONSTRAINT fk_reg_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_event_user (event_id, user_id),
    INDEX idx_reg_user_status (user_id, status)
) ENGINE=InnoDB;

-- 5. Attendance QR Tokens
CREATE TABLE IF NOT EXISTS attendance_qr_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NOT NULL,
    generated_by BIGINT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_qr_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    CONSTRAINT fk_qr_user FOREIGN KEY (generated_by) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_qr_token_hash (token_hash),
    INDEX idx_qr_event_expires (event_id, expires_at)
) ENGINE=InnoDB;

-- 6. Attendance
CREATE TABLE IF NOT EXISTS attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    registration_id BIGINT UNSIGNED NOT NULL,
    event_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    qr_token_id BIGINT UNSIGNED NULL,
    marked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('present', 'late') NOT NULL DEFAULT 'present',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_att_registration FOREIGN KEY (registration_id) REFERENCES event_registrations(id) ON DELETE CASCADE,
    CONSTRAINT fk_att_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    CONSTRAINT fk_att_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_att_qr FOREIGN KEY (qr_token_id) REFERENCES attendance_qr_tokens(id) ON DELETE SET NULL,
    UNIQUE KEY uq_attendance_registration (registration_id),
    INDEX idx_att_event (event_id),
    INDEX idx_att_user (user_id)
) ENGINE=InnoDB;

-- 7. Device Tokens (FCM)
CREATE TABLE IF NOT EXISTS device_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    fcm_token VARCHAR(512) NOT NULL,
    platform ENUM('android', 'ios', 'web') NOT NULL DEFAULT 'android',
    last_seen_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_dt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_device_fcm_token (fcm_token),
    INDEX idx_dt_user (user_id)
) ENGINE=InnoDB;

-- 8. Notifications History
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT UNSIGNED NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    recipient_count INT UNSIGNED NOT NULL DEFAULT 0,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL,
    CONSTRAINT fk_notif_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. User Sessions (Opaque Bearer Tokens)
CREATE TABLE IF NOT EXISTS user_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sess_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_session_token_hash (token_hash),
    INDEX idx_sess_user_expires (user_id, expires_at)
) ENGINE=InnoDB;

-- ============================================================================
-- SEED DATA (Development Accounts - Password for all: Password123!)
-- ============================================================================

INSERT INTO users (full_name, email, password_hash, role, student_id_number, department, phone) VALUES
('Dr. Meera Shah', 'admin@campus.edu', '$2y$10$VuD10as6ppxHstPp6jsNbO5GyNIMLYAzXsjQkr2XrLJoLyfMF/hbS', 'admin', 'ADM001', 'Administration', '+91-9876543210'),
('Prof. Rohan Verma', 'organizer@campus.edu', '$2y$10$VuD10as6ppxHstPp6jsNbO5GyNIMLYAzXsjQkr2XrLJoLyfMF/hbS', 'organizer', 'FAC102', 'Computer Engineering', '+91-9876543211'),
('Aarav Patel', 'student@campus.edu', '$2y$10$VuD10as6ppxHstPp6jsNbO5GyNIMLYAzXsjQkr2XrLJoLyfMF/hbS', 'student', '24CE001', 'Computer Engineering', '+91-9876543212'),
('Priya Nair', 'priya@campus.edu', '$2y$10$VuD10as6ppxHstPp6jsNbO5GyNIMLYAzXsjQkr2XrLJoLyfMF/hbS', 'student', '24CE002', 'Information Technology', '+91-9876543213');

INSERT INTO event_categories (name, description) VALUES
('Technical', 'Coding workshops, hackathons, and tech talks'),
('Cultural', 'Music, dance, drama, and annual fests'),
('Sports', 'Inter-department tournaments and athletics'),
('Seminar', 'Guest lectures, career guidance, and research talks'),
('Workshop', 'Hands-on skill development sessions');

INSERT INTO events (organizer_id, category_id, title, description, venue, start_time, end_time, max_capacity, status) VALUES
(2, 5, 'Flutter & PHP Full-Stack Bootcamp', 'Build a real-world Campus Event & Attendance app from scratch using Flutter, PHP 8, MySQL, and FCM.', 'Main Auditorium, Block A', DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY + INTERVAL 6 HOUR), 120, 'published'),
(2, 1, 'Annual Campus Hackathon 2026', '24-hour team coding challenge solving campus sustainability and student productivity problems.', 'Innovation Lab, 3rd Floor', DATE_ADD(NOW(), INTERVAL 7 DAY), DATE_ADD(NOW(), INTERVAL 8 DAY), 80, 'published'),
(2, 4, 'AI & Cloud Architecture Seminar', 'Industry architects discuss scalable mobile backends, REST APIs, and responsible AI workflows.', 'Seminar Hall 2', DATE_ADD(NOW(), INTERVAL 10 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY + INTERVAL 3 HOUR), 150, 'published');

INSERT INTO event_registrations (event_id, user_id, status) VALUES
(1, 3, 'registered'),
(2, 3, 'registered'),
(1, 4, 'registered');
