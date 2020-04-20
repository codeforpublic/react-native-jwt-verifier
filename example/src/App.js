/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  NativeModules,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';

const {JwtUtils} = NativeModules;

class App extends React.Component {
  constructor() {
    super();
    this.state = {
      testCaseResult1: 'Unknown',
      testCaseResult2: 'Unknown',
      testCaseResult3: 'Unknown',
    };
  }

  componentDidMount() {
    JwtUtils.verify(
      'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJfIjpbInA3b25sSkotT1FOdCIsIkciLCIiXSwiaWF0IjoxNTg3MjE0NjU2LCJpc3MiOiJUSENPVklEIn0.HMGVlhw4yQ0y6vX9huxPoNVFwbtX_OptmAwjdqxNCU_DwaGsjKkspRbzp09aerP0a8KQ7po9nPr1k3CSASy0zw',
      '6zI89SLAz2yOsOfSCc3aB0BPAQ2WkHBaagrlZMc_uKo',
      'NvSOFRce5bO1mKleYpI33sbj-8qTkSm9QGWmN5ls2is',
    )
      .then(result => {
        this.setState({
          testCaseResult1: result ? 'True' : 'False',
        });
      })
      .catch(error => {
        this.setState({
          testCaseResult1: error.message,
        });
      });
  }

  render() {
    return (
      <>
        <StatusBar barStyle="dark-content" />
        <SafeAreaView>
          <ScrollView
            contentInsetAdjustmentBehavior="automatic"
            style={styles.scrollView}>
            <View style={styles.body}>
              <View style={styles.sectionContainer}>
                <Text style={styles.sectionTitle}>JWT Utils Example</Text>
                <Text style={styles.sectionDescription}>
                  Test Case 1:{' '}
                  <Text style={styles.highlight}>
                    {this.state.testCaseResult1}
                  </Text>
                </Text>
                <Text style={styles.sectionDescription}>
                  Test Case 2:{' '}
                  <Text style={styles.highlight}>
                    {this.state.testCaseResult2}
                  </Text>
                </Text>
                <Text style={styles.sectionDescription}>
                  Test Case 3:{' '}
                  <Text style={styles.highlight}>
                    {this.state.testCaseResult3}
                  </Text>
                </Text>
              </View>
            </View>
          </ScrollView>
        </SafeAreaView>
      </>
    );
  }
}

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
});

export default App;
