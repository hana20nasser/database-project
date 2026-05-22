create database radiology_project;
use radiology_project;



create table employee (
    employee_id int primary key auto_increment,
    fname varchar(30) not null,
    lname varchar(30) not null,
    birthdate date,
    street varchar(50) not null,
    state varchar(50) not null,
    city varchar(50) not null,
    specialization varchar(30) not null,
    sex enum('male','female') not null,
    employee_type enum('physician','radiologist','technician') null
);

create table physician (
    employee_id int primary key,
    degree varchar(50),
    medical_license_num varchar(50) unique,
    foreign key (employee_id) references employee(employee_id)
        on update cascade
        on delete cascade
);

create table radiologist (
    employee_id int primary key,
    degree varchar(50),
    radiologist_license_num varchar(50) unique,
    foreign key (employee_id) references employee(employee_id)
        on update cascade
        on delete cascade
);

create table technician (
    employee_id int primary key,
    technical_certification varchar(100),
    experience_years int,
    foreign key (employee_id) references employee(employee_id)
        on update cascade
        on delete cascade
);


create table patient (
    patient_id int primary key auto_increment,
    patient_number varchar(30) unique,
    ssn varchar(20) unique,
    fname varchar(30) not null,
    lname varchar(30) not null,
    birthdate date,
    street varchar(50) not null,
    state varchar(50) not null,
    city varchar(50) not null,
    sex enum('male','female') not null
);

create table patient_phone (
    patient_id int,
    phone varchar(12),
    primary key (patient_id, phone),
    foreign key (patient_id) references patient(patient_id)
        on update cascade
        on delete cascade
);

create table medical_history (
    history_id int primary key auto_increment,
    patient_id int not null,
    condition_name varchar(50),
    description varchar(100),
    diagnosis_date date,
    foreign key (patient_id) references patient(patient_id)
        on update cascade
        on delete cascade
);

create table appointment (
    appointment_id int primary key auto_increment,
    patient_id int not null,
    physician_id int not null,
    appointment_datetime datetime not null,
    appointment_status enum('pending','scheduled','completed','cancelled') default 'pending'
);

alter table appointment
add constraint fk_appointment_patient
foreign key (patient_id) references patient(patient_id)
    on update cascade
    on delete restrict;

alter table appointment
add constraint fk_appointment_physician
foreign key (physician_id) references physician(employee_id)
    on update cascade
    on delete restrict;

create table scan_type (
    scan_type_id int primary key auto_increment,
    scan_name varchar(50) unique not null,
    modality varchar(30),
    description varchar(100)
);

create table scan_request (
    request_id int primary key auto_increment,
    appointment_id int not null,
    scan_type_id int not null,
    request_date date,
    reason varchar(100),
    notes varchar(100),
    request_status enum('pending','accepted') default 'pending'
);

alter table scan_request
add constraint fk_scan_request_appointment
foreign key (appointment_id) references appointment(appointment_id)
    on update cascade
    on delete cascade;

alter table scan_request
add constraint fk_scan_request_scan_type
foreign key (scan_type_id) references scan_type(scan_type_id)
    on update cascade
    on delete restrict;

create table room (
    room_id int primary key auto_increment,
    room_number varchar(20) unique not null,
    room_type varchar(30) not null,
    status enum('available','busy','maintenance') default 'available'
);

create table exam_order (
    exam_id int primary key auto_increment,
    request_id int not null unique,
    room_id int not null,
    technician_id int not null,
    scheduled_datetime datetime not null,
    patient_confirmation_status enum('pending','confirmed','declined') default 'pending'
);

alter table exam_order
add constraint fk_exam_order_request
foreign key (request_id) references scan_request(request_id)
    on update cascade
    on delete cascade;

alter table exam_order
add constraint fk_exam_order_room
foreign key (room_id) references room(room_id)
    on update cascade
    on delete restrict;

alter table exam_order
add constraint fk_exam_order_technician
foreign key (technician_id) references technician(employee_id)
    on update cascade
    on delete restrict;

create table image (
    image_id int primary key auto_increment,
    exam_id int not null,
    image_path varchar(255) not null,
    upload_date date,
    foreign key (exam_id) references exam_order(exam_id)
        on update cascade
        on delete cascade
);

create table report (
    report_id int primary key auto_increment,
    exam_id int not null unique,
    radiologist_id int not null,
    findings varchar(255),
    impression varchar(255),
    recommendation varchar(255),
    report_date date,
    report_status enum('pending','completed','reviewed') default 'pending'
);

alter table report
add constraint fk_report_exam_order
foreign key (exam_id) references exam_order(exam_id)
    on update cascade
    on delete cascade;

alter table report
add constraint fk_report_radiologist
foreign key (radiologist_id) references radiologist(employee_id)
    on update cascade
    on delete restrict;

USE radiology_project;

-- 1. مسح أي بيانات قديمة عشان ما يحصلش تضارب في الـ IDs
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE technician;
TRUNCATE TABLE radiologist;
TRUNCATE TABLE physician;
TRUNCATE TABLE employee;
SET FOREIGN_KEY_CHECKS = 1;

-- 2. إدخال الموظفين في الجدول الرئيسي (Employee) بالـ IDs المطلوبة بالظبط
INSERT INTO employee (employee_id, fname, lname, birthdate, street, state, city, specialization, sex, employee_type) VALUES
(1, 'John', 'Smith', '1980-05-12', '90 Tahrir St', 'Cairo', 'Giza', 'General Physician', 'male', 'physician'),
(2, 'Robert', 'John', '1985-08-22', '15 El-Nasr St', 'Cairo', 'Maadi', 'X-Ray Tech', 'male', 'technician'),
(3, 'Sarah', 'Ahmed', '1988-11-02', '45 Mosaddak St', 'Cairo', 'Dokki', 'Radiologist Specialist', 'female', 'radiologist');

-- 3. ربطهم في الجداول الفرعية بناءً على أدوارهم
INSERT INTO physician (employee_id, degree, medical_license_num) VALUES
(1, 'MD in Internal Medicine', 'LIC-112233');

INSERT INTO technician (employee_id, technical_certification, experience_years) VALUES
(2, 'Certified Radiologic Technologist', 8);

INSERT INTO radiologist (employee_id, degree, radiologist_license_num) VALUES
(3, 'PhD in Diagnostic Radiology', 'LIC-445566');