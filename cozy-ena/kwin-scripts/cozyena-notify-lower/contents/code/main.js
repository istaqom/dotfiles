/*
 * Align notification toasts with floating bottom dock.
 * Also catch Steam toasts (own windows, often keepAbove).
 */
var MARGIN = 10;
var DOCK_RESERVE = 62; // ~52 dock + gap — keep toast above dock when dock shown
var moving = false;

function isToast(window) {
    if (!window) return false;
    if (window.notification || window.criticalNotification) return true;
    try {
        var rc = ("" + window.resourceClass).toLowerCase();
        var rn = ("" + window.resourceName).toLowerCase();
        var cap = ("" + window.caption).toLowerCase();
        var steamish = rc.indexOf("steam") >= 0 || rn.indexOf("steam") >= 0
            || cap.indexOf("steam") >= 0;
        if (steamish) {
            // Steam toast: small skipTaskbar popup, or any steam notification-ish
            if (window.skipTaskbar || window.skipPager) return true;
            try {
                var g = window.frameGeometry;
                if (g && g.width <= 520 && g.height <= 220) return true;
            } catch (e) {}
        }
    } catch (e) {}
    return false;
}

function alignToast(window) {
    if (moving || !isToast(window)) return;
    var geo = window.frameGeometry;
    if (!geo || geo.width < 50 || geo.height < 30) return;

    var area;
    try {
        area = workspace.clientArea(KWin.FullScreenArea, window);
    } catch (e) {
        try { area = workspace.clientArea(KWin.FullArea, window); }
        catch (e2) { return; }
    }
    if (!area) return;

    // Prefer sitting just above dock band (not covering it)
    var targetY = Math.round(area.y + area.height - geo.height - DOCK_RESERVE);
    var minY = Math.round(area.y + MARGIN);
    if (targetY < minY) targetY = minY;

    moving = true;
    try {
        // Steam likes keepAbove — drop it so panel/dock can compete
        try { if (window.keepAbove) window.keepAbove = false; } catch (e) {}
        window.frameGeometry = {
            x: geo.x,
            y: targetY,
            width: geo.width,
            height: geo.height
        };
    } catch (e) {
        try {
            window.frameGeometry = Qt.rect(geo.x, targetY, geo.width, geo.height);
        } catch (e2) {}
    }
    moving = false;
}

function setup(window) {
    if (!isToast(window)) return;
    alignToast(window);
    try {
        window.frameGeometryChanged.connect(function () {
            alignToast(window);
        });
    } catch (e) {}
}

workspace.windowAdded.connect(setup);
try {
    workspace.windowList().forEach(setup);
} catch (e) {
    var list = workspace.windowList();
    for (var i = 0; i < list.length; i++) setup(list[i]);
}
