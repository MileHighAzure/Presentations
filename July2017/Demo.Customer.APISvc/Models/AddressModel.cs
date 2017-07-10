using System;
using System.Net.Http;

namespace Demo.Customer.APISvc
{
		
	public class AddressModel : BaseModel
	{

		public AddressModel()
		{

		}

		public AddressModel(HttpRequestMessage request) : base(request)
		{

		}

		public AddressModel(string errorMessage, HttpRequestMessage request) : base(errorMessage, request)
		{

		}

		public int AddressId { get; set; }

		public string AddressLine1 { get; set; }

		public string AddressLine2 { get; set; }

		public string City { get; set; }

		public string State { get; set; }

		public string PostalCode { get; set; }

		public DateTime LastUpdated { get; set; }

	}
}