{% from "map.jinja" import tier %}

{% for item in tier %}
start {{ tier[tier|length - loop.index] }} instance:
  salt.runner:
    - name: cloud.action
    - func: start
    - instances:
      - {{ tier[tier|length - loop.index] }}

wait until {{ tier[tier|length - loop.index] }} minion ready:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
        - {{ tier[tier|length - loop.index] }}
    - timeout: 600
    - require:
      - salt: start {{ tier[tier|length - loop.index] }} instance

start {{ tier[tier|length - loop.index] }} service:
  salt.state:
    - tgt: {{ tier[tier|length - loop.index] }}
    - sls:
        - start_{{ tier[tier|length - loop.index] }}
        
{% endfor %}
