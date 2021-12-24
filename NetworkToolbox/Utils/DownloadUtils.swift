//
//  DownloadUtils.swift
//  NetworkToolbox
//
//  Created by 周涵嵩 on 2021/12/24.
//

import Foundation

internal let NSURLSessionResumeInfoVersion = "NSURLSessionResumeInfoVersion"
internal let NSURLSessionResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
internal let NSURLSessionResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"
internal let NSURLSessionResumeByteRange = "NSURLSessionResumeByteRange"
internal let NSURLSessionResumeInfoTempFileName = "NSURLSessionResumeInfoTempFileName"
internal let NSURLSessionResumeInfoLocalPath = "NSURLSessionResumeInfoLocalPath"
internal let NSURLSessionResumeBytesReceived = "NSURLSessionResumeBytesReceived"


internal class ResumeDataHelper {
    
    internal class func handleResumeData(_ data: Data) -> Data? {
        return deleteResumeByteRange(data)
    }

    private class func deleteResumeByteRange(_ data: Data) -> Data? {
        guard let resumeDictionary = getResumeDictionary(data) else { return nil }
        resumeDictionary.removeObject(forKey: NSURLSessionResumeByteRange)
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    
    private class func correctResumeData(_ data: Data) -> Data? {
        guard let resumeDictionary = getResumeDictionary(data) else { return nil }
        
        resumeDictionary[NSURLSessionResumeCurrentRequest] = correct(requestData: resumeDictionary[NSURLSessionResumeCurrentRequest] as? Data)
        resumeDictionary[NSURLSessionResumeOriginalRequest] = correct(requestData: resumeDictionary[NSURLSessionResumeOriginalRequest] as? Data)
        
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    

    internal class func getResumeDictionary(_ data: Data) -> NSMutableDictionary? {
        // In beta versions, resumeData is NSKeyedArchive encoded instead of plist
        var resumeDictionary: NSMutableDictionary?
        if #available(OSX 10.11, iOS 9.0, *) {
            let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
            
            do {
                resumeDictionary = try keyedUnarchiver.decodeTopLevelObject(of: NSMutableDictionary.self, forKey: "NSKeyedArchiveRootObjectKey") ?? nil
                if resumeDictionary == nil {
                    resumeDictionary = try keyedUnarchiver.decodeTopLevelObject(of: NSMutableDictionary.self, forKey: NSKeyedArchiveRootObjectKey)
                }
            } catch {}
            keyedUnarchiver.finishDecoding()
            
        }
        
        if resumeDictionary == nil {
            do {
                resumeDictionary = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil) as? NSMutableDictionary
            } catch {}
        }
        
        return resumeDictionary
    }
    
    internal class func getTmpFileName(_ data: Data) -> String? {
        guard let resumeDictionary = ResumeDataHelper.getResumeDictionary(data), let version = resumeDictionary[NSURLSessionResumeInfoVersion] as? Int else { return nil }
        if version > 1 {
            return resumeDictionary[NSURLSessionResumeInfoTempFileName] as? String
        } else {
            guard let path = resumeDictionary[NSURLSessionResumeInfoLocalPath] as? String else { return nil }
            let url = URL(fileURLWithPath: path)
            return url.lastPathComponent
        }

    }
    
    private class func correct(requestData data: Data?) -> Data? {
        guard let data = data else {
            return nil
        }
        if NSKeyedUnarchiver.unarchiveObject(with: data) != nil {
            return data
        }
        guard let archive = (try? PropertyListSerialization.propertyList(from: data, options: [.mutableContainersAndLeaves], format: nil)) as? NSMutableDictionary else {
            return nil
        }
        // Rectify weird __nsurlrequest_proto_props objects to $number pattern
        var k = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "$\(k)") != nil {
            k += 1
        }
        var i = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_prop_obj_\(i)") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_prop_obj_\(i)"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_prop_obj_\(i)")
                arr?[1] = dic
                archive["$objects"] = arr
            }
            i += 1
        }
        if ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_props") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_props"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_props")
                arr?[1] = dic
                archive["$objects"] = arr
            }
        }

        if let obj = (archive["$top"] as? NSMutableDictionary)?.object(forKey: "NSKeyedArchiveRootObjectKey") as AnyObject? {
            (archive["$top"] as? NSMutableDictionary)?.setObject(obj, forKey: NSKeyedArchiveRootObjectKey as NSString)
            (archive["$top"] as? NSMutableDictionary)?.removeObject(forKey: "NSKeyedArchiveRootObjectKey")
        }
        // Reencode archived object
        let result = try? PropertyListSerialization.data(fromPropertyList: archive, format: PropertyListSerialization.PropertyListFormat.binary, options: PropertyListSerialization.WriteOptions())
        return result
    }

}
