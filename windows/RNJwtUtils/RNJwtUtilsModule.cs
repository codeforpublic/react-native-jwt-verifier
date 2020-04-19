using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Jwt.Utils.RNJwtUtils
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNJwtUtilsModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNJwtUtilsModule"/>.
        /// </summary>
        internal RNJwtUtilsModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNJwtUtils";
            }
        }
    }
}
