//
//  WatchRTCStatsTransformHelper.swift
//  AmazonChimeSDKDemo
//
//

import UIKit
import AmazonChimeSDK

// swiftlint:disable all

struct WatchRTCStatsTransformHelper {
    static func createOutboundRTPReportForVideo(tileState: VideoTileState,
                                                selectedVideoDevice: MediaDevice?,
                                                selectedVideoFormat: VideoCaptureFormat?,
                                                metrics: [ObservableMetric: Any]) -> [String: Any] {

        let objectId = "ov_\(tileState.attendeeId)"
        let remoteId = "remote_\(objectId)"
        let mediaSourceId = "source_\(selectedVideoDevice?.label.hashValue ?? 0)" // MARK: label is "Front Camera" so can change to "Rear Camera", etc. Is it ok?
        let codecId = "codec_\(objectId)"

        var result: [String: Any] = [:]
        
        let innerObject: [String: Any] = [
            "id": objectId,
            "type": "outbound-rtp",
            "kind": "video",
            "mediaType": "video",
            "mediaSourceId": mediaSourceId,
            "remoteId": remoteId,
            "codecId": codecId,
            "frameWidth": selectedVideoFormat?.width ?? 0,
            "frameHeight": selectedVideoFormat?.height ?? 0,
            "framesPerSecond": metrics[.videoSendFps] ?? 0
        ]
        
        result[objectId] = innerObject
        
        let remoteObject: [String: Any] = [
            "id": remoteId,
            "type": "remote-inbound-rtp",
            "kind": "video",
            "mediaType": "video",
            "jitter": 0, // MARK: seems that we don't have this one.
            "roundTripTime": 0, // MARK: we only have metrics[.videoSendRttMs], but seems that we need  smth like videoReceiveRttMs here?
            "packetLost": metrics[.videoReceivePacketLossPercent] ?? 0 // MARK: Percentage of video packets lost from server to client across all receive streams. Is it OK?
        ]
        
        result[remoteId] = remoteObject
        
        let mediaSourceObject: [String: Any] = [
            "id": mediaSourceId,
            "type": "media-source",
            "kind": "video",
            "width": selectedVideoFormat?.width ?? 0,
            "height": selectedVideoFormat?.height ?? 0,
            "framesPerSecond": selectedVideoFormat?.maxFrameRate ?? 0
        ]
        
        result[mediaSourceId] = mediaSourceObject
        
        let codecObject: [String: Any] = [
            "id": codecId,
            "type": "codec",
            "mimeType": "video/H264", // MARK: Can not find this info anywhere
            "sdpFmtpLine": ""
        ]
        
        result[codecId] = codecObject
        
        return result
    }
    
    static func createInboundRTPReportForVideo(tileState: VideoTileState,
                                               metrics: [ObservableMetric: Any]) -> [String: Any] {
        
        let objectId = "iv_\(tileState.attendeeId)"
        let remoteId = "remote_\(objectId)"
        let codecId = "codec_\(objectId)"

        var result: [String: Any] = [:]
        
        let innerObject: [String: Any] = [
            "id": objectId,
            "type": "inbound-rtp",
            "kind": "video",
            "mediaType": "video",
            "remoteId": remoteId,
            "codecId": codecId,
            "frameWidth": tileState.videoStreamContentWidth,
            "frameHeight": tileState.videoStreamContentHeight,
            "framesPerSecond": metrics[.videoSendFps] ?? 0
        ]
        
        result[objectId] = innerObject
        
        let remoteObject: [String: Any] = [
            "id": remoteId,
            "type": "remote-outbound-rtp",
            "kind": "video",
            "mediaType": "video",
            "jitter": 0, // MARK: seems that we don't have this one.
            "roundTripTime": metrics[.videoSendRttMs] ?? 0,
            "packetLost": metrics[.videoSendPacketLossPercent] ?? 0 // MARK: Percentage of video packets lost from client to server across all send streams. Is it OK?
        ]
        
        result[remoteId] = remoteObject
        
        let codecObject: [String: Any] = [
            "id": codecId,
            "type": "codec",
            "mimeType": "video/H264", // MARK: Can not find this info anywhere
            "sdpFmtpLine": ""
        ]
        
        result[codecId] = codecObject
        
        return result
    }
}
