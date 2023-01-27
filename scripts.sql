--- Flights by year for Austin

select a.year as Year, a.flights as AustinFlights
from `anetproject.prod.austin` a
where a.year between 2010 and 2022
group by a.year, a.flights 

--- Flights from the 3 locales, by year
select 
a.year Year, a.flights AustinFlights, b.flights NashvilleFlights, c.flights NationalFlights
from `anetproject.prod.austin` a 
left outer join `anetproject.prod.nash` b
on a.id = b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2022
group by a.year, a.flights, b.flights, c.flights


--- ASMs from the 3 locales, by year
select 
a.year Year, a.ASM ausASM, b.asm nashASM, c.asm natASM
from `anetproject.prod.austin` a 
left outer join `anetproject.prod.nash` b
on a.id = b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2022
group by a.year, a.ASM, b.asm, c.asm


--- RPMs from the 3 locales, by year
select 
a.year Year, a.rpm ausRPM, b.rpm nashRPM, c.rpm natRPM
from `anetproject.prod.austin` a 
left outer join `anetproject.prod.nash` b
on a.id = b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2022
group by a.year, a.rpm, b.rpm, c.rpm


--- PAX from the 3 locales, by year
select 
a.year Year, a.PAX ausPAX, b.pax nashPAX, c.pax natPAX
from `anetproject.prod.austin` a 
left outer join `anetproject.prod.nash` b
on a.id = b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2022
group by a.year, a.pax, b.pax, c.pax


--- Population Growth from the 3 locales, by year
select 
a.year Year, a.ECP ausPOP, b.ecp nashPOP, c.ecp natPOP
from `anetproject.prod.austin` a 
left outer join `anetproject.prod.nash` b
on a.id = b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2022
and a.ecp is not null
and b.ecp is not null
and c.ecp is not null
group by a.year, a.ecp, b.ecp, c.ecp

--- Percentage difference of flights (Austin) from 2010-2019
--- iaf = Initial Austin Flights --> 2010
--- faf = Final Austin Flights --> 2019
with iaf as (
  select a.flights Flights, a.year
  from `anetproject.prod.austin` a
  where a.year = 2010
  group by a.flights, a.year
),
faf as (
  select a.flights Flights, a.year Year
  from `anetproject.prod.austin` a
  where a.year = 2019
  group by a.flights, a.year
)
select round(((faf.flights-iaf.flights)/(iaf.flights))*(100.00),2) as PercDiffAustinFlights
from iaf,faf


--- LF Covid Bounceback
--- ilf: Initial Load Factor
--- flf: Final Load Factor
--- CBR: Covid Bounceback Rate

with init as (
  select a.year YearSplit, a.Load_Facor ausILF, b.Load_Factor nashILF, c.Load_Factor natILF
  from `anetproject.prod.austin` a
left outer join `anetproject.prod.nash` b
on a.id=b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year = 2019
group by a.year, a.Load_Facor, b.Load_Factor, c.Load_Factor
),
final as (
  select 
  a.year YearSplit, 
  a.load_facor ausFLF, 
  b.Load_Factor nashFLF, 
  c.Load_Factor natFLF
  from `anetproject.prod.austin` a
left outer join `anetproject.prod.nash` b
on a.id=b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year = 2021
group by a.year, a.Load_Facor, b.Load_Factor, c.Load_Factor
)
select 
round((final.ausflf/init.ausilf),2)*(100.00) as ausCBR,
round((final.nashflf/init.nashilf),2)*(100.00) as nashCBR,
Round((final.natflf/init.natilf),2)*(100.00) as natCBR
from init, final



--- Ranking the highest flight volume --> Each City
select 
a.flights AustinFlights, b.flights NashvilleFlights, c.flights USFlights, a.Year YearSplit,
dense_rank() over(order by a.flights desc) FlightsRank
from `anetproject.prod.austin` a
left outer join `anetproject.prod.nash` b
on a.id=b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id
where a.year between 2010 and 2021
group by
a.flights, b.flights, c.flights,
a.year
order by flightsrank


--- Average LF by location
select
round(avg(a.Load_Facor),4)*(100.00) austinLF, round(avg(b.Load_Factor),4)*(100.00) nashLF, round(avg(c.Load_Factor),4)*(100.00) usLF ---a.Year YearSplit
from `anetproject.prod.austin` a
left outer join `anetproject.prod.nash` b
on a.id=b.id
left outer join `anetproject.prod.nat` c
on b.id=c.id