import QtQuick 2.0
import DumbHome 1.0
import "MapObjects.js" as MapObjects

Item {
    id: container
    width: 500
    height: 500
    focus: true


    property int direction_up: 0
    property int direction_right: 1
    property int direction_down: 2
    property int direction_left: 3

    property int playerId: -1
    property MapObject player
    property int pastWindowX: width
    property int pastWindowY: height

    property int pressedKeysCount: 0

    onWidthChanged: {
        for (var index = 0; index < MapObjects.size(); index++) {
             var mapObject = MapObjects.get(index);
             mapObject.x += (width - pastWindowX)/2;
        }
        pastWindowX = width;
    }

    onHeightChanged: {
        for (var index = 0; index < MapObjects.size(); index++) {
             var mapObject = MapObjects.get(index);
             mapObject.y += (height - pastWindowY)/2;
        }
        pastWindowY = height;
    }


    SensorControls {
    }

    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Up:
            pressedKeysCount++;
            playerActionsReceiver.onMoveRequested(direction_down);
            break;
        case Qt.Key_Right:
            pressedKeysCount++;
            playerActionsReceiver.onMoveRequested(direction_right);
            break;
        case Qt.Key_Down:
            pressedKeysCount++;
            playerActionsReceiver.onMoveRequested(direction_up);
            break;
        case Qt.Key_Left:
            pressedKeysCount++;
            playerActionsReceiver.onMoveRequested(direction_left);
            break;
        }
    }

    Keys.onReleased: {
        pressedKeysCount--;
        if (pressedKeysCount == 0) {
            playerActionsReceiver.onMoveStopRequested();
        }
    }

    function createElementFrom(mapObject) {
        var component = Qt.createComponent("MapObject.qml");
        if (component.status === Component.Ready) {
            var element = component.createObject(container);
            element.x = mapObject.x;
            element.y = mapObject.y;
            element.width = mapObject.width;
            element.height = mapObject.height;
            element.color = mapObject.color;
            element.mapObjectId = mapObject.id;
            return element;
        }
    }

    function setUpGraphicalMap() {
        for (var i = 0; i < MapObjects.size(); i++) {
            MapObjects.get(i).destroy();
        }
        MapObjects.clear();

        for (var index = 0; index < qmlMapInterface.getObjectsCount(); index++) {
            var mapObject = qmlMapInterface.getMapObject(index);
            MapObjects.add(createElementFrom(mapObject));
        }
    }

    Component.onCompleted: {
        if (qmlMapInterface.isMapSetUp()) {
            setUpGraphicalMap();
        }
    }

    QmlMapInterface {
        id: qmlMapInterface
        objectName: "qmlMapInterface"


        property int playerX: -1
        property int playerY: -1


        onMapSetUp: {
            setUpGraphicalMap();
            //Find player
            for (var index = 0; index < qmlMapInterface.getObjectsCount(); index++) {
                var mapObject = qmlMapInterface.getMapObject(index);
                if (mapObject.id === qmlMapInterface.getPlayerId()) {
                    playerX = mapObject.x;
                    playerY = mapObject.y;
                    playerId = mapObject.id;
                }
            }

            for (index = 0; index < MapObjects.size(); index++) {
                 mapObject = MapObjects.get(index);
                 mapObject.x += (container.width/2 - playerX );
                 mapObject.y += (container.height/2 - playerY);
            }

        }

        onObjectChangedPosition: {
            if (id === qmlMapInterface.getPlayerId()) {
                for (var index = 0; index < MapObjects.size(); index++) {
                    var mapObject = MapObjects.get(index);
                    var xSmeshNow = x - playerX, ySmeshNow = y - playerY;
                    if (mapObject.mapObjectId !== id) {
                        //Move Right/Left
                        if(xSmeshNow != 0){
                            if(x > playerX){
                                mapObject.x -= 1;
                            }
                            else{
                                mapObject.x += 1;
                            }
                        }

                        //Move Up/Down
                        if(ySmeshNow != 0){
                            if(y > playerY){
                                mapObject.y -= 1;
                            }
                            else{
                                mapObject.y += 1;
                            }
                        }
                    }
                }
                playerX = x;
                playerY = y;
            }
        }
    }
}
