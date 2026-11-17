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
    p.addWidget("org.kde.plasma.mediacontroller");
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
    p.addWidget("org.kde.plasma.marginsseparator");
    p.addWidget("org.kde.plasma.mediacontroller");
    return p;
}

function placeClock() {
    var desks = desktops();
    for (var i = 0; i < desks.length; i++) {
        var d = desks[i];
        // only primary-ish
        if (typeof d.screen !== "undefined" && d.screen !== 0 && d.screen !== -1) {
            continue;
        }
        var w = d.addWidget("org.kde.plasma.digitalclock");
        try {
            // large center-ish clock (coords are desktop-local)
            w.geometry = { x: 660, y: 320, width: 600, height: 220 };
        } catch (e) {
            try { w.geometry = Qt.rect(660, 320, 600, 220); } catch (e2) {}
        }
        try {
            w.currentConfigGroup = ["Appearance"];
            w.writeConfig("showDate", "true");
            w.writeConfig("dateDisplayFormat", "BelowTime");
            w.writeConfig("fontStyleName", "Bold");
            w.writeConfig("use24hFormat", "2");
            w.writeConfig("autoFontAndSize", "false");
            w.writeConfig("fontSize", "72");
            w.reloadConfig();
        } catch (e) {}
        break;
    }
}

nukePanels();
makeTop();
makeDock();
placeClock();
print("cozy-ena layout applied");
