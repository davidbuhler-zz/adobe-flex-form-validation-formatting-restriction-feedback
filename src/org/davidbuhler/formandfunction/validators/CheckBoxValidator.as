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
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class CheckBoxValidator extends Validator
	{

		public function CheckBoxValidator()
		{
			super();
		}

		override protected function doValidation(value:Object):Array
		{
			var isSelected:Boolean=source.selected;

			var results:Array=[];
			results=super.doValidation(value);

			// Return if there are errors.
			if (results.length > 0)
				return results;

			if (isSelected)
			{
				return results;
			}
			else
			{
				results.push(new ValidationResult(true, null, "NoSelection", "This field is required"));
				return results;
			}
		}
	}
}

