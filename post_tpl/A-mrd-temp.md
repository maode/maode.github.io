{# 下面的格式有效的去除了多余的空行，但是看着真别扭！ -#}
---
title: {{title}}
date: {{dtime}}
{% if tags -%}
tags:
{% for tag in tags %}	- {{tag}}
{% endfor %}
{%- endif -%}	
---


暂时就这些，后面没有了！(=^ ^=)


<!-- more -->



