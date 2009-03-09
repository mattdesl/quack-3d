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

package sandy.parser
{
	/**
	* Dispatched when parsing fails.
	*
	* @eventType sandy.parser.ParserEvent.FAIL
	*/
	[Event(name="onFailEVENT", type="sandy.parser.ParserEvent")]

	/**
	* Dispatched when parsing is complete.
	*
	* @eventType sandy.parser.ParserEvent.INIT
	*/
	[Event(name="onInitEVENT", type="sandy.parser.ParserEvent")]

	/**
	* Dispatched when the file starts loading.
	*
	* @eventType sandy.parser.ParserEvent.LOAD
	*/
	[Event(name="onLoadEVENT", type="sandy.parser.ParserEvent")]

	/**
	* Dispatched when data is received as the parsing progresses.
	*
	* @eventType sandy.parser.ParserEvent.PROGRESS
	*/
	[Event(name="onProgressEVENT", type="sandy.parser.ParserEvent")]

	/**
	* Dispatched when a parser reads the next line of data in a file.
	*
	* @eventType sandy.parser.ParserEvent.PARSING
	*/
	[Event(name="onParsingEVENT", type="sandy.parser.ParserEvent")]

	/**
	 * The Parser factory class creates instances of parser classes.
	 * The specific parser can be specified in the create method's second parameter.
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		1.0
	 * @date 		04.08.2007
	 *
	 * @example To parse a 3DS file at runtime:
	 *
	 * <listing version="3.0">
	 *     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.MAX_3DS );
	 * </listing>
	 * 
	 */	
	
	public final class Parser
	{
		/**
		 * Specifies that the ASE (ASCII Scene Export) parser should be used.
		 */
		public static const ASE:String = "ASE";
		/**
		 * Specifies that the MD2 (Quake II model) parser should be used.
		 */
		public static const MD2:String = "MD2";
		/**
		 * Specifies that the 3DS (3D Studio) parser should be used.
		 */
		public static const MAX_3DS:String = "3DS";
		/**
		 * Specifies that the COLLADA (COLLAborative Design Activity ) parser should be used.
		 */
		public static const COLLADA:String = "DAE";
		
		/**
		 * The create method chooses which parser to use. This can be done automatically
		 * by looking at the file extension or by passing the parser type String as the
		 * second parameter.
		 * 
		 * @example To parse a 3DS file at runtime:
		 *
		 * <listing version="3.0">
		 *     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.3DS );
		 * </listing>
		 * 
		 * @param p_sFile			Can be either a string pointing to the location of the
		 * 							file or an instance of an embedded file
		 * @param p_sParserType		The parser type string
		 * @param p_nScale			The scale factor
		 * @param p_sTextureExtension	Overrides texture extension.
		 * @return					The parser to be used
		 */		
		public static function create( p_sFile:*, p_sParserType:String=null, p_nScale:Number=1, p_sTextureExtension:String = null ):IParser
		{
			var l_sExt:String,l_iParser:IParser = null;
			// --
			if( p_sFile is String && p_sParserType == null )
			{
				l_sExt = (p_sFile.split('.')).reverse()[0];
			}  
			else 
			{
				l_sExt = p_sParserType;
			}
			// --
			switch( l_sExt.toUpperCase() )
			{
				case ASE:
					l_iParser = new ASEParser( p_sFile, p_nScale, p_sTextureExtension );
					break;
				case MD2:
					l_iParser = new MD2Parser( p_sFile, p_nScale, p_sTextureExtension );
					break;
				case COLLADA:
					l_iParser = new ColladaParser( p_sFile, p_nScale, p_sTextureExtension );
					break;
				case MAX_3DS:
					l_iParser = new Parser3DS( p_sFile, p_nScale, p_sTextureExtension );
					break;
				default:
					break;
			}
			// --
			return l_iParser;
		}
	}
}
