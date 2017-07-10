using System;
using System.Net.Http;

namespace Demo.Customer.APISvc
{
		
	public class CustomerModel : BaseModel
	{

		public CustomerModel()
		{
			
		}

		public CustomerModel(HttpRequestMessage request) : base(request)
		{

		}

		public CustomerModel(string errorMessage, HttpRequestMessage request) : base(errorMessage, request)
		{

		}

		public int CustomerId { get; set; }

		public string FirstName { get; set; }
		
		public string LastName { get; set; }

		public AddressModel Address { get; set; }	 

		public DateTime LastUpdated { get; set; }

	}
}