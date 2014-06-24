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
package org.davidbuhler.formandfunction.model
{
	import org.davidbuhler.formandfunction.common.InputRestrictions;

	[Bindable]
	public class FormatHintsModel
	{
		public function FormatHintsModel()
		{
		}
		public var address1:String='184 Elm Street';
		public var address2:String='#203';
		public var companyName:String='Acme Corporation';
		public var creditCardExpirationDate:String='11/14';

		public var creditCardNumber_AmericanExpress:String='3400-0000-0000-009';
		public var creditCardNumber_DinersClub:String='3000-0000-0000-04';
		public var creditCardNumber_Discover:String='6011-0000-0000-0004';
		public var creditCardNumber_MasterCard:String='5500-0000-0000-0004';
		public var creditCardNumber_Visa:String='4111-1111-1111-1111';

		public var creditCardSecurityCode_AmericanExpress:String='6037';
		public var creditCardSecurityCode_DinersClub:String='745';
		public var creditCardSecurityCode_Discover:String='433';
		public var creditCardSecurityCode_MasterCard:String='183';
		public var creditCardSecurityCode_Visa:String='335';

		public var currency:String='$500.00';
		public var date:String=InputRestrictions.STANDARD_US_DATE_FORMAT;
		public var email:String='Jane.Smith@Domain.com';
		public var firstName:String='Jane';
		public var lastName:String='Smith';
		public var password:String='******';
		public var phoneNumber:String='(555) 555-5555';
		public var socialSecurity:String='555-55-5555';
		public var time:String='01:30am';
		public var uri:String='http://www.acme.com';
		public var zipCode:String='12345';
	}
}

