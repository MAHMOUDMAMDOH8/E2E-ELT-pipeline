

{% macro map_store_and_fwd_flag(store_and_fwd_flag_column) %}
    case {{ dbt.safe_cast(store_and_fwd_flag_column, api.Column.translate_type("string")) }}
        when 'Y' then 'Store and forward trip'
        when 'N' then 'Not a store and forward trip'
        else 'Unknown'
    end
{% endmacro %}