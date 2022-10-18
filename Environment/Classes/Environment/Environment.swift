//
//  Environment.swift
//  XunDao
//
//  Created by zjzl_00 on 2022/9/22.
//

import UIKit

///动态环境配置 比如api 第三方appid
struct Environment {
    
    enum Env: String {
        case debug = "environment_debug"
        case test  = "environment_test"
        case uat   = "environment_uat"
    }
    
    enum EnvKey: String {
        case api = "api"
        case meetCode = "meetCode"
        case ws = "ws"
    }
    
    private static var currentEnvironment = Env.debug
    
    
    
    ///环境变量属性
    private static var environmentDict = [String: Any]()
    
    /// 通过环境变量获取api
    /// - Returns: 返回当前环境的api为了不影响线上 如果失败 默认返回线上环境
    static func getApi()-> String {
        getValueFrom(key: .api)
    }
    
    ///获取测试会议号
    static func getMeetCode()-> String {
        return getValueFrom(key: .meetCode)
    }
    
    ///获取webSocket api
    static func getWebSocketApi()-> String {
        return getValueFrom(key: .ws)
    }
    
    private static func getValueFrom(key: EnvKey) -> String {
        
        if !checkEnvironmentDict() {
            return "https://xuandanys.allindata.cloud:9000/"
        }
        
        if environmentDict.keys.contains(key.rawValue) {
            return (environmentDict[key.rawValue] as? String) ?? "https://xuandanys.allindata.cloud:9000/"
        }
        
        return "https://xuandanys.allindata.cloud:9000/"
    }
    
    ///获取当前环境
    static func getCurrentEnvironment() -> Environment.Env {
        if !checkEnvironmentDict() {
            return .debug
        }
        return currentEnvironment
    }
    
    /// 检测环境变量是否配置以及初始化是否成功
    /// - Returns: 是否成功·
    private static func checkEnvironmentDict() -> Bool {
        if environmentDict.keys.count == 0 {
            guard let localPath = Bundle.main.path(forResource: "environment.txt", ofType: nil) else {
                return false
            }
            
            do {
                let pathValue = try String.init(contentsOfFile: localPath)
                let environmentPath = pathValue.components(separatedBy: "\r\n").first ?? "environment_uat"
                currentEnvironment = Env.init(rawValue: environmentPath) ?? .debug
                guard let environmentPlist = Bundle.main.path(forResource: environmentPath, ofType: ".plist") else{
                    return false
                }
                
                ///生成环境字典
                guard let dict = NSDictionary.init(contentsOfFile: environmentPlist) else {
                    return false
                }
                
                for key in dict.allKeys {
                    let keyStr: String = (key as? String) ?? ""
                    let value: Any = dict[key] ?? ""
                    if keyStr.count > 0  {
                        environmentDict[keyStr] = value
                    }else{
                        continue
                    }
                }
            }catch {
                return false
            }
        }
        
        if environmentDict.keys.count < 1 {
            return false
        }
        return true
    }
}
