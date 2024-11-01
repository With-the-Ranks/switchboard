alter table billing.clients add column taxable boolean not null default false;
alter table billing.clients drop column tax_name;
alter table billing.clients drop column has_read_replica;
