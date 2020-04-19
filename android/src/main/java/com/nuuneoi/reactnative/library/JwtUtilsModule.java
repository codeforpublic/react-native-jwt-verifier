
package com.nuuneoi.reactnative.library;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.ECDSAKeyProvider;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.nuuneoi.reactnative.library.utils.Base64Utils;

import org.spongycastle.jce.provider.BouncyCastleProvider;

import java.math.BigInteger;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECGenParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.ECPublicKeySpec;
import java.security.spec.InvalidKeySpecException;

public class JwtUtilsModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public JwtUtilsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        Security.insertProviderAt(new BouncyCastleProvider(), 1);
    }

    @Override
    public String getName() {
        return "JwtUtils";
    }

    @ReactMethod
    public void verify(String token, final String x, final String y, final Promise promise) {
        // Validate Input
        if (token == null || x == null || y == null) {
            promise.reject("JsonWebTokenError", "jwt malformed");
            return;
        }

        // Correct Base64 Characters
        token = token.replace('_', '/').replace('-', '+');
        final String xProcessed = x.replace('_', '/').replace('-', '+');
        final String yProcessed = y.replace('_', '/').replace('-', '+');

        // Create Key Provider
        ECDSAKeyProvider keyProvider = new ECDSAKeyProvider() {
            @Override
            public ECPublicKey getPublicKeyById(String keyId) {
                try {
                    BigInteger xb = new BigInteger(1, Base64Utils.decode(xProcessed));
                    BigInteger yb = new BigInteger(1, Base64Utils.decode(yProcessed));
                    ECPoint point = new ECPoint(xb, yb);
                    KeyPairGenerator kpg = KeyPairGenerator.getInstance("EC");
                    kpg.initialize(new ECGenParameterSpec("secp256k1"));
                    KeyPair kp = kpg.generateKeyPair();

                    ECPublicKeySpec otherKeySpec = new ECPublicKeySpec(point, ((ECPublicKey) kp.getPublic()).getParams());
                    KeyFactory keyFactory = KeyFactory.getInstance("EC");
                    ECPublicKey publicKey = (ECPublicKey) keyFactory.generatePublic(otherKeySpec);
                    return publicKey;
                } catch (NoSuchAlgorithmException e) {
                    e.printStackTrace();
                    return null;
                } catch (InvalidAlgorithmParameterException e) {
                    e.printStackTrace();
                    return null;
                } catch (InvalidKeySpecException e) {
                    e.printStackTrace();
                    return null;
                }
            }

            @Override
            public ECPrivateKey getPrivateKey() {
                return null;
            }

            @Override
            public String getPrivateKeyId() {
                return null;
            }
        };

        // Verification
        try {
            Algorithm algorithm = Algorithm.ECDSA256(keyProvider);
            JWT.require(algorithm).build().verify(token);
            promise.resolve(true);
        } catch (JWTVerificationException exception) {
            //Algorithm algorithm = Algorithm.ECDSA256();
            promise.reject("JsonWebTokenError", "invalid signature");
        } catch (Exception e) {
            promise.reject("JsonWebTokenError", "invalid signature");
        }
    }

}