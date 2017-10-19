//
//  LCNetWork.swift
//  LCTool
//
//  Created by 懒猫 on 2017/10/16.
//  Copyright © 2017年 懒猫. All rights reserved.
//

import UIKit
import Alamofire

class LCNetWork: NSObject {

    // 网络类型:未知网络,无网络,手机网络,WIFI网络
    @objc public enum LCNetWorkStatusType: Int {
        case UnKnow, NotReachable, ReachableViaWWAN, ReachableViaWiFi
    }
    // 请求数据格式
    @objc public enum LCRequestSerializer: Int {
        case JSON, HTTP
    }

    private var isOpenLog = false
    /** Manager对象，负责管理所有的网络请求 */
    static let manager = LCNetWork()
    //网络请求管理器
    private lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = self.requestTimeOutInterval
        return SessionManager(configuration: configuration)
    }()
    //网络监测器
    private lazy var netMonitor = NetworkReachabilityManager.init(host: self.netWorkMonitorHost)
    //缓存管理器
    private let lcNetCacheManager = LCNetCache()
    //请求任务管理器
    private var netTaskCache: [String:DataRequest] = [:]

    /** 请求成功的闭包 */
    public typealias LCHttpRequestSuccess = ((_ responseObj:Any) -> Void)
    /** 请求失败的闭包 */
    public typealias LCHttpRequestFailed = ((_ error: Error) -> Void)
    /** 请求进度闭包 */
    public typealias LCHttpRequestProgress = (_ progress: Progress) -> Void

    // MARK:- 请求配置模块

    /** 基础URL */
    open var intactUrl = ""

    /** 请求串格式 */
    open var requestSerializer: LCRequestSerializer = .JSON {
        willSet {
            LCNetWork.tempRequestSerializer = newValue
        }
    }

    /** 临时更改请求串格式,此属性只会影响一次网络请求 */
    open static var tempRequestSerializer: LCRequestSerializer = .JSON

    /** 常规请求时间限制 */
    open var requestTimeOutInterval: TimeInterval = 15

    /** 网络监测Host */
    open var netWorkMonitorHost = "https://github.com/Alamofire/Alamofire.git"

    /** 开启日志打印 */
    open func openLog() {
        self.isOpenLog = true
    }

    /** 关闭日志打印,默认关闭 */
    open func closeLog() {
        self.isOpenLog = false
    }

    /** 开启网络监测 */
    open func startMonitoring() {
        self.netMonitor?.startListening()
    }

    //关闭网络监测
    open func stopMonitoring() {
        self.netMonitor?.stopListening()
    }

    /** 网络状态改变的回调 */
    open func netWorkStatus(by: @escaping (_ status:LCNetWorkStatusType) -> Void) {
        self.netMonitor?.listener = { Status in
            switch Status {
            case .unknown:
                by(LCNetWorkStatusType.UnKnow)
                break
            case .notReachable:
                by(LCNetWorkStatusType.NotReachable)
                break
            case .reachable(NetworkReachabilityManager.ConnectionType.wwan):
                by(LCNetWorkStatusType.ReachableViaWWAN)
                break
            case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                by(LCNetWorkStatusType.ReachableViaWiFi)
                break
            }
        }
    }

    /** 网络连接是否可用 */
    open func isReachable() -> Bool {
        return self.netMonitor?.isReachable ?? false
    }

    /** 蜂窝连接是否可用 */
    open func isReachableViaWWAN() -> Bool {
        return self.netMonitor?.isReachableOnWWAN ?? false
    }

    /** WIFI连接是否可用 */
    open func isReachableViaWiFi() -> Bool {
        return self.netMonitor?.isReachableOnEthernetOrWiFi ?? false
    }

    //MARK:- 请求管理模块
    /** 取消请求任务 */
    open func cancelTask(withUrl: String) {
        let task = self.netTaskCache[withUrl]
        if task == nil {
            return
        }
        task?.cancel()
    }

    // MARK:- 常规请求方式模块

    /**
     *  GET请求
     *
     *  @param url        请求地址
     *  @param parameters 请求参数
     *  @param successClosure    请求成功的回调
     *  @param failtureClosure    请求失败的回调
     */
    open static func GET(url: String ,parameters: [String: Any]?, successClosure: LCHttpRequestSuccess? , failtureClosure: LCHttpRequestFailed?) {
        var reflectSerializer = LCNetWork.manager.requestSerializer
        if reflectSerializer != LCNetWork.tempRequestSerializer {
            reflectSerializer = LCNetWork.tempRequestSerializer
            LCNetWork.tempRequestSerializer = LCNetWork.manager.requestSerializer
        }
        LCNetWork.manager.GETImplement(url: url, parameters: parameters, requestSerializer: reflectSerializer, useCache: false, successClosure: successClosure, failtureClosure: failtureClosure)
    }

    /**
     *  POST请求
     *
     *  @param url        请求地址
     *  @param parameters 请求参数
     *  @param successClosure    请求成功的回调
     *  @param failtureClosure    请求失败的回调
     */
    open static func POST(url: String ,parameters: [String: Any]?, successClosure: LCHttpRequestSuccess?, failtureClosure: LCHttpRequestFailed?) {
        var reflectSerializer = LCNetWork.manager.requestSerializer
        if reflectSerializer != LCNetWork.tempRequestSerializer {
            reflectSerializer = LCNetWork.tempRequestSerializer
            LCNetWork.tempRequestSerializer = LCNetWork.manager.requestSerializer
        }
        LCNetWork.manager.POSTImplement(url: url, parameters: parameters, requestSerializer: reflectSerializer, useCache: false, successClosure: successClosure, failtureClosure: failtureClosure)
    }

    //每一个文件对应一个字典对象，key指示了文件类型，Value是文件对象，文件被保存在数组中作为参数传递进来
    //key解释：image->图片  video->数组   paramterName->这个键值对指明了data数据的字段名(value)
    ///
    ///
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 请求参数
    ///   - data: 文件
    ///   - successClosure: 请求成功的回调
    ///   - failtureClosure: 请求失败的回调
    open static func UPLOAD(url: String ,parameters: [String: String]?, data: Array<Dictionary<String,Any>>, successClosure: LCHttpRequestSuccess? , failtureClosure: LCHttpRequestFailed?) {
        self.manager.UPLOADImplement(url: url, parameters: parameters, data: data, successClosure: successClosure, failtureClosure: failtureClosure)
    }

    //MARK:- 具有缓存功能的网络请求模块
    //请求参数配置受全局配置影响
    //GET
    open static func GETWithCache(url: String ,parameters: [String: Any]?, successClosure: LCHttpRequestSuccess?, failtureClosure: LCHttpRequestFailed?) {
        var reflectSerializer = LCNetWork.manager.requestSerializer
        if reflectSerializer != LCNetWork.tempRequestSerializer {
            reflectSerializer = LCNetWork.tempRequestSerializer
            LCNetWork.tempRequestSerializer = LCNetWork.manager.requestSerializer
        }
        LCNetWork.manager.GETImplement(url: url, parameters: parameters, requestSerializer: reflectSerializer, useCache: true, successClosure: successClosure, failtureClosure: failtureClosure)
    }

    //POST
    open static func POSTWithCache(url: String ,parameters: [String: Any]?, successClosure: LCHttpRequestSuccess?, failtureClosure: LCHttpRequestFailed?) {
        var reflectSerializer = LCNetWork.manager.requestSerializer
        if reflectSerializer != LCNetWork.tempRequestSerializer {
            reflectSerializer = LCNetWork.tempRequestSerializer
            LCNetWork.tempRequestSerializer = LCNetWork.manager.requestSerializer
        }
        LCNetWork.manager.POSTImplement(url: url, parameters: parameters, requestSerializer: reflectSerializer, useCache: true, successClosure: successClosure, failtureClosure: failtureClosure)
    }

    //NOTE:
    //about: when @escaping meet optional
    //It's assume that all optional closures are treated as escaping, which is a complementary bug :) I going to assume that when it is fixed the compile will warn us to make the change.
    //take from: https://stackoverflow.com/questions/39618803/swift-3-optional-escaping-closure-parameter

    //Get Implement
    private func GETImplement(url: String, parameters: [String: Any]?, requestSerializer: LCRequestSerializer, useCache: Bool, successClosure:  LCHttpRequestSuccess? , failtureClosure: LCHttpRequestFailed?) {
        let intactUrl = self.intactUrl + url

        var paraEncoding: ParameterEncoding!
        if requestSerializer == .JSON {
            paraEncoding = JSONEncoding.default
        }else {
            paraEncoding = URLEncoding.default
        }

        let task = self.sessionManager.request(intactUrl, method: .get, parameters: parameters, encoding: paraEncoding, headers: nil).responseJSON { (response) in
            //清除缓存task
            self.netTaskCache.removeValue(forKey: url)

            //Success
            if response.result.isSuccess {

                let jsonData = response.result.value

                if self.isOpenLog {
                    print("=============================华丽的分割线=============================\n请求方式:GET")
                    print("接口Url---> \(intactUrl)\n参数---> \(String(describing: parameters))\n返回结果:--->")
                    print(LCUtils.ObjectToJson(data: jsonData) ?? "解析出错")
                }

                //缓存数据
                if useCache && jsonData != nil{
                    LCNetWork.manager.lcNetCacheManager[url] = jsonData!
                }

                if successClosure != nil && jsonData != nil {
                    successClosure!(jsonData!)
                }
            }
                //Failed
            else {

                if self.isOpenLog {
                    print("=============================华丽的分割线=============================\n请求方式:GET")
                    print("接口Url---> \(intactUrl)\n参数---> \(String(describing: parameters))")
                    print("error = \(String(describing: response.result.error))")
                }
                if failtureClosure != nil && response.result.error != nil {
                    failtureClosure!(response.result.error!)
                }

                //启用缓存的情况下，会在请求失败的情况下同时检测缓存并返回
                if useCache {
                    let cacheResult = LCNetWork.manager.lcNetCacheManager[url]
                    if cacheResult != nil {
                        if successClosure != nil {
                            successClosure!(cacheResult!)
                        }
                    }
                }
            }
        }
        self.netTaskCache[url] = task
    }


    //Post Implement
    private func POSTImplement(url: String, parameters: [String: Any]?, requestSerializer: LCRequestSerializer, useCache: Bool, successClosure: LCHttpRequestSuccess? , failtureClosure: LCHttpRequestFailed?) {

        let intactUrl = self.intactUrl + url

        var paraEncoding: ParameterEncoding!
        if requestSerializer == .JSON {
            paraEncoding = JSONEncoding.default
        }else {
            paraEncoding = URLEncoding.default
        }

        let task = self.sessionManager.request(intactUrl, method: .post, parameters: parameters, encoding: paraEncoding, headers: nil).responseJSON { (response) in
            //清除缓存task
            self.netTaskCache.removeValue(forKey: url)

            //Success
            if response.result.isSuccess {

                let jsonData = response.result.value

                if self.isOpenLog {
                    print("=============================华丽的分割线=============================\n请求方式:POST")
                    print("接口Url---> \(intactUrl)\n参数---> \(String(describing: parameters))\n返回结果:--->")
                    print(LCUtils.ObjectToJson(data: jsonData) ?? "解析出错")
                }

                //缓存数据
                if useCache && jsonData != nil{
                    LCNetWork.manager.lcNetCacheManager[url] = jsonData!
                }

                if successClosure != nil && jsonData != nil {
                    successClosure!(jsonData!)
                }
            }
                //Failed
            else {

                if self.isOpenLog {
                    print("=============================华丽的分割线=============================\n请求方式:POST")
                    print("接口Url---> \(intactUrl)\n参数---> \(String(describing: parameters))")
                    print("error = \(String(describing: response.result.error))")
                }
                if failtureClosure != nil && response.result.error != nil {
                    failtureClosure!(response.result.error!)
                }

                //启用缓存的情况下，会在请求失败的情况下同时检测缓存并返回
                if useCache {
                    let cacheResult = LCNetWork.manager.lcNetCacheManager[url]
                    if cacheResult != nil {
                        if successClosure != nil {
                            successClosure!(cacheResult!)
                        }
                    }
                }
            }
        }
        self.netTaskCache[url] = task
    }


    //Upload Implement
    private func UPLOADImplement(url: String ,parameters: [String: String]?, data: Array<Dictionary<String,Any>>, successClosure: LCHttpRequestSuccess? , failtureClosure: LCHttpRequestFailed?) {
        let intactUrl = self.intactUrl + url

        Alamofire.upload(multipartFormData: { (multipartFormData) in

            //拼接其他参数
            if !(parameters?.isEmpty ?? false) {
                for item in self.lcQueryStringPairsFromKeyAndValue(key: nil, value: parameters!) {
                    var data: Data?
                    if item.value is Data {
                        data = item.value as? Data
                    }
                    else if item.value is NSNull {
                        data = Data()
                    }
                    else {
                        data = item.value?.description.data(using: String.Encoding.utf8)
                    }
                    if data != nil {
                        multipartFormData.append(data!, withName: (item.field?.description)! )
                    }
                }
            }

            for index in 0..<data.count {
                let dict = data[index]
                if (dict["image"] != nil) {
                    let origin = dict["image"] as! UIImage
                    let name = dict["paramterName"] as! String
                    let data = UIImageJPEGRepresentation(origin, 0.5)
                    if data == nil {
                        continue
                    }
                    multipartFormData.append(data!, withName: name, fileName: "portrait\(index).png", mimeType: "image/png")
                }
                else if (dict["video"] != nil) {
                    let origin = dict["video"] as? Data
                    let name = dict["paramterName"] as! String
                    if origin == nil {
                        continue
                    }
                    multipartFormData.append(origin!, withName: name, fileName: "video\(index).mp4", mimeType: "video/mp4")
                }
                else if (dict["other"] != nil) {

                }
            }
        }, to: intactUrl) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let jsonData = response.result.value

                    if self.isOpenLog {
                        print("=============================华丽的分割线=============================\n请求方式:POST")
                        print("接口Url---> \(intactUrl)\n参数---> \(String(describing: parameters))\n返回结果:--->")
                        print(LCUtils.ObjectToJson(data: jsonData) ?? "解析出错")
                    }

                    if successClosure != nil && jsonData != nil {
                        successClosure!(jsonData!)
                    }
                }
            case .failure(let encodingError):
                if failtureClosure != nil {
                    failtureClosure!(encodingError)
                }
            }
        }
    }

    private func lcQueryStringPairsFromKeyAndValue(key: String?, value: Any) -> Array<LCQueryStringPair> {
        var queryStringComponents: [LCQueryStringPair] = []
        if let dict = value as? Dictionary<AnyHashable, Any> {
            for item in dict {
                queryStringComponents += self.lcQueryStringPairsFromKeyAndValue(key: (key != nil ? "\(key!)[\(item.key.description)]" : item.key.description), value: item.value)
            }
        }
        else if let array = value as? Array<Any> {
            for item in array {
                queryStringComponents += self.lcQueryStringPairsFromKeyAndValue(key: "\(key!)[]", value: item)
            }
        }
        else if let set = value as? Set<AnyHashable> {
            for item in set {
                queryStringComponents += self.lcQueryStringPairsFromKeyAndValue(key: key!, value: item)
            }
        }
        else {
            queryStringComponents.append(LCQueryStringPair.init(fieldP: key as AnyObject, valueP: value as AnyObject))
        }

        return queryStringComponents
    }
}

class LCQueryStringPair: NSObject {
    var field: AnyObject?
    var value: AnyObject?
    init(fieldP: AnyObject, valueP:AnyObject) {
        field = fieldP
        value = valueP
        super.init()
    }
}
