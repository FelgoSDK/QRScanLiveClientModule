import Felgo 3.0
import QtQuick 2.0
import QtMultimedia 5.5
import QtGraphicalEffects 1.0
import QZXing 2.3 // barcode scanning

Page {
  id: page

  property bool scanning: false

  // Holds value of scanned QR tag
  property string lastScannedTag: ""
  signal tagFound(string tag)

  // Initialize scanner when page is created
  Component.onCompleted: initializeScanner()

  onTagFound: {
    console.debug("Tag " + tag)
    page.lastScannedTag = tag // store scanned tag
  }

  // Initialize scanner
  function initializeScanner() {
    zxingFilter.active = true
    page.scanning = true
  }

  // Item for scanner, allows to show / remove camera live capturing as needed
  Item {
    anchors.fill: parent

    // Camera
    Camera {
      id:camera
      focus {
        focusMode: CameraFocus.FocusContinuous
        focusPointMode: CameraFocus.FocusPointAuto
      }
    }

    // Live Video Output
    VideoOutput {
      id: videoOutput
      source: camera
      anchors.fill: parent
      autoOrientation: true
      fillMode: VideoOutput.PreserveAspectCrop
      filters: [ zxingFilter ]
      MouseArea {
        anchors.fill: parent
        onClicked: {
          camera.focus.customFocusPoint = Qt.point(mouse.x / width,  mouse.y / height);
          camera.focus.focusMode = CameraFocus.FocusMacro;
          camera.focus.focusPointMode = CameraFocus.FocusPointCustom;
        }
      }
    }

    // Barcode Scanner Video Filter
    QZXingFilter {
      id: zxingFilter
      // Setup capture area
      captureRect: {
        videoOutput.contentRect;
        videoOutput.sourceRect;
        return videoOutput.mapRectToSource(videoOutput.mapNormalizedRectToItem(Qt.rect(
                                                                                 0.25, 0.25, 0.5, 0.5
                                                                                 )));
      }
      // Set up decoder
      decoder {
        enabledDecoders: QZXing.DecoderFormat_QR_CODE
        onTagFound: {
          console.log(tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet());
          page.tagFound(tag)
          initializeScanner()
        }
        tryHarder: false
      }
    }
  } // QR Scanner Item

  // Scanner UI
  Item {
    id: scannerUI
    anchors.fill: parent
    z: 1

    Rectangle {
      id: border
      color: "transparent"
      border.color: "#fff"
      border.width: dp(3)
      anchors.centerIn: parent
      visible: false
      width: videoOutput.contentRect.width / 2 + wobble
      height: videoOutput.contentRect.height / 2 + wobble
      property real wobble: 0
      NumberAnimation on wobble {
        running: page.scanning
        loops: Animation.Infinite
        from: dp(20)
        to: dp(-20)
        easing.type: Easing.InOutQuad
        duration: 1000
      }
    }

    Item {
      id: mask
      anchors.fill: border
      visible: false

      Rectangle {
        width: parent.width
        height: parent.height - dp(50)
        anchors.centerIn: parent
        color: "black"
      }
      Rectangle {
        width: parent.width - dp(50)
        height: parent.height
        anchors.centerIn: parent
        color: "black"
      }
    }

    OpacityMask {
      anchors.fill: border
      source: border
      maskSource: mask
      invert: true
      opacity: page.scanning ? 1 : 0
      Behavior on opacity {NumberAnimation{}}
    }
  } // Scanner UI

  // Capture Text Overlay
  AppText {
    id: captureText
    width: parent.width
    anchors.bottom: parent.bottom
    padding: dp(30)
    wrapMode: Text.WrapAnywhere
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    color: "white"
    font.pixelSize: sp(20)
    font.bold: true
    text: lastScannedTag
  }
}
