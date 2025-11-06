-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 04, 2025 at 01:47 AM
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
(3, 2, NULL, 'Scheduled', 5, 11);

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
(4, 2, 'SERIES 66', 150, 'Securities and Investments');

-- --------------------------------------------------------

--
-- Table structure for table `exam_provider`
--

CREATE TABLE `exam_provider` (
  `exam_provider_id` int(11) NOT NULL,
  `provider_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(2, 3, 1, 'INV-000002', '2025-09-17', 300.00);

-- --------------------------------------------------------

--
-- Table structure for table `exam_sponsor`
--

CREATE TABLE `exam_sponsor` (
  `exam_sponsor_id` int(11) NOT NULL,
  `sponsor_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam_sponsor`
--

INSERT INTO `exam_sponsor` (`exam_sponsor_id`, `sponsor_name`) VALUES
(1, 'Project Management Institute'),
(2, 'FINRA');

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
  `exam_provider_id` int(11) DEFAULT NULL,
  `exam_sponsor_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'AVNA Test Center', '123 Main Street', 'New York', 'NY', 'USA', '10021', 2);

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
  `seat_capacity` INT(11) NOT NULL CHECK (seat_capacity >= 0),
  `scheduled_count` INT(11) NOT NULL CHECK (scheduled_count >= 0 AND scheduled_count <= seat_capacity)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `test_center_availability`
--

INSERT INTO `test_center_availability` (`availability_slot_id`, `test_center_id`, `date_of_availability`, `start_time_slot`, `end_time_slot`, `seat_capacity`, `scheduled_count`) VALUES
(1, 1, '2025-12-10', '09:00:00', '10:00:00', 5, 2),
(2, 1, '2025-12-10', '10:00:00', '11:00:00', 5, 3),
(3, 1, '2025-12-10', '11:00:00', '12:00:00', 5, 5),
(4, 1, '2025-12-10', '12:00:00', '16:00:00', 5, 4),
(5, 1, '2025-12-10', '16:00:00', '18:00:00', 5, 0),
(6, 1, '2025-12-11', '09:00:00', '10:00:00', 5, 1),
(7, 1, '2025-12-11', '10:00:00', '11:00:00', 5, 1),
(8, 1, '2025-12-11', '11:00:00', '12:00:00', 5, 4),
(9, 1, '2025-12-11', '12:00:00', '16:00:00', 5, 5),
(10, 1, '2025-12-11', '16:00:00', '18:00:00', 5, 3),
(11, 1, '2025-12-12', '09:00:00', '13:00:00', 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `test_center_contract`
--

CREATE TABLE `test_center_contract` (
  `test_center_contract_id` int(11) NOT NULL,
  `exam_provider_id` int(11) DEFAULT NULL,
  `test_center_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'Billy Bob', 'Jones', '123-456-7890', '123 Main Street', 'New York', 'NY', 'USA', '10021', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(45) DEFAULT NULL,
  `user_password_h` varchar(255) DEFAULT NULL,
  `user_type` char(2) DEFAULT NULL CHECK (`user_type` in ('TC','TT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `user_email`, `user_password_h`, `user_type`) VALUES
(1, 'billybob@example.com', '$2b$12$ZqGHl6kF0lZdOrv6Zb8d7edSp8LQqgPwcQxj6kH2AvnDJR7rF3vG.', 'TT'),
(2, 'avnatestcenter@example.com', '$2b$12$8YxgE7D9rVw5Y9JfCkq9UOtYz4R2yE7m2VqM4zV4WQ8U1lHq9zZJq', 'TC');

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
-- Indexes for table `exam_provider`
--
ALTER TABLE `exam_provider`
  ADD PRIMARY KEY (`exam_provider_id`);

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
  ADD PRIMARY KEY (`exam_sponsor_id`);

--
-- Indexes for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  ADD PRIMARY KEY (`sponsor_contract_id`),
  ADD KEY `exam_provider_id` (`exam_provider_id`),
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
  ADD KEY `exam_provider_id` (`exam_provider_id`),
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
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `exam`
--
ALTER TABLE `exam`
  MODIFY `exam_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `exam_provider`
--
ALTER TABLE `exam_provider`
  MODIFY `exam_provider_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_registration`
--
ALTER TABLE `exam_registration`
  MODIFY `exam_registration_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `exam_sponsor`
--
ALTER TABLE `exam_sponsor`
  MODIFY `exam_sponsor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  MODIFY `sponsor_contract_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `test_center`
--
ALTER TABLE `test_center`
  MODIFY `test_center_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `test_center_availability`
--
ALTER TABLE `test_center_availability`
  MODIFY `availability_slot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `test_center_contract`
--
ALTER TABLE `test_center_contract`
  MODIFY `test_center_contract_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `test_taker`
--
ALTER TABLE `test_taker`
  MODIFY `test_taker_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
-- Constraints for table `sponsor_contract`
--
ALTER TABLE `sponsor_contract`
  ADD CONSTRAINT `sponsor_contract_ibfk_1` FOREIGN KEY (`exam_provider_id`) REFERENCES `exam_provider` (`exam_provider_id`),
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
  ADD CONSTRAINT `test_center_contract_ibfk_1` FOREIGN KEY (`exam_provider_id`) REFERENCES `exam_provider` (`exam_provider_id`),
  ADD CONSTRAINT `test_center_contract_ibfk_2` FOREIGN KEY (`test_center_id`) REFERENCES `test_center` (`test_center_id`);

--
-- Constraints for table `test_taker`
--
ALTER TABLE `test_taker`
  ADD CONSTRAINT `test_taker_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);
COMMIT;


--
-- Triggers
--


-- Before deleting an availability slot, automatically set all its scheduled appointments to Cancelled
-- The @deleting_availability flag is used to prevent the release_availability (see below) trigger from firing during this delete operation
DELIMITER $$
CREATE TRIGGER cancel_appointments_on_slot_delete
BEFORE DELETE ON test_center_availability
FOR EACH ROW
BEGIN
    SET @deleting_availability := 1;  
    UPDATE appointment ap
    SET ap.appointment_status = 'Cancelled'
    WHERE ap.availability_slot_id = OLD.availability_slot_id AND ap.appointment_status = 'Scheduled';
    SET @deleting_availability := NULL; 
END$$
DELIMITER ;

-- book appointment -> take seats
DELIMITER $$
CREATE TRIGGER acquire_availability
AFTER INSERT ON appointment
FOR EACH ROW
BEGIN
    UPDATE test_center_availability av
    SET av.scheduled_count = av.scheduled_count + 1
    WHERE av.availability_slot_id = NEW.availability_slot_id;
END$$
DELIMITER ;

-- cancel appointment -> release seats
DELIMITER $$
CREATE TRIGGER release_availability
AFTER UPDATE ON appointment
FOR EACH ROW
BEGIN
    IF COALESCE(@deleting_availability, 0) = 0 AND OLD.appointment_status = 'Scheduled' AND NEW.appointment_status = 'Cancelled'
    THEN
        UPDATE test_center_availability av
        SET av.scheduled_count = av.scheduled_count - 1
        WHERE av.availability_slot_id = NEW.availability_slot_id;
    END IF;
END$$
DELIMITER ;



/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


