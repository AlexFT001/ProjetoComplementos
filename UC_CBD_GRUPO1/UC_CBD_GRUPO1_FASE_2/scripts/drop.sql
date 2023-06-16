set SERVEROUTPU on;

begin
for i in (select object_name from user_objects where object_type = 'PROCEDURE')
loop
execute immediate 'drop procedure ' || i.object_name;
end loop;
end;
/


begin
for i in (select object_name from user_objects where object_type = 'VIEW')
loop
execute immediate 'drop view ' || i.object_name;
--dbms_output.put_line('drop view ' || i.object_name);
end loop;
end;
/

begin
for i in (select object_name from user_objects where object_type = 'INDEX')
loop
execute immediate 'drop view ' || i.object_name;
--dbms_output.put_line('drop view ' || i.object_name);
end loop;
end;
/


begin
for i in (select object_name from user_objects where object_type = 'FUNCTION')
loop
execute immediate 'drop function ' || i.object_name;
--dbms_output.put_line('drop function ' || i.object_name);
end loop;
end;
/



begin
for i in (select sequence_name from user_sequences)
loop
execute immediate 'drop sequence ' || i.sequence_name;
--dbms_output.put_line('drop sequence ' || i.sequence_name ||';');
end loop;
end;
/




begin
for i in (select table_name from user_tables)
loop
execute immediate 'drop table '|| i.table_name ||' cascade constraints'; 
--dbms_output.put_line('drop table '|| i.table_name ||' cascade constraints;');
end loop;
end;
/


purge recyclebin;