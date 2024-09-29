
{% macro map_rate_code(rate_code_column) %}
    case {{ dbt.safe_cast(rate_code_column, api.Column.translate_type("integer")) }}
        when 1 then 'Standard rate'
        when 2 then 'JFK'
        when 3 then 'Newark'
        when 4 then 'Nassau or Westchester'
        when 5 then 'Negotiated fare'
        when 6 then 'Group ride'
        else 'Unknown'
    end
{% endmacro %}