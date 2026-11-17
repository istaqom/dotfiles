/*
 * Snap notification popups down so their bottom edge matches
 * the floating bottom dock (~10px screen margin), not the old strut gap.
 */
var MARGIN = 10;
var moving = false;

function isToast(window) {
    if (!window) return false;
    if (window.notification || window.criticalNotification) return true;
    // Steam / random XDG sometimes mis-typed — catch by class + skipTaskbar popup size
    try {
        var rc = ("" + window.resourceClass).toLowerCase();
        var rn = ("" + window.resourceName).toLowerCase();
        if (rc.indexOf("steam") >= 0 && (window.skipTaskbar || window.skipPager)) return true;
        if (rn.indexOf("steam") >= 0 && window.skipTaskbar) return true;
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

    var targetY = Math.round(area.y + area.height - geo.height - MARGIN);
    // keep right-edge placement; only fix vertical
    if (Math.abs(geo.y - targetY) < 3) return;

    moving = true;
    try {
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
    // Plasma positions after map — nudge now and once shortly after
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
