/*
 *  NSString_VNCPasswordCrypto.cpp
 *  vnsea
 *
 *  Created by Chris Reed on 1/3/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "NSString_VNCPasswordCrypto.h"
#include <d3des.h>

static unsigned char s_fixedkey[8] = {23,82,107,6,35,78,88,7};

static NSString *vncEncryptPasswd(NSString *pnsPassword)
{
	int i, wNewSize;
	char *szTemp, *szPassword, szNew[400];
	
	if (pnsPassword == nil)
		return nil;
	else
		{
		szPassword = (char *)malloc([pnsPassword length]+2);
		strcpy(szPassword, [pnsPassword cString]);
		}
	wNewSize = ((strlen(szPassword)+7) / 8) * 8;
	szTemp = (char *)calloc(wNewSize+1, 1);
	*szNew = 0;
    deskey(s_fixedkey, EN0);
	for(i=0;i<wNewSize / 8;i++)
		{
		des((unsigned char *)(szPassword+(i*8)), (unsigned char *)(szPassword+(i*8)));
		}
	strcpy(szNew, "^");
	for(i=0;i<wNewSize;i++)
		{
		sprintf(szNew+strlen(szNew), "%x ", szPassword[i]);
		}
	szNew[strlen(szNew)-1] = 0;
	return [NSString stringWithFormat: @"%s",szNew];
}


static NSString *vncDecryptPasswd(NSString *pnsEncrypted)
{
	unsigned char szBinary[200];
	char szEncrypted[400];
	char *pch = szEncrypted;
	int i, ii = 0;
	
	if (pnsEncrypted == nil)
		return nil;
	else
		strcpy(szEncrypted, [pnsEncrypted cString]);
	if (*szEncrypted == '^')
		strcpy(szEncrypted, szEncrypted+1);
	else
		return [NSString stringWithFormat:@"%s", szEncrypted];

	NSLog(@"%s", szEncrypted);
	
    deskey(s_fixedkey, DE1);
	for(i=0;*pch != 0;i++)
		{
		unsigned char ch = (unsigned char)strtol(pch, &pch, 16);
		szBinary[ii++] = ch;
		}
	szBinary[ii] = 0;
	for(i=0;i<ii/8;i++)
		{
		des(szBinary + (i*8), szBinary + (i*8));
		}
	return [NSString stringWithFormat:@"%s", (char *)szBinary];
}

@implementation NSString (VNCPasswordCrypto)

- (NSString *)encryptPassword
{
	return vncEncryptPasswd(self);
}

- (NSString *)decryptPassword
{
	return vncDecryptPasswd(self);
}

@end


