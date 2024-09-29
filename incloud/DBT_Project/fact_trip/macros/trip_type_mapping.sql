
{% macro map_trip_type(trip_type_column) %}
    case {{ dbt.safe_cast(trip_type_column, api.Column.translate_type("integer")) }}
        when 1 then 'Street-hail'
        when 2 then 'Dispatch'
        else 'Unknown'
    end
{% endmacro %}