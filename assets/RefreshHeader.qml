import bb.cascades 1.0

Container {
    signal refreshTriggered
    id: refreshContainer
    property bool readyForRefresh: false
    property bool refreshing: false       // True if currently refreshing the list
    property string refreshedAt: ""
    property int refresh_threshold: 20    // How the user needs to pull to trigger before release to refresh 
    horizontalAlignment: HorizontalAlignment.Fill
    layout: DockLayout {
    }

    //TODO: add last refreshed item
    Container {
        id: refreshStatusContainer
        horizontalAlignment: HorizontalAlignment.Fill
        ImageView {
            id: refreshImage
            imageSource: "asset:///images/refresh.png"
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            preferredHeight: 75.0
            preferredWidth: 75.0
        }
        Label {
            id: refreshStatus
            text: qsTr("Pull to refresh")
            verticalAlignment: VerticalAlignment.Center
            textStyle.textAlign: TextAlign.Center
            leftPadding: 0.0
            topPadding: 10.0
            bottomPadding: 10.0
            textStyle.color: Color.create("#ffffff")
            horizontalAlignment: HorizontalAlignment.Fill
        }
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        ActivityIndicator {
            id: loadingIndicator
            preferredWidth: 100
            preferredHeight: 100
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }
    }
    Divider {
        opacity: 0.0
    }
    attachedObjects: [
        LayoutUpdateHandler {
            id: refreshHandler
            onLayoutFrameChanged: {
                if (refreshing) {
                    return;
                }
                readyForRefresh = false;

                if (layoutFrame.y >= 0) {
                    refreshImage.rotationZ = layoutFrame.y*2;
                    if (layoutFrame.y >= refresh_threshold) {
                        if (! refreshing) {
                            readyForRefresh = true;
                        }
                        refreshStatus.text = qsTr("Release to refresh")
                    }
                } else if (layoutFrame.y >= -100) {
                    refreshStatusContainer.visible = true;
                    if (refreshContainer.refreshedAt == "") {
                        refreshStatus.text = qsTr("Pull to refresh")
                    } else {
                        refreshStatus.text = qsTr("Pull to refresh. Last refreshed ") + timeSince(refreshContainer.refreshedAt);
                    }
                    refreshImage.rotationZ = 0;
                } else {
                    //don't refresh
                    refreshImage.rotationZ = 0;
                }
            }
        }
    ]
    function released() {
        if (readyForRefresh) {
            readyForRefresh = false;
            refreshing = false;
            refreshTriggered();
        }
    }
    onRefreshingChanged: {
        if (refreshing) {
            var tmpDate = new Date();
            refreshContainer.refreshedAt = tmpDate.getTime() / 1000;
                        
            refreshStatusContainer.visible = false;
            loadingIndicator.visible = true;
            loadingIndicator.running = true;
        } else {
            loadingIndicator.running = false;
            loadingIndicator.visible = false;
            refreshStatusContainer.visible = true;
            refreshContainer.setPreferredHeight(0);
        }
    }
    function timeSince(date) {
        var seconds = Math.floor(((new Date().getTime() / 1000) - date)), interval = Math.floor(seconds / 31536000);
        if (interval > 1) return qsTr("%L1y ago").arg(interval);
        interval = Math.floor(seconds / 2592000);
        if (interval > 1) return qsTr("%L1m ago").arg(interval)
        interval = Math.floor(seconds / 86400);
        if (interval >= 1) return qsTr("%L1d ago").arg(interval)
        interval = Math.floor(seconds / 3600);
        if (interval >= 1) return qsTr("%L1h ago").arg(interval)
        interval = Math.floor(seconds / 60);
        if (interval > 1) return qsTr("%L1m ago").arg(interval)
        return qsTr("just now");
    }
    function onListViewTouch(event) {
        refreshContainer.resetPreferredHeight();
        if (event.touchType == TouchType.Up) { //pulled and released
            released();
        }
    }
}
