//import Foundation
//
///// 投屏协议类型
//enum ProviderType: String, CaseIterable {
//    case googleCast = "Google Cast"
//    case dlna = "DLNA"
//    case roku = "Roku"
//    case airplay = "AirPlay"
//}
//
///// 统一的设备模型，屏蔽底层协议差异
//struct CastDevice: Identifiable, Hashable {
//    let id: String
//    let name: String
//    let type: ProviderType
//    let address: String?
//    let raw: Any?
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    static func == (lhs: CastDevice, rhs: CastDevice) -> Bool {
//        lhs.id == rhs.id
//    }
//}
