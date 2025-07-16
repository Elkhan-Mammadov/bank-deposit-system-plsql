
begin
insert_customer('Elxan', 'Mammadov', date '1985-08-20', 'AZE1234567');
insert_customer('Aysel', 'Huseynova', date '1990-03-15', 'AZE7654321');
insert_customer('Kamran', 'Rzayev',  date '1978-11-05', 'AZE9988776');
end;
/
  

begin
insert_currency(944, 'AZN');
insert_currency(840, 'USD');
insert_currency(978, 'EUR');
end;
/


begin
insert_branch(101, 'Nəsimi filial', 'Bakı, Nəsimi rayonu');
insert_branch(102, 'Xətai filial', 'Bakı, Xətai rayonu');
insert_branch(103, 'Yasamal filial','Bakı, Yasamal rayonu');
end;
/


begin

insert_product(1000,  5000, 180, 365, 5.0, 944);
insert_product(5001, 10000,  90, 180, 4.5, 944);
insert_product(100,   1000,  30,  90, 3.0, 840);
insert_product(1001,  5000,  91, 180, 2.5, 840);
end;
/


begin

insert_deposit(p_customer_id => 1,p_branch_id => 101,p_amount  => 3000,
p_start_date=> date '2025-07-01',p_end_date  => date '2025-01-17', p_currency_id => 944 );

insert_deposit(2, 102, 800,date '2025-07-01',date '2025-08-30',840);

insert_deposit(3, 103, 12000,date '2025-07-01',date '2025-10-29',944);
end;
/



begin
calculate_interest(3000, 200, 944);   
calculate_interest(800, 60, 840);    
calculate_interest(12000, 120, 944);  
end;
/
  

begin
calculate_profit(1);   
calculate_profit(2);   
calculate_profit(99); 
end;
/


begin
calculate_profit;
end;
/


begin
prolongate_deposits;
end;
/


select * from deposits;

select * from deposit_archive;

select * from exception_data;

select * from deposit_profit_log;

