-- ==============================================================================
-- Chiniot Power HSE Management System - Production Database Schema
-- Dialect: PostgreSQL 15+ with PostGIS Spatial Extension
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ------------------------------------------------------------------------------
-- 1. USERS & RBAC TABLE
-- ------------------------------------------------------------------------------
CREATE TYPE user_role_enum AS ENUM ('worker', 'inspector', 'manager', 'admin');

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id VARCHAR(20) NOT NULL UNIQUE, -- Standard pattern: CP-EMP-XXXX
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role user_role_enum NOT NULL DEFAULT 'worker',
    department VARCHAR(100) NOT NULL,
    plant_unit VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_employee_id ON users(employee_id);
CREATE INDEX idx_users_role ON users(role);

-- ------------------------------------------------------------------------------
-- 2. HAZARDS & 5x5 RISK MATRIX
-- ------------------------------------------------------------------------------
CREATE TYPE capa_status_enum AS ENUM (
    'draft', 
    'reported', 
    'under_review', 
    'assigned', 
    'action_taken', 
    'verification', 
    'closed'
);

CREATE TABLE IF NOT EXISTS hazards (
    id VARCHAR(50) PRIMARY KEY, -- e.g. HZ-2026-0042
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    plant_zone VARCHAR(100) NOT NULL,
    location GEOMETRY(Point, 4326) NOT NULL, -- PostGIS Spatial Coordinate Point
    altitude_meters NUMERIC(6, 2),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    probability INT NOT NULL CHECK (probability BETWEEN 1 AND 5),
    severity INT NOT NULL CHECK (severity BETWEEN 1 AND 5),
    score INT GENERATED ALWAYS AS (probability * severity) STORED, -- Computed 1-25
    status capa_status_enum NOT NULL DEFAULT 'reported',
    assigned_to VARCHAR(150),
    corrective_action TEXT,
    resolution_proof_url TEXT,
    supervisor_sign_off JSONB, -- Stores digital signature, hash, notes, supervisorId
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_hazards_location ON hazards USING GIST(location);
CREATE INDEX idx_hazards_status ON hazards(status);
CREATE INDEX idx_hazards_plant_zone ON hazards(plant_zone);
CREATE INDEX idx_hazards_score ON hazards(score);

-- ------------------------------------------------------------------------------
-- 3. HAZARD MEDIA & WATERMARKED EVIDENCE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hazard_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hazard_id VARCHAR(50) NOT NULL REFERENCES hazards(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    media_type VARCHAR(50) NOT NULL DEFAULT 'image/jpeg',
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_resolution_proof BOOLEAN NOT NULL DEFAULT FALSE,
    watermark_metadata JSONB -- Coordinate tags, device serial, timestamp
);

CREATE INDEX idx_hazard_media_hazard_id ON hazard_media(hazard_id);

-- ------------------------------------------------------------------------------
-- 4. CHECKLIST TEMPLATES & DAILY AUDITS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS checklist_templates (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    plant_unit VARCHAR(100) NOT NULL,
    target_role VARCHAR(50) NOT NULL,
    default_items JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS checklists (
    id VARCHAR(50) PRIMARY KEY, -- e.g. AUD-2026-108
    template_id VARCHAR(50) NOT NULL REFERENCES checklist_templates(id),
    inspector_id UUID NOT NULL REFERENCES users(id),
    plant_unit VARCHAR(100) NOT NULL,
    shift_type VARCHAR(50) NOT NULL,
    completion_rate NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
    status VARCHAR(50) NOT NULL DEFAULT 'completed',
    items JSONB NOT NULL, -- Array of items with Pass/Fail/NA and deviation notes
    audit_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_checklists_audit_date ON checklists(audit_date);
CREATE INDEX idx_checklists_plant_unit ON checklists(plant_unit);

-- ------------------------------------------------------------------------------
-- 5. SAFETY TRAININGS & CERTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trainings (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    duration_hours INT NOT NULL DEFAULT 4,
    mandatory_frequency_days INT NOT NULL DEFAULT 365,
    pdf_doc_url TEXT,
    video_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_certifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id VARCHAR(50) NOT NULL REFERENCES trainings(id),
    employee_id VARCHAR(20) NOT NULL REFERENCES users(employee_id),
    certificate_number VARCHAR(100) NOT NULL UNIQUE,
    score_percentage INT NOT NULL DEFAULT 100,
    issue_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_certifications_expiry ON user_certifications(expiry_date);
CREATE INDEX idx_user_certifications_emp ON user_certifications(employee_id);

-- ------------------------------------------------------------------------------
-- 6. EMERGENCY ALARMS & BROADCAST LOGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emergency_alarms (
    id VARCHAR(50) PRIMARY KEY,
    trigger_user_id UUID NOT NULL REFERENCES users(id),
    plant_area VARCHAR(100) NOT NULL,
    severity_level VARCHAR(50) NOT NULL, -- warning, critical, evacuation
    description TEXT NOT NULL,
    broadcast_channels TEXT[] NOT NULL,
    is_acknowledged BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged_by VARCHAR(150),
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alarms_triggered_at ON emergency_alarms(triggered_at);

-- ------------------------------------------------------------------------------
-- SEED DATA (Chiniot Power Plant Initial Provisioning)
-- ------------------------------------------------------------------------------
INSERT INTO users (employee_id, name, email, password_hash, role, department, plant_unit) VALUES
('CP-EMP-1001', 'Engr. Tariq Khan', 'tariq.khan@chiniotpower.com.pk', '$2b$12$eX4mP1eH4sh...', 'admin', 'Executive HSE Board', 'Plant Headquarters'),
('CP-EMP-1002', 'Asim Raza', 'asim.raza@chiniotpower.com.pk', '$2b$12$eX4mP1eH4sh...', 'manager', 'Safety & Compliance', 'Main Control Station'),
('CP-EMP-1003', 'Hamza Ali', 'hamza.ali@chiniotpower.com.pk', '$2b$12$eX4mP1eH4sh...', 'inspector', 'Field Audit', 'Turbine & Switchyard'),
('CP-EMP-1004', 'Rashid Mehmood', 'rashid.m@chiniotpower.com.pk', '$2b$12$eX4mP1eH4sh...', 'worker', 'Boiler Operations', 'Boiler Unit 1')
ON CONFLICT (employee_id) DO NOTHING;

