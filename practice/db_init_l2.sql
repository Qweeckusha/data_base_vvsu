-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema дикиеягоды
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema дикиеягоды
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `дикиеягоды` DEFAULT CHARACTER SET utf8 ;
USE `дикиеягоды` ;

-- -----------------------------------------------------
-- Table `дикиеягоды`.`Клиенты`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Клиенты` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(90) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Договоры`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Договоры` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `дата_заключения` DATE NOT NULL,
  `Клиенты_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Договоры_Клиенты1_idx` (`Клиенты_id` ASC) VISIBLE,
  CONSTRAINT `fk_Договоры_Клиенты1`
    FOREIGN KEY (`Клиенты_id`)
    REFERENCES `дикиеягоды`.`Клиенты` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Сотрудники`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Сотрудники` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(90) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Заказы`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Заказы` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Договоры_id` INT NOT NULL,
  `дата_создания` DATE NULL,
  `дата_выполнения` DATE NULL,
  `Сотрудники_id` INT NOT NULL,
  `Статус` ENUM("Отправлено", "Не отправлено", "Выдано") NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Заказы_Договоры1_idx` (`Договоры_id` ASC) VISIBLE,
  INDEX `fk_Заказы_Сотрудники1_idx` (`Сотрудники_id` ASC) VISIBLE,
  CONSTRAINT `fk_Заказы_Договоры1`
    FOREIGN KEY (`Договоры_id`)
    REFERENCES `дикиеягоды`.`Договоры` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Заказы_Сотрудники1`
    FOREIGN KEY (`Сотрудники_id`)
    REFERENCES `дикиеягоды`.`Сотрудники` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`ВидыНанесения`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`ВидыНанесения` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Поставщики`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Поставщики` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Товары`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Товары` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `Поставщики_id` INT NOT NULL,
  `Цена` FLOAT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Товары_Поставщики1_idx` (`Поставщики_id` ASC) VISIBLE,
  CONSTRAINT `fk_Товары_Поставщики1`
    FOREIGN KEY (`Поставщики_id`)
    REFERENCES `дикиеягоды`.`Поставщики` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`ТранспортныеКомп`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`ТранспортныеКомп` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`ВидыТранспорта`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`ВидыТранспорта` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`DeliveryInOrder`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`DeliveryInOrder` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ТранспортныеКомп_id` INT NOT NULL,
  `дата_отправки` DATE NULL,
  `Заказы_id` INT NOT NULL,
  `Статус_доставки` ENUM("Ожидает", "Отправлен", "Доставлен") NULL DEFAULT 'Ожидает',
  `ВидыТранспорта_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_DeliveryInOrder_ТранспортныеКомп1_idx` (`ТранспортныеКомп_id` ASC) VISIBLE,
  INDEX `fk_DeliveryInOrder_Заказы1_idx` (`Заказы_id` ASC) VISIBLE,
  INDEX `fk_DeliveryInOrder_ВидыТранспорта1_idx` (`ВидыТранспорта_id` ASC) VISIBLE,
  CONSTRAINT `fk_DeliveryInOrder_ТранспортныеКомп1`
    FOREIGN KEY (`ТранспортныеКомп_id`)
    REFERENCES `дикиеягоды`.`ТранспортныеКомп` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DeliveryInOrder_Заказы1`
    FOREIGN KEY (`Заказы_id`)
    REFERENCES `дикиеягоды`.`Заказы` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DeliveryInOrder_ВидыТранспорта1`
    FOREIGN KEY (`ВидыТранспорта_id`)
    REFERENCES `дикиеягоды`.`ВидыТранспорта` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `дикиеягоды`.`Корзина`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `дикиеягоды`.`Корзина` (
  `Заказы_id` INT NOT NULL,
  `Товары_id` INT NOT NULL,
  `ВидыНанесения_id` INT NOT NULL,
  `Количество` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`Заказы_id`, `Товары_id`),
  INDEX `fk_Заказы_has_Товары_Товары1_idx` (`Товары_id` ASC) VISIBLE,
  INDEX `fk_Заказы_has_Товары_Заказы1_idx` (`Заказы_id` ASC) VISIBLE,
  INDEX `fk_Корзина_ВидыНанесения1_idx` (`ВидыНанесения_id` ASC) VISIBLE,
  CONSTRAINT `fk_Заказы_has_Товары_Заказы1`
    FOREIGN KEY (`Заказы_id`)
    REFERENCES `дикиеягоды`.`Заказы` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Заказы_has_Товары_Товары1`
    FOREIGN KEY (`Товары_id`)
    REFERENCES `дикиеягоды`.`Товары` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Корзина_ВидыНанесения1`
    FOREIGN KEY (`ВидыНанесения_id`)
    REFERENCES `дикиеягоды`.`ВидыНанесения` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
