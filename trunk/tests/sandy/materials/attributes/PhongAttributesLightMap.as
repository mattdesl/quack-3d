/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/
package sandy.materials.attributes
{
	/**
	 * A lightmap used for some of the shaders.
	 *
	 * @version		3.0.2
	 */
	public final class PhongAttributesLightMap
	{
		/**
		 * An array of an array which contains the alphas of the strata. The values of the inner array must be between 0 and 1.
		 */
		public var alphas:Array = [[], []];
		
		/**
		 * An array of an array which contains the colors of the strata.
		 */
		public var colors:Array = [[], []];
		
		/**
		 * An array of an array which contains the ratios (length) of each strata.
		 */
		public var ratios:Array = [[], []];
	}
}