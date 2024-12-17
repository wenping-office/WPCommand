//
//  ShareManager.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

/*
class ShareManager {
    
    /// 分享到微信
    /// - Parameters:
    ///   - WeChat: 具体分享类型类型
    ///   - completion: 结果
    static func shareToWechat(_ WeChat:WeChat,completion:((Bool)->Void)? = nil){
        switch WeChat {
        case .image(let image,let quality,let thumbImg,let platform):print()
           WeChatApi.share(image, quality: quality, thumbImg: thumbImg, scene: platform.rawValue, complete: { resualt in
                completion?(resualt)
            })
        case .miniProgram(let title,let type,let webpageUrl,let id,let path,let hdData,let platform):print()
           WeChatApi.shareToMiniProgram(with: title, type: type, webpageUrl: webpageUrl, idStr: id, path: path, hdImageData: hdData, scene: platform.rawValue, complete: {resualt in
                completion?(resualt)
            })
        case .url(let title,let desc,let url,let thumbImage,let platform):print()
            WeChatApi.shareUrl(url, title: title, desc: desc, scene: platform.rawValue, thumbImage: thumbImage, complete: {resualt in
                completion?(resualt)
            })
        case .file(let fileName,let fileExtension,let fileData,let platform):print()
            WeChatApi.shareFile(fileName, fileExtension: fileExtension, fileData: fileData, scene: platform.rawValue, complete: { resualt in
                completion?(resualt)
            })
        }
    }
}

extension ShareManager{
    /// 微信平台
    enum WeChatPlatform : Int {
        /// 聊天界面
        case chat = 0
        /// 朋友圈
        case circle = 1
        /// 收藏
        case collection = 2
        /// 指定联系人
        case people = 3
    }
    
    /// 微信平台
    enum WeChat {
        /// image 图片 quality 压缩质量 thumbData 分享过去时的缩略图
        case image(image:UIImage,
                   quality:CGFloat = 0.5,
                   thumbImg:UIImage?,
                   platform:WeChatPlatform)
        /// webpageUrl 低版本网页链接
        /// id 小程序ID
        /// path 打开小程序的路径
        /// title 分享的标题
        /// hdImageData 占位图
        /// type 小程序的环境 0正式 1开发 2体验
        case miniProgram(title : String,
                         type : Int,
                         webpageUrl : String,
                         id : String,
                         path : String,
                         hdData:Data?,
                         platform:WeChatPlatform)
        /// 分享链接
        case url(title:String,
                 desc:String,
                 url:String,
                 thumbImage:UIImage,
                 platform:WeChatPlatform)
        /// 分享文件
        case file(fileName:String,
                  fileExtension:String,
                  fileData:Data,
                  platform:WeChatPlatform)
    }
}

*/

/*
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatApi : NSObject

/// 分享图片到微信
/// @param image 分享的图片
/// @param quality 图片压缩比例
/// @param thumbImg 平台图标
/// @param scene 分享到哪里  0,聊天界面 1,朋友圈 2,收藏 3指定联系人
/// @param complete 结果
+ (void)shareImage:(UIImage *)image
           quality:(CGFloat)quality
          thumbImg:(UIImage *_Nullable)thumbImg
             scene:(NSInteger)scene
          complete:(void(^)(BOOL))complete;

/// 分享到小程序
/// @param title 标题
/// @param type 小程序的环境 0正式 1开发 2体验
/// @param webpageUrl 低版本网页链接
/// @param idStr 小程序ID
/// @param path 打开小程序的路径
/// @param hdData 是否是文本
///  @param scene 分享到哪里  0,聊天界面 1,朋友圈 2,收藏 3指定联系人
/// @param hdData 占位图
/// @param complete 结果
+ (void)shareToMiniProgramWith:(NSString *)title
                          type:(NSInteger)type
                          webpageUrl:(NSString *)webpageUrl
                          idStr:(NSString*)idStr
                          path:(NSString *)path
                          hdImageData:(NSData * _Nullable )hdData
                          scene:(NSInteger)scene
                         complete:(void(^)(BOOL))complete;
/// 分享网页到微信
/// @param url 网页链接
/// @param title 网页标题
/// @param desc 网页描述
/// @param scene 0,聊天界面 1,朋友圈 2,收藏 3指定联系人
/// @param thumbImage 网页封面
/// @param complete 回调
+ (void)shareUrl:(NSString *)url
           title:(NSString *)title
            desc:(NSString *)desc
           scene:(NSInteger)scene
      thumbImage:(UIImage *)thumbImage
        complete:(void(^)(BOOL))complete;

/// 分享文件
/// @param name 文件名
/// @param extionsion 文件扩展
/// @param data 文件数据
/// @param scene 0,聊天界面 1,朋友圈 2,收藏 3指定联系人
/// @param complete 回调
+ (void)shareFile:(NSString *)name
    fileExtension:(NSString *)extionsion
         fileData:(NSData *)data
            scene:(NSInteger)scene
         complete:(void(^)(BOOL))complete;
@end

NS_ASSUME_NONNULL_END

*/

/* 桥接文件内容
 #import "WeChatApi.h"
 #import <WechatOpenSDK/WXApi.h>
 #import <WechatOpenSDK/WXApiObject.h>
 
 
 @implementation WeChatApi
 
 + (void)shareImage:(UIImage *)image
 quality:(CGFloat)quality
 thumbImg:(UIImage *_Nullable)thumbImg
 scene:(NSInteger)scene
 complete:(void(^)(BOOL))complete{
 
 WXImageObject *imgObj = [WXImageObject new];
 imgObj.imageData = UIImageJPEGRepresentation(image, quality);
 WXMediaMessage * media = [WXMediaMessage new];
 media.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
 media.mediaObject = imgObj;
 SendMessageToWXReq *req = [SendMessageToWXReq new];
 req.message = media;
 req.scene = scene;
 req.bText = NO;
 [WXApi sendReq:req completion:complete];
 }
 
 /// 分享到小程序
 /// @param title 标题
 /// @param type 小程序的环境 0正式 1开发 2体验
 /// @param webpageUrl 低版本网页链接
 /// @param idStr 小程序ID
 /// @param path 打开小程序的路径
 ///  @param scene 分享到哪里  0,聊天界面 1,朋友圈 2,收藏 3指定联系人
 /// @param hdData 占位图
 /// @param complete 结果
 + (void)shareToMiniProgramWith:(NSString *)title
 type:(NSInteger)type
 webpageUrl:(NSString *)webpageUrl
 idStr:(NSString*)idStr
 path:(NSString *)path
 hdImageData:(NSData * _Nullable )hdData
 scene:(NSInteger)scene
 complete:(void(^)(BOOL))complete{
 
 WXMiniProgramObject *prog =  [WXMiniProgramObject new];
 prog.webpageUrl = webpageUrl;
 prog.path = path;
 prog.userName = idStr;
 prog.miniProgramType = type;
 prog.hdImageData = hdData;
 WXMediaMessage *media = [WXMediaMessage new];
 media.title = title;
 media.mediaObject = prog;
 
 SendMessageToWXReq *req = [SendMessageToWXReq new];
 req.message = media;
 req.scene = scene;
 req.bText = NO;
 [WXApi sendReq:req completion:complete];
 }
 
 
 /// 分享网页到微信
 /// @param url 网页链接
 /// @param title 网页标题
 /// @param desc 网页描述
 /// @param scene 0,聊天界面 1,朋友圈 2,收藏 3指定联系人
 /// @param thumbImage 网页封面
 /// @param complete 回调
 + (void)shareUrl:(NSString *)url
 title:(NSString *)title
 desc:(NSString *)desc
 scene:(NSInteger)scene
 thumbImage:(UIImage *)thumbImage
 complete:(void(^)(BOOL))complete{
 
 WXWebpageObject *webpageObject = [WXWebpageObject object];
 webpageObject.webpageUrl = url;
 WXMediaMessage *message = [WXMediaMessage message];
 message.title = title;
 message.description = desc;
 [message setThumbImage:thumbImage];
 message.mediaObject = webpageObject;
 SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
 req.bText = NO;
 req.message = message;
 req.scene = scene;
 [WXApi sendReq:req completion:complete];
 }
 
 /// 分享文件
 /// @param name 文件名
 /// @param extionsion 文件扩展
 /// @param data 文件数据
 /// @param scene 0,聊天界面 1,朋友圈 2,收藏 3指定联系人
 /// @param complete 回调
 + (void)shareFile:(NSString *)name
 fileExtension:(NSString *)extionsion
 fileData:(NSData *)data
 scene:(NSInteger)scene
 complete:(void(^)(BOOL))complete{
 
 WXMediaMessage *message = [WXMediaMessage new];
 message.title = name;
 
 WXFileObject *file = [WXFileObject new];
 file.fileExtension = extionsion;
 file.fileData = data;
 message.mediaObject = file;
 
 SendMessageToWXReq *requ = [SendMessageToWXReq new];
 requ.bText = NO;
 requ.message = message;
 requ.scene = scene;
 [WXApi sendReq:requ completion:complete];
 
 }
 
 @end
 */
