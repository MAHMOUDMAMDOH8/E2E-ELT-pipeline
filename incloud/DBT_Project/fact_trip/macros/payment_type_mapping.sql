{% macro map_payment_type(payment_type_column) %}
    case {{ dbt.safe_cast(payment_type_column, api.Column.translate_type("integer")) }}
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end
{% endmacro %}