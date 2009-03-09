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
package sandy.errors
{
	/**
	 * The SingletonError class is used as a workaround for private constructors not existing
	 * in ActionScript 3.0. Every singleton class in Sandy has a private static variable
	 * called <code>instance</code>. The <code>instance</code> variable is given a 
	 * reference to an instance of the class the first time the class constructor or
	 * <code>getInstance()</code> is called. If an attempt is made to instantiate the
	 * class a the second time, a <code>SingletonError</code> will be thrown. Always 
	 * use the static method <code>Class.getInstance()</code> to get an instance of the 
	 * class.
	 * 
	 * @author		Dennis Ippel - ippeldv
	 * @version		1.0
	 * @date 		26.07.2007
	 */
	public class SingletonError extends Error
	{
		/**
		 * All the constructor does is pass the error message to the superclass.
		 */		
		public function SingletonError()
		{
			super("Class cannot be instantiated");
		}
	}
}