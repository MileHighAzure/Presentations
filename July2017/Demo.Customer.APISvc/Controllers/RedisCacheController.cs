using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using StackExchange.Redis;
using Swashbuckle.Examples;
using Swashbuckle.Swagger.Annotations;

namespace Demo.Customer.APISvc.Controllers
{

	/// <summary>
	/// Redis Cache controller
	/// </summary>
	/// <see cref="https://docs.microsoft.com/en-us/azure/redis-cache/cache-dotnet-how-to-use-azure-redis-cache#work-with-net-objects-in-the-cache"/>
	public class RedisCacheController : ApiController
    {

		RedisCacheCls cacheCls = null;

		public RedisCacheController()
		{
			cacheCls = new RedisCacheCls();
		}

		/// <summary>
		/// Get Redis Cache string value by cache key
		/// </summary>
		/// <param name="cacheKey"></param>
		/// <returns></returns>
		[HttpGet()]
		[Route("api/RedisCache/Get/{cacheKey}")]
		[SwaggerOperation("Get Cache Value")]
		[SwaggerResponse(HttpStatusCode.OK, "Cache Item", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.OK, typeof(string))]
		[SwaggerResponse(HttpStatusCode.NotFound, "No Cache found", typeof(Nullable))]
		[SwaggerResponseExample(HttpStatusCode.NotFound, typeof(Nullable))]
		[SwaggerResponse(HttpStatusCode.InternalServerError, "Cache Exception", typeof(Nullable))]
		[SwaggerResponseExample(HttpStatusCode.InternalServerError, typeof(Nullable))]
		public IHttpActionResult GetCacheValue(string cacheKey)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			try
			{				   

				string cacheResult = cacheCls.GetCacheValue(cacheKey);

				if (string.IsNullOrEmpty(cacheResult))
				{
					responseMsg = new HttpResponseMessage(HttpStatusCode.NotFound);
					responseMsg.Content = null;
					response = ResponseMessage(responseMsg);
				}
				else
				{
					responseMsg = new HttpResponseMessage(HttpStatusCode.OK);
					responseMsg.Content = new StringContent(cacheResult);
					response = ResponseMessage(responseMsg);
				}
				

			}
			catch
			{

				responseMsg = new HttpResponseMessage(HttpStatusCode.InternalServerError);
				responseMsg.Content = null;
				response = ResponseMessage(responseMsg);

			}

			return response;
		}

		/// <summary>
		/// Set Redis Cache by key and store cache value
		/// </summary>
		/// <param name="cacheKey"></param>
		/// <param name="cacheValue"></param>
		[HttpPost()]
		[Route("api/RedisCache/Cache/{cacheKey}")]
		[SwaggerOperation("Set Cache Value")]
		[SwaggerResponse(HttpStatusCode.Accepted, "Cached Request", typeof(string))]
		[SwaggerResponseExample(HttpStatusCode.Accepted, typeof(string))]
		[SwaggerResponse(HttpStatusCode.InternalServerError, "Cache Item Exception", typeof(Nullable))]
		[SwaggerResponseExample(HttpStatusCode.InternalServerError, typeof(Nullable))]
		public IHttpActionResult SetCache(string cacheKey, [FromBody]string cacheValue)
		{

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			try
			{
				// Perform cache operations using the cache object...	 
				cacheCls.SetCache(cacheKey, cacheValue);

				responseMsg = new HttpResponseMessage(HttpStatusCode.Accepted);
				responseMsg.Content = new StringContent(cacheValue);
				response = ResponseMessage(responseMsg);

			}
			catch
			{
				
				responseMsg = new HttpResponseMessage(HttpStatusCode.InternalServerError);
				responseMsg.Content = null;
				response = ResponseMessage(responseMsg);

			}

			return response;
		}	  
		  
		[HttpDelete]
		[Route("api/RedisCache/PurgeCache")]
		[SwaggerOperation("Purge Cache")]
		[SwaggerResponse(HttpStatusCode.NotImplemented)]
		public IHttpActionResult PurgeCache()
		{
			// TODO: Purge Cache

			IHttpActionResult response;
			HttpResponseMessage responseMsg;

			responseMsg = new HttpResponseMessage(HttpStatusCode.NotImplemented);
			responseMsg.Content = new StringContent(Constants.DefaultNotImplementedMessage);
			response = ResponseMessage(responseMsg);

			return response;
		}

	}
}
