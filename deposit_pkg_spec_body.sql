create or replace package deposit_pkg is

procedure insert_customer(
 p_name   varchar2,
p_surname  varchar2,
p_birth  date,
p_fin   varchar2);

  
procedure insert_currency(
p_currency_id  number,
p_currency_name  varchar2);


procedure insert_branch(
p_branch_id  number,
p_branch_name varchar2,
p_address  varchar2);

 
procedure insert_product(
p_min_amount number,
p_max_amount number,
p_min_term  number,
p_max_term  number,
p_interest_rate  number,
p_currency_id  number);

 
procedure insert_deposit(
p_customer_id number,
p_branch_id  number,
p_amount number,
p_start_date date,
p_end_date date,
p_currency_id  number);

  
procedure calculate_interest(
p_amount  number,
p_term  number,
p_currency_id number);

  
procedure calculate_profit(p_deposit_id number);

procedure calculate_profit;


function get_withdrawal_amount(p_deposit_id number) return number;

procedure prolongate_deposits;

end;
/



create or replace package body deposit_pkg is

 
procedure insert_customer(
p_name varchar2, p_surname varchar2,p_birth date,p_fin varchar2)
is
begin
insert into customers(customer_id, name, surname, birth_date, fin_code)
values (seq_customer_id.nextval, p_name, p_surname, p_birth, p_fin);
end insert_customer;

  
procedure insert_currency(p_currency_id number,p_currency_name varchar2) 
is
begin
insert into currencies(currency_id, currency_name)
values (p_currency_id, p_currency_name);
end insert_currency;


procedure insert_branch(p_branch_id number,p_branch_name varchar2, p_address varchar2)
is
begin
insert into branches(branch_id, branch_name, address)
values (p_branch_id, p_branch_name, p_address);
end insert_branch;

 
procedure insert_product(
p_min_amount number , p_max_amount number,
p_min_term number, p_max_term number,
p_interest_rate number,p_currency_id number) 
is
begin
insert into products(product_id, min_amount, max_amount, min_term, max_term, interest_rate, currency_id)
values (seq_product_id.nextval, p_min_amount, p_max_amount, p_min_term, p_max_term, p_interest_rate, p_currency_id);
end insert_product;

  
procedure insert_deposit(
p_customer_id number, p_branch_id number,
p_amount number,p_start_date date, p_end_date date,p_currency_id number)
is
v_product_id products.product_id%type;
v_interest   products.interest_rate%type;
begin

select product_id, interest_rate
into v_product_id, v_interest
from (select product_id, interest_rate
from products
where p_amount between min_amount and max_amount
and trunc(p_end_date - p_start_date) between min_term and max_term
and currency_id = p_currency_id)
where rownum = 1;

insert into deposits(deposit_id, customer_id, branch_id, product_id, amount, start_date, end_date, interest_rate)
values (seq_deposit_id.nextval,p_customer_id,p_branch_id,v_product_id,p_amount,
p_start_date,p_end_date,v_interest);

end insert_deposit;



procedure calculate_interest(
p_amount  number,
p_term  number,
p_currency_id number)
is
v_rate products.interest_rate%type;
begin
select interest_rateinto v_rate from (
select interest_rate from products
where p_amount  between min_amount and max_amount
and p_term   between min_term and max_term
and currency_id   = p_currency_id)
where rownum = 1;

dbms_output.put_line( 'Məbləğ: '||p_amount||', Müddət: '||p_term||', Valyuta ID: '||p_currency_id||', Faiz: '||v_rate||'%');
 
exception when no_data_found then
dbms_output.put_line('Heç bir uyğun məhsul tapılmadı.');
when others then
dbms_output.put_line('Səhv: '||sqlerrm);
end calculate_interest;


 
procedure calculate_profit(p_deposit_id number) is
v_amount  deposits.amount%type;
v_start  deposits.start_date%type;
v_end deposits.end_date%type;
v_rate deposits.interest_rate%type;
v_days  number;
v_profit  number;
  
begin   
select amount, start_date, end_date, interest_rate
into v_amount, v_start, v_end, v_rate from deposits
where deposit_id = p_deposit_id;

v_days := trunc(v_end - v_start);
v_profit := v_amount * v_rate/100 * v_days/365;

dbms_output.put_line('Deposit ID: '||p_deposit_id||', Müddət günlə: '||v_days|| ', Faiz məbləği: '||round(v_profit,2));
  
exception
when no_data_found then
dbms_output.put_line('Deposit tapılmadı: '||p_deposit_id);
when others then
dbms_output.put_line('Səhv: '||sqlerrm);
end calculate_profit;


 
procedure calculate_profit is
cursor c_active is select deposit_id, amount, start_date, end_date, interest_rate
from deposits where trunc(start_date) = trunc(sysdate)
and status = 'active';

begin
for r in c_active loop
     
      
declare
v_days  number := trunc(r.end_date - r.start_date);
v_profit number := r.amount * r.interest_rate/100 * v_days/365;
begin
insert into deposit_profit_log(deposit_id, profit_amount, log_date)
values (r.deposit_id, round(v_profit,2), sysdate);

exception
when others then null; 
end;
end loop;

dbms_output.put_line('Bugünkü müqavilələrin faizləri hesablandı.');
end calculate_profit;


  
function get_withdrawal_amount(p_deposit_id number) return number is
v_amount deposits.amount%type;
v_start deposits.start_date%type;
v_end  deposits.end_date%type;
v_rate  deposits.interest_rate%type;
v_days  number;
v_profit  number;
begin

select amount, start_date, end_date, interest_rate
into v_amount, v_start, v_end, v_rate from deposits
where deposit_id = p_deposit_id;

if v_now >= v_end then
v_days := trunc(v_end - v_start);
v_profit := v_amount * v_rate/100 * v_days/365;

else
    
v_profit := v_amount * v_rate/100 * 0.01;
end if;

return v_amount + round(v_profit,2);

exception
when no_data_found then
insert into exception_data(id, deposit_id, error_message)
values (seq_exception_id.nextval, p_deposit_id, 'Deposit tapılmadı');
raise_application_error(-20001, 'Deposit ID mövcud deyil.');
when others then
insert into exception_data(id, deposit_id, error_message)
values (seq_exception_id.nextval, p_deposit_id, sqlerrm);
raise;
end get_withdrawal_amount;


  
procedure prolongate_deposits is
cursor c_due is select deposit_id, amount, start_date, end_date, interest_rate
from deposits
where trunc(end_date) < trunc(sysdate)
and status = 'active';
begin
for r in c_due loop
      
insert into deposit_archive(archive_id, deposit_id, old_amount, old_start_date, old_end_date)
values (seq_archive_id.nextval,r.deposit_id,r.amount,r.start_date,r.end_date);

     
declare
v_term_days number := trunc(r.end_date - r.start_date);
v_new_start date   := r.end_date;
v_new_end date   := r.end_date + v_term_days;
v_new_amt number := r.amount + (r.amount * r.interest_rate/100);
begin
update deposits
set amount = round(v_new_amt,2),
start_date = v_new_start,
end_date = v_new_end,
status= 'prolonged'
where deposit_id   = r.deposit_id;
end;
end loop;
dbms_output.put_line('Prolongasiya tamamlandı.');
end prolongate_deposits;

end deposit_pkg;
/






