{% from "map.jinja" import tier %}


{% for item in tier %}
stop {{ item }} service:
  salt.state:
    - tgt: {{ item }}
    - sls:
        - stop_{{ item }}
        
stop {{ item }} instance:
  salt.runner:
    - name: cloud.action
    - func: stop
    # - provider: free-tier
    - instances:
      - {{ item }}
{% endfor %}