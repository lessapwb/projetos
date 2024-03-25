-- (Query 1) Receita, leads, conversão e ticket médio mês a mês
-- Colunas: mês, leads (#), vendas (#), receita (k, R$), conversão (%), ticket médio (k, R$)
with
	leads as (
		select 
			date_trunc('month', visit_page_date)::date as visit_page_month,
			count (*) as visit_page_count
		from sales.funnel
		group by visit_page_month
		order by visit_page_month desc
	),

	payments as (
		select
			date_trunc('month', fun.paid_date)::date as paid_month,
			count(fun.paid_date) as paid_count,
			sum(pro.price * (1+fun.discount)) as receita
		from sales.funnel as fun
		left join sales.products pro
			on fun.product_id = pro.product_id
		where fun.paid_date is not null
		group by paid_month
		order by paid_month desc
	)
select
	leads.visit_page_month as "mês",
	leads.visit_page_count as "leads (#)",
	payments.paid_count as "vendas (#)",
	ROUND(payments.receita/1000,2) as "receita (k,R$)",
	ROUND((payments.paid_count::float/leads.visit_page_count::float)::numeric,4) as "conversão (%)",
	ROUND(payments.receita/payments.paid_count/1000,2) as "ticket médio (k,R$)"

from leads
left join payments
	on leads.visit_page_month = paid_month
	
	
-- (Query 2) Estados que mais venderam
-- Colunas: país, estado, vendas (#)
select
	'Brazil' as país,
	cus.state as estado,
	count(fun.paid_date) as "vendas (#)"

from sales.funnel as fun
left join sales.customers as cus
	on fun.customer_id = cus.customer_id
where paid_date between '2021-08-01' and '2021-08-31'
group by país, estado
order by "vendas (#)" desc
limit 5

-- (Query 3) Marcas que mais venderam no mês
-- Colunas: marca, vendas (#)
select
	pro.brand as marca,
	count (fun.*) as "vendas (#)"
from sales.products pro
left join sales.funnel fun
	on pro.product_id = fun.product_id
where paid_date between '2021-08-01' and '2021-08-31'
group by brand
order by "vendas (#)" desc
limit 5


-- (Query 4) Lojas que mais venderam
-- Colunas: loja, vendas (#)
select
    sto.store_name as loja,
    count(fun.*) as "vendas (#)"

from sales.funnel fun
left join sales.stores sto
    on fun.store_id = sto.store_id
where paid_date between '2021-08-01' and '2021-08-31'
group by loja
order by "vendas (#)" desc
limit 5


-- (Query 5) Dias da semana com maior número de visitas ao site
-- Colunas: dia_semana, dia da semana, visitas (#)
select
    extract(dow from visit_page_date) as dia_semana,
    case extract(dow from visit_page_date)
        when 0 then 'Domingo'
        when 1 then 'Segunda'
        when 2 then 'Terça'
        when 3 then 'Quarta'
        when 4 then 'Quinta'
        when 5 then 'Sexta'
        when 6 then 'Sábado'
    end as "dia da semana",
    count(*) as "visitas (#)"
    from sales.funnel
    where visit_page_date between '2021-08-01' and '2021-08-31'
    group by dia_semana
    order by "visitas (#)" desc