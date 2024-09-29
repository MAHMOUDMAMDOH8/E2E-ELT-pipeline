
{% macro map_vendor(vendor_column) %}
    case {{ dbt.safe_cast(vendor_column, api.Column.translate_type("integer")) }}
        when 1 then 'Creative Mobile Technologies, LLC'
        when 2 then 'VeriFone Inc.'
        else 'Unknown'
    end
{% endmacro %}