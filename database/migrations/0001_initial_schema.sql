PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  permissions_json TEXT NOT NULL DEFAULT '[]',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  google_sub TEXT UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL COLLATE NOCASE UNIQUE,
  phone TEXT,
  avatar_url TEXT,
  role_id TEXT NOT NULL REFERENCES roles(id),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS services (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name_ar TEXT NOT NULL,
  description_ar TEXT NOT NULL DEFAULT '',
  image_key TEXT,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS service_requirements (
  id TEXT PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  title_ar TEXT NOT NULL,
  description_ar TEXT NOT NULL DEFAULT '',
  is_required INTEGER NOT NULL DEFAULT 1 CHECK (is_required IN (0,1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS service_schedule_settings (
  id TEXT PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  weekday INTEGER NOT NULL CHECK (weekday BETWEEN 0 AND 6),
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  slot_duration_minutes INTEGER NOT NULL CHECK (slot_duration_minutes > 0),
  capacity INTEGER NOT NULL CHECK (capacity > 0),
  is_closed INTEGER NOT NULL DEFAULT 0 CHECK (is_closed IN (0,1)),
  UNIQUE(service_id, weekday)
);

CREATE TABLE IF NOT EXISTS appointment_slots (
  id TEXT PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id),
  slot_date TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  capacity INTEGER NOT NULL CHECK (capacity > 0),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','closed')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  UNIQUE(service_id, slot_date, start_time)
);

CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  reference TEXT NOT NULL UNIQUE,
  user_id TEXT NOT NULL REFERENCES users(id),
  service_id TEXT NOT NULL REFERENCES services(id),
  slot_id TEXT NOT NULL REFERENCES appointment_slots(id),
  phone_at_booking TEXT NOT NULL,
  booking_status TEXT NOT NULL DEFAULT 'confirmed' CHECK (booking_status IN ('confirmed','completed','cancelled')),
  request_status TEXT NOT NULL DEFAULT 'new' CHECK (request_status IN ('new','processing','awaiting_documents','completed','rejected')),
  customer_note TEXT,
  internal_note TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS documents (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id),
  requirement_id TEXT REFERENCES service_requirements(id),
  file_key TEXT NOT NULL UNIQUE,
  original_filename TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size_bytes INTEGER NOT NULL CHECK (size_bytes > 0),
  status TEXT NOT NULL DEFAULT 'uploaded' CHECK (status IN ('uploaded','under_review','accepted','resubmission_required')),
  uploaded_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS document_reviews (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  reviewer_id TEXT NOT NULL REFERENCES users(id),
  status TEXT NOT NULL CHECK (status IN ('under_review','accepted','resubmission_required')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS booking_history (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  actor_id TEXT REFERENCES users(id),
  field_name TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  note TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  booking_id TEXT REFERENCES bookings(id),
  channel TEXT NOT NULL CHECK (channel IN ('email','whatsapp')),
  template_key TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','sent','failed')),
  provider_message_id TEXT,
  error_message TEXT,
  scheduled_for TEXT,
  sent_at TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS business_settings (
  setting_key TEXT PRIMARY KEY,
  setting_value TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  actor_id TEXT REFERENCES users(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT,
  metadata_json TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_bookings_user_created ON bookings(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bookings_slot_status ON bookings(slot_id, booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_service_status ON bookings(service_id, booking_status, request_status);
CREATE INDEX IF NOT EXISTS idx_slots_service_date ON appointment_slots(service_id, slot_date, status);
CREATE INDEX IF NOT EXISTS idx_documents_booking ON documents(booking_id, status);
CREATE INDEX IF NOT EXISTS idx_notifications_due ON notifications(status, scheduled_for);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at DESC);

INSERT OR IGNORE INTO roles (id, name, description, permissions_json) VALUES
  ('role_customer', 'customer', 'عميل', '[]'),
  ('role_owner', 'owner', 'المدير الرئيسي', '["*"]'),
  ('role_employee', 'employee', 'موظف بصلاحيات محددة', '[]');

INSERT OR IGNORE INTO services (id, slug, name_ar, description_ar, sort_order) VALUES
  ('service_medical', 'medical', 'الفيزا العلاجية', 'خدمات التأشيرة للسفر بغرض العلاج في تركيا.', 1),
  ('service_student', 'student', 'الفيزا الطلابية', 'خدمات التأشيرة للدراسة والقبول الجامعي.', 2),
  ('service_business', 'business', 'الفيزا التجارية', 'خدمات التأشيرة للأعمال والزيارات التجارية.', 3),
  ('service_exhibitions', 'exhibitions', 'الدعوات والمعارض', 'خدمات التأشيرة لحضور الدعوات والمعارض.', 4);

INSERT OR IGNORE INTO business_settings (setting_key, setting_value) VALUES
  ('business_name', 'VIZTOS – فيزتو'),
  ('business_address', 'حلب، الجميلية، بناء مديرية الأوقاف، برج حلب التجاري، الطابق الخامس، المكتب رقم 2'),
  ('business_phone', '00936944321492'),
  ('business_email', 'viztos7@gmail.com'),
  ('business_website', 'https://viztos.com/'),
  ('timezone', 'Asia/Damascus'),
  ('default_reminder_hours', '24'),
  ('default_max_upload_bytes', '10485760');
