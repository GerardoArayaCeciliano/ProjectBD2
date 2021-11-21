ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
create profile usuario limit
--seccion por usuario
sessions_per_user 3
cpu_per_session unlimited
connect_time 120
idle_time 3
failed_login_attempts 3
password_life_time 120
;