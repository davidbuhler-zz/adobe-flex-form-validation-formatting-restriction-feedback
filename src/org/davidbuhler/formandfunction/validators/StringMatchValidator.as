/*
 * #%L
 * GwtBootstrap3
 * %%
 * Copyright (C) 2013 FormFunction
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package org.davidbuhler.formandfunction.validators
{
	import mx.controls.Alert;
	import mx.validators.StringValidator;
	import mx.validators.ValidationResult;

	public class StringMatchValidator extends StringValidator
	{

		// Constructor.
		public function StringMatchValidator()
		{
			super();
		}

		// Define compare string
		private var _matches:String="";

		// Define mismatch error messsage
		private var _mismatchError:String="The value entered does not match";

		// Define Array for the return value of doValidation().
		private var results:Array;

		public function set matches(s:String):void
		{
			_matches=s;
		}

		[Bindable]
		public function get matches():String
		{
			return this._matches;
		}

		public function set mismatchError(s:String):void
		{
			_mismatchError=s;
		}

		// Define the doValidation() method.
		override protected function doValidation(value:Object):Array
		{
			//var pwd: Password = value as Password;
			var s1:String=matches;
			var s2:String=source.text;

			results=[];
			results=super.doValidation(value);

			// Return if there are errors.
			if (results.length > 0)
				return results;

			if (s1 == s2)
			{
				return results;
			}
			else
			{
				results.push(new ValidationResult(true, null, "Mismatch", _mismatchError));
				return results;
			}
		}
	}
}

