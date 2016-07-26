use cellavita;
select * from donors;
select * from exams;
select * from stages;
select * from travels;
select * from cultures;
select * from vaccines;
select * from addresses;
select * from telephones;
alter table `cellavita`.`cultures` add index `fk_cultures_cells1_idx` (`donor_id` ASC, `cell_id` ASC);
select (max(`donor_id`)+1) as `next_id` from `cellavita`.`donors`;
select (max(`address_id`)+1) as `donor_next_address_id` from `cellavita`.`addresses` where `donor_id`= 2;
select (max(`phone_id`)+1) as `donor_next_telephone_id` from `cellavita`.`telephones` where `donor_id`= 1;