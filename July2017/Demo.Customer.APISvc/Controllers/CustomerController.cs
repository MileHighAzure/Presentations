using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using Newtonsoft.Json;
using Swashbuckle;
using Swashbuckle.Examples;
using Swashbuckle.Swagger.Annotations;

namespace Demo.Customer.APISvc.Controllers
{

	/// <summary>
	///		Customer WebAPI 2.1 Controller
	/// </summary>
	/// <remarks>
	///		Using Swashbuckle Swagger Documentation
	/// </remarks>
	/// <seealso cref="https://mattfrear.com/2016/01/25/generating-swagger-example-requests-with-swashbuckle/"/>
	public class CustomerController : ApiController
	{

		private const string _allCustomersRedisKey = "AllCustomers";

		/// <summary>
		///		Random enumerations for First Names
		/// </summary>
		private enum FirstName
		{
			John = 1,
			Jane = 2,
			Bill = 3,
			Jose = 4,
			William = 5
		};

		/// <summary>
		///		Random enumerations for Last Names
		/// </summary>
		private enum LastName
		{
			Smith = 1,
			Doe = 2,
			Martinez = 3,
			Jones = 4,
			Young = 5
		};

		Random randomNumberCls = null;
			

		/// <summary>
		///		Get All Customers
		/// </summary>
		/// <returns></returns>
		[Route(template: "api/Customer/Get")]
		[SwaggerOperation("GetAll?useRedisCache={useRedisCache}")]
		[SwaggerResponse(HttpStatusCode.OK, "Get All Customers", typeof(List<CustomerModel>))]
		[SwaggerResponseExample(HttpStatusCode.OK, typeof(List<CustomerModel>))]
		[SwaggerResponse(HttpStatusCode.InternalServerError, "Get All Customers Exception", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.InternalServerError, typeof(string))]
		[SwaggerResponse(HttpStatusCode.NotFound, "No Customer data", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.NotFound, typeof(string))]		
		public IHttpActionResult Get(bool useRedisCache)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			randomNumberCls = new Random();		   			

			try
			{

				// Use Redis Cache or not:
				List<CustomerModel> customers = useRedisCache ? GetCachedCustomers() : CreateCustomers();

				if ( customers == null || customers.Count == 0)
				{
					responseMsg = new HttpResponseMessage(HttpStatusCode.NotFound);
					responseMsg.Content = new StringContent("No Customer data found");
					response = ResponseMessage(responseMsg);
				}
				else
				{
					responseMsg = new HttpResponseMessage(HttpStatusCode.OK);
					responseMsg.Content = new ObjectContent<List<CustomerModel>>(customers, new JsonMediaTypeFormatter());
					response = ResponseMessage(responseMsg);
				}
								

								
			}
			catch(Exception)
			{  

				responseMsg = new HttpResponseMessage(HttpStatusCode.InternalServerError);
				responseMsg.Content = new StringContent(Constants.DefaultErrorMessage);
				response = ResponseMessage(responseMsg);

			}


			return response;
		}

		/// <summary>
		///		Get Customer By Id
		/// </summary>
		/// <param name="id">Customer Id</param>
		/// <returns></returns>
		/// <seealso cref="https://docs.microsoft.com/en-us/aspnet/web-api/overview/getting-started-with-aspnet-web-api/action-results" />
		/// <seealso cref="https://docs.microsoft.com/en-us/aspnet/web-api/overview/error-handling/exception-handling"/>
		[Route("api/Customer/Get/{id}")]
		[SwaggerOperation("GetById/{id}?useRedisCache={useRedisCache}")]
		[SwaggerResponse(HttpStatusCode.OK, "Get Customer By Id", typeof(CustomerModel))]
		[SwaggerResponseExample(HttpStatusCode.OK, typeof(CustomerModel))]
		[SwaggerResponseExample(HttpStatusCode.NotFound, typeof(string))]
		[SwaggerResponse(HttpStatusCode.NotFound, "Get Customer Not Found", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.InternalServerError, typeof(HttpResponseException))]
		[SwaggerResponse(HttpStatusCode.InternalServerError, "Get Customer Exception", typeof(string))]
		public IHttpActionResult Get(int id, bool useRedisCache = false)
		{
			randomNumberCls = new Random();

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			try
			{

				IEnumerable<CustomerModel> customers = useRedisCache ? GetCachedCustomers() : CreateCustomers();

				CustomerModel customer = null;

				if (customers != null)
				{
					customer = customers
												.Where(x => x.CustomerId == id)
												.FirstOrDefault();
				}

				if ( id == 0 || customer == null )
				{				
					
					var message = $"Customer with id = {id} not found";

					responseMsg = new HttpResponseMessage(HttpStatusCode.NotFound);
					responseMsg.Content = new StringContent(message);
					response = ResponseMessage(responseMsg);

					return response;
				}

				// Return Found Customer by Id with OK (200) HTTP Status Code:
				responseMsg = new HttpResponseMessage(HttpStatusCode.OK);
				responseMsg.Content = new ObjectContent<CustomerModel>(customer, new JsonMediaTypeFormatter());
				response = ResponseMessage(responseMsg);				 

				return response;

				// Another way of doing this:
				// return Ok(customer);
			}
			catch(Exception)
			{

				// Return friendly HTTP Exception message and 500 Internal server Error Code:
				responseMsg = new HttpResponseMessage(HttpStatusCode.InternalServerError);
				responseMsg.Content = new StringContent(Constants.DefaultErrorMessage);
				response = ResponseMessage(responseMsg);

				return response;

				// Another way of doing this:
				// return InternalServerError(new HttpResponseException(Request.CreateErrorResponse(HttpStatusCode.InternalServerError, _defaultErrorMessage)));

			}

		}

		/// <summary>
		///		Get all Customers and Cache to Redis
		/// </summary>
		/// <returns></returns>
		[HttpGet()]
		[Route("api/Customer/CustomerCache")]
		[SwaggerOperation("CustomerRedisCache")]
		[SwaggerResponse(HttpStatusCode.OK, "Customer Redis Cache", typeof(List<CustomerModel>))]
		[SwaggerResponseExample(HttpStatusCode.OK, typeof(List<CustomerModel>))]
		[SwaggerResponse(HttpStatusCode.InternalServerError, "Customer Redis Cache Exception", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.InternalServerError, typeof(string))]
		public IHttpActionResult BuildCustomerRedisCache()
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			randomNumberCls = new Random();

			try
			{

				List<CustomerModel> customers = CreateCustomers();

				CacheCustomers(customers);

				responseMsg = new HttpResponseMessage(HttpStatusCode.OK);
				responseMsg.Content = new ObjectContent<List<CustomerModel>>(customers, new JsonMediaTypeFormatter());
				response = ResponseMessage(responseMsg);

				return Ok(customers);
			}
			catch (Exception)
			{


				responseMsg = new HttpResponseMessage(HttpStatusCode.InternalServerError);
				responseMsg.Content = new StringContent(Constants.DefaultErrorMessage);
				response = ResponseMessage(responseMsg);

				return response;
			}
			
		}

		// POST api/<controller>
		[SwaggerResponseExample(HttpStatusCode.NotImplemented, typeof(NotImplementedException))]
		public IHttpActionResult Post([FromBody]string value)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			responseMsg = new HttpResponseMessage(HttpStatusCode.NotImplemented);
			responseMsg.Content = new StringContent(Constants.DefaultNotImplementedMessage);
			response = ResponseMessage(responseMsg);

			return response;
		}

		// PUT api/<controller>/5
		[SwaggerResponseExample(HttpStatusCode.NotImplemented, typeof(NotImplementedException))]
		public IHttpActionResult Put(int id, [FromBody]string value)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			responseMsg = new HttpResponseMessage(HttpStatusCode.NotImplemented);
			responseMsg.Content = new StringContent(Constants.DefaultNotImplementedMessage);
			response = ResponseMessage(responseMsg);

			return response;
		}

		// DELETE api/<controller>/5
		[SwaggerResponseExample(HttpStatusCode.NotImplemented, typeof(NotImplementedException))]
		public IHttpActionResult Delete(int id)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			responseMsg = new HttpResponseMessage(HttpStatusCode.NotImplemented);
			responseMsg.Content = new StringContent(Constants.DefaultNotImplementedMessage);
			response = ResponseMessage(responseMsg);

			return response;
		}



		/// <summary>
		/// Cache customers list into Redis
		/// </summary>
		/// <param name="customers"></param>
		private void CacheCustomers(List<CustomerModel> customers)
		{

			var redisCls = new RedisCacheCls();

			redisCls.SetCache(_allCustomersRedisKey, JsonConvert.SerializeObject(customers));

		}
														
		/// <summary>
		/// Get customers in Redis Cache
		/// </summary>
		/// <returns></returns>
		private List<CustomerModel> GetCachedCustomers()
		{

			List<CustomerModel> result = null;

			var redisCls = new RedisCacheCls();

			string cacheResult = redisCls.GetCacheValue(_allCustomersRedisKey);

			if (!string.IsNullOrEmpty(cacheResult))
			{
				result = JsonConvert.DeserializeObject<List<CustomerModel>>(cacheResult);
			}

			return result;
		}

		/// <summary>
		/// Create customers using generation algorithm
		/// </summary>
		/// <returns></returns>
		private List<CustomerModel> CreateCustomers()
		{
			var result = new List<CustomerModel>();

			// Generate one static record:
			result.Add(GenerateCustomerModel(true, false));

			// Generate Random Data:
			while (result.Count < 10)
			{
				result.Add(GenerateCustomerModel(false, false));
			}

			return result;
		}
				   
		private CustomerModel GenerateCustomerModel(bool createStaticData, bool hasException)
		{				

			var result = new CustomerModel(Request);

			if (hasException)
			{
				result.ErrorMessage = Constants.DefaultErrorMessage;
				return result;
			}
				 
			result.CustomerId = createStaticData ? 1 : ReturnRandomNumber(10, 1000);
			result.FirstName = createStaticData ? "Demo" : GenerateFirstName(ReturnRandomNumber(1, 5));
			result.LastName = createStaticData ? "User" : GenerateLastName(ReturnRandomNumber(1, 5));
			result.LastUpdated = createStaticData ? new DateTime(2016, 01, 01) : DateTime.Now;

			result.Address = GenerateAddressModel(createStaticData, hasException);

			return result;
		}

		private AddressModel GenerateAddressModel(bool createStaticData, bool hasException)
		{

			var result = new AddressModel(Request);								  				   
		
			result.AddressId = createStaticData ? 1 : ReturnRandomNumber(10, 1000);
			result.AddressLine1 = createStaticData ? "1 Main Street" : $"{ReturnRandomNumber(10, 999)} Main Street";
			result.City = "Anytown";
			result.State = "CO";
			result.PostalCode = createStaticData ? "80121" : ReturnRandomNumber(10000, 99999).ToString();

			return result;
		}
 
		/// <summary>
		/// Generate customer first name based upon random enum value
		/// </summary>
		/// <param name="enumValue"></param>
		/// <returns></returns>
		private string GenerateFirstName(int enumValue)
		{					   
			return Enum.GetName(typeof(FirstName), enumValue);
		}

		/// <summary>
		/// Generate customer last name based upon random enum value
		/// </summary>
		/// <param name="enumValue"></param>
		/// <returns></returns>
		private string GenerateLastName(int enumValue)
		{
			return Enum.GetName(typeof(LastName), enumValue);
		}

		/// <summary>
		/// Generate a random number
		/// </summary>
		/// <param name="min"></param>
		/// <param name="max"></param>
		/// <returns></returns>
		private int ReturnRandomNumber(int min, int max)
		{		  
			return randomNumberCls.Next(min, max);
		}
	}
}