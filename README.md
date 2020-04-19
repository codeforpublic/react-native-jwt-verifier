# react-native-jwt-verifier

JWT Token verifier bridge for React Native (Android and iOS). Only algorithm currently supported is ES256 with secp256k1 curve.

## Installation

```
npm install --save react-native-jwt-verifier
```

## Usage

```
import {NativeModules} from 'react-native';
const {JwtUtils} = NativeModules;
JwtUtils.verify(token, x, y)
    .then(result => {
      // Verified
    })
    .catch(error => {
      // Error with message described in error.message
    });
```
