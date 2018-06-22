-- modifyDataStore.sql, a SQL script by Ben Guaraldi

-- Convert into a temporary table the current JSON from the organisationUnitLevels key of the 
-- assignments namespace of the DHIS 2 data store, which stores 
-- each key as a value in the keyjsonvalue table

with current as (
	select * from (
		select (json_populate_record(null::datimorgunitassignments,value::JSON)).* 
		from (
			select value::json
			from json_each((
				select value::json
				from keyjsonvalue 
				where namespace = 'assignments' 
					and namespacekey = 'organisationUnitLevels'
			))) as x) as y

-- Add a row (for the new "country") and a column for the index to the table from above
-- and order by the index

), index_and_data as (
	select *, case name4 when '' then name3 else name4 end as index from current
		union
	select 'Sequel' as name3, name4, country, prioritization, planning, community, facility, 'Sequel' as index from current
		where name3 = 'Namibia'
	order by index

-- remove the index from index_and_data

), just_data as (
	select name3, name4, country, prioritization, planning, community, facility
	from index_and_data

-- merge the index from index_and_data and the JSONified rows from just_data into a
-- JSON string to reinsert into the data store

), final as (
	select json_object_agg(index_and_data.index, row_to_json(just_data)) as json
	from index_and_data join just_data 
	on index_and_data.name3 = just_data.name3 
	and index_and_data.name4 = just_data.name4
)

-- and, finally, insert the JSON from final into the keyjsonvalue table
update keyjsonvalue
set value = final.json
from final
where namespace = 'assignments' and
	namespacekey = 'organisationUnitLevels';