//
//  NSString+ParseUrl.h
//  PearDylib
//
//  Created by dengliwen on 2018/6/28.
//  Copyright © 2018年 dengliwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ParseUrl)

- (NSMutableDictionary *)bd_getURLParameters;

@end

@interface NSDictionary (CHXJSON)

- (NSString *)chx_JSONString;
/**
 *  将字典转为链接参数形式
 *
 *  @return 链接字符串
 */
- (NSString *)chx_URLParameterString;

@end

@interface NSData (CHXJSON)

/**
 *  Create a Foundation object from JSON data
 *
 *  @return Foundation object
 */
- (id)chx_JSONObject;

/**
 *  Generate JSON data from a Foundation object
 *
 *  @param object Foundation object
 *
 *  @return JSON data
 */
+ (NSData *)chx_dataWithJSONObject:(id)object;

/**
 *  Generate an JSON data from a property list
 *
 *  @param plist property list
 *
 *  @return JSON data
 */
+ (NSData *)chx_dataWithPropertyList:(id)plist;

@end
