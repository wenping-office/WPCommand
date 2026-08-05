//import GoogleCast
//import KTVHTTPCache
//import Base
//
//
//final class GoogleCastProvider:
//NSObject,
//CastProvider {
//
//
//    private let discoveryManager: GCKDiscoveryManager
//
//    private let sessionManager: GCKSessionManager
//
//
//    private weak var discoveryListener:
//    DeviceDiscoveryListener?
//
//
//    private var stateListeners =
//    NSHashTable<AnyObject>.weakObjects()
//
//
//    private var devices:
//    [String: GCKDevice] = [:]
//
//
//    private var connectCallback:
//    ((Bool, String?) -> Void)?
//
//
//    private var playbackState =
//    PlaybackState()
//
//
//
//    override init() {
//
//        let context =
//        GCKCastContext.sharedInstance()
//
//        discoveryManager =
//        context.discoveryManager
//
//        sessionManager =
//        context.sessionManager
//
//        super.init()
//    }
//
//
//
//    private func log(
//        _ text:String
//    ) {
//        print("📺 [GoogleCast] \(text)")
//    }
//
//
//
//    // MARK: Provider
//
//
//    func type() -> ProviderType {
//
//        .googleCast
//    }
//
//
//
//    func isAvailable() -> Bool {
//
//        let state =
//        GCKCastContext.sharedInstance()
//            .castState
//
//        log("castState=\(state.rawValue)")
//
////        return state != .noDevicesAvailable
//        return true
//    }
//
//
//    // MARK: Discovery
//
//    func startDiscovery(
//        listener: DeviceDiscoveryListener
//    ) {
//
//
//        discoveryListener = listener
//
//
//        discoveryManager.add(self)
//
//
//        if !discoveryManager.isDiscoveryActive(
//            forDeviceCategory:
//                kGCKCastDeviceCategory
//        ) {
//
//            discoveryManager.startDiscovery()
//        }
//
//
//        // 已经存在的设备
//        updateDeviceList()
//    }
//
//    func stopDiscovery() {
//
//        discoveryManager.remove(self)
//
//        discoveryManager.stopDiscovery()
//
//        discoveryListener = nil
//    }
//
//    private func updateDeviceList() {
//
//
//        for index in 0..<discoveryManager.deviceCount {
//
//
//            let device =
//            discoveryManager.device(at:index)
//
//
//            devices[device.deviceID] =
//            device
//
//
//            discoveryListener?
//                .onDeviceFound(
//                    makeDevice(device)
//                )
//        }
//    }
//
//    private func makeDevice(
//        _ device:GCKDevice
//    )->CastDevice {
//
//
//        CastDevice(
//            id: device.deviceID,
//            name: device.friendlyName ?? "",
//            type: .googleCast,
//            address: device.ipAddress,
//            raw: device
//        )
//    }
//
//    // MARK: Connect
//    func connect(
//        device:CastDevice,
//        callback:@escaping(
//            Bool,
//            String?
//        )->Void
//    ) {
//
//
//        guard let gckDevice =
//                devices[device.id]
//        else {
//
//            callback(
//                false,
//                "device not found"
//            )
//
//            return
//        }
//
//
//        connectCallback = callback
//
//
//        sessionManager.add(self)
//
//
//        sessionManager.startSession(
//            with:gckDevice
//        )
//    }
//
//    func disconnect() {
//
//
//        sessionManager
//            .endSessionAndStopCasting(true)
//    }
//
//    func isConnected()->Bool {
//
//        sessionManager
//            .currentCastSession != nil
//    }
//
//    // MARK: Media
//    func loadMedia(url: String,
//                   title: String,
//                   subItem:NativePlayView.SUBItem?,
//                   mimeType: String) {
//
//        guard let client =
//                sessionManager
//                .currentCastSession?
//                .remoteMediaClient
//        else {
//            return
//        }
//
//        playbackState.mediaUrl =
//            url
//
//        playbackState.title =
//            title
//
//        let metadata =
//        GCKMediaMetadata(
//            metadataType:.movie
//        )
//
//
//        metadata.setString(
//            title,
//            forKey:kGCKMetadataKeyTitle
//        )
//
//        log("url--\(url)")
//        log("mineType--\(mimeType)")
//        log("title--\(title)")
//
//        captions(sub: subItem,
//                 complete: { item in
//            
//           if let tracks = item as? GCKMediaTrack{
//                let media =
//                GCKMediaInformation(
//                    contentID:url,
//                    streamType:.buffered,
//                    contentType:mimeType,
//                    metadata:metadata,
//                    streamDuration:0,
//                    mediaTracks:[tracks],
//                    textTrackStyle:nil,
//                    customData:nil
//                )
//               
//               let options = GCKMediaLoadOptions()
//               options.activeTrackIDs = [1]
//               client.loadMedia(media, with: options)
//            }else{
//                let media =
//                GCKMediaInformation(
//                    contentID:url,
//                    streamType:.buffered,
//                    contentType:mimeType,
//                    metadata:metadata,
//                    streamDuration:0,
//                    mediaTracks:nil,
//                    textTrackStyle:nil,
//                    customData:nil
//                )
//                client.loadMedia(media)
//            }
//        })
//    }
//
//
//
//    func play() {
//
//        sessionManager
//            .currentCastSession?
//            .remoteMediaClient?
//            .play()
//    }
//
//
//
//    func pause() {
//
//        sessionManager
//            .currentCastSession?
//            .remoteMediaClient?
//            .pause()
//    }
//
//
//
//    func stop() {
//
//        sessionManager
//            .currentCastSession?
//            .remoteMediaClient?
//            .stop()
//    }
//
//
//
//
//    func seekTo(
//        positionMs:Int64
//    ) {
//
//
//        let option =
//        GCKMediaSeekOptions()
//
//
//        option.interval =
//            TimeInterval(positionMs) / 1000
//
//
//        sessionManager
//            .currentCastSession?
//            .remoteMediaClient?
//            .seek(with:option)
//    }
//
//
//
//
//
//    func setVolume(
//        _ volume:Float
//    ) {
//
//
//        sessionManager
//            .currentCastSession?
//            .setDeviceVolume(volume)
//    }
//
//
//
//
//
//    // MARK: State Listener
//
//
//
//    func addStateListener(
//        _ listener:any PlaybackStateListener
//    ) {
//
//        stateListeners.add(listener)
//    }
//
//
//
//
//    func removeStateListener(
//        _ listener:any PlaybackStateListener
//    ) {
//
//        stateListeners.remove(listener)
//    }
//
//
//
//
//    private func notifyState() {
//
//
//        for item in stateListeners.allObjects {
//
//            (
//                item as?
//                PlaybackStateListener
//            )?
//            .onStateChanged(
//                playbackState
//            )
//        }
//    }
//
//
//
//
//
//    private func updatePlaybackState(
//        _ status: GCKMediaStatus
//    ) {
//
//        switch status.playerState {
//
//        case .playing:
//
//            playbackState.status = .playing
//            playbackState.isPlaying = true
//
//
//        case .paused:
//
//            playbackState.status = .paused
//            playbackState.isPlaying = false
//
//
//        case .idle:
//
//            playbackState.status = .stopped
//            playbackState.isPlaying = false
//
//
//        default:
//
//            playbackState.status = .noramal
//        }
//
//
//        playbackState.position =
//            status.streamPosition
//
//
//        playbackState.positionMs =
//            Int64(status.streamPosition * 1000)
//
//
//
//        let duration =
//            status.mediaInformation?.streamDuration ?? 0
//
//
//        playbackState.duration =
//            duration
//
//
//        playbackState.durationMs =
//            Int64(duration * 1000)
//
//
//
//        playbackState.idleReason =
//            "\(status.idleReason)"
//
//
//
//        if let session =
//            sessionManager.currentCastSession {
//
//            playbackState.volume = session.currentDeviceVolume
//
//            playbackState.isMuted = session.currentDeviceMuted
//        }
//
//
//        playbackState.isConnected =
//            isConnected()
//    }
//
//    func captions(sub: NativePlayView.SUBItem?, complete: @escaping (Any?) -> Void) {
//        if let url = sub?.value.url.asUrl(){
//            if let proxyUrl = CastSubtitleProxy.shared.addSubtitle(srtURL: url){
//                print("转换字幕url\(url),代理字幕url\(proxyUrl.absoluteString)")
//                let subtitleTrack = GCKMediaTrack(
//                    identifier: 1,
//                    contentIdentifier: proxyUrl.absoluteString,
//                    contentType: "text/vtt",
//                    type: .text,
//                    textSubtype: .captions,
//                    name: sub!.value.lanName,
//                    languageCode: sub!.value.lan,
//                    customData: nil
//                )
//                
//                DispatchQueue.main.async {
//                    complete(subtitleTrack)
//                }
//            }else{
//                DispatchQueue.main.async {
//                    complete(nil)
//                }
//            }
//        }else{
//            DispatchQueue.main.async {
//                complete(nil)
//            }
//        }
//    }
//
//
//    func destroy() {
//
//        stopDiscovery()
//
//        disconnect()
//
//        stateListeners.removeAllObjects()
//    }
//}
//
//
//
//
//
//
//extension GoogleCastProvider:
//GCKDiscoveryManagerListener,
//GCKSessionManagerListener,
//GCKRemoteMediaClientListener {
//
//
//
//    // MARK: Discovery
//
//
//    func didUpdateDeviceList() {
//
//        updateDeviceList()
//    }
//
//
//
//    func didRemove(
//        _ device:GCKDevice
//    ) {
//
//
//        devices.removeValue(
//            forKey:
//                device.deviceID
//        )
//
//
//        discoveryListener?
//            .onDeviceLost(
//                makeDevice(device)
//            )
//    }
//
//
//
//
//
//    // MARK: Session
//
//
//    func sessionManager(
//        _ sessionManager:GCKSessionManager,
//        didStart session:GCKSession
//    ) {
//
//
//        playbackState.isConnected =
//            true
//
//
//
//        if let castSession =
//            session as? GCKCastSession {
//
//
//            castSession
//                .remoteMediaClient?
//                .add(self)
//        }
//
//
//
//        connectCallback?(
//            true,
//            nil
//        )
//
//        connectCallback = nil
//
//
//        notifyState()
//    }
//
//
//
//
//
//    func sessionManager(
//        _ sessionManager:GCKSessionManager,
//        didEnd session:GCKSession,
//        withError error:Error?
//    ) {
//
//
//        playbackState.isConnected =
//            false
//
//
//        playbackState.status =
//            .stopped
//
//
//        notifyState()
//    }
//
//
//
//
//
//    func sessionManager(
//        _ sessionManager:GCKSessionManager,
//        didFailToStart session:GCKSession,
//        withError error:Error
//    ) {
//
//
//        connectCallback?(
//            false,
//            error.localizedDescription
//        )
//
//
//        connectCallback = nil
//    }
//
//
//
//
//
//    // MARK: Remote Media
//
//
//
//    func remoteMediaClient(
//        _ client:GCKRemoteMediaClient,
//        didUpdate mediaStatus:GCKMediaStatus?
//    ) {
//
//
//        guard let status =
//                mediaStatus
//        else {
//            return
//        }
//
//
//        updatePlaybackState(status)
//
//
//        notifyState()
//    }
//}
//
//import Foundation
//
//final class SubtitleConverter {
//
//    static func convertSRTToVTT(
//        srtURL: URL,
//        completion: @escaping (Result<URL, Error>) -> Void
//    ) {
//
//        URLSession.shared.dataTask(with: srtURL) { data, _, error in
//
//            if let error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data,
//                  let srt = String(data: data, encoding: .utf8)
//            else {
//                completion(.failure(
//                    NSError(
//                        domain: "Subtitle",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey:
//                            "字幕解析失败"
//                        ]
//                    )
//                ))
//                return
//            }
//
//
//            let vtt = convert(srt)
//
//
//            do {
//
//                let fileName =
//                UUID().uuidString + ".vtt"
//
//
//                let fileURL =
//                FileManager.default
//                    .temporaryDirectory
//                    .appendingPathComponent(fileName)
//
//
//                try vtt.write(
//                    to: fileURL,
//                    atomically: true,
//                    encoding: .utf8
//                )
//
//
//                completion(.success(fileURL))
//
//
//            } catch {
//
//                completion(.failure(error))
//            }
//
//
//        }.resume()
//
//    }
//
//
//    private static func convert(
//        _ srt: String
//    ) -> String {
//
//        var result = "WEBVTT\n\n"
//
//
//        let lines =
//        srt.components(
//            separatedBy: .newlines
//        )
//
//
//        for line in lines {
//
//            var newLine = line
//
//
//            // SRT:
//            // 00:01:02,500 --> 00:01:05,000
//            //
//            // VTT:
//            // 00:01:02.500 --> 00:01:05.000
//
//            if line.contains("-->") {
//
//                newLine =
//                line.replacingOccurrences(
//                    of: ",",
//                    with: "."
//                )
//            }
//
//
//            result += newLine + "\n"
//        }
//
//
//        return result
//    }
//}
