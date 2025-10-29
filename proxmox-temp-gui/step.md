### Add CPU Package Temperature to Proxmox Node Status

Follow these steps to expose and display CPU package temperature in the Proxmox UI.

1) Edit backend: `PVE/API2/Nodes.pm`

- Open the file:

```bash
nano /usr/share/perl5/PVE/API2/Nodes.pm
```

- Use search (F6) to find:

```
my $dinfo
```

- Insert the following lines before that location:

```perl
$res->{pveversion} = PVE::pvecfg::package() . "/" .
    PVE::pvecfg::version_text();

$res->{thermalstate} = `sensors -j`;

my $dinfo = df('/', 1);     # output is bytes
```

2) Edit frontend: `pvemanagerlib.js`

- Open the file:

```bash
nano /usr/share/pve-manager/js/pvemanagerlib.js
```

- Use search (F6) to find:

```
widget.pveNodeStatus
```

- Update the widget configuration as follows:

```js
bodyPadding: '15 5 15 5',

// Remove colspan from CPU and add thermal under load
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
3) Restart the Proxmox proxy to apply changes

```bash
systemctl restart pveproxy
```