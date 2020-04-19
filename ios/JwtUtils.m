
#include <CommonCrypto/CommonDigest.h>

#import "JwtUtils.h"

#import "secp256k1.h"
#import "secp256k1_recovery.h"

@implementation JwtUtils

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

#pragma Error Handling

static void counting_illegal_callback_fn(const char* str, void* data) {
}

#pragma Bridge Functions

RCT_EXPORT_METHOD(verify: (NSString*)token
                       x: (NSString*)x
                       y: (NSString*)y
                resolver: (RCTPromiseResolveBlock)resolve
                rejecter: (RCTPromiseRejectBlock)reject)
{
    unsigned char publicKeyFull[65];
    unsigned char signatureFull[64];
    secp256k1_pubkey publicKey;
    secp256k1_ecdsa_signature signature;
    unsigned char message[32];
    int32_t ecount = 0;
    
    token = [self correctBase64Characters: token];
    x = [self correctBase64Characters: x];
    y = [self correctBase64Characters: y];
    
    NSArray *parts = [token componentsSeparatedByString:@"."];
    if (parts.count != 3) {
        reject(@"JsonWebTokenError", @"jwt malformed", nil);
        return;
    }
    
    NSString* encodedMessage = [NSString stringWithFormat:@"%@.%@", parts[0], parts[1]];
    
    NSMutableData* hashedMessage = [self sha256:encodedMessage];
    memcpy(&message, [hashedMessage bytes], [hashedMessage length]);
    
    // Build Public Key
    NSData *xKeyData = [self base64Decode: x];
    NSData *yKeyData = [self base64Decode: y];
    
    publicKeyFull[0] = 4;
    memcpy(publicKeyFull + 1, [xKeyData bytes], [xKeyData length]);
    memcpy(publicKeyFull + 33, [yKeyData bytes], [yKeyData length]);

    // Build Signature
    NSData *signatureData = [self base64Decode: parts[2]];
    memcpy(signatureFull, [signatureData bytes], [signatureData length]);

    // Create verifier context
    secp256k1_context* vrfy = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    
    secp256k1_context_set_error_callback(vrfy, counting_illegal_callback_fn, &ecount);
    secp256k1_context_set_illegal_callback(vrfy, counting_illegal_callback_fn, &ecount);
    
    // Validate Public Key
    int publicKeyValidationResult = secp256k1_ec_pubkey_parse(vrfy, &publicKey, publicKeyFull, 65);
    //NSLog(@">>>>>>>>> Public Key Validation = %d", publicKeyValidationResult);
   
    // Validate Signature
    int signatureValidationResult = secp256k1_ecdsa_signature_parse_compact(vrfy, &signature, signatureFull);
    //NSLog(@">>>>>>>>> Signature Validation = %d", signatureValidationResult);

    // Signature Normalization
    int signatureNormalizationResult = secp256k1_ecdsa_signature_normalize(vrfy, &signature, &signature);
    //NSLog(@">>>>>>>>> Signature Normalization = %d", signatureNormalizationResult);

    // Verify
    int verificationResult = secp256k1_ecdsa_verify(vrfy, &signature, message, &publicKey);
    //NSLog(@">>>>>>>>> Verify Result = %d", verificationResult);
    
    if (verificationResult == 0) {
        reject(@"JsonWebTokenError", @"invalid signature", nil);
        return;
    }
    
    // Clean up
    secp256k1_context_destroy(vrfy);
    
    // Respones
    resolve(@(true));
}

#pragma Base64

- (NSData*) base64Decode: (NSString*) encodedString {
    return [[NSData alloc] initWithBase64EncodedString:[self fixBase64Padding: encodedString] options:0];
}

- (NSString*)fixBase64Padding: (NSString*) input {
    unsigned long length = [input length];
    if (length % 4 == 0)
        return input;
    length = ([input length] / 4 + 1) * 4;
    NSString* padding = [@"====" substringToIndex:4 - [input length] % 4];
    NSString *result = [NSString stringWithFormat:@"%@%@", input, padding];
    return result;
}

- (NSString*)correctBase64Characters: (NSString*) input {
    NSString* output;
    {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"_"];
        output = [[input componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"/"];
    }
    {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"-"];
        output = [[output componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @"+"];
    }
    return output;
}

#pragma SHA256

- (NSMutableData*)sha256: (NSString*) input {
    NSData* data = [input dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], [sha256Data mutableBytes]);
    return sha256Data;
}

- (NSString*)sha256String: (NSString*) input {
    NSMutableData *sha256Data = [self sha256: input];
    return [self hexadecimalString: sha256Data];
}

#pragma Hex

- (NSString *)hexadecimalString: (NSData*)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */

    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

@end
  
