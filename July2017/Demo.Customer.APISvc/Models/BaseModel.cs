using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace Demo.Customer.APISvc
{

	[Serializable()]
	public class BaseModel : IHttpActionResult
	{

		string _errorMessage;
		HttpRequestMessage _request;

		public string ErrorMessage{
			get{
				return _errorMessage;
			}
			set{
				_errorMessage = value;
			}
		}
	  
		public BaseModel()
		{
			_request = null;
			_errorMessage = null;
		}

		public BaseModel(HttpRequestMessage request)
		{

			_errorMessage = null;
			_request = request;
		}

		public BaseModel(string errorMessage, HttpRequestMessage request)
		{

			_errorMessage = errorMessage;
			_request = request;
		}

		Task<HttpResponseMessage> IHttpActionResult.ExecuteAsync(CancellationToken cancellationToken)
		{
			var response = new HttpResponseMessage()
								{ 
									RequestMessage = _request
								};

			return Task.FromResult(response);

		}
	}
}