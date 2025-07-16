--Customers table

create table customers (
customer_id   number primary key,
name   varchar2(50) not null,
surname   varchar2(50) not null,
birth_date  date not null,
fin_code  varchar2(10) unique not null);

create sequence seq_customer_id ;


--currency table

create table currencies (
currency_id number primary key,
currency_name varchar2(50) not null);


--Branche table

create table branches (
branch_id  number primary key,
branch_name  varchar2(100) not null,
address   varchar2(150));


--Products table

create table products (
product_id  number primary key,
min_amount  number not null,
max_amount   number not null,
min_term  number not null,
max_term number not null,
interest_rate  number(5,2) not null,
currency_id   number not null,
constraint fk_products_currency foreign key (currency_id) references currencies(currency_id));

create sequence seq_product_id ;


--Deposits table

create table deposits (
deposit_id  number primary key,
customer_id   number not null,
branch_id  number not null,
product_id   number not null,
amount   number not null,
start_date  date not null,
end_date date not null,
interest_rate  number(5,2) not null,
status  varchar2(20) default 'active',
constraint fk_deposits_customer foreign key (customer_id)references customers(customer_id),
constraint fk_deposits_branch foreign key (branch_id)references branches(branch_id),
constraint fk_deposits_product foreign key (product_id)references products(product_id));

create sequence seq_deposit_id ;


--Exception_data

create table exception_data (
 id  number primary key,
 deposit_id number,
error_message  varchar2(4000),
log_date  date default sysdate );

create sequence seq_exception_id ;


--deposit_archive table


create table deposit_archive (
archive_id  number primary key,
deposit_id   number,
old_amount  number,
old_start_date date,
old_end_date date,
archive_date date default sysdate );

create sequence seq_archive_id ;

