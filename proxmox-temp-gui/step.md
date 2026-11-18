# CPU package temp on the Proxmox node status panel

Shows package temperature next to CPU / IO / load. Edits under `/usr/share` — redo after `pve-manager` upgrades.

## 1. Backend — `Nodes.pm`

```bash
nano /usr/share/perl5/PVE/API2/Nodes.pm
```

Search (`F6`) for `my $dinfo`. Insert **above** that line:

```perl
$res->{pveversion} = PVE::pvecfg::package() . "/" .
    PVE::pvecfg::version_text();

$res->{thermalstate} = `sensors -j`;

my $dinfo = df('/', 1);     # output is bytes
```

Needs `lm-sensors` (`sensors -j` must work on the node).

## 2. Frontend — `pvemanagerlib.js`

```bash
nano /usr/share/pve-manager/js/pvemanagerlib.js
```

Search for `widget.pveNodeStatus`. In the status `items` list, drop `colspan` from IO delay if present, and add a thermal block:

```js
bodyPadding: '15 5 15 5',

items:
    {
        itemId: 'cpu',
        iconCls: 'fa fa-fw pmx-itype-icon-processor pmx-icon',
        title: gettext('CPU usage'),
        valueField: 'cpu',
        maxField: 'cpuinfo',
        renderer: Proxmox.Utils.render_node_cpu_usage,
    },
    {
        itemId: 'wait',
        iconCls: 'fa fa-fw fa-clock-o',
        title: gettext('IO delay'),
        valueField: 'wait',
    },
    {
        itemId: 'load',
        iconCls: 'fa fa-fw fa-tasks',
        title: gettext('Load average'),
        printBar: false,
        textField: 'loadavg',
    },
    {
        itemId: 'thermal',
        printBar: false,
        iconCls: 'fa fa-fw fa-thermometer-half',
        title: gettext('Package Temperature'),
        textField: 'thermalstate',
        renderer: function(value) {
            let objValue = JSON.parse(value);
            let cpu = objValue["coretemp-isa-0000"]["Package id 0"]["temp1_input"];
            return `${cpu} °C`;
        }
    },
```

Sensor path (`coretemp-isa-0000` / `Package id 0`) varies by CPU — adjust to match `sensors -j` on your box.

## 3. Reload UI

```bash
systemctl restart pveproxy
```

Hard-refresh the browser (cache).
