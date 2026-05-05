create database publictest;

use publictest;

create table messages(
	[id] int primary key identity(1, 1),
	[username] nvarchar(10),
	[subject] nvarchar(50),
	[body] nvarchar(1000)
);

alter table messages
add [IP] nvarchar(20); 

create login ITHS with password = 'ITHS';

create user ITHS for login ITHS;

alter role [db_datareader] add member ITHS;

alter procedure sendMessage @subject nvarchar(50), @message nvarchar(1000), @username nvarchar(10) = 'Anonymous' as
begin
	DECLARE @IP_Address varchar(255);

	select @IP_Address = cast(CONNECTIONPROPERTY('client_net_address') as varchar);

	insert into messages values (@username, @subject, @message, @IP_Address);
end;

GRANT EXECUTE ON sendMessage TO ITHS;

