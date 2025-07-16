begin
dbms_scheduler.create_job (
job_name => 'PROLONGATE_DEPOSITS_JOB',
job_type  => 'STORED_PROCEDURE',
job_action  => 'deposit_pkg.prolongate_deposits',
start_date  => systimestamp,
repeat_interval => 'FREQ=DAILY; BYHOUR=22; BYMINUTE=0; BYSECOND=0',
enabled  => TRUE,
comments  => 'Hər gün saat 22:00-da depozit prolongasiyasını işə salır');
end;
/
