-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 09, 2025 at 10:00 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.1.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `exam_booker`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointment`
--

CREATE TABLE `appointment` (
  `appointment_id` int(11) NOT NULL,
  `exam_registration_id` int(11) DEFAULT NULL,
  `accomodations` text DEFAULT NULL,
  `appointment_status` enum('Scheduled','Cancelled') NOT NULL,
  `seat_number` int(11) DEFAULT NULL,
  `availability_slot_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointment`
--

INSERT INTO `appointment` (`appointment_id`, `exam_registration_id`, `accomodations`, `appointment_status`, `seat_number`, `availability_slot_id`) VALUES
(3, 2, NULL, 'Scheduled', 5, 11),
(8, 7, NULL, 'Scheduled', 2, 13),
(9, 3, NULL, 'Cancelled', 3, NULL),
(11, 3, NULL, 'Scheduled', 1, 14),
(12, 4, NULL, 'Scheduled', 2, 11),
(13, 5, NULL, 'Scheduled', 1, 6),
(14, 6, NULL, 'Scheduled', 1, 27),
(15, 8, NULL, 'Scheduled', 3, 11),
(16, 9, NULL, 'Scheduled', 2, 6),
(17, 10, NULL, 'Scheduled', 1, 17),
(18, 11, NULL, 'Scheduled', 1, 19),
(19, 12, NULL, 'Scheduled', 1, 29),
(20, 13, NULL, 'Scheduled', 1, 22),
(21, 14, NULL, 'Scheduled', 2, 17),
(22, 15, NULL, 'Scheduled', 2, 14),
(23, 16, NULL, 'Scheduled', 3, 6),
(24, 1, NULL, 'Cancelled', 1, 4),
(25, 1, NULL, 'Cancelled', 1, 4),
(26, 1, NULL, 'Scheduled', 1, 4);

--
-- Triggers `appointment`
--
DELIMITER $$
CREATE TRIGGER `acquire_availability` AFTER INSERT ON `appointment` FOR EACH ROW BEGIN
    UPDATE test_center_availability av
    SET av.scheduled_count = av.scheduled_count + 1
    WHERE av.availability_slot_id = NEW.availability_slot_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `release_availability` AFTER UPDATE ON `appointment` FOR EACH ROW BEGIN
    IF COALESCE(@deleting_availability, 0) = 0 AND OLD.appointment_status = 'Scheduled' AND NEW.appointment_status = 'Cancelled'
    THEN
        UPDATE test_center_availability av
        SET av.scheduled_count = av.scheduled_count - 1
        WHERE av.availability_slot_id = NEW.availability_slot_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `exam`
--

CREATE TABLE `exam` (
  `exam_id` int(11) NOT NULL,
  `exam_sponsor_id` int(11) DEFAULT NULL,
  `exam_name` varchar(100) NOT NULL,
  `exam_duration` int(11) NOT NULL CHECK (`exam_duration` > 0),
  `domain` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam`
--

INSERT INTO `exam` (`exam_id`, `exam_sponsor_id`, `exam_name`, `exam_duration`, `domain`) VALUES
(1, 1, 'Project Management Professional', 230, 'Project Management'),
(2, 1, 'Certified Associate in Project Management', 180, 'Project Management'),
(3, 2, 'SERIES 7', 225, 'Securities and Investments'),
(4, 2, 'SERIES 66', 150, 'Securities and Investments'),
(5, 1, 'Agile Certified Practitioner (PMI-ACP)', 210, 'Agile Management'),
(6, 4, 'Certified Administrative Professional (CAP)', 60, 'Office Administration'),
(7, 4, 'Organizational Management Specialty', 95, 'Business Administration'),
(8, 4, 'Business Management Essentials', 150, 'Business Leadership'),
(9, 4, 'Strategic Leadership Certification', 200, 'Leadership and Strategy'),
(10, 4, 'Performance Management and Analytics', 160, 'Operations Management'),
(11, 5, 'Network Infrastructure Specialist', 120, 'Networking'),
(12, 5, 'Cloud Solutions Architect Exam', 240, 'Cloud Computing'),
(13, 6, 'Certified Medical Office Specialist', 60, 'Healthcare Administration'),
(14, 6, 'Healthcare Compliance Professional', 120, 'Healthcare Compliance'),
(15, 7, 'Certified Clinical Technician', 120, 'Clinical Practice'),
(16, 7, 'Medical Records Specialist', 90, 'Health Information Management'),
(17, 8, 'Renewable Energy Technician', 180, 'Energy Systems'),
(18, 8, 'Power Systems Safety Certification', 55, 'Electrical Safety'),
(19, 9, 'Occupational Safety Certification', 45, 'Workplace Safety'),
(20, 9, 'Certified Compliance Auditor', 210, 'Regulatory Compliance'),
(21, 10, 'Certified Financial Analyst Exam', 240, 'Finance and Investment'),
(22, 10, 'Accounting Fundamentals Proficiency', 180, 'Accounting'),
(23, 11, 'Certified Cybersecurity Analyst', 60, 'Cybersecurity'),
(24, 11, 'Incident Response Specialist', 120, 'Network Defense'),
(25, 12, 'Environmental Impact Assessment Certification', 180, 'Environmental Engineering'),
(26, 13, 'Professional in Human Resources (PHR)', 180, 'Human Resources'),
(27, 14, 'Certified Data Analyst', 60, 'Data Analytics'),
(28, 14, 'AI and Machine Learning Practitioner', 90, 'Artificial Intelligence'),
(29, 14, 'Data Visualization Specialist', 150, 'Data Science'),
(30, 15, 'Solar Energy Systems Technician', 180, 'Renewable Energy'),
(31, 15, 'Wind Turbine Maintenance Certification', 150, 'Renewable Energy'),
(32, 15, 'Energy Storage System Specialist', 90, 'Energy Engineering'),
(33, 1, 'Risk Management Professional', 150, 'Risk Management');

-- --------------------------------------------------------

--
-- Table structure for table `exam_registration`
--

CREATE TABLE `exam_registration` (
  `exam_registration_id` int(11) NOT NULL,
  `exam_id` int(11) DEFAULT NULL,
  `test_taker_id` int(11) DEFAULT NULL,
  `invoice_number` varchar(12) DEFAULT NULL,
  `registration_date` date DEFAULT NULL,
  `amount_paid` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam_registration`
--

INSERT INTO `exam_registration` (`exam_registration_id`, `exam_id`, `test_taker_id`, `invoice_number`, `registration_date`, `amount_paid`) VALUES
(1, 1, 1, 'INV-000001', '2025-10-03', 405.00),
(2, 3, 1, 'INV-000002', '2025-09-17', 300.00),
(3, 8, 3, 'INV-000003', '2025-02-16', 310.00),
(4, 12, 4, 'INV-000004', '2025-03-01', 995.00),
(5, 13, 5, 'INV-000005', '2025-03-15', 180.00),
(6, 17, 6, 'INV-000006', '2025-04-02', 390.00),
(7, 19, 7, 'INV-000007', '2025-04-19', 150.00),
(8, 21, 8, 'INV-000008', '2025-05-05', 825.00),
(9, 23, 9, 'INV-000009', '2025-05-22', 640.00),
(10, 25, 10, 'INV-000010', '2025-06-04', 320.00),
(11, 26, 11, 'INV-000011', '2025-07-10', 375.00),
(12, 27, 12, 'INV-000012', '2025-07-28', 440.00),
(13, 28, 13, 'INV-000013', '2025-08-13', 1125.00),
(14, 30, 14, 'INV-000014', '2025-09-02', 380.00),
(15, 21, 15, 'INV-000015', '2025-09-27', 825.00),
(16, 6, 2, 'INV-000016', '2025-02-04', 225.00);

-- --------------------------------------------------------

--
-- Table structure for table `exam_sponsor`
--

CREATE TABLE `exam_sponsor` (
  `exam_sponsor_id` int(11) NOT NULL,
  `sponsor_name` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam_sponsor`
--

INSERT INTO `exam_sponsor` (`exam_sponsor_id`, `sponsor_name`, `user_id`) VALUES
(1, 'Project Management Institute', 56),
(2, 'FINRA', 42),
(3, 'International Association of Administrative Profes', 43),
(4, 'American Management Association', 44),
(5, 'Global Information Technology Institute', 45),
(6, 'Healthcare Certification Board', 46),
(7, 'National Association of Medical Professionals', 47),
(8, 'Energy Systems Certification Council', 48),
(9, 'International Safety and Compliance Institute', 49),
(10, 'Global Finance and Accounting Academy', 50),
(11, 'Cybersecurity Standards Organization', 51),
(12, 'Environmental Engineering Certification Authority', 52),
(13, 'Human Resources Credentialing Group', 53),
(14, 'Data Analytics and AI Certification Institute', 54),
(15, 'Renewable Energy Training Alliance', 55);

-- --------------------------------------------------------

--
-- Stand-in structure for view `registered_test_takers`
-- (See below for the actual view)
--
CREATE TABLE `registered_test_takers` (
`test_taker_id` int(11)
,`exam_registration_id` int(11)
,`exam_name` varchar(100)
,`exam_duration` int(11)
,`exam_id` int(11)
,`exam_sponsor_id` int(11)
,`appointment_status` enum('Scheduled','Cancelled')
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `scheduled_test_takers`
-- (See below for the actual view)
--
CREATE TABLE `scheduled_test_takers` (
`exam_id` int(11)
,`exam_sponsor_id` int(11)
,`exam_duration` int(11)
,`test_taker_id` int(11)
,`state_address` varchar(30)
,`country` varchar(30)
,`exam_registration_id` int(11)
,`appointment_id` int(11)
,`accomodations` text
,`appointment_status` enum('Scheduled','Cancelled')
,`seat_number` int(11)
,`availability_slot_id` int(11)
,`date_of_availability` date
,`start_time_slot` time
,`end_time_slot` time
,`seat_capacity` int(11)
,`scheduled_count` int(11)
,`test_center_id` int(11)
,`test_center_name` varchar(50)
,`test_center_street` varchar(100)
,`test_center_state` varchar(30)
,`test_center_city` varchar(30)
,`test_center_country` varchar(30)
,`test_center_zip_code` varchar(15)
);

-- --------------------------------------------------------

--
-- Table structure for table `sponsor_contract`
--

CREATE TABLE `sponsor_contract` (
  `sponsor_contract_id` int(11) NOT NULL,
  `exam_sponsor_id` int(11) DEFAULT NULL,
  `sponsor_start_date` date DEFAULT NULL,
  `sponsor_end_date` date DEFAULT NULL,
  `seat_commitment` int(11) DEFAULT NULL,
  `sponsor_contract_status` enum('Active','Expired','Draft','Terminated') DEFAULT NULL,
  `rate_per_tester` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsor_contract`
--

INSERT INTO `sponsor_contract` (`sponsor_contract_id`, `exam_sponsor_id`, `sponsor_start_date`, `sponsor_end_date`, `seat_commitment`, `sponsor_contract_status`, `rate_per_tester`) VALUES
(1, 1, '2020-03-15', '2026-03-14', 500, 'Active', 55.00),
(2, 2, '2020-11-01', '2026-10-31', 600, 'Active', 59.00),
(3, 3, '2023-07-30', '2026-07-29', 1000, 'Active', 61.00),
(4, 4, '2024-03-25', '2026-03-24', 60, 'Active', 63.00),
(5, 5, '2021-04-10', '2026-04-09', 2000, 'Active', 66.00),
(6, 6, '2022-01-20', '2027-01-19', 30, 'Active', 69.00),
(7, 7, '2024-08-10', '2028-08-09', 100, 'Active', 72.00),
(8, 8, '2021-09-01', '2027-08-31', 75, 'Active', 74.00),
(9, 9, '2022-06-05', '2027-06-04', 350, 'Active', 77.00),
(10, 10, '2023-02-14', '2029-02-13', 500, 'Active', 80.00),
(11, 11, '2025-09-01', '2026-08-31', 1500, 'Active', 82.00),
(12, 12, '2023-07-30', '2026-07-29', 150, 'Active', 74.00),
(13, 13, '2020-11-01', '2026-10-31', 250, 'Active', 75.00),
(14, 14, '2023-02-14', '2029-02-13', 100, 'Active', 60.00),
(15, 15, '2020-11-01', '2026-10-31', 450, 'Active', 55.00);

-- --------------------------------------------------------

--
-- Stand-in structure for view `sponsor_exam_details`
-- (See below for the actual view)
--
CREATE TABLE `sponsor_exam_details` (
`exam_sponsor_id` int(11)
,`sponsor_name` varchar(50)
,`exam_id` int(11)
,`exam_name` varchar(100)
,`exam_duration` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `test_center`
--

CREATE TABLE `test_center` (
  `test_center_id` int(11) NOT NULL,
  `test_center_name` varchar(50) NOT NULL,
  `test_center_street` varchar(100) DEFAULT NULL,
  `test_center_city` varchar(30) DEFAULT NULL,
  `test_center_state` varchar(30) DEFAULT NULL,
  `test_center_country` varchar(30) DEFAULT NULL,
  `test_center_zip_code` varchar(15) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test_center`
--

INSERT INTO `test_center` (`test_center_id`, `test_center_name`, `test_center_street`, `test_center_city`, `test_center_state`, `test_center_country`, `test_center_zip_code`, `user_id`) VALUES
(1, 'AVNA Test Center', '123 Main Street', 'New York', 'NY', 'USA', '10021', 59),
(2, 'Riverview Center', '15 Harbor Blvd', 'Boston', 'MA', 'USA', '02110', 59),
(3, 'CertifyNow Testing', '98 Tech Park Drive', 'Atlanta', 'GA', 'USA', '30308', 59),
(4, 'Prometric', '450 Innovation Way', 'Baltimore', 'MD', 'USA', '21202', 59),
(5, 'Eduveritas Center', '234 University Ave', 'Chicago', 'IL', 'USA', '60616', 59),
(6, 'AccuTest Analytics', '76 Research Drive', 'San Diego', 'CA', 'USA', '92101', 59),
(7, 'Summit Certification Group', '300 Summit Blvd', 'Denver', 'CO', 'USA', '80205', 59),
(8, 'Harborview Testing', '50 Pier Street', 'Seattle', 'WA', 'USA', '98121', 59),
(9, 'North Shore Labs', '129 Lakefront Rd', 'Minneapolis', 'MN', 'USA', '55401', 59),
(10, 'Bluesky Center', '400 Aviation Way', 'Dallas', 'TX', 'USA', '75235', 59),
(11, 'Peak Performance', '85 Mountain View Ave', 'Salt Lake City', 'UT', 'USA', '84101', 59),
(12, 'Test Test', '123 Main Street', 'New York', 'NY', 'USA', '10021', 59);

-- --------------------------------------------------------

--
-- Stand-in structure for view `test_centers_with_availability`
-- (See below for the actual view)
--
CREATE TABLE `test_centers_with_availability` (
`test_center_id` int(11)
,`test_center_name` varchar(50)
,`test_center_street` varchar(100)
,`test_center_city` varchar(30)
,`test_center_state` varchar(30)
,`test_center_country` varchar(30)
,`test_center_zip_code` varchar(15)
,`availability_slot_id` int(11)
,`date_of_availability` date
,`start_time_slot` time
,`end_time_slot` time
,`slot_duration` bigint(21)
,`seat_capacity` int(11)
,`scheduled_count` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `test_center_availability`
--

CREATE TABLE `test_center_availability` (
  `availability_slot_id` int(11) NOT NULL,
  `test_center_id` int(11) DEFAULT NULL,
  `date_of_availability` date DEFAULT NULL,
  `start_time_slot` time DEFAULT NULL,
  `end_time_slot` time DEFAULT NULL,
  `seat_capacity` int(11) NOT NULL CHECK (`seat_capacity` >= 0),
  `scheduled_count` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test_center_availability`
--

INSERT INTO `test_center_availability` (`availability_slot_id`, `test_center_id`, `date_of_availability`, `start_time_slot`, `end_time_slot`, `seat_capacity`, `scheduled_count`) VALUES
(1, 1, '2025-12-10', '09:00:00', '10:00:00', 5, 0),
(2, 1, '2025-12-10', '10:00:00', '11:00:00', 5, 0),
(3, 1, '2025-12-10', '11:00:00', '12:00:00', 5, 0),
(4, 1, '2025-12-10', '12:00:00', '16:00:00', 5, 1),
(5, 1, '2025-12-10', '16:00:00', '18:00:00', 5, 0),
(6, 1, '2025-12-11', '09:00:00', '10:00:00', 5, 3),
(7, 1, '2025-12-11', '10:00:00', '11:00:00', 5, 0),
(8, 1, '2025-12-11', '11:00:00', '12:00:00', 5, 0),
(9, 1, '2025-12-11', '12:00:00', '16:00:00', 5, 0),
(10, 1, '2025-12-11', '16:00:00', '18:00:00', 5, 0),
(11, 1, '2025-12-12', '09:00:00', '13:00:00', 5, 3),
(12, 2, '2025-12-05', '09:00:00', '11:00:00', 4, 0),
(13, 2, '2025-12-05', '11:30:00', '13:30:00', 4, 1),
(14, 2, '2026-01-08', '10:00:00', '12:30:00', 5, 2),
(15, 3, '2025-12-10', '08:00:00', '09:00:00', 3, 0),
(17, 3, '2026-01-05', '09:00:00', '12:00:00', 4, 2),
(18, 4, '2025-12-12', '09:00:00', '11:30:00', 4, 0),
(19, 4, '2025-12-12', '12:00:00', '15:00:00', 5, 1),
(20, 4, '2026-01-09', '08:30:00', '11:30:00', 4, 0),
(21, 4, '2026-01-09', '12:00:00', '13:30:00', 3, 0),
(22, 5, '2025-12-15', '09:00:00', '10:30:00', 3, 1),
(23, 5, '2025-12-15', '11:00:00', '13:00:00', 4, 0),
(24, 5, '2026-01-06', '09:00:00', '11:00:00', 5, 0),
(25, 6, '2025-12-18', '08:00:00', '10:00:00', 3, 1),
(26, 6, '2025-12-18', '10:15:00', '12:45:00', 5, 0),
(27, 6, '2026-01-10', '09:00:00', '12:00:00', 4, 1),
(28, 7, '2025-12-20', '09:00:00', '10:00:00', 4, 0),
(29, 7, '2025-12-20', '11:15:00', '12:15:00', 4, 1),
(30, 7, '2026-01-04', '09:00:00', '12:30:00', 5, 0),
(31, 8, '2025-12-22', '08:00:00', '09:00:00', 3, 0),
(32, 8, '2025-12-22', '10:15:00', '13:15:00', 4, 0),
(33, 8, '2026-01-07', '09:00:00', '11:00:00', 5, 0),
(34, 9, '2025-12-28', '09:00:00', '10:00:00', 4, 0),
(35, 9, '2025-12-28', '11:30:00', '14:00:00', 5, 0),
(36, 9, '2026-01-11', '09:00:00', '10:30:00', 3, 0),
(37, 10, '2025-12-30', '09:00:00', '12:00:00', 5, 0),
(38, 10, '2025-12-30', '12:15:00', '14:15:00', 4, 0),
(39, 10, '2026-01-14', '08:00:00', '10:30:00', 3, 0),
(40, 11, '2025-12-31', '09:00:00', '10:00:00', 4, 0),
(41, 11, '2025-12-31', '11:30:00', '13:30:00', 5, 0),
(42, 11, '2026-01-15', '08:00:00', '10:00:00', 3, 0),
(43, 8, '2025-12-22', '09:00:00', '10:00:00', 3, 0),
(44, 7, '2025-12-20', '10:00:00', '11:00:00', 4, 0),
(45, 11, '2025-12-31', '10:00:00', '11:00:00', 4, 0),
(46, 9, '2025-12-28', '10:00:00', '11:00:00', 4, 0),
(47, 3, '2025-12-10', '09:00:00', '10:00:00', 3, 0),
(48, 7, '2025-12-20', '12:15:00', '13:15:00', 4, 0);

--
-- Triggers `test_center_availability`
--
DELIMITER $$
CREATE TRIGGER `cancel_appointments_on_slot_delete` BEFORE DELETE ON `test_center_availability` FOR EACH ROW BEGIN
    SET @deleting_availability := 1;  
    UPDATE appointment ap
    SET ap.appointment_status = 'Cancelled'
    WHERE ap.availability_slot_id = OLD.availability_slot_id AND ap.appointment_status = 'Scheduled';
    SET @deleting_availability := NULL; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `test_center_contract`
--

CREATE TABLE `test_center_contract` (
  `test_center_contract_id` int(11) NOT NULL,
  `test_center_id` int(11) DEFAULT NULL,
  `center_start_date` date DEFAULT NULL,
  `center_end_date` date DEFAULT NULL,
  `center_contract_status` enum('Active','Expired','Draft','Terminated') DEFAULT NULL,
  `rate_per_seat` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test_center_contract`
--

INSERT INTO `test_center_contract` (`test_center_contract_id`, `test_center_id`, `center_start_date`, `center_end_date`, `center_contract_status`, `rate_per_seat`) VALUES
(1, 1, '2020-03-15', '2026-03-14', 'Active', 45.00),
(2, 2, '2020-11-01', '2026-10-31', 'Active', 30.00),
(3, 3, '2023-07-30', '2026-07-29', 'Active', 31.00),
(4, 4, '2024-03-25', '2026-03-24', 'Active', 18.00),
(5, 5, '2021-04-10', '2026-04-09', 'Active', 22.00),
(6, 6, '2022-01-20', '2027-01-19', 'Active', 51.00),
(7, 7, '2024-08-10', '2028-08-09', 'Active', 60.00),
(8, 8, '2021-09-01', '2027-08-31', 'Active', 32.00),
(9, 9, '2022-06-05', '2027-06-04', 'Active', 24.00),
(10, 10, '2023-02-14', '2029-02-13', 'Active', 30.00),
(11, 11, '2025-09-01', '2026-08-31', 'Active', 35.00),
(12, 12, '2025-10-01', '2026-09-30', 'Active', 50.00);

-- --------------------------------------------------------

--
-- Table structure for table `test_taker`
--

CREATE TABLE `test_taker` (
  `test_taker_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `street` varchar(100) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `state_address` varchar(30) DEFAULT NULL,
  `country` varchar(30) DEFAULT NULL,
  `zip_code` varchar(15) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test_taker`
--

INSERT INTO `test_taker` (`test_taker_id`, `first_name`, `last_name`, `phone_number`, `street`, `city`, `state_address`, `country`, `zip_code`, `user_id`) VALUES
(1, 'Billy Bob', 'Jones', '123-456-7890', '123 Main Street', 'New York', 'NY', 'USA', '10021', 1),
(2, 'Jennifer', 'Lane', '234-567-8901', '45 Oak Avenue', 'Chicago', 'IL', 'USA', '60614', 3),
(3, 'Marcus', 'Perez', '345-678-9012', '78 Pine Road', 'Houston', 'TX', 'USA', '77002', 4),
(4, 'Linda', 'Choi', '456-789-0123', '56 Maple Drive', 'Seattle', 'WA', 'USA', '98101', 5),
(5, 'Drew', 'Sanders', '567-890-1234', '89 Elm Street', 'Denver', 'CO', 'USA', '80202', 6),
(6, 'Sophie', 'Michaels', '678-901-2345', '321 Birch Lane', 'Boston', 'MA', 'USA', '02108', 7),
(7, 'Andrew', 'Jameson', '789-012-3456', '654 Walnut Street', 'Atlanta', 'GA', 'USA', '30303', 8),
(8, 'Rachel', 'Liu', '890-123-4567', '99 Cedar Avenue', 'San Francisco', 'CA', 'USA', '94103', 9),
(9, 'Ben', 'Thompson', '901-234-5678', '12 Cherry Blvd', 'Austin', 'TX', 'USA', '73301', 10),
(10, 'Carla', 'Nunez', '212-345-6789', '88 Ash Court', 'Miami', 'FL', 'USA', '33101', 11),
(11, 'Alex', 'Martin', '323-456-7890', '120 Willow Way', 'Los Angeles', 'CA', 'USA', '90001', 12),
(12, 'Natalie', 'Green', '434-567-8901', '456 Poplar Road', 'Portland', 'OR', 'USA', '97201', 13),
(13, 'Omar', 'Ali', '545-678-9012', '75 Cypress Street', 'Dallas', 'TX', 'USA', '75201', 14),
(14, 'Hannah', 'Wells', '656-789-0123', '140 Magnolia Dr', 'Philadelphia', 'PA', 'USA', '19103', 15),
(15, 'Liam', 'Brooks', '767-890-1234', '230 Spruce Lane', 'Salt Lake City', 'UT', 'USA', '84101', 16),
(16, 'Olivia', 'Gray', '878-901-2345', '99 Hickory Ave', 'Minneapolis', 'MN', 'USA', '55401', 17),
(17, 'Noah', 'Reid', '989-012-3456', '11 Pinecone Blvd', 'San Diego', 'CA', 'USA', '92101', 18),
(18, 'Mia', 'Santos', '101-123-4567', '205 Redwood Way', 'Phoenix', 'AZ', 'USA', '85001', 19),
(19, 'Ethan', 'Clarke', '202-234-5678', '75 Chestnut Rd', 'Indianapolis', 'IN', 'USA', '46204', 20),
(20, 'Isabella', 'Long', '303-345-6789', '88 Laurel St', 'Charlotte', 'NC', 'USA', '28202', 21),
(21, 'Alice', 'Johnson', '414-456-7890', '22 Willow Bend', 'Cincinnati', 'OH', 'USA', '45202', 32),
(22, 'Brandon', 'Kim', '525-567-8901', '144 Bayview Dr', 'Baltimore', 'MD', 'USA', '21201', 33),
(23, 'Caroline', 'Rice', '636-678-9012', '98 Meadow Ln', 'Cleveland', 'OH', 'USA', '44114', 34),
(24, 'Diego', 'Morales', '747-789-0123', '31 Hilltop Rd', 'Kansas City', 'MO', 'USA', '64106', 35),
(25, 'Elena', 'Suarez', '858-890-1234', '57 Lakeview Ave', 'Tampa', 'FL', 'USA', '33602', 36),
(26, 'Frederick', 'Owens', '969-901-2345', '76 Brookside Blvd', 'Detroit', 'MI', 'USA', '48226', 37),
(27, 'Grace', 'Lewis', '111-234-5678', '100 Garden Path', 'Nashville', 'TN', 'USA', '37203', 38),
(28, 'Henry', 'Cho', '222-345-6789', '190 Lakewood St', 'Raleigh', 'NC', 'USA', '27601', 39),
(29, 'Irene', 'Park', '333-456-7890', '27 Highland Ave', 'Milwaukee', 'WI', 'USA', '53202', 40),
(30, 'Jason', 'Foster', '444-567-8901', '46 Clover Rd', 'Louisville', 'KY', 'USA', '40202', 41);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(45) DEFAULT NULL,
  `user_password_h` varchar(255) DEFAULT NULL,
  `user_type` char(2) DEFAULT NULL CHECK (`user_type` in ('TC','TT','ES'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `user_email`, `user_password_h`, `user_type`) VALUES
(1, 'billybob@example.com', '$2b$12$ZqGHl6kF0lZdOrv6Zb8d7edSp8LQqgPwcQxj6kH2AvnDJR7rF3vG.', 'TT'),
(2, 'avnatestcenter@example.com', '$2b$12$8YxgE7D9rVw5Y9JfCkq9UOtYz4R2yE7m2VqM4zV4WQ8U1lHq9zZJq', 'TC'),
(3, 'jennifer.lane@example.com', 'a87ff679a2f3e71d9181a67b7542122c', 'TT'),
(4, 'marcus_perez@example.com', '25d55ad283aa400af464c76d713c07ad', 'TT'),
(5, 'linda.choi@example.com', '098f6bcd4621d373cade4e832627b4f6', 'TT'),
(6, 'drew.sanders@example.com', '202cb962ac59075b964b07152d234b70', 'TT'),
(7, 'sophie.michaels@example.com', '81dc9bdb52d04dc20036dbd8313ed055', 'TT'),
(8, 'andrew.jameson@example.com', 'e99a18c428cb38d5f260853678922e03', 'TT'),
(9, 'rachel_liu@example.com', '21232f297a57a5a743894a0e4a801fc3', 'TT'),
(10, 'ben.thompson@example.com', '5ebe2294ecd0e0f08eab7690d2a6ee69', 'TT'),
(11, 'carla.nunez@example.com', '900150983cd24fb0d6963f7d28e17f72', 'TT'),
(12, 'alex.martin@example.com', '827ccb0eea8a706c4c34a16891f84e7b', 'TT'),
(13, 'natalie.green@example.com', 'c4ca4238a0b923820dcc509a6f75849b', 'TT'),
(14, 'omar.ali@example.com', '6512bd43d9caa6e02c990b0a82652dca', 'TT'),
(15, 'hannah.wells@example.com', 'c20ad4d76fe97759aa27a0c99bff6710', 'TT'),
(16, 'liam.brooks@example.com', 'c51ce410c124a10e0db5e4b97fc2af39', 'TT'),
(17, 'olivia.gray@example.com', 'aab3238922bcc25a6f606eb525ffdc56', 'TT'),
(18, 'noah.reid@example.com', '9bf31c7ff062936a96d3c8bd1f8f2ff3', 'TT'),
(19, 'mia.santos@example.com', 'c74d97b01eae257e44aa9d5bade97baf', 'TT'),
(20, 'ethan.clarke@example.com', '70efdf2ec9b086079795c442636b55fb', 'TT'),
(21, 'isabella.long@example.com', '6f4922f45568161a8cdf4ad2299f6d23', 'TT'),
(22, 'riverview.center@example.com', '3c59dc048e8850243be8079a5c74d079', 'TC'),
(23, 'certifynow.testing@example.com', '1f0e3dad99908345f7439f8ffabdffc4', 'TC'),
(24, 'prometric.lab@example.com', '98f13708210194c475687be6106a3b84', 'TC'),
(25, 'eduveritas.center@example.com', '3b5d5c3712955042212316173ccf37be', 'TC'),
(26, 'accutest.analytics@example.com', 'b6d767d2f8ed5d21a44b0e5886680cb9', 'TC'),
(27, 'summit.certgroup@example.com', '37693cfc748049e45d87b8c7d8b9aacd', 'TC'),
(28, 'harborview.testing@example.com', '1ff1de774005f8da13f42943881c655f', 'TC'),
(29, 'northshore.tc@example.com', '8e296a067a37563370ded05f5a3bf3ec', 'TC'),
(30, 'bluesky.center@example.com', '4e732ced3463d06de0ca9a15b6153677', 'TC'),
(31, 'peakperformance.tc@example.com', '02e74f10e0327ad868d138f2b4fdd6f0', 'TC'),
(32, 'alice.johnson@example.com', '33e75ff09dd601bbe69f351039152189', 'TT'),
(33, 'brandon.kim@example.com', '6ea9ab1baa0efb9e19094440c317e21b', 'TT'),
(34, 'caroline.rice@example.com', '34173cb38f07f89ddbebc2ac9128303f', 'TT'),
(35, 'diego.morales@example.com', 'c16a5320fa475530d9583c34fd356ef5', 'TT'),
(36, 'elena.suarez@example.com', '6364d3f0f495b6ab9dcf8d3b5c6e0b01', 'TT'),
(37, 'frederick.owens@example.com', '182be0c5cdcd5072bb1864cdee4d3d6e', 'TT'),
(38, 'grace.lewis@example.com', '1b6453892473a467d07372d45eb05abc', 'TT'),
(39, 'henry.cho@example.com', '8f14e45fceea167a5a36dedd4bea2543', 'TT'),
(40, 'irene.park@example.com', 'b53b3a3d6ab90ce0268229151c9bde11', 'TT'),
(41, 'jason.foster@example.com', '9a1158154dfa42caddbd0694a4e9bdc8', 'TT'),
(42, 'finra@example.com', 'ZqGHl6kF0lZdOrv6Zb8d7edSp8LQqgPwcQxj6kH', 'ES'),
(43, 'iaa@example.com', '1f0e3dad99908345f7439f8ffabdffc4', 'ES'),
(44, 'ama@example.com', '98f13708210194c475687be6106a3b84', 'ES'),
(45, 'giti@example.com', '3b5d5c3712955042212316173ccf37be', 'ES'),
(46, 'hcb@example.com', 'b6d767d2f8ed5d21a44b0e5886680cb9', 'ES'),
(47, 'nationalmedical@example.com', '37693cfc748049e45d87b8c7d8b9aacd', 'ES'),
(48, 'energysystems@example.com', '1ff1de774005f8da13f42943881c655f', 'ES'),
(49, 'isci@example.com', '8e296a067a37563370ded05f5a3bf3ec', 'ES'),
(50, 'globalfinance@example.com', '4e732ced3463d06de0ca9a15b6153677', 'ES'),
(51, 'cyberstandards@example.com', '02e74f10e0327ad868d138f2b4fdd6f0', 'ES'),
(52, 'eeca@example.com', '33e75ff09dd601bbe69f351039152189', 'ES'),
(53, 'hrcg@example.com', '6ea9ab1baa0efb9e19094440c317e21b', 'ES'),
(54, 'dataanalytics@example.com', '34173cb38f07f89ddbebc2ac9128303f', 'ES'),
(55, 'energytrainingalliance@example.com', '9bf31c7ff062936a96d3c8bd1f8f2ff3', 'ES'),
(56, 'pmi@example.com', '5f4dcc3b5aa765d61d8327deb882cf99', 'ES'),
(59, 'testtest@example.com', 'a$2b$12$8YxgE7D9rVw5Y9JfC', 'TC');

-- --------------------------------------------------------

--
-- Structure for view `registered_test_takers`
--
DROP TABLE IF EXISTS `registered_test_takers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `registered_test_takers`  AS SELECT `r`.`test_taker_id` AS `test_taker_id`, `r`.`exam_registration_id` AS `exam_registration_id`, `e`.`exam_name` AS `exam_name`, `e`.`exam_duration` AS `exam_duration`, `e`.`exam_id` AS `exam_id`, `e`.`exam_sponsor_id` AS `exam_sponsor_id`, `a`.`appointment_status` AS `appointment_status` FROM ((`exam` `e` join `exam_registration` `r` on(`e`.`exam_id` = `r`.`exam_id`)) left join `appointment` `a` on(`r`.`exam_registration_id` = `a`.`exam_registration_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `scheduled_test_takers`
--
DROP TABLE IF EXISTS `scheduled_test_takers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `scheduled_test_takers`  AS SELECT `e`.`exam_id` AS `exam_id`, `e`.`exam_sponsor_id` AS `exam_sponsor_id`, `e`.`exam_duration` AS `exam_duration`, `t`.`test_taker_id` AS `test_taker_id`, `t`.`state_address` AS `state_address`, `t`.`country` AS `country`, `r`.`exam_registration_id` AS `exam_registration_id`, `a`.`appointment_id` AS `appointment_id`, `a`.`accomodations` AS `accomodations`, `a`.`appointment_status` AS `appointment_status`, `a`.`seat_number` AS `seat_number`, `av`.`availability_slot_id` AS `availability_slot_id`, `av`.`date_of_availability` AS `date_of_availability`, `av`.`start_time_slot` AS `start_time_slot`, `av`.`end_time_slot` AS `end_time_slot`, `av`.`seat_capacity` AS `seat_capacity`, `av`.`scheduled_count` AS `scheduled_count`, `tc`.`test_center_id` AS `test_center_id`, `tc`.`test_center_name` AS `test_center_name`, `tc`.`test_center_street` AS `test_center_street`, `tc`.`test_center_state` AS `test_center_state`, `tc`.`test_center_city` AS `test_center_city`, `tc`.`test_center_country` AS `test_center_country`, `tc`.`test_center_zip_code` AS `test_center_zip_code` FROM (((((`test_taker` `t` join `exam_registration` `r` on(`t`.`test_taker_id` = `r`.`test_taker_id`)) join `exam` `e` on(`r`.`exam_id` = `e`.`exam_id`)) join `appointment` `a` on(`r`.`exam_registration_id` = `a`.`exam_registration_id`)) join `test_center_availability` `av` on(`a`.`availability_slot_id` = `av`.`availability_slot_id`)) join `test_center` `tc` on(`av`.`test_center_id` = `tc`.`test_center_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `sponsor_exam_details`
--
DROP TABLE IF EXISTS `sponsor_exam_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sponsor_exam_details`  AS SELECT `s`.`exam_sponsor_id` AS `exam_sponsor_id`, `s`.`sponsor_name` AS `sponsor_name`, `e`.`exam_id` AS `exam_id`, `e`.`exam_name` AS `exam_name`, `e`.`exam_duration` AS `exam_duration` FROM (`exam` `e` join `exam_sponsor` `s` on(`e`.`exam_sponsor_id` = `s`.`exam_sponsor_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `test_centers_with_availability`
--
DROP TABLE IF EXISTS `test_centers_with_availability`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `test_centers_with_availability`  AS SELECT `tc`.`test_center_id` AS `test_center_id`, `tc`.`test_center_name` AS `test_center_name`, `tc`.`test_center_street` AS `test_center_street`, `tc`.`test_center_city` AS `test_center_city`, `tc`.`test_center_state` AS `test_center_state`, `tc`.`test_center_country` AS `test_center_country`, `tc`.`test_center_zip_code` AS `test_center_zip_code`, `av`.`availability_slot_id` AS `availability_slot_id`, `av`.`date_of_availability` AS `date_of_availability`, `av`.`start_time_slot` AS `start_time_slot`, `av`.`end_time_slot` AS `end_time_slot`, timestampdiff(MINUTE,`av`.`start_time_slot`,`av`.`end_time_slot`) AS `slot_duration`, `av`.`seat_capacity` AS `seat_capacity`, `av`.`scheduled_count` AS `scheduled_count` FROM (`test_center` `tc` join `test_center_availability` `av` on(`tc`.`test_center_id` = `av`.`test_center_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointment`
--
ALTER TABLE `appointment`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `exam_registration_id` (`exam_registration_id`),
  ADD KEY `availability_slot_id` (`availability_slot_id`);

--
-- Indexes for table `exam`
--
ALTER TABLE `exam`
  ADD PRIMARY KEY (`exam_id`),
  ADD KEY `exam_sponsor_id` (`exam_sponsor_id`);

--
-- Indexes for table `exam_registration`
--
ALTER TABLE `exam_registration`
  ADD PRIMARY KEY (`exam_registration_id`),
  ADD KEY `exam_id` (`exam_id`),
  ADD KEY `test_taker_id` (`test_taker_id`);

--
-- Indexes for table `exam_sponsor`
--
ALTER TABLE `exam_sponsor`
  ADD PRIMARY KEY (`exam_sponsor_id`),
  ADD KEY `exam_sponsor_ibfk_1` (`user_id`);

--
-- Indexes for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  ADD PRIMARY KEY (`sponsor_contract_id`),
  ADD KEY `exam_sponsor_id` (`exam_sponsor_id`);

--
-- Indexes for table `test_center`
--
ALTER TABLE `test_center`
  ADD PRIMARY KEY (`test_center_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `test_center_availability`
--
ALTER TABLE `test_center_availability`
  ADD PRIMARY KEY (`availability_slot_id`),
  ADD KEY `test_center_id` (`test_center_id`);

--
-- Indexes for table `test_center_contract`
--
ALTER TABLE `test_center_contract`
  ADD PRIMARY KEY (`test_center_contract_id`),
  ADD KEY `test_center_id` (`test_center_id`);

--
-- Indexes for table `test_taker`
--
ALTER TABLE `test_taker`
  ADD PRIMARY KEY (`test_taker_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointment`
--
ALTER TABLE `appointment`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `exam`
--
ALTER TABLE `exam`
  MODIFY `exam_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `exam_registration`
--
ALTER TABLE `exam_registration`
  MODIFY `exam_registration_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `exam_sponsor`
--
ALTER TABLE `exam_sponsor`
  MODIFY `exam_sponsor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  MODIFY `sponsor_contract_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `test_center`
--
ALTER TABLE `test_center`
  MODIFY `test_center_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `test_center_availability`
--
ALTER TABLE `test_center_availability`
  MODIFY `availability_slot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `test_center_contract`
--
ALTER TABLE `test_center_contract`
  MODIFY `test_center_contract_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `test_taker`
--
ALTER TABLE `test_taker`
  MODIFY `test_taker_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointment`
--
ALTER TABLE `appointment`
  ADD CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`exam_registration_id`) REFERENCES `exam_registration` (`exam_registration_id`),
  ADD CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`availability_slot_id`) REFERENCES `test_center_availability` (`availability_slot_id`) ON DELETE SET NULL;

--
-- Constraints for table `exam`
--
ALTER TABLE `exam`
  ADD CONSTRAINT `exam_ibfk_1` FOREIGN KEY (`exam_sponsor_id`) REFERENCES `exam_sponsor` (`exam_sponsor_id`);

--
-- Constraints for table `exam_registration`
--
ALTER TABLE `exam_registration`
  ADD CONSTRAINT `exam_registration_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exam` (`exam_id`),
  ADD CONSTRAINT `exam_registration_ibfk_2` FOREIGN KEY (`test_taker_id`) REFERENCES `test_taker` (`test_taker_id`);

--
-- Constraints for table `exam_sponsor`
--
ALTER TABLE `exam_sponsor`
  ADD CONSTRAINT `exam_sponsor_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  ADD CONSTRAINT `sponsor_contract_ibfk_2` FOREIGN KEY (`exam_sponsor_id`) REFERENCES `exam_sponsor` (`exam_sponsor_id`);

--
-- Constraints for table `test_center`
--
ALTER TABLE `test_center`
  ADD CONSTRAINT `test_center_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `test_center_availability`
--
ALTER TABLE `test_center_availability`
  ADD CONSTRAINT `test_center_availability_ibfk_1` FOREIGN KEY (`test_center_id`) REFERENCES `test_center` (`test_center_id`);

--
-- Constraints for table `test_center_contract`
--
ALTER TABLE `test_center_contract`
  ADD CONSTRAINT `test_center_contract_ibfk_2` FOREIGN KEY (`test_center_id`) REFERENCES `test_center` (`test_center_id`);

--
-- Constraints for table `test_taker`
--
ALTER TABLE `test_taker`
  ADD CONSTRAINT `test_taker_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
