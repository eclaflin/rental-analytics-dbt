{% macro clean_price(column_name) %}
    replace(replace({{ column_name }}, '$', ''), ',', '')::numeric
{% endmacro %}
