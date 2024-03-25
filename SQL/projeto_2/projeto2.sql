-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)
select 
	case
		when ibge.gender = 'male' then 'homens'
		when ibge.gender = 'female' then 'mulheres'
		end as "gênero", 
	count (*) as "leads (#)"
from sales.customers as cus
left join temp_tables.ibge_genders as ibge
	on lower(cus.first_name) = lower(ibge.first_name)
group by ibge.gender

-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)

/* select distinct professional_status
from sales.customers */

select
	case
		when professional_status = 'feelancer' then 'freelancer'
		when professional_status = 'retired' then 'aposentado'
		when professional_status = 'clt'then 'clt'
		when professional_status = 'self_employed' then 'autônomo(a)'
		when professional_status = 'other' then 'outro'
		when professional_status = 'businessman' then 'empresário(a)'
		when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
		when professional_status = 'student' then 'estudante'
	end as "status_professional",
	(count(*)::float)/(select count (*) from sales.customers) as "leads (%)"
	
from sales.customers cus
group by professional_status
order by "leads (%)"

-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)

/* create function datediff(unidade varchar, data_inicial date, data_final date)
returns integer
language sql

as

$$

	select
		case
			when unidade in ('d', 'day', 'days') then (data_final - data_inicial)
			when unidade in ('w', 'week', 'weeks') then (data_final - data_inicial)/7
			when unidade in ('m', 'month', 'months') then (data_final - data_inicial)/30
			when unidade in ('y', 'year', 'years') then (data_final - data_inicial)/365
			end as diferenca

$$ */

select
    case
        when datediff('years', birth_date, current_date) < 20 then '0-20'
        when datediff('years', birth_date, current_date) < 40 then '20-40'
        when datediff('years', birth_date, current_date) < 60 then '40-60'
        when datediff('years', birth_date, current_date) < 80 then '60-80'
        else '80+' end "faixa etária",
        count(*)::float/(select count(*) from sales.customers) as "leads(%)"

from sales.customers cus
group by "faixa etária"
order by "faixa etária" desc

-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem

select
    case
        when income < 5000 then '0-5.000'
        when income < 10000 then '0-10.000'
        when income < 15000 then '0-15.000'
        when income < 20000 then '0-20.000'
        else '20.000+' end "faixa salarial",
        count(*)::float/(select count(*) from sales.customers) as "leads(%)",
	case
        when income < 5000 then '1'
        when income < 10000 then '2'
        when income < 15000 then '3'
        when income < 20000 then '4'
        else '5' end "ordem"

from sales.customers cus
group by "faixa salarial","ordem"
order by "ordem" asc

-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos
with
	classificacao_veiculos as (
	
	select
		fun.visit_page_date,
		pro.model_year,
		extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
		case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
			else 'seminovo'
		end "classificação do veículo"
	from sales.funnel as fun	
	left join sales.products as pro
		on fun.product_id = pro.product_id
	)

select 
	"classificação do veículo",
	count(*) as "veículos visitas (#)"
from classificacao_veiculos
group by "classificação do veículo"
-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

with
	faixa_de_idade_veiculos as (
	
	select
		fun.visit_page_date,
		pro.model_year,
		extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
		case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 a 4 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 a 6 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 a 8 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 a 10 anos'
		else 'acima de 10 anos'
		end "idade do veículo",
		
		case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then '1'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then '2'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then '3'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then '4'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then '5'
		else 'acima de 10 anos'
		end "ordem"
	from sales.funnel as fun	
	left join sales.products as pro
		on fun.product_id = pro.product_id
	)

select
	"idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	ordem
from faixa_de_idade_veiculos
group by "idade do veículo", ordem
order by ordem

-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

select
    pro.brand,
    pro.model,
    count(*) as "visitas (#)"
from sales.funnel as fun
left join sales.products as pro
    on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"
