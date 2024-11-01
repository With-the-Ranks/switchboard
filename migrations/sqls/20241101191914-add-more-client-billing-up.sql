alter table billing.clients drop column taxable;
alter table billing.clients add column tax_name text not null default 'Out of State, no tax payable';
alter table billing.clients add column has_read_replica boolean not null default false;
