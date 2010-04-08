/*
 *  NSString_VNCPasswordCrypto.h
 *  vnsea
 *
 *  Created by Chris Reed on 1/3/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#if !defined(_VNCPasswordCrypto_h_)
#define _VNCPasswordCrypto_h_

#import <Foundation/Foundation.h>

/*!
 * @brief Category on NSString for password encryption.
 */
@interface NSString (VNCPasswordCrypto)

//! @brief Encrypt a password string with a fixed key.
- (NSString *)encryptPassword;

//! @brief Decrypt an encrypted password with a fixed key.
- (NSString *)decryptPassword;

@end

#endif // _VNCPasswordCrypto_h_
