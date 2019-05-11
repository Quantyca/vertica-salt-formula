{% from "vertica/map.jinja" import vertica_user with context %}
{% from "vertica/map.jinja" import dbadmin_passwd with context %}
{% from "vertica/map.jinja" import vertica_db with context %}

{% set flat_list = [] %}
{% for sublist in salt['mine.get']('roles:vertica_*','vertica-addrs', 'grain').values() %}
  {% for item in sublist %}
    {% do flat_list.append(item) %}
  {% endfor %}
{% endfor %}

Create Database:
  cmd.run:
    - name: su - {{vertica_user}} -c "/opt/vertica/bin/admintools -t create_db -d {{vertica_db}} -p '{{dbadmin_passwd}}' -s {{ ','.join(flat_list |sort) }}"

Set restart policy to always:
  cmd.run:
    - name: su - {{vertica_user}} -c "/opt/vertica/bin/admintools -t set_restart_policy -d {{vertica_db}} -p always"
    - require:
      - cmd: Create Database