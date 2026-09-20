{#
    Overrides dbt's default schema naming to use custom schema names verbatim,
    rather than the default '<target_schema>_<custom_schema>' prefix pattern.

    Trade-off: appropriate for a single-developer local project where schema
    isolation between runs is not required. In a multi-developer or CI environment,
    the default prefix behavior isolates each developer's or run's schemas from one
    another — removing it means all runs write to the same schemas.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
