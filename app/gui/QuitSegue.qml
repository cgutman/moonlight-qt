import QtQuick 2.0
import QtQuick.Controls 2.2

import ComputerManager 1.0
import Session 1.0

Item {
    property string appName
    property Session nextSession : null
    property string nextAppName : ""

    property string stageText : "Quitting " + appName + "..."

    function quitAppCompleted(error)
    {
        // Display a failed dialog if we got an error
        if (error !== undefined) {
            errorDialog.text = error
            errorDialog.open()
        }

        // If we're supposed to launch another game after this, do so now
        if (error === undefined && nextSession !== null) {
            var component = Qt.createComponent("StreamSegue.qml")
            var segue = component.createObject(stackView, {"appName": nextAppName, "session": nextSession})
            stackView.replace(segue)
        }
        else {
            // Exit this view
            stackView.pop()
        }
    }

    StackView.onActivated: {
        // Hide the toolbar before we start loading
        //toolBar.visible = false //Breaks frameless Window

        // Connect the quit completion signal
        ComputerManager.quitAppCompleted.connect(quitAppCompleted)
    }

    StackView.onDeactivating: {
        // Show the toolbar again
        //toolBar.visible = true //Breaks Framelesswindow

        // Disconnect the signal
        ComputerManager.quitAppCompleted.disconnect(quitAppCompleted)
    }

    Row {
        anchors.centerIn: parent
        spacing: 5

        BusyIndicator {
            id: stageSpinner
        }

        Label {
            id: stageLabel
            height: stageSpinner.height
            text: stageText
            font.pointSize: 20
            verticalAlignment: Text.AlignVCenter

            wrapMode: Text.Wrap
        }
    }

    ErrorMessageDialog {
        id: errorDialog
    }
}
