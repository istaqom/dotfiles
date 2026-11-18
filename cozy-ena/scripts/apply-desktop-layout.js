// Cozy Ena Plasma layout: top bar + bottom dock + big desktop clock
// Run via plasmashell evaluateScript

function nukePanels() {
    var ps = panels();
    for (var i = ps.length - 1; i >= 0; i--) {
        ps[i].remove();
    }
}

function makeTop() {
    var p = new Panel;
    p.location = "top";
    p.height = 42;
    p.floating = true;
    p.opacity = "adaptive";
    p.hiding = "none";
    p.alignment = "center";
    p.lengthMode = "fill";
    p.offset = 0;

    p.addWidget("org.kde.plasma.pager");
    p.addWidget("org.kde.plasma.marginsseparator");
    p.addWidget("org.kde.plasma.panelspacer");
    p.addWidget("org.kde.plasma.systemtray");
    var clock = p.addWidget("org.kde.plasma.digitalclock");
    try {
        clock.currentConfigGroup = ["Appearance"];
        clock.writeConfig("fontStyleName", "Bold");
        clock.writeConfig("use24hFormat", "2");
        clock.writeConfig("dateDisplayFormat", "BesideTime");
        clock.writeConfig("showDate", "true");
        clock.reloadConfig();
    } catch (e) {}
    return p;
}

function makeDock() {
    var p = new Panel;
    p.location = "bottom";
    p.height = 56;
    p.floating = true;
    p.opacity = "adaptive";
    p.hiding = "dodgewindows"; // no bottom strut — notifications level with dock
    p.alignment = "center";
    p.lengthMode = "fit";
    p.maximumLength = 900;
    p.minimumLength = 200;
    p.offset = 0;

    p.addWidget("org.kde.plasma.kickoff");
    var tasks = p.addWidget("org.kde.plasma.icontasks");
    try {
        tasks.currentConfigGroup = ["General"];
        tasks.writeConfig("launchers", "applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop");
        tasks.reloadConfig();
    } catch (e) {}
    p.addWidget("org.cozyena.mediadock");
    return p;
}

function placeClock() {
    // Match lock idle seat: centered, y = 8% of screen (LockScreenUi.qml idleY)
    var sg = screenGeometry(0);
    var clockW = 560;
    var clockH = 200;
    var x = Math.round((sg.width - clockW) / 2);
    var y = Math.round(sg.height * 0.08);
    var desks = desktops();
    for (var i = 0; i < desks.length; i++) {
        var d = desks[i];
        if (typeof d.screen !== "undefined" && d.screen !== 0 && d.screen !== -1) {
            continue;
        }
        // Reuse existing bigclock if present
        var ws = d.widgets();
        var w = null;
        for (var j = 0; j < ws.length; j++) {
            if (("" + ws[j].type).indexOf("org.cozyena.bigclock") >= 0) {
                w = ws[j];
                break;
            }
        }
        if (!w) {
            w = d.addWidget("org.cozyena.bigclock");
        }
        try {
            w.geometry = { x: x, y: y, width: clockW, height: clockH };
        } catch (e) {}
        break;
    }
}

nukePanels();
makeTop();
makeDock();
placeClock();
print("cozy-ena layout applied");
